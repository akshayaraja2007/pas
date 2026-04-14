import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  VoiceService()
      : _speechToText = SpeechToText(),
        _flutterTts = FlutterTts();

  final SpeechToText _speechToText;
  final FlutterTts _flutterTts;
  bool _isInitialized = false;

  Future<void> _init() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _isInitialized = true;
  }

  Future<void> listen({required Function(String text) onResult}) async {
    await _init();
    final available = await _speechToText.initialize();

    if (!available) {
      onResult('Speech recognition unavailable on this device.');
      return;
    }

    await _speechToText.listen(
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      onResult: (result) {
        final words = result.recognizedWords.trim();
        if (words.isNotEmpty) {
          onResult(words);
        }
      },
    );
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  Future<void> speak(String text) async {
    await _init();
    if (text.trim().isEmpty) return;
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> dispose() async {
    await stopListening();
    await _flutterTts.stop();
  }
}
