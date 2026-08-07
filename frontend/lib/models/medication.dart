class Medication {
  final String id;
  final String name;
  final String dosage;
  final int frequencyPerDay;
  final String mealRelation;
  final List<String> times;
  final String? notes;
  final String category;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequencyPerDay,
    required this.mealRelation,
    required this.times,
    this.notes,
    required this.category,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequencyPerDay: json['frequency_per_day'] ?? 1,
      mealRelation: json['meal_relation'] ?? '',
      times: List<String>.from(json['times'] ?? []),
      notes: json['notes'],
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency_per_day': frequencyPerDay,
      'meal_relation': mealRelation,
      'times': times,
      'notes': notes,
      'category': category,
    };
  }
}
