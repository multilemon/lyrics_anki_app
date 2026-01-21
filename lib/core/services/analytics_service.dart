import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logSongAnalysis({
    required String songTitle,
    required String artist,
    required String language,
  }) async {
    const name = 'analyze_song';
    final parameters = {
      'song_title': songTitle,
      'artist': artist,
      'language': language,
    };

    _logToConsole(name, parameters);

    try {
      await _analytics.logEvent(name: name, parameters: parameters);
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
    const name = 'export_anki';
    final parameters = {
      'song_title': songTitle,
      'artist': artist,
      'jlpt_level': level,
      'vocab_count': vocabCount,
      'grammar_count': grammarCount,
      'kanji_count': kanjiCount,
    };

    _logToConsole(name, parameters);

    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logError(String error, [String? context]) async {
    const name = 'app_error';
    final parameters = {
      'error_message': error,
      if (context != null) 'context': context,
    };

    _logToConsole(name, parameters);

    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  void _logToConsole(String name, Map<String, dynamic> parameters) {
    if (kDebugMode) {
      final prettyJson = const JsonEncoder.withIndent('  ').convert(parameters);
      debugPrint('\n📊 Analytics Request: $name\n$prettyJson\n');
    }
  }
}

// Global provider (simple DI, or use Riverpod if preferred, but this is stateless mostly)
final analyticsService = AnalyticsService();
