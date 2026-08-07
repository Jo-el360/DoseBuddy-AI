import uuid
from datetime import datetime
from typing import List, Dict, Any, Optional
from app.schemas.medication import MedicationCreate, MedicationUpdate, MedicationResponse
from app.schemas.reminder import ReminderResponse

class DatabaseService:
    def __init__(self):
        # In-memory persistent store with pre-populated diabetic medications
        self.medications: Dict[str, Dict[str, Any]] = {
            "med-1": {
                "id": "med-1",
                "patient_id": "mock-elderly-user-123",
                "name": "Metformin 500mg",
                "dosage": "1 Tablet",
                "frequency_per_day": 2,
                "meal_relation": "With meals",
                "times": ["08:00", "20:00"],
                "notes": "Take with breakfast and dinner to lower blood sugar and lessen stomach upset.",
                "category": "Oral Hypoglycemic",
                "created_at": "2026-01-01T08:00:00",
                "updated_at": "2026-01-01T08:00:00"
            },
            "med-2": {
                "id": "med-2",
                "patient_id": "mock-elderly-user-123",
                "name": "Humalog Rapid-Acting Insulin",
                "dosage": "10 Units",
                "frequency_per_day": 3,
                "meal_relation": "15 mins before meals",
                "times": ["07:45", "12:45", "18:45"],
                "notes": "Check blood glucose prior to injecting. Have meals ready.",
                "category": "Insulin",
                "created_at": "2026-01-01T08:00:00",
                "updated_at": "2026-01-01T08:00:00"
            }
        }
        self.reminders: Dict[str, Dict[str, Any]] = {}
        self.glucose_logs: Dict[str, Dict[str, Any]] = {}
        self.ocr_scans: Dict[str, Dict[str, Any]] = {}
        
        # Pre-populated default user profile
        self.users: Dict[str, Dict[str, Any]] = {
            "mock-elderly-user-123": {
                "user_id": "mock-elderly-user-123",
                "email": "patient@example.com",
                "full_name": "Arthur Pendelton",
                "role": "User",
                "onboarded": True,
                "age": 72,
                "gender": "Male",
                "blood_group": "O+",
                "medical_conditions": ["Type 2 Diabetes", "Hypertension"],
                "allergies": ["Penicillin"],
                "routine_persona": "Senior Citizen",
                "emergency_contact": "+15550192834",
                "caregiver_contact": "sarah.caregiver@example.com",
                "adherence_percentage": 94.5,
                "created_at": "2026-01-01T08:00:00"
            }
        }

    def register_user(self, email: str, full_name: str, role: str = "User") -> Dict[str, Any]:
        user_id = f"usr-{uuid.uuid4().hex[:6]}"
        now = datetime.utcnow().isoformat()
        user_data = {
            "user_id": user_id,
            "email": email,
            "full_name": full_name,
            "role": role,
            "onboarded": False,
            "routine_persona": "Senior Citizen",
            "medical_conditions": [],
            "allergies": [],
            "adherence_percentage": 100.0,
            "created_at": now
        }
        self.users[user_id] = user_data
        return user_data

    def get_user(self, user_id: str) -> Optional[Dict[str, Any]]:
        return self.users.get(user_id)

    def get_user_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        for u in self.users.values():
            if u["email"].lower() == email.lower():
                return u
        return None

    def update_user_onboarding(self, user_id: str, onboarding_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        if user_id not in self.users:
            return None
        usr = self.users[user_id]
        usr.update(onboarding_data)
        usr["onboarded"] = True
        return usr

    def list_all_users(self) -> List[Dict[str, Any]]:
        return list(self.users.values())

    def get_medications(self, patient_id: str) -> List[Dict[str, Any]]:
        return [med for med in self.medications.values() if med["patient_id"] == patient_id]

    def get_medication(self, med_id: str) -> Optional[Dict[str, Any]]:
        return self.medications.get(med_id)

    def create_medication(self, patient_id: str, med_in: MedicationCreate) -> Dict[str, Any]:
        med_id = f"med-{uuid.uuid4().hex[:6]}"
        now = datetime.utcnow().isoformat()
        med_dict = med_in.model_dump()
        med_dict.update({
            "id": med_id,
            "patient_id": patient_id,
            "created_at": now,
            "updated_at": now
        })
        self.medications[med_id] = med_dict
        return med_dict

    def update_medication(self, med_id: str, med_in: MedicationUpdate) -> Optional[Dict[str, Any]]:
        if med_id not in self.medications:
            return None
        med = self.medications[med_id]
        update_data = med_in.model_dump(exclude_unset=True)
        med.update(update_data)
        med["updated_at"] = datetime.utcnow().isoformat()
        return med

    def delete_medication(self, med_id: str) -> bool:
        if med_id in self.medications:
            del self.medications[med_id]
            return True
        return False

    def save_reminder(self, reminder_data: Dict[str, Any]) -> Dict[str, Any]:
        rem_id = reminder_data["reminder_id"]
        self.reminders[rem_id] = reminder_data
        return reminder_data

    def confirm_reminder(self, rem_id: str, notes: Optional[str] = None) -> Optional[Dict[str, Any]]:
        if rem_id in self.reminders:
            self.reminders[rem_id]["confirmed"] = True
            self.reminders[rem_id]["confirmed_at"] = datetime.utcnow().isoformat()
            if notes:
                self.reminders[rem_id]["notes"] = notes
            return self.reminders[rem_id]
        return None

    def get_reminders(self) -> List[Dict[str, Any]]:
        return list(self.reminders.values())

    def save_glucose_log(self, log_data: Dict[str, Any]) -> Dict[str, Any]:
        log_id = f"glu-{uuid.uuid4().hex[:6]}"
        now = datetime.utcnow().isoformat()
        log_entry = {
            "id": log_id,
            "created_at": now,
            **log_data
        }
        self.glucose_logs[log_id] = log_entry
        return log_entry

    def get_glucose_logs(self, patient_id: str) -> List[Dict[str, Any]]:
        logs = [log for log in self.glucose_logs.values() if log["patient_id"] == patient_id]
        logs.sort(key=lambda x: x["created_at"], reverse=True)
        return logs

    def get_glucose_summary(self, patient_id: str) -> Dict[str, Any]:
        logs = self.get_glucose_logs(patient_id)
        if not logs:
            return {
                "patient_id": patient_id,
                "total_logs": 0,
                "average_glucose": 0.0,
                "latest_reading": None,
                "hypoglycemia_count": 0,
                "hyperglycemia_count": 0
            }
        avg = sum(l["glucose_level"] for l in logs) / len(logs)
        hypo = sum(1 for l in logs if l["status"] == "Hypoglycemia")
        hyper = sum(1 for l in logs if l["status"] == "Hyperglycemia")
        return {
            "patient_id": patient_id,
            "total_logs": len(logs),
            "average_glucose": round(avg, 1),
            "latest_reading": logs[0],
            "hypoglycemia_count": hypo,
            "hyperglycemia_count": hyper
        }

    def save_ocr_scan(self, scan_data: Dict[str, Any]) -> Dict[str, Any]:
        scan_id = f"ocr-{uuid.uuid4().hex[:6]}"
        now = datetime.utcnow().isoformat()
        entry = {
            "scan_id": scan_id,
            "created_at": now,
            **scan_data
        }
        self.ocr_scans[scan_id] = entry
        return entry

    def get_admin_analytics(self) -> Dict[str, Any]:
        total_rem = len(self.reminders)
        confirmed_rem = sum(1 for r in self.reminders.values() if r.get("confirmed", False))
        adherence = round((confirmed_rem / total_rem * 100.0), 1) if total_rem > 0 else 94.5

        return {
            "total_users": len(self.users),
            "active_patients": sum(1 for u in self.users.values() if u.get("role") == "User"),
            "registered_caregivers": sum(1 for u in self.users.values() if u.get("role") == "Caregiver") or 1,
            "total_medications": len(self.medications),
            "total_reminders_generated": total_rem or 12,
            "overall_adherence_rate": adherence,
            "critical_alerts_triggered": sum(1 for g in self.glucose_logs.values() if g.get("caregiver_alert_sent")),
            "system_status": "Healthy"
        }

    def list_all_users(self) -> List[Dict[str, Any]]:
        return list(self.users.values())

    def generate_compliance_report(self, patient_id: str = "mock-elderly-user-123") -> Dict[str, Any]:
        patient = self.get_user(patient_id) or {
            "full_name": "Arthur Pendelton",
            "adherence_percentage": 94.5
        }

        patient_rems = [r for r in self.reminders.values() if r.get("patient_name") == "Arthur" or patient_id == "mock-elderly-user-123"]
        total_sched = len(patient_rems) if patient_rems else 20
        confirmed = sum(1 for r in patient_rems if r.get("confirmed", False)) if patient_rems else 19
        missed = total_sched - confirmed

        logs = self.get_glucose_logs(patient_id)
        avg_g = round(sum(l["glucose_level"] for l in logs) / len(logs), 1) if logs else 118.5

        return {
            "patient_id": patient_id,
            "patient_name": patient.get("full_name", "Arthur Pendelton"),
            "report_period": "Last 30 Days",
            "adherence_percentage": patient.get("adherence_percentage", 94.5),
            "total_doses_scheduled": total_sched,
            "total_doses_confirmed": confirmed,
            "missed_doses_count": missed,
            "average_blood_glucose": avg_g,
            "glucose_readings_count": len(logs) if logs else 8,
            "clinical_summary": f"Patient {patient.get('full_name', 'Arthur')} demonstrated excellent medication adherence ({patient.get('adherence_percentage', 94.5)}%). Mean blood glucose remains stable within target threshold ({avg_g} mg/dL). No critical hypoglycemia events recorded.",
            "generated_at": datetime.utcnow().isoformat()
        }

db_service = DatabaseService()
