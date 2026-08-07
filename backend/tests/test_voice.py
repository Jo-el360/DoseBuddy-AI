import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_process_voice_command_dose_confirmation():
    payload = {
        "patient_id": "mock-elderly-user-123",
        "voice_prompt": "I just took my insulin dose",
        "routine_persona": "Senior Citizen"
    }
    response = client.post("/api/v1/voice/command", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["command_type"] == "DOSE_CONFIRMATION"
    assert data["action_executed"] is True
    assert "spoken_response" in data

def test_process_voice_command_emergency_sos():
    payload = {
        "patient_id": "mock-elderly-user-123",
        "voice_prompt": "Help me my sugar is low and I feel dizzy",
        "routine_persona": "Senior Citizen"
    }
    response = client.post("/api/v1/voice/command", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["command_type"] == "EMERGENCY_SOS"

def test_dispatch_emergency_sos():
    payload = {
        "patient_id": "mock-elderly-user-123",
        "trigger_reason": "Patient pressed emergency button on dashboard"
    }
    response = client.post("/api/v1/voice/sos", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "EMERGENCY_DISPATCHED"
    assert "sos_id" in data
    assert len(data["caregivers_notified"]) >= 1
