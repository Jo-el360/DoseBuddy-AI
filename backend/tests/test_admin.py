import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_get_admin_analytics():
    response = client.get("/api/v1/admin/analytics")
    assert response.status_code == 200
    data = response.json()
    assert "total_users" in data
    assert "overall_adherence_rate" in data
    assert "system_status" in data
    assert data["system_status"] == "Healthy"

def test_list_admin_users():
    response = client.get("/api/v1/admin/users")
    assert response.status_code == 200
    data = response.json()
    assert "users" in data
    assert "total_count" in data
    assert data["total_count"] >= 1

def test_get_system_logs():
    response = client.get("/api/v1/admin/logs")
    assert response.status_code == 200
    data = response.json()
    assert "logs" in data
    assert len(data["logs"]) >= 1

def test_export_compliance_report():
    response = client.get("/api/v1/admin/export-report?patient_id=mock-elderly-user-123")
    assert response.status_code == 200
    data = response.json()
    assert data["patient_name"] == "Arthur Pendelton"
    assert "adherence_percentage" in data
    assert "clinical_summary" in data
