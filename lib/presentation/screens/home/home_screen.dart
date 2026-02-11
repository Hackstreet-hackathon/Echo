import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/announcement_model.dart';
import '../../../providers/announcement_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/providers.dart';
import '../../../providers/speech_capture_provider.dart';

import '../../widgets/announcement_banner.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/retry_button.dart';
import '../../widgets/skeleton_loader.dart';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  AnnouncementModel? _latestBanner;
  bool _bannerDismissed = false;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  /* ---------------- RECORDER SETUP ---------------- */

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException(
          "Microphone permission not granted");
    }

    await _recorder.openRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  /* ---------------- START RECORDING ---------------- */

  Future<void> _startRecording() async {
    final dir = await getTemporaryDirectory();
    _audioPath = '${dir.path}/recorded_audio.wav';

    await _recorder.startRecorder(
      toFile: _audioPath,
      codec: Codec.pcm16WAV,
    );

    setState(() => _isRecording = true);

    print("Recording started...");
  }

  /* ---------------- STOP RECORDING ---------------- */

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() => _isRecording = false);

    print("Recording stopped.");

    if (_audioPath != null) {
      print("Recording saved at: $_audioPath");

      final file = File(_audioPath!);
      print("File exists: ${file.existsSync()}");

      if (file.existsSync()) {
        print("File size: ${file.lengthSync()} bytes");
      }
    }
  }

  /* ---------------- TEXT TO SPEECH ---------------- */

  void _playVoice(String text) {
    ref.read(speechServiceProvider).speak(text);
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    final announcements = ref.watch(announcementsRealtimeProvider);
    final connectivity = ref.watch(connectivityServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('ECHO'),
        actions: [
          if (!connectivity.isConnected)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text('Offline',
                    style: TextStyle(fontSize: 12)),
                backgroundColor:
                    AppColors.warning.withOpacity(0.2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/feed'),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => context.push('/train-filter'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_latestBanner != null && !_bannerDismissed)
            AnnouncementBanner(
              announcement: _latestBanner!,
              onDismiss: () =>
                  setState(() => _bannerDismissed = true),
              onPlayVoice: () =>
                  _playVoice(_latestBanner!.speechRecognized),
            ),
          Expanded(
            child: announcements.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text("No announcements yet"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final a = list[i];
                    return AnnouncementCard(
                      announcement: a,
                      onPlayVoice: () =>
                          _playVoice(a.speechRecognized),
                      onFavorite: () async {
                        await ref
                            .read(cacheServiceProvider)
                            .addToFavorites(a);
                        await ref
                            .read(cacheServiceProvider)
                            .addToHistory(a);
                      },
                      showPwdBadge: true,
                    );
                  },
                );
              },
              loading: () => const SkeletonLoader(),
              error: (e, _) =>
                  const Center(child: Text("Error loading")),
            ),
          ),
        ],
      ),

      /* -------- RECORD BUTTON -------- */

      floatingActionButton: FloatingActionButton(
        backgroundColor:
            _isRecording ? Colors.red : Colors.blue,
        onPressed: () {
          if (_isRecording) {
            _stopRecording();
          } else {
            _startRecording();
          }
        },
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
        ),
      ),
    );
  }
}
