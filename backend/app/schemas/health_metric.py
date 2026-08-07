from typing import Optional, List
from pydantic import BaseModel, Field, ConfigDict

class BloodGlucoseCreate(BaseModel):
    patient_id: str = Field(default="mock-elderly-user-123", json_schema_extra={"example": "mock-elderly-user-123"})
    glucose_level: float = Field(..., ge=20.0, le=600.0, json_schema_extra={"example": 145.0})  # mg/dL
    measurement_type: str = Field(default="Fasting", json_schema_extra={"example": "Fasting"})  # Fasting, Pre-meal, Post-meal, Bedtime, Random
    notes: Optional[str] = Field(None, json_schema_extra={"example": "Felt a bit dizzy before breakfast"})

class BloodGlucoseResponse(BaseModel):
    id: str
    patient_id: str
    glucose_level: float
    measurement_type: str
    status: str  # "Normal", "Hypoglycemia", "Hyperglycemia"
    safety_recommendation: str
    audio_warning_script: str
    caregiver_alert_sent: bool
    created_at: str
    notes: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

class HealthSummaryResponse(BaseModel):
    patient_id: str
    total_logs: int
    average_glucose: float
    latest_reading: Optional[BloodGlucoseResponse] = None
    hypoglycemia_count: int
    hyperglycemia_count: int
