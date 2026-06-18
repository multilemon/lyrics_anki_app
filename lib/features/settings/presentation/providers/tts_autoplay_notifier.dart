import 'package:lyrics_anki_app/core/providers/hive_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_autoplay_notifier.g.dart';

@riverpod
class TtsAutoplayNotifier extends _$TtsAutoplayNotifier {
  static const _kTtsAutoplayKey = 'tts_autoplay_on_flip';

  @override
  bool build() {
    final box = ref.watch(settingsBoxProvider);
    final saved = box?.get(_kTtsAutoplayKey);
    if (saved != null && saved is bool) {
      return saved;
    }
    return false;
  }

  Future<void> setAutoplay(bool enabled) async {
    state = enabled;
    final box = ref.read(settingsBoxProvider);
    await box?.put(_kTtsAutoplayKey, enabled);
  }
}
