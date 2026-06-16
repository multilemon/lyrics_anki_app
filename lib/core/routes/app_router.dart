import 'package:go_router/go_router.dart';
import 'package:lyrics_anki_app/features/home/presentation/pages/home_page.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/pages/lyrics_page.dart';
import 'package:lyrics_anki_app/features/settings/presentation/pages/language_selection_page.dart';
import 'package:lyrics_anki_app/features/srs/presentation/pages/srs_review_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'lyrics',
            name: 'lyrics',
            builder: (context, state) {
              final title = state.uri.queryParameters['title'];
              final artist = state.uri.queryParameters['artist'];
              final language = state.uri.queryParameters['language'];
              return LyricsPage(
                title: title,
                artist: artist,
                language: language,
              );
            },
          ),
          GoRoute(
            path: 'review',
            name: 'review',
            builder: (context, state) => const SrsReviewPage(),
          ),
          GoRoute(
            path: 'language',
            name: 'language',
            builder: (context, state) => const LanguageSelectionPage(),
          ),
        ],
      ),
    ],
  );
}
