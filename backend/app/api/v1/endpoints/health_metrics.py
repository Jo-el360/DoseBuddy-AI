from typing import List, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status
from app.schemas.health_metric import BloodGlucoseCreate, BloodGlucoseResponse, HealthSummaryResponse
from app.services.firestore_service import db_service
from app.services.gemini_service import gemini_service
from app.services.caregiver_service import caregiver_service
from app.schemas.caregiver import CaregiverAlertRequest
from app.core.security import verify_token

router = APIRouter()

@router.post("/glucose", response_model=BloodGlucoseResponse, summary="Log blood glucose reading with Gemini safety check")
async def log_blood_glucose(
    data: BloodGlucoseCreate,
    current_user: Dict[str, Any] = Depends(verify_token)
):
    """
    Logs a patient's blood glucose level, executes a Gemini AI clinical safety analysis,
    and automatically dispatches push alerts to registered caregivers if severe hypoglycemia or hyperglycemia is detected.
    """
    patient_name = current_user.get("name", "Arthur")
    analysis = await gemini_service.analyze_blood_glucose(
        patient_name=patient_name,
        glucose_level=data.glucose_level,
        measurement_type=data.measurement_type
    )

    alert_sent = False
    if analysis["caregiver_alert"]:
        alert_req = CaregiverAlertRequest(
            patient_id=data.patient_id,
            patient_name=patient_name,
            medication_name=f"CRITICAL GLUCOSE ALERT ({analysis['status']}: {data.glucose_level:.0f} mg/dL)",
            scheduled_time="Immediate",
            minutes_overdue=0
        )
        await caregiver_service.trigger_missed_dose_alert(alert_req)
        alert_sent = True

    log_entry = db_service.save_glucose_log({
        "patient_id": data.patient_id,
        "glucose_level": data.glucose_level,
        "measurement_type": data.measurement_type,
        "status": analysis["status"],
        "safety_recommendation": analysis["safety_recommendation"],
        "audio_warning_script": analysis["audio_warning_script"],
        "caregiver_alert_sent": alert_sent,
        "notes": data.notes
    })

    return log_entry

@router.get("/glucose", response_model=List[BloodGlucoseResponse], summary="Get blood glucose log history")
def get_glucose_history(
    patient_id: str = "mock-elderly-user-123",
    current_user: Dict[str, Any] = Depends(verify_token)
):
    """Returns blood glucose log history ordered by timestamp."""
    return db_service.get_glucose_logs(patient_id)

@router.get("/summary", response_model=HealthSummaryResponse, summary="Get health & blood glucose summary statistics")
def get_health_summary(
    patient_id: str = "mock-elderly-user-123",
    current_user: Dict[str, Any] = Depends(verify_token)
):
    """Returns summary analytics including average blood glucose and hypoglycemia/hyperglycemia counts."""
    return db_service.get_glucose_summary(patient_id)
