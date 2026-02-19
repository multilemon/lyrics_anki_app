import 'package:lyrics_anki_app/features/home/presentation/providers/home_ui_providers.dart';
import 'package:lyrics_anki_app/features/lyrics/data/lyrics_repository.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_notifier.g.dart';

@Riverpod(keepAlive: true)
class HistoryNotifier extends _$HistoryNotifier {
  @override
  FutureOr<List<HistoryItem>> build() async {
    final repo = ref.watch(lyricsRepositoryProvider);
    final mode = ref.watch(learningModeProvider);

    // Observe database changes in real-time
    final subscription = repo.watchHistory(mode: mode).listen((items) {
      state = AsyncValue.data(items);
    });
    ref.onDispose(subscription.cancel);

    return repo.getHistory(mode: mode);
  }

  Future<void> addHistoryItem(
    String title,
    String artist,
    String snippet,
    String language,
  ) async {
    final newItem = HistoryItem(
      songTitle: title,
      artist: artist,
      lyricsSnippet:
          snippet.length > 50 ? '${snippet.substring(0, 50)}...' : snippet,
      analyzedAt: DateTime.now(),
      tags: [],
      targetLanguage: language,
    );

    await ref.read(lyricsRepositoryProvider).saveToHistory(newItem);
  }
}
