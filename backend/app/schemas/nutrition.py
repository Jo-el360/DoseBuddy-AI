from typing import Optional, List
from pydantic import BaseModel, Field

class MealAnalysisRequest(BaseModel):
    patient_id: str = Field(default="mock-elderly-user-123", json_schema_extra={"example": "mock-elderly-user-123"})
    meal_description: str = Field(..., json_schema_extra={"example": "2 slices of whole wheat toast with scrambled eggs and black coffee"})
    meal_type: str = Field(default="Breakfast", json_schema_extra={"example": "Breakfast"})  # Breakfast, Lunch, Dinner, Snack

class MealAnalysisResponse(BaseModel):
    meal_name: str
    estimated_carbs_grams: float
    glycemic_index: str = Field(..., json_schema_extra={"example": "Medium"})  # Low, Medium, High
    predicted_glucose_surge_mg_dl: float
    insulin_timing_recommendation: str
    safety_guidance: str
    healthy_alternatives: List[str] = []
