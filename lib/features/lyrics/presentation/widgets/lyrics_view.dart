import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lyrics_anki_app/core/services/analytics_service.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/grammar_list.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/kanji_list.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/vocab_list.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';
// Add more imports as needed

class Match {
  Match(this.start, this.end, this.data, this.index, this.type);
  final int start;
  final int end;
  final dynamic data;
  final int index;
  final String type;
}

class LyricsView extends StatelessWidget {
  const LyricsView({required this.analysis, super.key});

  final AnalysisResult analysis;

  Color _getColor(String type) {
    switch (type) {
      case 'vocab':
        return AppColors.sakura;
      case 'grammar':
        return AppColors.accent; // Cherry pink for grammar
      case 'kanji':
        return AppColors.peach; // Blue for kanji
      default:
        return AppColors.textPrimary;
    }
  }

  void _showPopup(BuildContext context, Match match) {
    showDialog<void>(
      context: context,
      builder: (context) {
        Widget content;
        String title;
        if (match.type == 'vocab') {
          title = context.l10n.vocabType;
          final v = match.data as Vocab;
          content = VocabItem(index: match.index, vocab: v);
          analyticsService.logItemView(
            type: 'vocab',
            item: v.word,
            source: 'lyrics_highlight',
          );
        } else if (match.type == 'grammar') {
          title = context.l10n.grammarType;
          final g = match.data as Grammar;
          content = GrammarItem(index: match.index, grammar: g);
          analyticsService.logItemView(
            type: 'grammar',
            item: g.point,
            source: 'lyrics_highlight',
          );
        } else {
          title = context.l10n.kanjiType;
          final k = match.data as Kanji;
          content = KanjiItem(index: match.index, kanji: k);
          analyticsService.logItemView(
            type: 'kanji',
            item: k.char,
            source: 'lyrics_highlight',
          );
        }

        return AlertDialog(
          title: Text(title, style: Theme.of(context).textTheme.titleLarge),
          content: SingleChildScrollView(child: content),
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          scrollable: true,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.closeButton,
                style: const TextStyle(color: AppColors.sakura),
              ),
            ),
          ],
        );
      },
    );
  }

  List<TextSpan> _buildSpans(BuildContext context) {
    final lyrics = analysis.lyrics;
    final spans = <TextSpan>[];
    if (lyrics.isEmpty) return spans;

    final matches = <Match>[];

    String cleanText(String input, String type) {
      if (type != 'grammar') return input.trim();
      // Remove structural markers like "V.", "Adj.", "~", etc.
      return input
          .replaceAll(RegExp(r'^[A-Za-z]+\.'), '') // Remove "V.", "N." prefix
          .replaceAll('~', '') // Remove tilde
          .replaceAll('～', '') // Remove full-width tilde
          .trim();
    }

    void addMatches(
      List<dynamic> items,
      String type,
      String Function(dynamic) getText,
    ) {
      for (var i = 0; i < items.length; i++) {
        final rawText = getText(items[i]);
        // Try exact match first
        var text = rawText.trim();

        // If it's grammar, try the cleaner version if exact match fails
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

    addMatches(analysis.vocabs, 'vocab', (d) => (d as Vocab).word);
    addMatches(analysis.grammar, 'grammar', (d) => (d as Grammar).point);
    addMatches(analysis.kanji, 'kanji', (d) => (d as Kanji).char);

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
  Widget build(BuildContext context) {
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
        TextSpan(children: _buildSpans(context)),
        textAlign: TextAlign.center,
      ),
    );
  }
}
