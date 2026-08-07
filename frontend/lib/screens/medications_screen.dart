import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/medication.dart';
import '../services/api_service.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({Key? key}) : super(key: key);

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final ApiService _apiService = ApiService();
  List<Medication> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() => _isLoading = true);
    final list = await _apiService.fetchMedications();
    setState(() {
      _medications = list;
      _isLoading = false;
    });
  }

"  void _checkRegimenInteractions() async {
    setState(() => _isLoading = true);
    final existingNames = _medications.map((m) => m.name).toList();
    if (existingNames.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No medications registered to check.')),
      );
      return;
    }

    final testMed = existingNames.first;
    final otherMeds = existingNames.sublist(1);
    final result = await _apiService.checkDrugInteractions(testMed, otherMeds);
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result['has_interaction'] == true ? Icons.warning_amber_rounded : Icons.shield_rounded,
              color: result['has_interaction'] == true ? DoseBuddyTheme.warningOrange : DoseBuddyTheme.successGreen,
              size: 32,
            ),
            const SizedBox(width: 8),
            const Expanded(child: Text('Drug Safety Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Severity: ${result['severity'] ?? "None"}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: result['has_interaction'] == true ? DoseBuddyTheme.warningOrange : DoseBuddyTheme.successGreen)),
            const SizedBox(height: 8),
            Text(result['interaction_summary'] ?? 'No interaction detected.', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text('Recommendation: ${result['recommendation'] ?? "Safe"}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddMedicationModal() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final mealRelationController = TextEditingController(text: 'With meals');
    bool checkingSafety = false;
    Map<String, dynamic>? safetyResult;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add New Medication',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      labelText: 'Medication Name (e.g. Glipizide)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dosageController,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      labelText: 'Dosage (e.g. 5mg / 1 Tablet)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: mealRelationController,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      labelText: 'Meal Relation (e.g. Before Breakfast)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: checkingSafety
                        ? null
                        : () async {
                            if (nameController.text.isEmpty) return;
                            setModalState(() => checkingSafety = true);
                            final existing = _medications.map((m) => m.name).toList();
                            final res = await _apiService.checkDrugInteractions(nameController.text, existing);
                            setModalState(() {
                              checkingSafety = false;
                              safetyResult = res;
                            });
                          },
                    icon: const Icon(Icons.psychology_outlined),
                    label: Text(checkingSafety ? 'AI Checking Safety...' : 'Check Drug Interactions with AI'),
                  ),
                  if (safetyResult != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: safetyResult!['has_interaction'] == true
                            ? DoseBuddyTheme.warningOrange.withOpacity(0.15)
                            : DoseBuddyTheme.successGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: safetyResult!['has_interaction'] == true ? DoseBuddyTheme.warningOrange : DoseBuddyTheme.successGreen,
                        ),
                      ),
                      child: Text(
                        '${safetyResult!['severity']}: ${safetyResult!['interaction_summary']}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: safetyResult!['has_interaction'] == true ? DoseBuddyTheme.warningOrange : DoseBuddyTheme.successGreen,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        final newMed = Medication(
                          id: 'med-${DateTime.now().millisecondsSinceEpoch}',
                          name: nameController.text,
                          dosage: dosageController.text.isNotEmpty ? dosageController.text : '1 Dose',
                          frequencyPerDay: 1,
                          mealRelation: mealRelationController.text,
                          times: ['08:00 AM'],
                          notes: 'Custom added medication',
                          category: 'Diabetic Care',
                        );
                        setState(() {
                          _medications.add(newMed);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Medication added successfully!')),
                        );
                      }
                    },
                    child: const Text('SAVE MEDICATION'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medications'),
        actions: [
          IconButton(
            tooltip: 'Check Drug Safety',
            icon: const Icon(Icons.shield_outlined, size: 28),
            onPressed: _checkRegimenInteractions,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMedicationModal,
        backgroundColor: DoseBuddyTheme.accentAmber,
        icon: const Icon(Icons.add, size: 28),
        label: const Text('Add Med', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _medications.length,
              itemBuilder: (context, index) {
                final med = _medications[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              med.name,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: DoseBuddyTheme.primaryTeal),
                            ),
                            Chip(
                              label: Text(med.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              backgroundColor: DoseBuddyTheme.primaryTeal,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Dosage: ${med.dosage}', style: const TextStyle(fontSize: 18)),
                        Text('Meal Instruction: ${med.mealRelation}', style: const TextStyle(fontSize: 18)),
                        Text('Scheduled Times: ${med.times.join(", ")}', style: const TextStyle(fontSize: 18)),
                        if (med.notes != null) ...[
                          const SizedBox(height: 8),
                          Text('Notes: ${med.notes}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
"
