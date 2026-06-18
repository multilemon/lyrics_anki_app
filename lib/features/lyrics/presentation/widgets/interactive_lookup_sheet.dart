import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/services/tts_service.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/core/theme/app_text_styles.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/result_card.dart';
import 'package:lyrics_anki_app/features/srs/data/repositories/hive_srs_repository.dart';
import 'package:lyrics_anki_app/features/srs/domain/entities/srs_card.dart';

class InteractiveLookupSheet extends ConsumerStatefulWidget {
  const InteractiveLookupSheet({
    required this.type,
    required this.data,
    required this.analysis,
    super.key,
  });

  final String type; // 'vocab', 'grammar', 'kanji'
  final dynamic data; // Vocab, Grammar, or Kanji
  final AnalysisResult analysis;

  @override
  ConsumerState<InteractiveLookupSheet> createState() =>
      _InteractiveLookupSheetState();
}

class _InteractiveLookupSheetState
    extends ConsumerState<InteractiveLookupSheet> {
  bool _isInStudyList = false;

  String get _word {
    if (widget.type == 'vocab') return (widget.data as Vocab).word;
    if (widget.type == 'grammar') return (widget.data as Grammar).point;
    return (widget.data as Kanji).char;
  }

  @override
  void initState() {
    super.initState();
    _checkStudyList();
  }

  void _checkStudyList() {
    try {
      final repo = ref.read(srsRepositoryProvider);
      _isInStudyList = repo.getAllCards().any((card) => card.word == _word);
    } on Object catch (_) {
      _isInStudyList = false;
    }
  }

  Future<void> _toggleStudyList() async {
    try {
      final repo = ref.read(srsRepositoryProvider);
      if (_isInStudyList) {
        await repo.deleteCard(_word);
        setState(() => _isInStudyList = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed "$_word" from Study List'),
              backgroundColor: AppColors.sakura,
            ),
          );
        }
      } else {
        SrsCard card;
        if (widget.type == 'vocab') {
          final v = widget.data as Vocab;
          card = SrsCard.newCard(
            word: v.word,
            reading: v.reading,
            meaning: v.meaning,
            songTitle: widget.analysis.song,
            artist: widget.analysis.artist,
            jlptV: v.jlptV,
            context: v.context,
          );
        } else if (widget.type == 'grammar') {
          final g = widget.data as Grammar;
          card = SrsCard.newCard(
            word: g.point,
            reading: g.usage,
            meaning: g.explanation,
            songTitle: widget.analysis.song,
            artist: widget.analysis.artist,
          );
        } else {
          final k = widget.data as Kanji;
          card = SrsCard.newCard(
            word: k.char,
            reading: k.readings,
            meaning: k.meanings,
            songTitle: widget.analysis.song,
            artist: widget.analysis.artist,
          );
        }

        await repo.saveCard(card);
        setState(() => _isInStudyList = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added "$_word" to Study List!'),
              backgroundColor: AppColors.matcha,
            ),
          );
        }
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update Study List: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build contents depending on type
    Widget detailsWidget;
    String typeLabel = '';
    Color themeColor = AppColors.sakura;

    if (widget.type == 'vocab') {
      typeLabel = 'Vocabulary';
      themeColor = AppColors.sakura;
      final v = widget.data as Vocab;
      detailsWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                v.reading,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: 'Serif',
                ),
              ),
              if (v.partOfSpeech.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '[${v.partOfSpeech}]',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: themeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            v.meaning,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          if (v.context.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Song Context:',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                v.context,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
          if (v.nuanceNote.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Nuance Note:',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              v.nuanceNote,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      );
    } else if (widget.type == 'grammar') {
      typeLabel = 'Grammar';
      themeColor = AppColors.accent;
      final g = widget.data as Grammar;
      detailsWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usage: ${g.usage}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            g.explanation,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      );
    } else {
      typeLabel = 'Kanji';
      themeColor = AppColors.peach;
      final k = widget.data as Kanji;
      detailsWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Readings:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  k.readings,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontFamily: 'Serif',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Meanings:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            k.meanings,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      );
    }

    String jlptLevel = '';
    if (widget.type == 'vocab') jlptLevel = (widget.data as Vocab).jlptV;
    if (widget.type == 'grammar') jlptLevel = (widget.data as Grammar).level;
    if (widget.type == 'kanji') jlptLevel = (widget.data as Kanji).level;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.82),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.4),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag indicator handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header Badge Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: themeColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              typeLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: themeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (jlptLevel.trim().isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Tag(
                              label: jlptLevel,
                              color: themeColor,
                            ),
                          ],
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.textSecondary,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Word & Action Buttons Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text Word
                      Expanded(
                        child: Text(
                          _word,
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Serif',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Speak Button
                      IconButton.filledTonal(
                        icon: const Icon(Icons.volume_up_rounded),
                        onPressed: () => TtsService.speak(_word),
                        style: IconButton.styleFrom(
                          foregroundColor: themeColor,
                          backgroundColor: themeColor.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Bookmark/StudyList Button
                      IconButton.filled(
                        icon: Icon(
                          _isInStudyList
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_add_outlined,
                        ),
                        onPressed: _toggleStudyList,
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: _isInStudyList
                              ? AppColors.matcha
                              : AppColors.sakura,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Dynamic details content
                  detailsWidget,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
