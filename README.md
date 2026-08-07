# 💊 DoseBuddy AI

> **Production-Ready Full-Stack AI Medication Reminder Application for Elderly Diabetic Patients**

**DoseBuddy AI** is a specialized full-stack health application designed specifically to solve one critical problem: helping elderly diabetic patients adhere to complex medication routines (insulin, oral hypoglycemics, BP meds) through AI-personalized reminders, high-contrast accessible UI, and automated caregiver escalations.

---

## 🌟 Key Features

- **👴 Accessible Elderly UI**: Custom Flutter high-contrast design with oversized fonts, high touch targets, and single-tap *"I TOOK MY MEDICINE"* confirmation button.
- **🤖 Gemini AI Personalized Reminders**: Dynamically generates warm, empathetic reminder messages and text-to-speech scripts tailored for diabetic medication safety (e.g., reminding patient to eat within 15 minutes of rapid-acting insulin).
- **🚨 Caregiver Escalation Alerts**: Automatically dispatches FCM push notifications to registered caregivers if a medication dose remains unconfirmed past the safe threshold.
- **🔐 Secure Firebase Auth & Firestore**: Strict document permissions isolating patient records and caregiver access rules.
- **⚡ FastAPI Python Backend**: High-performance async REST API with interactive Swagger OpenAPI documentation at `/docs`.
- **🐳 Docker Support & Tests**: `docker-compose.yml`, `Dockerfile`, and unit tests for backend services.

---

## 📁 Repository Structure

```
DoseBuddy-AI/
├── frontend/             # Flutter Application (Clean Architecture, Elderly UI)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/         # Theme, Constants
│   │   ├── models/       # Medication, Reminder, Caregiver models
│   │   ├── services/     # API Service, Auth Service
│   │   └── screens/      # Dashboard, Med Manager, AI Reminders, Caregiver Alerts
│   └── test/             # Flutter Widget tests
├── backend/              # FastAPI Python Backend
│   ├── app/
│   │   ├── main.py       # FastAPI Entrypoint
│   │   ├── core/         # Config, Security, Firebase Admin init
│   │   ├── api/v1/       # Routers: medications, reminders, caregivers
│   │   ├── schemas/      # Pydantic Schemas
│   │   └── services/     # Gemini AI Service, Caregiver Alerts, Database Service
│   ├── tests/            # Pytest suite for backend endpoints
│   ├── Dockerfile
│   ├── requirements.txt
│   └── .env.example
├── firebase/             # Firebase Security Rules & Config
│   ├── firestore.rules
│   ├── firestore.indexes.json
│   └── firebase.json
├── docs/                 # Documentation
│   ├── ARCHITECTURE.md
│   ├── API_SPECIFICATION.md
│   └── SETUP.md
├── docker-compose.yml    # Root Docker Compose file
└── README.md             # Master README Guide
```

---

## 🚀 Quickstart Guide

### 1. Run Backend Server (FastAPI)
```bash
cd backend
python -m venv venv
.\venv\Scripts\activate   # On Windows
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```
- Open Swagger API Docs at: **http://localhost:8000/docs**

### 2. Run Backend Unit Tests
```bash
cd backend
pytest
```

### 3. Run Frontend Application (Flutter)
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

---

## 📄 License
Distributed under the MIT License.
