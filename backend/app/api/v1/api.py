from fastapi import APIRouter
from app.api.v1.endpoints import auth, medications, reminders, caregivers, health_metrics, ocr, admin, voice, nutrition

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication & Onboarding"])
api_router.include_router(medications.router, prefix="/medications", tags=["Medications"])
api_router.include_router(reminders.router, prefix="/reminders", tags=["AI Reminders"])
api_router.include_router(caregivers.router, prefix="/caregivers", tags=["Caregiver Alerts"])
api_router.include_router(health_metrics.router, prefix="/health-metrics", tags=["Health Metrics & Glucose"])
api_router.include_router(ocr.router, prefix="/ocr", tags=["OCR Prescription Scanner"])
api_router.include_router(admin.router, prefix="/admin", tags=["Admin Panel & System Logs"])
api_router.include_router(voice.router, prefix="/voice", tags=["Module 8: Voice Assistant & SOS"])
api_router.include_router(nutrition.router, prefix="/nutrition", tags=["Module 9: Diabetic Meal & Nutrition Advisor"])
