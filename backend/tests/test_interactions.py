import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_check_drug_interactions_no_conflict():
    payload = {
        "new_medication_name": "Vitamin D3 1000 IU",
        "existing_medication_names": ["Metformin 500mg", "Lisinopril 10mg"]
    }
    response = client.post("/api/v1/medications/check-interactions", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "has_interaction" in data
    assert "severity" in data
    assert data["severity"] in ["None", "Low", "Moderate", "High"]

def test_check_drug_interactions_high_risk_bleed():
    payload = {
        "new_medication_name": "Aspirin 325mg",
        "existing_medication_names": ["Warfarin 5mg", "Metformin 500mg"]
    }
    response = client.post("/api/v1/medications/check-interactions", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["has_interaction"] is True
    assert data["severity"] == "High"
    assert len(data["conflicting_drugs"]) > 0

def test_check_drug_interactions_moderate_beta_blocker():
    payload = {
        "new_medication_name": "Metoprolol 50mg",
        "existing_medication_names": ["Humalog Rapid-Acting Insulin"]
    }
    response = client.post("/api/v1/medications/check-interactions", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["has_interaction"] is True
    assert data["severity"] == "Moderate"
