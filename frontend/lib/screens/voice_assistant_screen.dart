import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/api_service.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({Key? key}) : super(key: key);

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _voiceInputController = TextEditingController();
  bool _isListening = false;
  bool _isProcessing = false;
  String? _lastSpokenResponse;

  final List<String> _samplePrompts = [
    'I took my morning insulin dose',
    'Help! My blood sugar feels low and I am dizzy',
    'What is my next medication time?',
    'Logged 124 mg/dL blood glucose',
  ];

  void _processVoicePrompt(String prompt) async {
    setState(() {
      _isProcessing = true;
      _voiceInputController.text = prompt;
    });

    final res = await _apiService.sendVoiceCommand(prompt);

    setState(() {
      _isProcessing = false;
      _lastSpokenResponse = res['spoken_response'];
    });

    if (res['command_type'] == 'EMERGENCY_SOS') {
      _triggerSos();
    }
  }

  void _triggerSos() async {
    final sosRes = await _apiService.triggerEmergencySOS(reason: 'Voice SOS / User Emergency');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.red.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_rounded, color: Colors.white, size: 36),
            SizedBox(width: 8),
            Expanded(child: Text('EMERGENCY SOS DISPATCHED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
          ],
        ),
        content: Text(
          sosRes['message'] ?? 'Caregivers and Emergency contact notified.',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('DISMISS', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Module 8: AI Voice & SOS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Emergency SOS Banner Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
              ),
              onPressed: _triggerSos,
              icon: const Icon(Icons.sos_rounded, color: Colors.white, size: 36),
              label: const Text(
                'EMERGENCY SOS (TAP TO ALERT CAREGIVER)',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'Hands-Free Voice Assistant',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Speak naturally or tap a sample command below. Gemini AI executes your intent and reads back a spoken response.',
              style: TextStyle(fontSize: 15, color: Colors.black60),
            ),
            const SizedBox(height: 20),

            // Voice Microphone Button
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() => _isListening = !_isListening);
                  if (!_isListening && _voiceInputController.text.isNotEmpty) {
                    _processVoicePrompt(_voiceInputController.text);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.red.shade400 : DoseBuddyTheme.primaryTeal,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? Colors.red : DoseBuddyTheme.primaryTeal).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _isListening ? 'Listening... Speak your command' : 'Tap Microphone to Speak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isListening ? Colors.red : DoseBuddyTheme.primaryTeal,
                ),
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _voiceInputController,
              decoration: InputDecoration(
                hintText: 'Or type voice command here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: DoseBuddyTheme.primaryTeal),
                  onPressed: () {
                    if (_voiceInputController.text.isNotEmpty) {
                      _processVoicePrompt(_voiceInputController.text);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Sample Voice Commands:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _samplePrompts.map((prompt) {
                return ActionChip(
                  backgroundColor: DoseBuddyTheme.primaryTeal.withOpacity(0.1),
                  label: Text(prompt, style: const TextStyle(fontSize: 14, color: DoseBuddyTheme.primaryTeal, fontWeight: FontWeight.w600)),
                  onPressed: () => _processVoicePrompt(prompt),
                );
              }).toList(),
            ),

            if (_isProcessing) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],

            if (_lastSpokenResponse != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.volume_up, color: Colors.blue, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('AI Voice Response:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          const SizedBox(height: 4),
                          Text(
                            '"$_lastSpokenResponse"',
                            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
