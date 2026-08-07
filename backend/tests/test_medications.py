import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_list_medications():
    response = client.get("/api/v1/medications/")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    assert data[0]["name"] == "Metformin 500mg"

def test_create_medication():
    new_med = {
        "name": "Glipizide 5mg",
        "dosage": "1 Tablet",
        "frequency_per_day": 1,
        "meal_relation": "30 mins before breakfast",
        "times": ["07:30"],
        "notes": "Take before meal to stimulate insulin release",
        "category": "Sulfonylurea"
    }
    response = client.post("/api/v1/medications/", json=new_med)
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Glipizide 5mg"
    assert "id" in data
