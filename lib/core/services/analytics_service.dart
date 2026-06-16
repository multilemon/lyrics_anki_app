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
    const name = 'search_song'; // Standardized name
    final parameters = {
      'search_term': '$songTitle $artist', // Standard parameter
      'song_title': songTitle,
      'artist': artist,
      'language': language,
    };

    _logToConsole(name, parameters);

    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } on Exception catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logAnalysisComplete({
    required String songTitle,
    required String artist,
    required int vocabCount,
    required int grammarCount,
    required int kanjiCount,
    required int durationMs,
  }) async {
    const name = 'analysis_complete';
    final parameters = {
      'song_title': songTitle,
      'artist': artist,
      'vocab_count': vocabCount,
      'grammar_count': grammarCount,
      'kanji_count': kanjiCount,
      'total_items': vocabCount + grammarCount + kanjiCount,
      'duration_ms': durationMs,
    };

    _logToConsole(name, parameters);

    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } on Exception catch (e) {
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
      'card_count': vocabCount + grammarCount + kanjiCount,
    };

    _logToConsole(name, parameters);

    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } on Exception catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logItemView({
    required String type, // vocab, grammar, kanji
    required String item,
    required String source, // list_view, lyrics_highlight
  }) async {
    const name = 'select_content'; // Standard Firebase event name
    final parameters = {
      'content_type': type,
      'item_id': item,
      'method': source,
    };

    _logToConsole(name, parameters);

    try {
      await _analytics.logSelectContent(
        contentType: type,
        itemId: item,
      );
      // Also log custom param for method
      await _analytics.logEvent(
        name: 'view_item_detail',
        parameters: parameters,
      );
    } on Exception catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logError(String error, [String? context]) async {
    const name = 'app_exception';
    final parameters = {
      'message': error,
      'context': ?context,
      'fatal': false,
    };

    _logToConsole(name, parameters);

    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } on Exception catch (e) {
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

// Global provider (simple DI, or use Riverpod if preferred,
// but this is stateless mostly)
final analyticsService = AnalyticsService();
