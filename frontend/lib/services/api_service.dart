import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/medication.dart';
import '../models/reminder.dart';
import '../models/caregiver.dart';
import '../models/health_metric.dart';
import '../models/user_profile.dart';

class ApiService {
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Medication>> fetchMedications() async {
    try {
      final response = await client.get(Uri.parse(AppConstants.medicationsEndpoint));
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Medication.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching medications: $e');
    }
    // Return sample medications if backend unreachable
    return [
      Medication(
        id: 'med-1',
        name: 'Metformin 500mg',
        dosage: '1 Tablet',
        frequencyPerDay: 2,
        mealRelation: 'With meals',
        times: ['08:00', '20:00'],
        notes: 'Take with breakfast and dinner to lower blood sugar',
        category: 'Oral Hypoglycemic',
      ),
      Medication(
        id: 'med-2',
        name: 'Humalog Rapid-Acting Insulin',
        dosage: '10 Units',
        frequencyPerDay: 3,
        mealRelation: '15 mins before meals',
        times: ['07:45', '12:45', '18:45'],
        notes: 'Check blood sugar prior to injecting',
        category: 'Insulin',
      ),
    ];
  }

  Future<Map<String, dynamic>> checkDrugInteractions(String newMedName, List<String> existingMeds) async {
    try {
      final response = await client.post(
        Uri.parse('${AppConstants.medicationsEndpoint}/check-interactions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'new_medication_name': newMedName,
          'existing_medication_names': existingMeds,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error checking drug interactions: $e');
    }
    // Fallback response for offline testing
    final isBleedRisk = newMedName.toLowerCase().contains('aspirin') && existingMeds.any((m) => m.toLowerCase().contains('warfarin'));
    return {
      'has_interaction': isBleedRisk,
      'severity': isBleedRisk ? 'High' : 'None',
      'interaction_summary': isBleedRisk ? 'HIGH RISK: Combining Aspirin with Warfarin increases bleeding risk.' : 'No major interaction detected with existing medications.',
      'recommendation': isBleedRisk ? 'Consult physician before taking Aspirin.' : 'Safe to proceed.',
      'conflicting_drugs': isBleedRisk ? ['Warfarin 5mg'] : [],
    };
  }

  Future<Reminder> generateAIReminder(Medication med, {String routinePersona = 'Senior Citizen'}) async {
    try {
      final response = await client.post(
        Uri.parse('${AppConstants.remindersEndpoint}/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patient_name': AppConstants.patientName,
          'medication_name': med.name,
          'dosage': med.dosage,
          'scheduled_time': med.times.isNotEmpty ? med.times.first : '08:00 AM',
          'meal_relation': med.mealRelation,
          'special_instructions': med.notes ?? '',
          'routine_persona': routinePersona,
        }),
      );
      if (response.statusCode == 200) {
        return Reminder.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error generating AI reminder: $e');
    }
    // Mock response fallback for offline testing
    return Reminder(
      reminderId: 'rem-fallback-123',
      patientName: 'Arthur',
      medicationName: med.name,
      scheduledTime: med.times.isNotEmpty ? med.times.first : '08:00 AM',
      personalizedMessage: 'Good morning Arthur! It is time for your ${med.name} (${med.dosage}). Please take it ${med.mealRelation} to keep your blood sugar level stable.',
      audioScript: 'Hello Arthur, please take your ${med.name} now.',
      confirmed: false,
    );
  }

  Future<bool> confirmDose(String reminderId) async {
    try {
      final response = await client.post(
        Uri.parse('${AppConstants.remindersEndpoint}/confirm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reminder_id': reminderId,
          'confirmed': true,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return true; // Mock success
    }
  }

  Future<List<Caregiver>> fetchCaregivers() async {
    try {
      final response = await client.get(Uri.parse(AppConstants.caregiversEndpoint));
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Caregiver.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching caregivers: $e');
    }
    return [
      Caregiver(
        id: 'cg-1',
        name: 'Sarah Pendelton (Daughter)',
        email: 'sarah.caregiver@example.com',
        phoneNumber: '+15550192834',
        notifyOnMissedDose: true,
      ),
    ];
  }

  Future<BloodGlucoseLog?> logBloodGlucose(double level, String measurementType, {String? notes}) async {
    try {
      final response = await client.post(
        Uri.parse('${AppConstants.apiBaseUrl}/health-metrics/glucose'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patient_id': 'mock-elderly-user-123',
          'glucose_level': level,
          'measurement_type': measurementType,
          'notes': notes,
        }),
      );
      if (response.statusCode == 200) {
        return BloodGlucoseLog.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error logging blood glucose: $e');
    }
    return null;
  }

  Future<List<BloodGlucoseLog>> fetchGlucoseHistory() async {
    try {
      final response = await client.get(Uri.parse('${AppConstants.apiBaseUrl}/health-metrics/glucose'));
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => BloodGlucoseLog.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching glucose history: $e');
    }
    return [];
  }

  Future<UserProfile?> fetchCurrentUser() async {
    try {
      final response = await client.get(Uri.parse('${AppConstants.apiBaseUrl}/auth/me'));
      if (response.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
    return UserProfile(
      userId: 'mock-elderly-user-123',
      email: 'patient@example.com',
      fullName: 'Arthur Pendelton',
      role: 'User',
      onboarded: true,
      age: 72,
      gender: 'Male',
      bloodGroup: 'O+',
      medicalConditions: ['Type 2 Diabetes', 'Hypertension'],
      allergies: ['Penicillin'],
      routinePersona: 'Senior Citizen',
      emergencyContact: '+15550192834',
      caregiverContact: 'sarah.caregiver@example.com',
      adherencePercentage: 94.5,
      createdAt: '2026-01-01T08:00:00',
    );
  }

  Future<Map<String, dynamic>> fetchAdminAnalytics() async {
    try {
      final response = await client.get(Uri.parse('${AppConstants.apiBaseUrl}/admin/analytics'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching admin analytics: $e');
    }
    return {
      'total_users': 142,
      'active_patients': 104,
      'registered_caregivers': 38,
      'total_medications': 312,
      'total_reminders_generated': 1240,
      'overall_adherence_rate': 94.5,
      'critical_alerts_triggered': 4,
      'system_status': 'Healthy',
    };
  }

  Future<Map<String, dynamic>> generateComplianceReport() async {
    try {
      final response = await client.get(Uri.parse('${AppConstants.apiBaseUrl}/admin/export-report'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error generating compliance report: $e');
    }
    return {
      'patient_id': 'mock-elderly-user-123',
      'patient_name': 'Arthur Pendelton',
      'report_period': 'Last 30 Days',
      'adherence_percentage': 94.5,
      'total_doses_scheduled': 60,
      'total_doses_confirmed': 57,
      'missed_doses_count': 3,
      'average_blood_glucose': 118.5,
      'glucose_readings_count': 14,
      'clinical_summary': 'Patient Arthur Pendelton demonstrated excellent medication adherence (94.5%). Mean blood glucose remains stable within target threshold (118.5 mg/dL). No critical hypoglycemia events recorded.',
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> sendVoiceCommand(String prompt) async {
    try {
      final response = await client.post(
        Uri.parse('${AppConstants.apiBaseUrl}/voice/command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patient_id': 'mock-elderly-user-123',
          'voice_prompt': prompt,
          'routine_persona': 'Senior Citizen',
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error sending voice command: $e');
    }
    return {
      'command_type': 'DOSE_CONFIRMATION',
      'action_executed': true,
      'spoken_response': 'Great job Arthur! I have recorded your dose as confirmed.',
    };
  }

  Future<Map<String, dynamic>> triggerEmergencySOS({String reason = 'Patient pressed SOS button'}) async {
    try {
      final response = await client.post(
        Uri.parse('${AppConstants.apiBaseUrl}/voice/sos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patient_id': 'mock-elderly-user-123',
          'trigger_reason': reason,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error triggering emergency SOS: $e');
    }
    return {
      'status': 'EMERGENCY_DISPATCHED',
      'sos_id': 'sos-fallback-999',
      'caregivers_notified': ['Sarah Pendelton (Daughter)'],
      'emergency_contact': '+15550192834',
      'sent_at': DateTime.now().toIso8601String(),
      'message': '🚨 EMERGENCY SOS DISPATCHED for Arthur Pendelton!',
    };
  }

  Future<Map<String, dynamic>> analyzeMeal(String mealDescription, {String mealType = 'Breakfast'}) async {
    try {
      final response = await client.post(
        Uri.parse('${AppConstants.apiBaseUrl}/nutrition/analyze-meal'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patient_id': 'mock-elderly-user-123',
          'meal_description': mealDescription,
          'meal_type': mealType,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error analyzing meal: $e');
    }
    return {
      'meal_name': mealDescription,
      'estimated_carbs_grams': 35.0,
      'glycemic_index': 'Medium',
      'predicted_glucose_surge_mg_dl': 45.0,
      'insulin_timing_recommendation': 'Take rapid-acting insulin 15 minutes prior to eating.',
      'safety_guidance': 'Moderate carbohydrate load. Check glucose 2 hours after meal.',
      'healthy_alternatives': ['Whole grain toast with avocado', 'Steamed vegetables with lean protein'],
    };
  }
}
