import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_generate_ai_reminder():
    req_payload = {
        "patient_name": "Arthur",
        "medication_name": "Humalog Insulin",
        "dosage": "10 Units",
        "scheduled_time": "08:00 AM",
        "meal_relation": "15 mins before breakfast",
        "special_instructions": "Check blood glucose prior to injecting."
    }
    response = client.post("/api/v1/reminders/generate", json=req_payload)
    assert response.status_code == 200
    data = response.json()
    assert "personalized_message" in data
    assert "audio_friendly_script" in data
    assert "Arthur" in data["personalized_message"] or "Humalog" in data["personalized_message"]

def test_confirm_dose():
    confirm_payload = {
        "reminder_id": "rem-sample123",
        "confirmed": True,
        "notes": "Taken with glass of water"
    }
    response = client.post("/api/v1/reminders/confirm", json=confirm_payload)
    assert response.status_code == 200
    data = response.json()
    assert data["confirmed"] is True
