import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await _apiService.fetchCurrentUser();
    setState(() {
      _profile = p;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile & Health Summary'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 46,
                          backgroundColor: DoseBuddyTheme.primaryTeal,
                          child: Icon(Icons.person, size: 54, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(_profile?.fullName ?? 'Arthur Pendelton', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(_profile?.email ?? 'patient@example.com', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                        const SizedBox(height: 8),
                        Chip(
                          avatar: const Icon(Icons.star, color: Colors.amber, size: 18),
                          label: Text('Persona: ${_profile?.routinePersona}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: DoseBuddyTheme.primaryTeal.withOpacity(0.1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Health Metrics & Vitals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Divider(),
                          _buildDetailRow('Age / Gender', '${_profile?.age ?? 72} years • ${_profile?.gender ?? "Male"}'),
                          _buildDetailRow('Blood Group', _profile?.bloodGroup ?? 'O+'),
                          _buildDetailRow('Conditions', _profile?.medicalConditions.join(', ') ?? 'Type 2 Diabetes'),
                          _buildDetailRow('Allergies', _profile?.allergies.join(', ') ?? 'Penicillin'),
                          _buildDetailRow('Adherence %', '${_profile?.adherencePercentage ?? 94.5}% Target Adherence'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Emergency Contacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Divider(),
                          _buildDetailRow('Emergency Phone', _profile?.emergencyContact ?? '+15550192834'),
                          _buildDetailRow('Primary Caregiver', _profile?.caregiverContact ?? 'sarah.caregiver@example.com'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
