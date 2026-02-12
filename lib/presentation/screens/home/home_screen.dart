import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isRecording = false;
  String? _filePath;
  List<Map<String, dynamic>> announcements = [];
  String? _currentlyPlayingId;

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://roofless-unmelodramatically-sharita.ngrok-free.dev',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initTts();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    await Permission.microphone.request();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _currentlyPlayingId = null;
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _currentlyPlayingId = null;
      });
    });
  }

  Future<void> _playAnnouncement(String text, String id) async {
    if (_currentlyPlayingId == id) {
      await _flutterTts.stop();
      setState(() {
        _currentlyPlayingId = null;
      });
    } else {
      await _flutterTts.stop();
      setState(() {
        _currentlyPlayingId = id;
      });
      await _flutterTts.speak(text);
    }
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/recorded_audio.wav';
    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.pcm16WAV,
    );
    setState(() {
      _isRecording = true;
      _filePath = path;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });

    if (_filePath != null) {
      await _sendAudio(File(_filePath!));
    }
  }

  Future<void> _sendAudio(File file) async {
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: "audio.wav"),
      });

      final response = await dio.post('/upload_audio', data: formData);

      if (response.statusCode == 200) {
        final data = response.data;

        setState(() {
          announcements.add({
            "id": DateTime.now().millisecondsSinceEpoch.toString(),
            "text": data['llm_output'],
            "priority": data['priority'] ?? 'low',
            "timestamp": DateTime.now(),
          });

          // Sort by priority: high > medium > low
          announcements.sort((a, b) {
            const priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
            return priorityOrder[a['priority']]!.compareTo(priorityOrder[b['priority']]!);
          });
        });
      }
    } catch (e) {
      debugPrint("Error sending audio: $e");
    }
  }

  void _clearAllAnnouncements() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Announcements'),
        content: const Text('Are you sure you want to clear all announcements?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                announcements.clear();
              });
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade100;
      case 'medium':
        return Colors.orange.shade100;
      case 'low':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getPriorityBorderColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'HIGH PRIORITY';
      case 'medium':
        return 'MEDIUM PRIORITY';
      case 'low':
        return 'LOW PRIORITY';
      default:
        return 'UNKNOWN';
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcements"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (announcements.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllAnnouncements,
              tooltip: 'Clear all announcements',
            ),
        ],
      ),
      body: announcements.isEmpty
          ? const Center(
              child: Text(
                "No announcements yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final ann = announcements[index];
                final priority = ann['priority'] as String;
                final announcementId = ann['id'] as String;
                final isPlaying = _currentlyPlayingId == announcementId;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  elevation: 3,
                  color: _getPriorityColor(priority),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _getPriorityBorderColor(priority),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getPriorityBorderColor(priority),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getPriorityLabel(priority),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isPlaying ? Icons.stop_circle : Icons.volume_up,
                                color: _getPriorityBorderColor(priority),
                              ),
                              onPressed: () => _playAnnouncement(
                                ann['text'],
                                announcementId,
                              ),
                              tooltip: isPlaying ? 'Stop' : 'Play announcement',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          ann['text'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Received at: ${ann['timestamp'].toString().substring(11, 19)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isRecording ? _stopRecording : _startRecording,
        backgroundColor: _isRecording ? Colors.red : Colors.blue.shade700,
        child: Icon(_isRecording ? Icons.stop : Icons.mic),
      ),
    );
  }
}