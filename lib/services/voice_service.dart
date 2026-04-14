import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  VoiceService()
      : _speechToText = SpeechToText(),
        _flutterTts = FlutterTts();

  final SpeechToText _speechToText;
  final FlutterTts _flutterTts;

  bool _isInitialized = false;
  bool _isListening = false;

  /// Initialize TTS once
  Future<void> _init() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _isInitialized = true;
  }

  /// 🎤 Start listening (NO WARNINGS VERSION)
  Future<void> listen({required Function(String text) onResult}) async {
    await _init();

    final available = await _speechToText.initialize(
      onStatus: (status) {
        debugPrint("Speech status: $status");
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
      onError: (error) {
        debugPrint("Speech error: $error");
        _isListening = false;
      },
    );

    if (!available) {
      onResult('Speech recognition unavailable.');
      return;
    }

    if (_isListening) return;

    _isListening = true;

    await _speechToText.listen(
      onResult: (result) {
        final text = result.recognizedWords.trim();

        if (text.isNotEmpty) {
          onResult(text);
        }
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        listenMode: ListenMode.confirmation,
      ),
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 3),
    );
  }

  /// 🛑 Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speechToText.stop();
    _isListening = false;
  }

  /// 🔊 Speak text
  Future<void> speak(String text) async {
    await _init();

    if (text.trim().isEmpty) return;

    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  /// ♻ Dispose resources
  Future<void> dispose() async {
    await stopListening();
    await _flutterTts.stop();
  }
}
