import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/learning_mode.dart';

// Signal to clear the Home Page form fields (Song Title, Artist)
// Increment this value to trigger a clear action.
final clearHomeFormSignalProvider = StateProvider<int>((ref) => 0);

final learningModeProvider =
    StateProvider<LearningMode>((ref) => LearningMode.japanese);
