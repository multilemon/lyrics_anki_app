import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logSongAnalysis({
    required String songTitle,
    required String artist,
    required String language,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'analyze_song',
        parameters: {
          'song_title': songTitle,
          'artist': artist,
          'language': language,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logExport({
    required String songTitle,
    required String artist,
    required String level,
    required int vocabCount,
    required int grammarCount,
    required int kanjiCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'export_anki',
        parameters: {
          'song_title': songTitle,
          'artist': artist,
          'jlpt_level': level,
          'vocab_count': vocabCount,
          'grammar_count': grammarCount,
          'kanji_count': kanjiCount,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logError(String error, [String? context]) async {
    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_message': error,
          if (context != null) 'context': context,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }
}

// Global provider (simple DI, or use Riverpod if preferred, but this is stateless mostly)
final analyticsService = AnalyticsService();
