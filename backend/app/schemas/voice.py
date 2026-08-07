from typing import Optional, List
from pydantic import BaseModel, Field

class VoiceCommandRequest(BaseModel):
    patient_id: str = Field(default="mock-elderly-user-123", json_schema_extra={"example": "mock-elderly-user-123"})
    voice_prompt: str = Field(..., json_schema_extra={"example": "I just took my morning insulin dose"})
    routine_persona: str = Field(default="Senior Citizen", json_schema_extra={"example": "Senior Citizen"})

class VoiceCommandResponse(BaseModel):
    command_type: str = Field(..., json_schema_extra={"example": "DOSE_CONFIRMATION"})  # DOSE_CONFIRMATION, GLUCOSE_LOG, EMERGENCY_SOS, MED_QUERY, GENERAL_CHAT
    action_executed: bool = True
    spoken_response: str
    detail_data: Optional[dict] = None

class EmergencySOSRequest(BaseModel):
    patient_id: str = Field(default="mock-elderly-user-123", json_schema_extra={"example": "mock-elderly-user-123"})
    trigger_reason: str = Field(default="Patient pressed red Emergency SOS button", json_schema_extra={"example": "Severe dizziness / low sugar feeling"})
    current_location: Optional[str] = Field(None, json_schema_extra={"example": "Home - Living Room"})

class EmergencySOSResponse(BaseModel):
    status: str = "EMERGENCY_DISPATCHED"
    sos_id: str
    caregivers_notified: List[str]
    emergency_contact: str
    sent_at: str
    message: str
