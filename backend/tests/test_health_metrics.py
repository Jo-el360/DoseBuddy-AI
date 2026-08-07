import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_log_normal_glucose():
    payload = {
        "patient_id": "mock-elderly-user-123",
        "glucose_level": 115.0,
        "measurement_type": "Fasting",
        "notes": "Feeling good this morning"
    }
    response = client.post("/api/v1/health-metrics/glucose", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["glucose_level"] == 115.0
    assert data["status"] == "Normal"
    assert data["caregiver_alert_sent"] is False
    assert "safety_recommendation" in data
    assert "audio_warning_script" in data

def test_log_hypoglycemia_trigger_alert():
    payload = {
        "patient_id": "mock-elderly-user-123",
        "glucose_level": 58.0,
        "measurement_type": "Pre-meal",
        "notes": "Feeling shaky and dizzy"
    }
    response = client.post("/api/v1/health-metrics/glucose", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["glucose_level"] == 58.0
    assert data["status"] == "Hypoglycemia"
    assert data["caregiver_alert_sent"] is True
    assert "juice" in data["safety_recommendation"].lower() or "sugar" in data["safety_recommendation"].lower() or "low" in data["safety_recommendation"].lower()

def test_log_hyperglycemia_trigger_alert():
    payload = {
        "patient_id": "mock-elderly-user-123",
        "glucose_level": 280.0,
        "measurement_type": "Post-meal",
        "notes": "Extremely thirsty"
    }
    response = client.post("/api/v1/health-metrics/glucose", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "Hyperglycemia"
    assert data["caregiver_alert_sent"] is True

def test_get_glucose_history_and_summary():
    history_resp = client.get("/api/v1/health-metrics/glucose")
    assert history_resp.status_code == 200
    history = history_resp.json()
    assert isinstance(history, list)
    assert len(history) >= 3

    summary_resp = client.get("/api/v1/health-metrics/summary")
    assert summary_resp.status_code == 200
    summary = summary_resp.json()
    assert summary["total_logs"] >= 3
    assert summary["hypoglycemia_count"] >= 1
    assert summary["hyperglycemia_count"] >= 1
    assert summary["average_glucose"] > 0
