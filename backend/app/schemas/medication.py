from typing import Optional, List
from pydantic import BaseModel, Field, ConfigDict

class MedicationBase(BaseModel):
    name: str = Field(..., json_schema_extra={"example": "Metformin 500mg"})
    dosage: str = Field(..., json_schema_extra={"example": "1 Tablet"})
    frequency_per_day: int = Field(default=2, ge=1, le=6, json_schema_extra={"example": 2})
    meal_relation: str = Field(..., json_schema_extra={"example": "With meals"})  # "Before meal", "With meal", "After meal", "Bedtime"
    times: List[str] = Field(..., json_schema_extra={"example": ["08:00", "20:00"]})  # HH:MM format
    notes: Optional[str] = Field(None, json_schema_extra={"example": "Take with a full glass of water to reduce stomach upset"})
    category: str = Field(default="Oral Hypoglycemic", json_schema_extra={"example": "Oral Hypoglycemic"})  # E.g. Insulin, Oral, BP, Vitamin

class MedicationCreate(MedicationBase):
    pass

class MedicationUpdate(BaseModel):
    name: Optional[str] = None
    dosage: Optional[str] = None
    frequency_per_day: Optional[int] = None
    meal_relation: Optional[str] = None
    times: Optional[List[str]] = None
    notes: Optional[str] = None
    category: Optional[str] = None

class MedicationResponse(MedicationBase):
    id: str
    patient_id: str
    created_at: str
    updated_at: str

    model_config = ConfigDict(from_attributes=True)

class DrugInteractionRequest(BaseModel):
    new_medication_name: str = Field(..., json_schema_extra={"example": "Aspirin 81mg"})
    existing_medication_names: List[str] = Field(default=[], json_schema_extra={"example": ["Warfarin 5mg", "Metformin 500mg"]})

class DrugInteractionResponse(BaseModel):
    has_interaction: bool
    severity: str = Field(..., json_schema_extra={"example": "High"})  # High, Moderate, Low, None
    interaction_summary: str
    recommendation: str
    conflicting_drugs: List[str] = []
