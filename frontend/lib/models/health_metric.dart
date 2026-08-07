class BloodGlucoseLog {
  final String id;
  final String patientId;
  final double glucoseLevel;
  final String measurementType;
  final String status;
  final String safetyRecommendation;
  final String audioWarningScript;
  final bool caregiverAlertSent;
  final String createdAt;
  final String? notes;

  BloodGlucoseLog({
    required this.id,
    required this.patientId,
    required this.glucoseLevel,
    required this.measurementType,
    required this.status,
    required this.safetyRecommendation,
    required this.audioWarningScript,
    required this.caregiverAlertSent,
    required this.createdAt,
    this.notes,
  });

  factory BloodGlucoseLog.fromJson(Map<String, dynamic> json) {
    return BloodGlucoseLog(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      glucoseLevel: (json['glucose_level'] as num).toDouble(),
      measurementType: json['measurement_type'] ?? 'Fasting',
      status: json['status'] ?? 'Normal',
      safetyRecommendation: json['safety_recommendation'] ?? '',
      audioWarningScript: json['audio_warning_script'] ?? '',
      caregiverAlertSent: json['caregiver_alert_sent'] ?? false,
      createdAt: json['created_at'] ?? '',
      notes: json['notes'],
    );
  }
}
