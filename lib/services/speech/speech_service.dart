import 'package:flutter_tts/flutter_tts.dart';

import '../../core/utils/logger.dart';

/// Text-to-speech service for accessibility
class SpeechService {
  SpeechService() : _tts = FlutterTts();

  final FlutterTts _tts;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    try {
      await init();
      await _tts.speak(text);
    } catch (e, s) {
      AppLogger.debug('TTS speak failed', e, s);
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<bool> isSpeaking() async {
    return false;
  }

  Future<void> setLanguage(String language) async {
    await _tts.setLanguage(language);
  }

  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }
}
