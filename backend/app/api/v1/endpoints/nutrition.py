from typing import Dict, Any
from fastapi import APIRouter, Depends
from app.schemas.nutrition import MealAnalysisRequest, MealAnalysisResponse
from app.services.gemini_service import gemini_service
from app.core.security import verify_token

router = APIRouter()

@router.post("/analyze-meal", response_model=MealAnalysisResponse, summary="Analyze meal carbs, GI, and predicted blood sugar surge")
async def analyze_diabetic_meal(req: MealAnalysisRequest, current_user: Dict[str, Any] = Depends(verify_token)):
    """Provides AI diabetic nutrition analysis, carb counting, glycemic index rating, and postprandial glucose surge prediction."""
    user_name = current_user.get("full_name", "Arthur")
    return await gemini_service.analyze_diabetic_meal(user_name, req.meal_description, req.meal_type)
