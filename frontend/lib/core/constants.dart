class AppConstants {
  // Base URL pointing to FastAPI Backend (Adjust to localhost or remote IP)
  static const String apiBaseUrl = 'http://localhost:8000/api/v1';

  static const String patientName = 'Arthur';
  
  static const String medicationsEndpoint = '$apiBaseUrl/medications';
  static const String remindersEndpoint = '$apiBaseUrl/reminders';
  static const String caregiversEndpoint = '$apiBaseUrl/caregivers';
}
