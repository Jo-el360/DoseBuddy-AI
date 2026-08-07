from typing import Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status
from app.schemas.admin import AdminSystemAnalytics, UserManagementResponse, SystemLogResponse, ComplianceReportResponse
from app.services.firestore_service import db_service
from app.core.security import verify_token

router = APIRouter()

@router.get("/analytics", response_model=AdminSystemAnalytics, summary="Get full system analytics for Admin Panel")
def get_analytics(current_user: Dict[str, Any] = Depends(verify_token)):
    """Fetches high-level metrics on active patients, caregivers, adherence rates, and critical alert counts."""
    return db_service.get_admin_analytics()

@router.get("/export-report", response_model=ComplianceReportResponse, summary="Export patient compliance & medical summary report")
def export_compliance_report(patient_id: str = "mock-elderly-user-123", current_user: Dict[str, Any] = Depends(verify_token)):
    """Generates a comprehensive clinical compliance summary report for physicians and caregivers."""
    return db_service.generate_compliance_report(patient_id)

@router.get("/users", response_model=UserManagementResponse, summary="List all registered system users")
def list_users(current_user: Dict[str, Any] = Depends(verify_token)):
    """Returns list of registered users, roles, and adherence percentages."""
    users = db_service.list_all_users()
    return {
        "users": users,
        "total_count": len(users)
    }

@router.get("/logs", response_model=SystemLogResponse, summary="Get system log entries")
def get_system_logs(current_user: Dict[str, Any] = Depends(verify_token)):
    """Returns system logs for administrative monitoring."""
    logs = [
        {"id": "log-1", "timestamp": "2026-08-04T14:00:00", "level": "INFO", "category": "AI Engine", "message": "Gemini AI personalized reminder generated successfully."},
        {"id": "log-2", "timestamp": "2026-08-04T14:15:00", "level": "WARN", "category": "Caregiver Alert", "message": "Critical Glucose Alert dispatched to Sarah Pendelton (Daughter)."},
        {"id": "log-3", "timestamp": "2026-08-04T14:30:00", "level": "INFO", "category": "OCR", "message": "Prescription label parsed with 96% confidence score."}
    ]
    return {
        "logs": logs,
        "total_count": len(logs)
    }
