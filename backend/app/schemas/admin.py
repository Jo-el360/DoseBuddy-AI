from typing import List, Dict, Any
from pydantic import BaseModel, ConfigDict
from app.schemas.user import UserProfileResponse

class AdminSystemAnalytics(BaseModel):
    total_users: int
    active_patients: int
    registered_caregivers: int
    total_medications: int
    total_reminders_generated: int
    overall_adherence_rate: float
    critical_alerts_triggered: int
    system_status: str = "Healthy"

class SystemLogEntry(BaseModel):
    id: str
    timestamp: str
    level: str
    category: str
    message: str

class UserManagementResponse(BaseModel):
    users: List[UserProfileResponse]
    total_count: int

class SystemLogResponse(BaseModel):
    logs: List[SystemLogEntry]
    total_count: int

class ComplianceReportResponse(BaseModel):
    patient_id: str
    patient_name: str
    report_period: str
    adherence_percentage: float
    total_doses_scheduled: int
    total_doses_confirmed: int
    missed_doses_count: int
    average_blood_glucose: float
    glucose_readings_count: int
    clinical_summary: str
    generated_at: str
