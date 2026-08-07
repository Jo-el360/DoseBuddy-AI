# DoseBuddy AI - Architecture & Design Document

## Problem & Mission
Elderly diabetic patients face significant cognitive and routine challenges managing complex medication regimes (e.g. basal vs bolus insulin, Metformin, BP medications). Forgetting a dose or taking it improperly (e.g. taking fast-acting insulin without food) can lead to severe hypo/hyperglycemic events.

**DoseBuddy AI** solves this single problem with precision by combining:
1. High-contrast, elderly-tailored UI with single-tap confirmation.
2. AI-personalized, empathetic reminders generated dynamically via Google Gemini API.
3. Automated caregiver push notifications (FCM) when a dose is overdue.

---

## Clean System Architecture

```
+-----------------------------------------------------------------------------------+
|                                 CLIENT LAYER                                      |
|                                                                                   |
|  +-----------------------------------------------------------------------------+  |
|  |                             Flutter Application                             |  |
|  |  - Core: Elderly Theme, API Client, Firebase Auth State                     |  |
|  |  - Features: Dashboard, Med Manager, AI Reminders, Caregiver Alerts           |  |
|  +-----------------------------------------------------------------------------+  |
+-----------------------------------------------------------------------------------+
                                         |
                                         v REST HTTP / JSON
+-----------------------------------------------------------------------------------+
|                                BACKEND SERVICE LAYER                              |
|                                                                                   |
|  +-----------------------------------------------------------------------------+  |
|  |                            FastAPI Python Engine                            |  |
|  |  - Auth Middleware (Firebase ID Token Verification)                          |  |
|  |  - CRUD API Endpoints (/medications, /reminders, /caregivers)                 |  |
|  |  - Gemini AI Service (Generative Model: personalized reminder & audio script) |  |
|  |  - Caregiver Escalation Engine (FCM Missed Dose Alerts)                    |  |
|  +-----------------------------------------------------------------------------+  |
+-----------------------------------------------------------------------------------+
                                  |                     |
                                  v                     v
                     +------------------------+  +-------------------------+
                     |  Google Gemini AI API  |  |  Firebase Cloud Store   |
                     |  (Prompt Synthesis)    |  |  & Auth Services        |
                     +------------------------+  +-------------------------+
```

---

## Data Models & Schema Design

### Medication Entity
- `id`: String (UUID)
- `patient_id`: String (Firebase UID)
- `name`: String (e.g., "Humalog Insulin")
- `dosage`: String (e.g., "10 Units")
- `frequency_per_day`: Integer (e.g., 3)
- `meal_relation`: String ("Before meal", "With meal", "After meal")
- `times`: Array of Strings (e.g., ["08:00", "20:00"])
- `notes`: String
- `category`: String ("Insulin", "Oral Hypoglycemic")

### Reminder Entity
- `reminder_id`: String (UUID)
- `patient_name`: String
- `medication_name`: String
- `scheduled_time`: String
- `personalized_message`: String (Synthesized by Gemini)
- `audio_friendly_script`: String
- `confirmed`: Boolean
- `confirmed_at`: Timestamp string

---

## Key Technical Decisions
- **FastAPI**: Asynchronous Python framework providing high throughput, automatic OpenAPI/Swagger documentation generation, and strict typing via Pydantic.
- **Google Gemini API**: Utilized to craft empathetic, context-aware reminders for diabetic patients taking into account meal relationships and safety instructions.
- **Flutter**: Single cross-platform codebase targeting Web, Android, and iOS with an elderly-accessible theme design.
- **Firebase Authentication & Firestore**: Secure user identity management and real-time document store.
