class Caregiver {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final bool notifyOnMissedDose;

  Caregiver({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.notifyOnMissedDose,
  });

  factory Caregiver.fromJson(Map<String, dynamic> json) {
    return Caregiver(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      notifyOnMissedDose: json['notify_on_missed_dose'] ?? true,
    );
  }
}
