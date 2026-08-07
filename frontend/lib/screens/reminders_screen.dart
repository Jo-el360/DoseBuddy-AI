import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/medication.dart';
import '../models/reminder.dart';
import '../services/api_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final ApiService _apiService = ApiService();
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  // TTS Simulation State
  String? _currentlyPlayingId;
  double _playbackProgress = 0.0;
  double _speechRate = 1.0;
  Timer? _ttsTimer;

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  @override
  void dispose() {
    _ttsTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchReminders() async {
    setState(() => _isLoading = true);
    final meds = await _apiService.fetchMedications();
    List<Reminder> generated = [];
    for (var med in meds) {
      final rem = await _apiService.generateAIReminder(med);
      generated.add(rem);
    }
    setState(() {
      _reminders = generated;
      _isLoading = false;
    });
  }

  void _toggleTtsPlayback(Reminder reminder) {
    if (_currentlyPlayingId == reminder.reminderId) {
      // Pause / Stop
      _ttsTimer?.cancel();
      setState(() {
        _currentlyPlayingId = null;
        _playbackProgress = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio playback stopped.')),
      );
    } else {
      // Start playback
      _ttsTimer?.cancel();
      setState(() {
        _currentlyPlayingId = reminder.reminderId;
        _playbackProgress = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔊 Speaking at ${_speechRate}x speed: "${reminder.audioScript}"'),
          duration: const Duration(seconds: 4),
        ),
      );

      final intervalMs = (100 / _speechRate).round();
      _ttsTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _playbackProgress += 0.04;
          if (_playbackProgress >= 1.0) {
            _playbackProgress = 1.0;
            _currentlyPlayingId = null;
            timer.cancel();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini AI Reminders'),
        actions: [
          PopupMenuButton<double>(
            icon: const Icon(Icons.speed, size: 28),
            tooltip: 'Speech Speed Rate',
            initialValue: _speechRate,
            onSelected: (rate) {
              setState(() => _speechRate = rate);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('TTS Speech Speed set to ${rate}x')),
              );
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 0.75, child: Text('0.75x (Slower for Elderly)')),
              PopupMenuItem(value: 1.0, child: Text('1.0x (Normal)')),
              PopupMenuItem(value: 1.25, child: Text('1.25x (Faster)')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final rem = _reminders[index];
                final isPlaying = _currentlyPlayingId == rem.reminderId;

                return Card(
                  color: const Color(0xFFFAF8F5),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: DoseBuddyTheme.accentAmber, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              rem.medicationName,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: DoseBuddyTheme.primaryTeal.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                rem.scheduledTime,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: DoseBuddyTheme.primaryTeal),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          rem.personalizedMessage,
                          style: const TextStyle(fontSize: 18, height: 1.4),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isPlaying ? Colors.blue.withOpacity(0.15) : Colors.blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: isPlaying ? Border.all(color: Colors.blue, width: 2) : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                      color: Colors.blue,
                                      size: 36,
                                    ),
                                    onPressed: () => _toggleTtsPlayback(rem),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Audio Script: "${rem.audioScript}"',
                                          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                                        ),
                                        if (isPlaying) ...[
                                          const SizedBox(height: 6),
                                          LinearProgressIndicator(
                                            value: _playbackProgress,
                                            backgroundColor: Colors.blue.withOpacity(0.2),
                                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (isPlaying) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.graphic_eq, color: Colors.blue, size: 24),
                                    SizedBox(width: 6),
                                    Text('AI Voice Speaking...', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
