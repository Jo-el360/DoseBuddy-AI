class Reminder {
  final String reminderId;
  final String patientName;
  final String medicationName;
  final String scheduledTime;
  final String personalizedMessage;
  final String audioScript;
  final bool confirmed;
  final String? confirmedAt;

  Reminder({
    required this.reminderId,
    required this.patientName,
    required this.medicationName,
    required this.scheduledTime,
    required this.personalizedMessage,
    required this.audioScript,
    required this.confirmed,
    this.confirmedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      reminderId: json['reminder_id'] ?? '',
      patientName: json['patient_name'] ?? '',
      medicationName: json['medication_name'] ?? '',
      scheduledTime: json['scheduled_time'] ?? '',
      personalizedMessage: json['personalized_message'] ?? '',
      audioScript: json['audio_friendly_script'] ?? '',
      confirmed: json['confirmed'] ?? false,
      confirmedAt: json['confirmed_at'],
    );
  }
}
