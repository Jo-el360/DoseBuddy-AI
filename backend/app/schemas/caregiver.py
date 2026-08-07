from typing import Optional, List
from pydantic import BaseModel, EmailStr, Field

class CaregiverContact(BaseModel):
    name: str = Field(..., json_schema_extra={"example": "Sarah Pendelton (Daughter)"})
    email: EmailStr = Field(..., json_schema_extra={"example": "sarah.caregiver@example.com"})
    phone_number: str = Field(..., json_schema_extra={"example": "+15550192834"})
    fcm_token: Optional[str] = Field(None, json_schema_extra={"example": "fcm_token_sample_abc123"})
    notify_on_missed_dose: bool = True

class CaregiverAlertRequest(BaseModel):
    patient_id: str
    patient_name: str
    medication_name: str
    scheduled_time: str
    minutes_overdue: int

class CaregiverAlertResponse(BaseModel):
    status: str
    alert_id: str
    recipient_count: int
    sent_at: str
    detail: str
