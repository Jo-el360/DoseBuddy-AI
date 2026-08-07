# DoseBuddy AI - API Specification

Base Endpoint: `http://localhost:8000/api/v1`

---

## 1. Medications Endpoints (`/medications`)

### `GET /api/v1/medications/`
Retrieves all registered medications for the current user.
- **Header**: `Authorization: Bearer <FIREBASE_ID_TOKEN>`
- **Response `200 OK`**:
  ```json
  [
    {
      "id": "med-1",
      "patient_id": "mock-elderly-user-123",
      "name": "Metformin 500mg",
      "dosage": "1 Tablet",
      "frequency_per_day": 2,
      "meal_relation": "With meals",
      "times": ["08:00", "20:00"],
      "notes": "Take with breakfast and dinner",
      "category": "Oral Hypoglycemic",
      "created_at": "2026-01-01T08:00:00",
      "updated_at": "2026-01-01T08:00:00"
    }
  ]
  ```

### `POST /api/v1/medications/`
Creates a new medication entry.
- **Request Body**:
  ```json
  {
    "name": "Glipizide 5mg",
    "dosage": "1 Tablet",
    "frequency_per_day": 1,
    "meal_relation": "30 mins before breakfast",
    "times": ["07:30"],
    "notes": "Take before breakfast",
    "category": "Sulfonylurea"
  }
  ```
- **Response `201 Created`**: Returns created `MedicationResponse`.

### `POST /api/v1/medications/check-interactions`
Analyzes clinical drug-drug interaction safety between a new medication and existing prescription list using Gemini AI.
- **Request Body**:
  ```json
  {
    "new_medication_name": "Aspirin 325mg",
    "existing_medication_names": ["Warfarin 5mg", "Metformin 500mg"]
  }
  ```
- **Response `200 OK`**:
  ```json
  {
    "has_interaction": true,
    "severity": "High",
    "interaction_summary": "HIGH RISK: Combining Aspirin with Warfarin significantly increases risk of internal bleeding.",
    "recommendation": "Consult your physician before taking over-the-counter pain relievers while on Warfarin.",
    "conflicting_drugs": ["Warfarin 5mg"]
  }
  ```

---

## 2. AI Reminders Endpoints (`/reminders`)

### `POST /api/v1/reminders/generate`
Synthesizes a personalized reminder message and audio script using Google Gemini AI.
- **Request Body**:
  ```json
  {
    "patient_name": "Arthur",
    "medication_name": "Humalog Insulin",
    "dosage": "10 Units",
    "scheduled_time": "08:00 AM",
    "meal_relation": "15 mins before breakfast",
    "special_instructions": "Check blood glucose prior to injecting."
  }
  ```
- **Response `200 OK`**:
  ```json
  {
    "reminder_id": "rem-a1b2c3d4",
    "patient_name": "Arthur",
    "medication_name": "Humalog Insulin",
    "scheduled_time": "08:00 AM",
    "personalized_message": "Good morning Arthur! It is time for your 10 Units of Humalog Insulin. Please take it 15 mins before breakfast.",
    "audio_friendly_script": "Hello Arthur, please take your Humalog Insulin now.",
    "confirmed": false,
    "confirmed_at": null,
    "created_at": "2026-08-04T11:30:00"
  }
  ```

### `POST /api/v1/reminders/confirm`
Single-tap dose confirmation from the Flutter frontend.
- **Request Body**:
  ```json
  {
    "reminder_id": "rem-a1b2c3d4",
    "confirmed": true
  }
  ```

---

## 3. Caregivers Endpoints (`/caregivers`)

### `POST /api/v1/caregivers/alert-missed-dose`
Triggers an immediate FCM notification dispatch if a medication dose is unconfirmed past threshold.
- **Request Body**:
  ```json
  {
    "patient_id": "mock-elderly-user-123",
    "patient_name": "Arthur Pendelton",
    "medication_name": "Humalog Insulin",
    "scheduled_time": "08:00 AM",
    "minutes_overdue": 30
  }
  ```
- **Response `200 OK`**:
  ```json
  {
    "status": "SUCCESS",
    "alert_id": "alt-88f91a2b",
    "recipient_count": 1,
    "sent_at": "2026-08-04T11:35:00",
    "detail": "Notification dispatched to 1 registered caregiver(s)."
  }
  ```

---

## 4. Admin & Compliance Export Endpoints (`/admin`)

### `GET /api/v1/admin/analytics`
Fetches high-level metrics on active patients, caregivers, adherence rates, and critical alert counts.
- **Response `200 OK`**:
  ```json
  {
    "total_users": 142,
    "active_patients": 104,
    "registered_caregivers": 38,
    "total_medications": 312,
    "total_reminders_generated": 1240,
    "overall_adherence_rate": 94.5,
    "critical_alerts_triggered": 4,
    "system_status": "Healthy"
  }
  ```

### `GET /api/v1/admin/export-report`
Generates a clinical compliance summary report for doctors and caregivers.
- **Query Parameter**: `patient_id` (default: `mock-elderly-user-123`)
- **Response `200 OK`**:
  ```json
  {
    "patient_id": "mock-elderly-user-123",
    "patient_name": "Arthur Pendelton",
    "report_period": "Last 30 Days",
    "adherence_percentage": 94.5,
    "total_doses_scheduled": 60,
    "total_doses_confirmed": 57,
    "missed_doses_count": 3,
    "average_blood_glucose": 118.5,
    "glucose_readings_count": 14,
    "clinical_summary": "Patient Arthur Pendelton demonstrated excellent medication adherence (94.5%). Mean blood glucose remains stable within target threshold (118.5 mg/dL).",
    "generated_at": "2026-08-06T14:34:00"
  }
  ```

---

## 5. Module 8: Voice Assistant & Emergency SOS (`/voice`)

### `POST /api/v1/voice/command`
Processes natural language voice input from elderly users and returns action execution + TTS spoken audio script.
- **Request Body**:
  ```json
  {
    "patient_id": "mock-elderly-user-123",
    "voice_prompt": "I just took my morning insulin dose",
    "routine_persona": "Senior Citizen"
  }
  ```
- **Response `200 OK`**:
  ```json
  {
    "command_type": "DOSE_CONFIRMATION",
    "action_executed": true,
    "spoken_response": "Great job Arthur! I have recorded your dose as confirmed."
  }
  ```

### `POST /api/v1/voice/sos`
Triggers immediate Emergency SOS push alert to registered caregivers and emergency contacts.
- **Request Body**:
  ```json
  {
    "patient_id": "mock-elderly-user-123",
    "trigger_reason": "Patient pressed red Emergency SOS button"
  }
  ```

---

## 6. Module 9: Diabetic Meal & Nutrition Advisor (`/nutrition`)

### `POST /api/v1/nutrition/analyze-meal`
Provides AI diabetic nutrition analysis, carb counting, glycemic index rating, and postprandial glucose surge prediction.
- **Request Body**:
  ```json
  {
    "patient_id": "mock-elderly-user-123",
    "meal_description": "2 slices white toast with jam and orange juice",
    "meal_type": "Breakfast"
  }
  ```
- **Response `200 OK`**:
  ```json
  {
    "meal_name": "2 slices white toast with jam and orange juice",
    "estimated_carbs_grams": 48.0,
    "glycemic_index": "High",
    "predicted_glucose_surge_mg_dl": 65.0,
    "insulin_timing_recommendation": "High glycemic load detected. Take rapid-acting insulin 15-20 minutes before eating.",
    "safety_guidance": "Caution Arthur: Expect a blood sugar rise of ~65 mg/dL.",
    "healthy_alternatives": ["Avocado & spinach omelet", "Steamed cauliflower rice with lean protein"]
  }
  ```
