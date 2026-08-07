import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/medication.dart';
import '../models/reminder.dart';
import '../services/api_service.dart';
import 'medications_screen.dart';
import 'reminders_screen.dart';
import 'caregiver_screen.dart';
import 'onboarding_screen.dart';
import 'ocr_scan_screen.dart';
import 'admin_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Medication> _medications = [];
  Reminder? _activeAIReminder;
  bool _isLoading = true;
  bool _doseConfirmed = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final meds = await _apiService.fetchMedications();
    Reminder? reminder;
    if (meds.isNotEmpty) {
      reminder = await _apiService.generateAIReminder(meds.first, routinePersona: 'Senior Citizen');
    }
    setState(() {
      _medications = meds;
      _activeAIReminder = reminder;
      _isLoading = false;
    });
  }

  Future<void> _handleConfirmDose() async {
    if (_activeAIReminder != null) {
      await _apiService.confirmDose(_activeAIReminder!.reminderId);
      setState(() {
        _doseConfirmed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ Great job! Your dose has been recorded.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: DoseBuddyTheme.successGreen,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DoseBuddy AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            tooltip: 'User Profile',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh Reminders',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: DoseBuddyTheme.primaryTeal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Elderly Welcome Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: DoseBuddyTheme.primaryTeal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Good Morning, Arthur 👋',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Here is your personalized diabetic medication schedule for today.',
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Active Gemini AI Reminder Card
                  if (_activeAIReminder != null) ...[
                    Card(
                      color: _doseConfirmed ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _doseConfirmed ? Icons.check_circle : Icons.auto_awesome,
                                  color: _doseConfirmed ? DoseBuddyTheme.successGreen : DoseBuddyTheme.accentAmber,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _doseConfirmed ? 'Dose Taken Successfully' : 'Next Dose Reminder (AI)',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: _doseConfirmed ? DoseBuddyTheme.successGreen : DoseBuddyTheme.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24, thickness: 1.5),
                            Text(
                              _activeAIReminder!.personalizedMessage,
                              style: const TextStyle(fontSize: 20, height: 1.4, color: DoseBuddyTheme.textDark),
                            ),
                            const SizedBox(height: 20),

                            // Single Tap Confirm Button
                            if (!_doseConfirmed)
                              ElevatedButton.icon(
                                onPressed: _handleConfirmDose,
                                icon: const Icon(Icons.check_box, size: 30),
                                label: const Text('I TOOK MY MEDICINE'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DoseBuddyTheme.successGreen,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(65),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                              )
                            else
                              const Center(
                                child: Text(
                                  'Caregivers notified of confirmation 👍',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: DoseBuddyTheme.successGreen),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Quick Action Grid
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.medication,
                          label: 'My Medicines',
                          color: DoseBuddyTheme.primaryTeal,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicationsScreen())),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.smart_toy,
                          label: 'AI Reminders',
                          color: DoseBuddyTheme.accentAmber,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen())),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.qr_code_scanner,
                          label: 'OCR Scanner',
                          color: Colors.purple,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OCRScanScreen())),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.tune,
                          label: 'Persona Onboarding',
                          color: Colors.teal,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen())),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.contact_emergency,
                          label: 'Caregiver Alerts',
                          color: const Color(0xFF1565C0),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CaregiverScreen())),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.admin_panel_settings,
                          label: 'Admin Analytics',
                          color: Colors.deepOrange,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen())),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
