import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  late stt.SpeechToText _speech;  // Marked as late
  bool _isListening = false;

  SpeechService() {
    _speech = stt.SpeechToText();
  }

  Future<void> initSpeech() async {
    _isListening = await _speech.initialize();
  }

  void startListening(Function(String) onResult) {
    if (_isListening) {
      _speech.listen(onResult: (result) {
        onResult(result.recognizedWords);
      });
    }
  }

  void stopListening() {
    _speech.stop();
  }
}
