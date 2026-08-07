class UserProfile {
  final String userId;
  final String email;
  final String fullName;
  final String role;
  final bool onboarded;
  final int? age;
  final String? gender;
  final String? bloodGroup;
  final List<String> medicalConditions;
  final List<String> allergies;
  final String routinePersona;
  final String? emergencyContact;
  final String? caregiverContact;
  final double adherencePercentage;
  final String createdAt;

  UserProfile({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.onboarded,
    this.age,
    this.gender,
    this.bloodGroup,
    required this.medicalConditions,
    required this.allergies,
    required this.routinePersona,
    this.emergencyContact,
    this.caregiverContact,
    required this.adherencePercentage,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'User',
      onboarded: json['onboarded'] ?? false,
      age: json['age'],
      gender: json['gender'],
      bloodGroup: json['blood_group'],
      medicalConditions: List<String>.from(json['medical_conditions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      routinePersona: json['routine_persona'] ?? 'Senior Citizen',
      emergencyContact: json['emergency_contact'],
      caregiverContact: json['caregiver_contact'],
      adherencePercentage: (json['adherence_percentage'] as num?)?.toDouble() ?? 100.0,
      createdAt: json['created_at'] ?? '',
    );
  }
}
