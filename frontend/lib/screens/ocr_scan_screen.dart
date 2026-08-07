import 'package:flutter/material.dart';
import '../core/theme.dart';

class OCRScanScreen extends StatefulWidget {
  const OCRScanScreen({Key? key}) : super(key: key);

  @override
  State<OCRScanScreen> createState() => _OCRScanScreenState();
}

class _OCRScanScreenState extends State<OCRScanScreen> {
  bool _isScanning = false;
  Map<String, dynamic>? _scannedResult;

  void _simulateScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isScanning = false;
      _scannedResult = {
        "name": "Metformin 850mg Extended-Release",
        "dosage": "1 Tablet",
        "frequency": "2 times per day",
        "meal_relation": "With evening meal",
        "category": "Diabetes",
        "confidence": "96%"
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription & Label Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: DoseBuddyTheme.primaryTeal, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera_alt, size: 64, color: DoseBuddyTheme.primaryTeal),
                  SizedBox(height: 12),
                  Text('Align medicine bottle or prescription label here', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: DoseBuddyTheme.primaryTeal,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isScanning ? null : _simulateScan,
              icon: _isScanning
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: Text(_isScanning ? 'Scanning via Gemini Vision AI...' : 'Scan Prescription Label', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            if (_scannedResult != null) ...[
              const SizedBox(height: 28),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified, color: DoseBuddyTheme.successGreen, size: 28),
                          const SizedBox(width: 8),
                          Text('AI Scan Parsed (${_scannedResult!['confidence']})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 24),
                      Text('Medication: ${_scannedResult!['name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('Dosage: ${_scannedResult!['dosage']}'),
                      const SizedBox(height: 6),
                      Text('Timing: ${_scannedResult!['meal_relation']} (${_scannedResult!['frequency']})'),
                      const SizedBox(height: 6),
                      Text('Category: ${_scannedResult!['category']}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: DoseBuddyTheme.accentBlue),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medication added to schedule!')));
                          Navigator.pop(context);
                        },
                        child: const Text('Add to My Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
