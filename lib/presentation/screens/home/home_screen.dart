import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../providers/announcement_provider.dart';
import '../../../providers/providers.dart';
import '../../../data/models/announcement_model.dart';
import '../../../core/utils/logger.dart';
import '../../../providers/saved_announcements_provider.dart';
import '../filters/train_filter_screen.dart';
import '../../widgets/announcement_card.dart';

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

  late final Dio dio;

  @override
  void initState() {
    super.initState();
    final backendUrl = dotenv.env['BACKEND_URL'] ?? 'https://echo-0jga.onrender.com';
    dio = Dio(
      BaseOptions(
        baseUrl: backendUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error processing voice: ${e.toString()}")),
        );
      }
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
            icon: const Icon(Icons.search),
            onPressed: () async {
              final trainService = ref.read(trainServiceProvider);
              await trainService.initialize();
              if (mounted) {
                final selectedTrain = await showSearch(
                  context: context,
                  delegate: TrainSearchDelegate(trainService),
                );
                if (selectedTrain != null) {
                  ref.read(trainFilterProvider.notifier).state = selectedTrain.number;
                }
              }
            },
            tooltip: 'Search by train',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAllAnnouncements,
            tooltip: 'Clear all announcements',
          ),
        ],
      ),
      body: Column(
        children: [
          // Active Filter Chip
          Consumer(
            builder: (context, ref, _) {
              final filter = ref.watch(trainFilterProvider);
              if (filter == 'All' || filter.isEmpty) return const SizedBox.shrink();
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Filtered by Train: $filter',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => ref.read(trainFilterProvider.notifier).state = 'All',
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: announcementsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      "No matching announcements",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isRecording ? _stopRecording : _startRecording,
        backgroundColor: _isRecording ? Colors.red : Colors.blue.shade700,
        child: Icon(_isRecording ? Icons.stop : Icons.mic),
      ),
    );
  }
}