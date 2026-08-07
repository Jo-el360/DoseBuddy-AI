from typing import Optional, List
from pydantic import BaseModel, Field

class ReminderGenerateRequest(BaseModel):
    patient_name: str = Field(default="Arthur", json_schema_extra={"example": "Arthur"})
    medication_name: str = Field(..., json_schema_extra={"example": "Humalog Insulin"})
    dosage: str = Field(..., json_schema_extra={"example": "10 Units"})
    scheduled_time: str = Field(..., json_schema_extra={"example": "08:00 AM"})
    meal_relation: str = Field(..., json_schema_extra={"example": "15 mins before breakfast"})
    special_instructions: Optional[str] = Field(None, json_schema_extra={"example": "Check blood glucose prior to injecting."})
    routine_persona: Optional[str] = Field(default="Senior Citizen", json_schema_extra={"example": "Senior Citizen"})

class ReminderResponse(BaseModel):
    reminder_id: str
    patient_name: str
    medication_name: str
    scheduled_time: str
    personalized_message: str
    audio_friendly_script: str
    confirmed: bool = False
    confirmed_at: Optional[str] = None
    created_at: str

class DoseConfirmationRequest(BaseModel):
    reminder_id: str
    confirmed: bool = True
    notes: Optional[str] = None
