import 'package:lyrics_anki_app/features/lyrics/domain/entities/learning_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_ui_providers.g.dart';

// Signal to clear the Home Page form fields (Song Title, Artist)
// Increment this value to trigger a clear action.
@riverpod
class ClearHomeFormSignal extends _$ClearHomeFormSignal {
  @override
  int build() => 0;

  void increment() => state++;
}

@riverpod
class LearningModeNotifier extends _$LearningModeNotifier {
  @override
  LearningMode build() => LearningMode.japanese;

  void set(LearningMode mode) => state = mode;
}
