import 'package:web/web.dart' as web;

class TtsService {
  TtsService._();

  static void speak(String text) {
    try {
      final synth = web.window.speechSynthesis;
      final utterance = web.SpeechSynthesisUtterance(text);
      utterance.lang = 'ja-JP';
      synth.speak(utterance);
    } on Object catch (_) {
      // Ignore
    }
  }
}
