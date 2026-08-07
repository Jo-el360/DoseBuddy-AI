from typing import Optional, List
from pydantic import BaseModel, Field, ConfigDict

class OCRScanRequest(BaseModel):
    image_base64: str = Field(..., json_schema_extra={"example": "data:image/jpeg;base64,..."})
    scan_type: str = Field(default="Medicine Label", json_schema_extra={"example": "Medicine Label"})  # "Medicine Label" or "Prescription"

class ParsedMedicationInfo(BaseModel):
    name: str
    dosage: str
    frequency_per_day: int
    meal_relation: str
    category: str
    notes: Optional[str] = None
    warnings: List[str] = []

class OCRScanResponse(BaseModel):
    scan_id: str
    scan_type: str
    raw_text: str
    parsed_medication: ParsedMedicationInfo
    confidence_score: float
    created_at: str

    model_config = ConfigDict(from_attributes=True)
