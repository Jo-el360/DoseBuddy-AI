import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_analyze_diabetic_meal_high_gi():
    payload = {
        "patient_id": "mock-elderly-user-123",
        "meal_description": "White toast with strawberry jam and orange juice",
        "meal_type": "Breakfast"
    }
    response = client.post("/api/v1/nutrition/analyze-meal", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "estimated_carbs_grams" in data
    assert data["glycemic_index"] in ["High", "Medium", "Low"]
    assert "predicted_glucose_surge_mg_dl" in data
    assert len(data["healthy_alternatives"]) >= 1

def test_analyze_diabetic_meal_balanced():
    payload = {
        "patient_id": "mock-elderly-user-123",
        "meal_description": "Grilled chicken salad with avocado and olive oil",
        "meal_type": "Lunch"
    }
    response = client.post("/api/v1/nutrition/analyze-meal", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["glycemic_index"] == "Low"
    assert data["predicted_glucose_surge_mg_dl"] <= 40.0
