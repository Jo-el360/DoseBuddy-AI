import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_list_caregivers():
    response = client.get("/api/v1/caregivers/")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1

def test_alert_missed_dose():
    alert_payload = {
        "patient_id": "mock-elderly-user-123",
        "patient_name": "Arthur Pendelton",
        "medication_name": "Humalog Insulin",
        "scheduled_time": "08:00 AM",
        "minutes_overdue": 35
    }
    response = client.post("/api/v1/caregivers/alert-missed-dose", json=alert_payload)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "SUCCESS"
    assert data["recipient_count"] >= 1
