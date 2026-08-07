import logging
from datetime import datetime
import uuid
from typing import Dict, Any, List
from app.schemas.caregiver import CaregiverAlertRequest, CaregiverAlertResponse, CaregiverContact

logger = logging.getLogger(__name__)

class CaregiverService:
    def __init__(self):
        # In-memory caregiver register
        self.caregivers: List[Dict[str, Any]] = [
            {
                "id": "cg-1",
                "name": "Sarah Pendelton (Daughter)",
                "email": "sarah.caregiver@example.com",
                "phone_number": "+15550192834",
                "fcm_token": "mock_fcm_token_daughter",
                "notify_on_missed_dose": True
            }
        ]
        self.alert_history: List[Dict[str, Any]] = []

    def get_caregivers(self) -> List[Dict[str, Any]]:
        return self.caregivers

    def add_caregiver(self, contact: CaregiverContact) -> Dict[str, Any]:
        new_cg = contact.dict()
        new_cg["id"] = f"cg-{uuid.uuid4().hex[:6]}"
        self.caregivers.append(new_cg)
        return new_cg

    async def trigger_missed_dose_alert(self, req: CaregiverAlertRequest) -> CaregiverAlertResponse:
        alert_id = f"alt-{uuid.uuid4().hex[:8]}"
        sent_at = datetime.utcnow().isoformat()
        
        active_caregivers = [cg for cg in self.caregivers if cg.get("notify_on_missed_dose")]
        
        notification_title = f"⚠️ Missed Medication Alert for {req.patient_name}"
        notification_body = (
            f"{req.patient_name} has not confirmed taking {req.medication_name} scheduled for {req.scheduled_time}. "
            f"It is currently {req.minutes_overdue} minutes overdue. Please check on them."
        )

        logger.info(f"Triggering FCM Alert [{alert_id}] to {len(active_caregivers)} caregiver(s): {notification_body}")

        alert_record = {
            "alert_id": alert_id,
            "patient_id": req.patient_id,
            "patient_name": req.patient_name,
            "medication_name": req.medication_name,
            "scheduled_time": req.scheduled_time,
            "minutes_overdue": req.minutes_overdue,
            "sent_at": sent_at,
            "recipients": [cg["name"] for cg in active_caregivers],
            "title": notification_title,
            "body": notification_body
        }
        self.alert_history.append(alert_record)

        return CaregiverAlertResponse(
            status="SUCCESS",
            alert_id=alert_id,
            recipient_count=len(active_caregivers),
            sent_at=sent_at,
            detail=f"Notification dispatched to {len(active_caregivers)} registered caregiver(s)."
        )

caregiver_service = CaregiverService()
