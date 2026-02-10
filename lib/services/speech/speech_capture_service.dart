import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Service to capture live speech from the device microphone and
/// expose recognized text chunks to higher layers.
class SpeechCaptureService {
  SpeechCaptureService() : _speech = stt.SpeechToText();

  final stt.SpeechToText _speech;

  bool _available = false;

  bool get isListening => _speech.isListening;
  bool get isAvailable => _available;

  Future<bool> initialize() async {
    if (_available) return true;

    _available = await _speech.initialize(
      onStatus: (status) {
        // status updates can be logged if needed
      },
      onError: (error) {
        // errors can be surfaced via higher-level state if desired
      },
    );
    return _available;
  }

  Future<void> startListening(void Function(String text) onFinalResult) async {
    if (!_available) {
      final ok = await initialize();
      if (!ok) return;
    }

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          onFinalResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }
}

