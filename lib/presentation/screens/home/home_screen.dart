import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/announcement_provider.dart';
import '../../../providers/providers.dart';
import '../../../data/models/announcement_model.dart';
import '../../../core/utils/logger.dart';
import '../../../providers/saved_announcements_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isRecording = false;
  String? _filePath;
  String? _currentlyPlayingId;

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://roofless-unmelodramatically-sharita.ngrok-free.dev',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
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
        
        final announcement = AnnouncementModel(
          name: "Station Announcement",
          speechRecognized: data['llm_output'] ?? '',
          priority: data['priority']?.toString() ?? 'Low',
          time: DateTime.now().toIso8601String(),
        );

        await ref.read(apiServiceProvider).uploadAnnouncement(announcement.toJson());
      }
    } catch (e, s) {
      AppLogger.debug("Error sending audio", e, s);
    }
  }

  void _clearAllAnnouncements() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Announcements'),
        content: const Text('Are you sure you want to clear all announcements? This will remove them permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // In a real app, you might want a batch delete API.
              // For now, we'll just show the user how to clear them if needed.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete functionality coming soon')),
              );
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
    final announcementsAsync = ref.watch(announcementsRealtimeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcements"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAllAnnouncements,
            tooltip: 'Clear all announcements',
          ),
        ],
      ),
      body: announcementsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                "No announcements yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final ann = list[index];
              final announcementId = ann.id ?? index.toString();
              final isSaved = ref.watch(savedAnnouncementsProvider).value?.any((e) => e.id == ann.id) ?? false;

              return AnnouncementCard(
                announcement: ann,
                isFavorite: isSaved,
                onFavorite: () => ref.read(savedAnnouncementsProvider.notifier).toggleSave(ann),
                onPlayVoice: () => _playAnnouncement(
                  ann.speechRecognized,
                  announcementId,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading announcements: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isRecording ? _stopRecording : _startRecording,
        backgroundColor: _isRecording ? Colors.red : Colors.blue.shade700,
        child: Icon(_isRecording ? Icons.stop : Icons.mic),
      ),
    );
  }
}