import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/caregiver.dart';
import '../services/api_service.dart';

class CaregiverScreen extends StatefulWidget {
  const CaregiverScreen({Key? key}) : super(key: key);

  @override
  State<CaregiverScreen> createState() => _CaregiverScreenState();
}

class _CaregiverScreenState extends State<CaregiverScreen> {
  final ApiService _apiService = ApiService();
  List<Caregiver> _caregivers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCaregivers();
  }

  Future<void> _loadCaregivers() async {
    setState(() => _isLoading = true);
    final list = await _apiService.fetchCaregivers();
    setState(() {
      _caregivers = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregivers & Escalations'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1976D2)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.shield, color: Color(0xFF1976D2), size: 36),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'If a medication dose is not confirmed within 30 minutes, DoseBuddy sends instant push alerts to registered caregivers.',
                            style: TextStyle(fontSize: 16, color: Color(0xFF0D47A1), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Registered Caregivers',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._caregivers.map(
                    (cg) => Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: DoseBuddyTheme.primaryTeal,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(cg.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        subtitle: Text('${cg.email}\nPhone: ${cg.phoneNumber}', style: const TextStyle(fontSize: 16)),
                        trailing: const Icon(Icons.notifications_active, color: DoseBuddyTheme.successGreen, size: 28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
