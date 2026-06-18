import 'package:lyrics_anki_app/core/providers/hive_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'jlpt_level_notifier.g.dart';

@riverpod
class JlptLevelNotifier extends _$JlptLevelNotifier {
  static const _kJlptLevelKey = 'jlpt_calibration_level';

  @override
  String build() {
    final box = ref.watch(settingsBoxProvider);
    final saved = box?.get(_kJlptLevelKey);
    if (saved != null && saved is String) {
      return saved;
    }
    return 'none';
  }

  Future<void> setLevel(String level) async {
    state = level;
    final box = ref.read(settingsBoxProvider);
    await box?.put(_kJlptLevelKey, level);
  }
}
