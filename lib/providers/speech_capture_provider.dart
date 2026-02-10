import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/speech/speech_capture_service.dart';

class LiveSpeechState {
  const LiveSpeechState({
    this.isListening = false,
    this.lastChunk,
    this.errorMessage,
  });

  final bool isListening;
  final String? lastChunk;
  final String? errorMessage;

  LiveSpeechState copyWith({
    bool? isListening,
    String? lastChunk,
    String? errorMessage,
  }) {
    return LiveSpeechState(
      isListening: isListening ?? this.isListening,
      lastChunk: lastChunk ?? this.lastChunk,
      errorMessage: errorMessage,
    );
  }
}

class LiveSpeechNotifier extends StateNotifier<LiveSpeechState> {
  LiveSpeechNotifier(this._service) : super(const LiveSpeechState());

  final SpeechCaptureService _service;

  Future<void> toggle() async {
    if (state.isListening) {
      await _service.stopListening();
      state = state.copyWith(isListening: false);
      return;
    }

    final ok = await _service.initialize();
    if (!ok) {
      state = state.copyWith(
        errorMessage: 'Speech recognition not available on this device.',
      );
      return;
    }

    state = state.copyWith(isListening: true, errorMessage: null);

    await _service.startListening((text) async {
      state = state.copyWith(lastChunk: text);
      await _sendChunkToSupabase(text);
    });
  }

  Future<void> _sendChunkToSupabase(String text) async {
    final client = Supabase.instance.client;
    try {
      await client.from('speech').insert({
        'speech_text': text,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to send speech chunk: $e',
      );
    }
  }
}

final liveSpeechCaptureProvider =
    StateNotifierProvider<LiveSpeechNotifier, LiveSpeechState>((ref) {
  final service = SpeechCaptureService();
  return LiveSpeechNotifier(service);
});

