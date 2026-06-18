import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/services/analytics_service.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/core/utils/jlpt_utils.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/interactive_lookup_sheet.dart';
import 'package:lyrics_anki_app/features/settings/presentation/providers/jlpt_level_notifier.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';

class Match {
  Match(this.start, this.end, this.data, this.index, this.type);
  final int start;
  final int end;
  final dynamic data;
  final int index;
  final String type;
}

class LyricsView extends ConsumerWidget {
  const LyricsView({required this.analysis, super.key});

  final AnalysisResult analysis;

  Color _getColor(String type) {
    switch (type) {
      case 'vocab':
        return AppColors.sakura;
      case 'grammar':
        return AppColors.accent;
      case 'kanji':
        return AppColors.peach;
      default:
        return AppColors.textPrimary;
    }
  }

  void _showPopup(BuildContext context, Match match) {
    String word;
    if (match.type == 'vocab') {
      word = (match.data as Vocab).word;
    } else if (match.type == 'grammar') {
      word = (match.data as Grammar).point;
    } else {
      word = (match.data as Kanji).char;
    }
    analyticsService.logItemView(
      type: match.type,
      item: word,
      source: 'lyrics_highlight',
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => InteractiveLookupSheet(
        type: match.type,
        data: match.data,
        analysis: analysis,
      ),
    );
  }

  String _cleanLyrics(String rawLyrics) {
    // Strip timestamps like [00:15.30] or [00:15.300]
    return rawLyrics.replaceAll(RegExp(r'\[\d{2}:\d{2}\.\d{2,3}\]'), '');
  }

  List<TextSpan> _buildSpans(BuildContext context, WidgetRef ref) {
    final jlptLevel = ref.watch(jlptLevelProvider);

    bool shouldShow(String level) {
      return shouldShowJlpt(level, jlptLevel);
    }

    final lyrics = _cleanLyrics(analysis.lyrics);
    final spans = <TextSpan>[];
    if (lyrics.isEmpty) return spans;

    final matches = <Match>[];

    String cleanText(String input, String type) {
      if (type != 'grammar') return input.trim();
      return input
          .replaceAll(RegExp(r'^[A-Za-z]+\.'), '')
          .replaceAll('~', '')
          .replaceAll('～', '')
          .trim();
    }

    void addMatches(
      List<dynamic> items,
      String type,
      String Function(dynamic) getText,
    ) {
      for (var i = 0; i < items.length; i++) {
        final rawText = getText(items[i]);
        var text = rawText.trim();

        if (type == 'grammar' && !lyrics.contains(text)) {
          text = cleanText(rawText, type);
        }

        if (text.isEmpty) continue;

        var start = 0;
        while (true) {
          final idx = lyrics.indexOf(text, start);
          if (idx == -1) break;
          matches.add(Match(idx, idx + text.length, items[i], i, type));
          start = idx + 1;
        }
      }
    }

    addMatches(
      analysis.vocabs.where((v) => shouldShow(v.jlptV)).toList(),
      'vocab',
      (d) => (d as Vocab).word,
    );
    addMatches(
      analysis.grammar.where((g) => shouldShow(g.level)).toList(),
      'grammar',
      (d) => (d as Grammar).point,
    );
    addMatches(
      analysis.kanji.where((k) => shouldShow(k.level)).toList(),
      'kanji',
      (d) => (d as Kanji).char,
    );

    // Sort: Start Time asc, Length desc (Longest match wins)
    matches.sort((a, b) {
      if (a.start != b.start) return a.start.compareTo(b.start);
      return b.end.compareTo(a.end);
    });

    final validMatches = <Match>[];
    var lastEnd = 0;
    for (final m in matches) {
      if (m.start >= lastEnd) {
        validMatches.add(m);
        lastEnd = m.end;
      }
    }

    var currentIndex = 0;
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodyLarge?.copyWith(
      height: 1.8,
      fontSize: 16,
    );

    for (final m in validMatches) {
      if (m.start > currentIndex) {
        spans.add(
          TextSpan(
            text: lyrics.substring(currentIndex, m.start),
            style: baseStyle,
          ),
        );
      }

      final color = _getColor(m.type);
      spans.add(
        TextSpan(
          text: lyrics.substring(m.start, m.end),
          style: baseStyle?.copyWith(
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            decorationColor: color,
            decorationStyle: TextDecorationStyle.solid,
            decorationThickness: 2,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _showPopup(context, m),
        ),
      );

      currentIndex = m.end;
    }

    if (currentIndex < lyrics.length) {
      spans.add(
        TextSpan(
          text: lyrics.substring(currentIndex),
          style: baseStyle,
        ),
      );
    }

    return spans;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (analysis.lyrics.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noLyricsAvailable,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 88,
      ),
      child: SelectableText.rich(
        TextSpan(
          children: _buildSpans(context, ref),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
