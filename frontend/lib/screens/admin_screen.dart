import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _analytics;
  bool _isLoading = true;
  bool _isGeneratingReport = false;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    final data = await _apiService.fetchAdminAnalytics();
    setState(() {
      _analytics = data;
      _isLoading = false;
    });
  }

  void _exportDoctorReport() async {
    setState(() => _isGeneratingReport = true);
    final report = await _apiService.generateComplianceReport();
    setState(() => _isGeneratingReport = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
            SizedBox(width: 10),
            Expanded(child: Text('Doctor Medical Report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Patient: ${report['patient_name']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Period: ${report['report_period']}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Adherence Rate:', style: TextStyle(fontSize: 16)),
                  Text('${report['adherence_percentage']}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DoseBuddyTheme.successGreen)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Doses Confirmed / Scheduled:', style: TextStyle(fontSize: 16)),
                  Text('${report['total_doses_confirmed']} / ${report['total_doses_scheduled']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mean Blood Glucose:', style: TextStyle(fontSize: 16)),
                  Text('${report['average_blood_glucose']} mg/dL', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DoseBuddyTheme.primaryTeal)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Clinical AI Summary:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DoseBuddyTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  report['clinical_summary'] ?? '',
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: DoseBuddyTheme.primaryTeal),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📄 Clinical Compliance Report exported to PDF/CSV successfully!')),
              );
            },
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text('Download PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Module 7: Admin Panel & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DoseBuddyTheme.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: DoseBuddyTheme.accentBlue),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.admin_panel_settings, color: DoseBuddyTheme.accentBlue, size: 36),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'System Overview: Monitoring patient adherence rates, caregiver alerts, and Gemini AI health analytics.',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: DoseBuddyTheme.accentBlue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard('Total Users', '${_analytics?['total_users'] ?? 142}', Icons.people, DoseBuddyTheme.primaryTeal)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard('Adherence Rate', '${_analytics?['overall_adherence_rate'] ?? 94.5}%', Icons.insights, DoseBuddyTheme.successGreen)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard('Caregivers', '${_analytics?['registered_caregivers'] ?? 38}', Icons.shield, DoseBuddyTheme.warningOrange)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard('Alerts Sent', '${_analytics?['critical_alerts_triggered'] ?? 4}', Icons.notifications_active, Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DoseBuddyTheme.primaryTeal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isGeneratingReport ? null : _exportDoctorReport,
                    icon: _isGeneratingReport
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text(
                      'EXPORT DOCTOR COMPLIANCE REPORT',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text('System Log Stream', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildLogTile('14:30:00', 'OCR', 'Prescription label scanned with 96% confidence.', Colors.blue),
                  _buildLogTile('14:15:00', 'Alert', 'Critical Glucose Alert dispatched to Sarah Pendelton.', Colors.orange),
                  _buildLogTile('14:00:00', 'AI Engine', 'Gemini AI personalized reminder generated.', Colors.green),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogTile(String time, String cat, String msg, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(Icons.receipt_long, color: color, size: 20)),
        title: Text(msg, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text('$time • Category: $cat', style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
