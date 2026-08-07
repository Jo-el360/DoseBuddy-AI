import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_user_registration_and_onboarding():
    # 1. Register User
    reg_payload = {
        "email": "student_user@example.com",
        "password": "Password123!",
        "full_name": "Alex Student",
        "role": "User"
    }
    response = client.post("/api/v1/auth/register", json=reg_payload)
    assert response.status_code == 201
    data = response.json()
    assert "access_token" in data
    assert data["user"]["email"] == "student_user@example.com"

    # 2. Complete Onboarding
    token = data["access_token"]
    onboarding_payload = {
        "age": 21,
        "gender": "Female",
        "height_cm": 165.0,
        "weight_kg": 58.0,
        "blood_group": "A+",
        "medical_conditions": ["Vitamin D Deficiency"],
        "allergies": [],
        "emergency_contact": "+15559876543",
        "caregiver_contact": "mom@example.com",
        "preferred_language": "English",
        "country": "United States",
        "time_zone": "America/Los_Angeles",
        "routine_persona": "Student",
        "wake_time": "07:30",
        "sleep_time": "23:00",
        "breakfast_time": "08:15",
        "lunch_time": "12:30",
        "dinner_time": "19:00"
    }
    headers = {"Authorization": f"Bearer {token}"}
    onb_resp = client.post("/api/v1/auth/onboarding", json=onboarding_payload, headers=headers)
    assert onb_resp.status_code == 200
    onb_data = onb_resp.json()
    assert onb_data["onboarded"] is True
    assert onb_data["routine_persona"] == "Student"

def test_persona_ai_reminders():
    # Student Persona Reminder
    student_payload = {
        "patient_name": "Alex",
        "medication_name": "Vitamin D3 2000 IU",
        "dosage": "1 Softgel",
        "scheduled_time": "08:00 AM",
        "meal_relation": "With breakfast",
        "special_instructions": "Take before heading to class",
        "routine_persona": "Student"
    }
    resp = client.post("/api/v1/reminders/generate", json=student_payload)
    assert resp.status_code == 200
    msg = resp.json()["personalized_message"]
    assert "Alex" in msg
    assert "class" in msg.lower() or "studies" in msg.lower() or "breakfast" in msg.lower()

    # Night Shift Worker Persona Reminder
    night_payload = {
        "patient_name": "Marcus",
        "medication_name": "Lisinopril 10mg",
        "dosage": "1 Tablet",
        "scheduled_time": "07:00 PM",
        "meal_relation": "Before shift",
        "special_instructions": "Check blood pressure",
        "routine_persona": "Night Shift Worker"
    }
    night_resp = client.post("/api/v1/reminders/generate", json=night_payload)
    assert night_resp.status_code == 200
    night_msg = night_resp.json()["personalized_message"]
    assert "Marcus" in night_msg
    assert "shift" in night_msg.lower() or "night" in night_msg.lower()

def test_ocr_label_scanning():
    scan_payload = {
        "image_base64": "data:image/jpeg;base64,samplebase64string",
        "scan_type": "Medicine Label"
    }
    resp = client.post("/api/v1/ocr/scan-label", json=scan_payload)
    assert resp.status_code == 200
    data = resp.json()
    assert "parsed_medication" in data
    assert data["parsed_medication"]["name"] == "Metformin 850mg Extended-Release"
    assert data["confidence_score"] > 0.9

def test_admin_analytics_and_logs():
    resp = client.get("/api/v1/admin/analytics")
    assert resp.status_code == 200
    analytics = resp.json()
    assert analytics["total_users"] >= 1
    assert analytics["system_status"] == "Healthy"

    users_resp = client.get("/api/v1/admin/users")
    assert users_resp.status_code == 200
    assert users_resp.json()["total_count"] >= 1

    logs_resp = client.get("/api/v1/admin/logs")
    assert logs_resp.status_code == 200
    assert logs_resp.json()["total_count"] >= 3
