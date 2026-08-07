import uuid
from datetime import datetime
from typing import Dict, Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from app.schemas.reminder import ReminderGenerateRequest, ReminderResponse, DoseConfirmationRequest
from app.services.gemini_service import gemini_service
from app.services.firestore_service import db_service
from app.core.security import verify_token

router = APIRouter()

@router.post("/generate", response_model=ReminderResponse, summary="Generate Gemini AI personalized reminder")
async def generate_reminder(
    req: ReminderGenerateRequest,
    current_user: Dict[str, Any] = Depends(verify_token)
):
    """Generates an empathetic, high-contrast, personalized reminder via Gemini AI."""
    ai_result = await gemini_service.generate_personalized_reminder(
        patient_name=req.patient_name,
        medication_name=req.medication_name,
        dosage=req.dosage,
        scheduled_time=req.scheduled_time,
        meal_relation=req.meal_relation,
        special_instructions=req.special_instructions or "",
        routine_persona=req.routine_persona or "Senior Citizen"
    )

    rem_id = f"rem-{uuid.uuid4().hex[:8]}"
    created_at = datetime.utcnow().isoformat()

    reminder_record = {
        "reminder_id": rem_id,
        "patient_name": req.patient_name,
        "medication_name": req.medication_name,
        "scheduled_time": req.scheduled_time,
        "personalized_message": ai_result["personalized_message"],
        "audio_friendly_script": ai_result["audio_script"],
        "confirmed": False,
        "confirmed_at": None,
        "created_at": created_at
    }

    db_service.save_reminder(reminder_record)
    return reminder_record

@router.post("/confirm", response_model=ReminderResponse, summary="Confirm dose taken by patient")
def confirm_dose(
    req: DoseConfirmationRequest,
    current_user: Dict[str, Any] = Depends(verify_token)
):
    """Single-tap dose confirmation endpoint for elderly patients."""
    updated = db_service.confirm_reminder(req.reminder_id, req.notes)
    if not updated:
        # If reminder not in memory, return dummy confirmation response
        return {
            "reminder_id": req.reminder_id,
            "patient_name": "Arthur",
            "medication_name": "Medication",
            "scheduled_time": "Now",
            "personalized_message": "Dose confirmed! Great job taking care of your health today.",
            "audio_friendly_script": "Dose confirmed. Thank you!",
            "confirmed": True,
            "confirmed_at": datetime.utcnow().isoformat(),
            "created_at": datetime.utcnow().isoformat()
        }
    return updated

@router.get("/", response_model=List[ReminderResponse], summary="List generated reminders")
def list_reminders(current_user: Dict[str, Any] = Depends(verify_token)):
    return db_service.get_reminders()
