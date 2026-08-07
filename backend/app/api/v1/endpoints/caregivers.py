from typing import List, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status
from app.schemas.caregiver import CaregiverContact, CaregiverAlertRequest, CaregiverAlertResponse
from app.services.caregiver_service import caregiver_service
from app.core.security import verify_token

router = APIRouter()

@router.get("/", summary="List registered caregivers")
def list_caregivers(current_user: Dict[str, Any] = Depends(verify_token)):
    return caregiver_service.get_caregivers()

@router.post("/", summary="Add a new caregiver contact")
def add_caregiver(contact: CaregiverContact, current_user: Dict[str, Any] = Depends(verify_token)):
    return caregiver_service.add_caregiver(contact)

@router.post("/alert-missed-dose", response_model=CaregiverAlertResponse, summary="Trigger caregiver alert for missed medication")
async def alert_missed_dose(
    req: CaregiverAlertRequest,
    current_user: Dict[str, Any] = Depends(verify_token)
):
    """Triggers an immediate FCM push notification to caregivers if a diabetic dose is unconfirmed."""
    return await caregiver_service.trigger_missed_dose_alert(req)

@router.get("/alerts", summary="Get alert dispatch history")
def list_alerts(current_user: Dict[str, Any] = Depends(verify_token)):
    return caregiver_service.alert_history
