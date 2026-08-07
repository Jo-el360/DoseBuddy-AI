import 'package:flutter/material.dart';
import '../core/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPersona = 'Senior Citizen';
  final List<String> _personas = [
    'Senior Citizen',
    'Student',
    'Office Worker',
    'Night Shift Worker',
    'Retired',
    'Traveling'
  ];

  final TextEditingController _ageCtrl = TextEditingController(text: '72');
  final TextEditingController _conditionsCtrl = TextEditingController(text: 'Type 2 Diabetes, Hypertension');
  final TextEditingController _allergiesCtrl = TextEditingController(text: 'Penicillin');
  final TextEditingController _emergencyCtrl = TextEditingController(text: '+15550192834');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalized Onboarding'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DoseBuddyTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DoseBuddyTheme.primaryTeal),
                ),
                child: const Text(
                  'Welcome to DoseBuddy AI! Select your daily routine persona so Gemini AI can generate perfectly timed, natural reminders.',
                  style: TextStyle(fontSize: 16, color: DoseBuddyTheme.primaryTeal, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Daily Routine Persona', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPersona,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_pin, color: DoseBuddyTheme.primaryTeal),
                ),
                items: _personas.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) => setState(() => _selectedPersona = val!),
              ),
              const SizedBox(height: 16),
              const Text('Age', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.cake, color: DoseBuddyTheme.primaryTeal),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Medical Conditions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _conditionsCtrl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.medical_information, color: DoseBuddyTheme.primaryTeal),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Emergency Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emergencyCtrl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone_emergency, color: DoseBuddyTheme.warningOrange),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DoseBuddyTheme.primaryTeal,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Onboarding saved! Profile set to $_selectedPersona.')),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text('Save & Start DoseBuddy AI', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
