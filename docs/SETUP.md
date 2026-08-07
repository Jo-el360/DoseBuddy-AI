# DoseBuddy AI - Setup & Installation Guide

This guide outlines step-by-step instructions for running **DoseBuddy AI** both locally and via Docker.

---

## Prerequisites
- **Python**: Version 3.11+
- **Flutter SDK**: Version 3.0+ (Optional for mobile/web frontend execution)
- **Docker & Docker Compose** (Optional for containerized run)
- **Google Gemini API Key** (Get free key from [Google AI Studio](https://aistudio.google.com/))

---

## Option A: Local Quickstart (Development Mode)

### Step 1: Set Up Backend (FastAPI)
```bash
# Navigate to backend folder
cd backend

# Create virtual environment
python -m venv venv

# Activate environment (Windows)
.\venv\Scripts\activate
# Activate environment (Linux/macOS)
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create .env configuration
cp .env.example .env
```
*(Optionally add your `GEMINI_API_KEY` in `.env`. Out of the box, `USE_MOCK_SERVICES=true` is enabled so you can test immediately without cloud keys.)*

#### Run Backend Server:
```bash
uvicorn app.main:app --reload --port 8000
```
- Interactive Swagger Docs: `http://localhost:8000/docs`
- Health Endpoint: `http://localhost:8000/api/v1/health`

#### Run Pytest Unit Tests:
```bash
pytest
```

---

### Step 2: Set Up Frontend (Flutter)
```bash
# Navigate to frontend folder
cd frontend

# Fetch Flutter dependencies
flutter pub get

# Run on Web (Chrome)
flutter run -d chrome

# Run unit tests
flutter test
```

---

## Option B: Run with Docker Compose

To launch the entire stack using Docker:

```bash
docker-compose up --build
```

- Backend API: `http://localhost:8000`
- Swagger Interactive Docs: `http://localhost:8000/docs`
