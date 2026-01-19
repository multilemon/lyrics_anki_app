import 'dart:async';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/providers/hive_provider.dart';
import 'package:lyrics_anki_app/core/services/analytics_service.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/home/presentation/providers/home_ui_providers.dart';
import 'package:lyrics_anki_app/features/lyrics/data/services/anki_export_service_impl.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/native_video_player.dart';
import 'package:lyrics_anki_app/features/main/presentation/pages/main_page.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';

class LyricsPage extends ConsumerStatefulWidget {
  const LyricsPage({super.key});

  @override
  ConsumerState<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends ConsumerState<LyricsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showPlayer = false;
  bool _isDragging = false;
  Offset? _playerOffset;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Reset video player when song changes
    ref.listen(lyricsNotifierProvider, (_, __) {
      if (_showPlayer) {
        setState(() => _showPlayer = false);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Song Title & Artist Header
                    Consumer(
                      builder: (context, ref, _) {
                        final analysis =
                            ref.watch(lyricsNotifierProvider).asData?.value;
                        if (analysis == null) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Text(
                                analysis.song,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                analysis.artist,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      },
                    ),

                    // Filters (Quick Select) - Applies to all tabs
                    Consumer(
                      builder: (context, ref, child) {
                        final analysis =
                            ref.watch(lyricsNotifierProvider).asData?.value;
                        if (analysis == null) return const SizedBox.shrink();

                        final selected = ref.watch(selectionManagerProvider);

                        bool isLevelSelected(String level) {
                          final vocabIndices = <int>[];
                          for (var i = 0; i < analysis.vocabs.length; i++) {
                            if (analysis.vocabs[i].jlptV.trim().toUpperCase() ==
                                level.toUpperCase()) {
                              vocabIndices.add(i);
                            }
                          }

                          final grammarIndices = <int>[];
                          for (var i = 0; i < analysis.grammar.length; i++) {
                            if (analysis.grammar[i].level
                                    .trim()
                                    .toUpperCase() ==
                                level.toUpperCase()) {
                              grammarIndices.add(i);
                            }
                          }

                          final kanjiIndices = <int>[];
                          for (var i = 0; i < analysis.kanji.length; i++) {
                            if (analysis.kanji[i].level.trim().toUpperCase() ==
                                level.toUpperCase()) {
                              kanjiIndices.add(i);
                            }
                          }

                          if (vocabIndices.isEmpty &&
                              grammarIndices.isEmpty &&
                              kanjiIndices.isEmpty) {
                            return false;
                          }

                          final vocabSelected = vocabIndices
                              .every(selected.vocabIndices.contains);
                          final grammarSelected = grammarIndices
                              .every(selected.grammarIndices.contains);
                          final kanjiSelected = kanjiIndices
                              .every(selected.kanjiIndices.contains);

                          return vocabSelected &&
                              grammarSelected &&
                              kanjiSelected;
                        }

                        bool isAllSelected() {
                          if (analysis.vocabs.isEmpty &&
                              analysis.grammar.isEmpty &&
                              analysis.kanji.isEmpty) {
                            return false;
                          }

                          final vocabAll = selected.vocabIndices.length ==
                              analysis.vocabs.length;
                          final grammarAll = selected.grammarIndices.length ==
                              analysis.grammar.length;
                          final kanjiAll = selected.kanjiIndices.length ==
                              analysis.kanji.length;

                          return vocabAll && grammarAll && kanjiAll;
                        }

                        final presentLevels = <String>{};
                        var hasOther = false;

                        void checkLevels(
                          List<dynamic> items,
                          String Function(dynamic) getLevel,
                        ) {
                          for (final item in items) {
                            final lvl = getLevel(item).trim().toUpperCase();
                            if (['N1', 'N2', 'N3', 'N4', 'N5'].contains(lvl)) {
                              presentLevels.add(lvl);
                            } else {
                              hasOther = true;
                            }
                          }
                        }

                        checkLevels(analysis.vocabs, (d) => (d as Vocab).jlptV);
                        checkLevels(
                          analysis.grammar,
                          (d) => (d as Grammar).level,
                        );
                        checkLevels(analysis.kanji, (d) => (d as Kanji).level);

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'All', // TODO(user): Localize
                                value: isAllSelected(),
                                onChanged: (val) {
                                  ref
                                      .read(selectionManagerProvider.notifier)
                                      .toggleAll(analysis, select: val);
                                },
                              ),
                              const SizedBox(width: 8),
                              for (final level in [
                                'N1',
                                'N2',
                                'N3',
                                'N4',
                                'N5',
                              ])
                                if (presentLevels.contains(level)) ...[
                                  _FilterChip(
                                    label: level,
                                    value: isLevelSelected(level),
                                    onChanged: (val) {
                                      ref
                                          .read(
                                            selectionManagerProvider.notifier,
                                          )
                                          .toggleLevel(
                                            analysis,
                                            level,
                                            select: val,
                                          );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              if (hasOther)
                                _FilterChip(
                                  label: 'Other', // TODO(user): Localize
                                  value: (() {
                                    final nonLevelVocab = <int>[];
                                    for (var i = 0;
                                        i < analysis.vocabs.length;
                                        i++) {
                                      final lvl = analysis.vocabs[i].jlptV
                                          .trim()
                                          .toUpperCase();
                                      if (!['N1', 'N2', 'N3', 'N4', 'N5']
                                          .contains(lvl)) {
                                        nonLevelVocab.add(i);
                                      }
                                    }

                                    final nonLevelGrammar = <int>[];
                                    for (var i = 0;
                                        i < analysis.grammar.length;
                                        i++) {
                                      final lvl = analysis.grammar[i].level
                                          .trim()
                                          .toUpperCase();
                                      if (!['N1', 'N2', 'N3', 'N4', 'N5']
                                          .contains(lvl)) {
                                        nonLevelGrammar.add(i);
                                      }
                                    }

                                    final nonLevelKanji = <int>[];
                                    for (var i = 0;
                                        i < analysis.kanji.length;
                                        i++) {
                                      final lvl = analysis.kanji[i].level
                                          .trim()
                                          .toUpperCase();
                                      if (!['N1', 'N2', 'N3', 'N4', 'N5']
                                          .contains(lvl)) {
                                        nonLevelKanji.add(i);
                                      }
                                    }

                                    if (nonLevelVocab.isEmpty &&
                                        nonLevelGrammar.isEmpty &&
                                        nonLevelKanji.isEmpty) {
                                      return false;
                                    }

                                    final vocabAll = nonLevelVocab
                                        .every(selected.vocabIndices.contains);
                                    final grammarAll = nonLevelGrammar.every(
                                      selected.grammarIndices.contains,
                                    );
                                    final kanjiAll = nonLevelKanji
                                        .every(selected.kanjiIndices.contains);

                                    return vocabAll && grammarAll && kanjiAll;
                                  })(),
                                  onChanged: (val) {
                                    final targetIndices = <int>[];
                                    for (var i = 0;
                                        i < analysis.vocabs.length;
                                        i++) {
                                      final lvl = analysis.vocabs[i].jlptV
                                          .trim()
                                          .toUpperCase();
                                      if (!['N1', 'N2', 'N3', 'N4', 'N5']
                                          .contains(lvl)) {
                                        targetIndices.add(i);
                                      }
                                    }

                                    for (final idx in targetIndices) {
                                      ref
                                          .read(
                                            selectionManagerProvider.notifier,
                                          )
                                          .toggle(
                                            SelectionType.vocab,
                                            idx,
                                            force: val,
                                          );
                                    }
                                    for (var i = 0;
                                        i < analysis.grammar.length;
                                        i++) {
                                      final lvl = analysis.grammar[i].level
                                          .trim()
                                          .toUpperCase();
                                      if (!['N1', 'N2', 'N3', 'N4', 'N5']
                                          .contains(lvl)) {
                                        ref
                                            .read(
                                              selectionManagerProvider.notifier,
                                            )
                                            .toggle(
                                              SelectionType.grammar,
                                              i,
                                              force: val,
                                            );
                                      }
                                    }
                                    for (var i = 0;
                                        i < analysis.kanji.length;
                                        i++) {
                                      final lvl = analysis.kanji[i].level
                                          .trim()
                                          .toUpperCase();
                                      if (!['N1', 'N2', 'N3', 'N4', 'N5']
                                          .contains(lvl)) {
                                        ref
                                            .read(
                                              selectionManagerProvider.notifier,
                                            )
                                            .toggle(
                                              SelectionType.kanji,
                                              i,
                                              force: val,
                                            );
                                      }
                                    }
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Tabs
                    Consumer(
                      builder: (context, ref, _) {
                        final analysis =
                            ref.watch(lyricsNotifierProvider).asData?.value;
                        final vocabCount = analysis?.vocabs.length ?? 0;
                        final grammarCount = analysis?.grammar.length ?? 0;
                        final kanjiCount = analysis?.kanji.length ?? 0;

                        return TabBar(
                          controller: _tabController,
                          labelColor: AppColors.sakuraDark,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.sakuraDark,
                          tabs: [
                            Tab(text: '${context.l10n.vocabTab} ($vocabCount)'),
                            Tab(
                              text:
                                  '${context.l10n.grammarTab} ($grammarCount)',
                            ),
                            Tab(text: '${context.l10n.kanjiTab} ($kanjiCount)'),
                            Tab(text: context.l10n.lyricsTab),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Results Area
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final state = ref.watch(lyricsNotifierProvider);
                          return state.when(
                            data: (analysis) {
                              if (analysis == null) {
                                return Center(
                                  child: Text(
                                    'No analysis data available.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                );
                              }

                              return TabBarView(
                                controller: _tabController,
                                children: [
                                  _VocabList(vocabList: analysis.vocabs),
                                  _GrammarList(grammarList: analysis.grammar),
                                  _KanjiList(kanjiList: analysis.kanji),
                                  _LyricsView(lyrics: analysis.lyrics),
                                ],
                              );
                            },
                            loading: () => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(
                                    color: AppColors.sakuraDark,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    context.l10n.analysisInProgress,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            error: (Object e, StackTrace s) {
                              if (e is SongNotFoundException) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.search_off_rounded,
                                          size: 48,
                                          color: AppColors.error,
                                        ),
                                        const SizedBox(height: 16),
                                        const SizedBox(height: 16),
                                        Text(
                                          context.l10n.songNotFound,
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          context.l10n.songNotFoundMessage(
                                            e.title,
                                            e.artist,
                                          ),
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 32),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            // Clear Home fields
                                            ref
                                                .read(
                                                  clearHomeFormSignalProvider
                                                      .notifier,
                                                )
                                                .state++;
                                            // Navigate to Home (Index 0)
                                            ref
                                                .read(navIndexProvider.notifier)
                                                .state = 0;
                                            // Also clear current lyrics state
                                            ref.invalidate(
                                              lyricsNotifierProvider,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.sakuraDark,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon:
                                              const Icon(Icons.refresh_rounded),
                                          label: const Text('Try Again'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              if (e is ServerOverloadedException) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.cloud_off_rounded,
                                          size: 48,
                                          color: AppColors.sakuraDark,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'AI is Busy',
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'The AI service is currently overloaded (503).\n'
                                          'This happens with the Free Tier.\n'
                                          'Please wait a moment and try again.',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(height: 1.4),
                                        ),
                                        const SizedBox(height: 32),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            ref
                                                .read(
                                                  lyricsNotifierProvider
                                                      .notifier,
                                                )
                                                .retry();
                                          },
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Retry Now'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.sakuraDark,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              if (e is QuotaExceededException) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.hourglass_empty_rounded,
                                          size: 48,
                                          color: AppColors.sakuraDark,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Daily Limit Reached',
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "You've hit the daily usage limit for the free AI tier.\n"
                                          'Please try again tomorrow.',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(height: 1.4),
                                        ),
                                        const SizedBox(height: 32),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            // Describe navigation purely via providers
                                            ref
                                                .read(
                                                  clearHomeFormSignalProvider
                                                      .notifier,
                                                )
                                                .state++;
                                            ref
                                                .read(navIndexProvider.notifier)
                                                .state = 0;
                                            ref.invalidate(
                                              lyricsNotifierProvider,
                                            );
                                          },
                                          icon: const Icon(Icons.arrow_back),
                                          label: const Text('Back to Search'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.sakuraDark,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              // General Error Handling
                              final errorMsg = e.toString();
                              final isNotJapanese = errorMsg.contains(
                                'not appear to be primarily in Japanese',
                              );
                              final isJsonError =
                                  errorMsg.contains('JSON Parse Error') ||
                                      errorMsg.contains('FormatException');
                              final isLyricsNotFound = errorMsg.contains(
                                'LYRICS_NOT_FOUND',
                              );

                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isNotJapanese
                                          ? Icons.translate_rounded
                                          : isLyricsNotFound
                                              ? Icons.library_music_rounded
                                              : Icons.error_outline,
                                      size: 48,
                                      color: AppColors.error,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      isNotJapanese
                                          ? 'Language Mismatch'
                                          : isLyricsNotFound
                                              ? 'Lyrics Unavailable'
                                              : 'Analysis Failed',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                      ),
                                      child: Text(
                                        isJsonError
                                            ? 'Sometimes AI makes a mistake.\n'
                                                'Please try again.'
                                            : isLyricsNotFound
                                                ? 'The AI could not find the full official lyrics for this song.\n'
                                                    'Please try a different song or artist variation.'
                                                : errorMsg.replaceAll(
                                                    'Exception: ',
                                                    '',
                                                  ),
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(height: 1.4),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    if (isNotJapanese || isLyricsNotFound)
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          // Clear Home fields
                                          ref
                                              .read(
                                                clearHomeFormSignalProvider
                                                    .notifier,
                                              )
                                              .state++;
                                          // Navigate to Home (Index 0)
                                          ref
                                              .read(navIndexProvider.notifier)
                                              .state = 0;
                                          // Also clear current lyrics state
                                          ref.invalidate(
                                            lyricsNotifierProvider,
                                          );
                                        },
                                        icon: const Icon(Icons.search),
                                        label:
                                            const Text('Search Another Song'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.sakuraDark,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 14,
                                          ),
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      )
                                    else
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          ref
                                              .read(
                                                lyricsNotifierProvider.notifier,
                                              )
                                              .retry();
                                        },
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Retry Analysis'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.sakuraDark,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Floating Video Player
          if (_showPlayer)
            Consumer(
              builder: (context, ref, child) {
                final analysis =
                    ref.watch(lyricsNotifierProvider).asData?.value;
                if (analysis?.youtubeId == null) return const SizedBox.shrink();

                final size = MediaQuery.of(context).size;
                const videoWidth = 300.0;
                const headerHeight = 48.0;
                const videoHeight = 169.0;
                const totalHeight = headerHeight + videoHeight;

                // Default position: Centered
                final defaultLeft = (size.width - videoWidth) / 2;
                final defaultTop = (size.height - totalHeight) / 2;

                return Positioned(
                  left: _playerOffset?.dx ?? defaultLeft,
                  top: _playerOffset?.dy ?? defaultTop,
                  child: Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    color: AppColors.sakuraDark,
                    child: SizedBox(
                      width: videoWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag Handle Header
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanStart: (_) =>
                                setState(() => _isDragging = true),
                            onPanEnd: (_) =>
                                setState(() => _isDragging = false),
                            onPanCancel: () =>
                                setState(() => _isDragging = false),
                            onPanUpdate: (details) {
                              setState(() {
                                final currentLeft =
                                    _playerOffset?.dx ?? defaultLeft;
                                final currentTop =
                                    _playerOffset?.dy ?? defaultTop;
                                _playerOffset = Offset(
                                  currentLeft + details.delta.dx,
                                  currentTop + details.delta.dy,
                                );
                              });
                            },
                            child: Container(
                              height: headerHeight,
                              color: AppColors.sakuraDark,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.drag_indicator,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Video',
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => setState(() {
                                      _showPlayer = false;
                                      // Keep _playerOffset to remember position
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Video Player
                          SizedBox(
                            height: videoHeight,
                            child: Stack(
                              children: [
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                                NativeVideoPlayer(
                                  videoId: analysis!.youtubeId!,
                                  key: ValueKey(analysis.youtubeId),
                                ),
                                if (_isDragging)
                                  Positioned.fill(
                                    child: Container(color: Colors.transparent),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final analysis = ref.watch(lyricsNotifierProvider).asData?.value;
          final selectedState = ref.watch(selectionManagerProvider);
          final hasSelection = selectedState.vocabIndices.isNotEmpty ||
              selectedState.grammarIndices.isNotEmpty ||
              selectedState.kanjiIndices.isNotEmpty;

          if (analysis == null) {
            return const SizedBox.shrink();
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (analysis.youtubeId != null) ...[
                FloatingActionButton(
                  heroTag: 'video_fab',
                  backgroundColor: AppColors.sakuraDark,
                  onPressed: () => setState(() => _showPlayer = !_showPlayer),
                  child: _showPlayer
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.smart_display_rounded,
                              color: Colors.white,
                            ),
                            // Masking "Eraser" to separate slash from icon
                            Transform.rotate(
                              angle: -0.785, // -45 degrees
                              child: Container(
                                width: 4.5,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.sakuraDark,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            // The actual Slash
                            Transform.rotate(
                              angle: -0.785,
                              child: Container(
                                width: 2,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Icon(
                          Icons.smart_display_rounded,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(height: 16),
              ],
              if (hasSelection)
                FloatingActionButton(
                  heroTag: 'export_fab',
                  backgroundColor: AppColors.sakuraDark,
                  onPressed: () {
                    // Re-read to get latest state in callback
                    final analysis =
                        ref.read(lyricsNotifierProvider).asData?.value;
                    if (analysis == null) return;

                    final selectedState = ref.read(selectionManagerProvider);

                    final selectedVocabs = <Vocab>[];
                    for (final i in selectedState.vocabIndices) {
                      if (i < analysis.vocabs.length) {
                        selectedVocabs.add(analysis.vocabs[i]);
                      }
                    }

                    final selectedGrammar = <Grammar>[];
                    for (final i in selectedState.grammarIndices) {
                      if (i < analysis.grammar.length) {
                        selectedGrammar.add(analysis.grammar[i]);
                      }
                    }

                    final selectedKanji = <Kanji>[];
                    for (final i in selectedState.kanjiIndices) {
                      if (i < analysis.kanji.length) {
                        selectedKanji.add(analysis.kanji[i]);
                      }
                    }

                    if (selectedVocabs.isEmpty &&
                        selectedGrammar.isEmpty &&
                        selectedKanji.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select items to export')),
                      );
                      return;
                    }

                    showDialog<void>(
                      context: context,
                      builder: (context) => _ExportDialog(
                        onExport: (userLevel) async {
                          try {
                            final exportService =
                                ref.read(ankiExportServiceProvider);

                            // Log export initiation
                            unawaited(
                              analyticsService.logExport(
                                songTitle: analysis.song,
                                artist: analysis.artist,
                                level: userLevel,
                                vocabCount: selectedVocabs.length,
                                grammarCount: selectedGrammar.length,
                                kanjiCount: selectedKanji.length,
                              ),
                            );

                            // Generate .apkg
                            final bytes = await exportService.generateApkg(
                              vocabs: selectedVocabs,
                              grammar: selectedGrammar,
                              kanji: selectedKanji,
                              songTitle: analysis.song,
                              artist: analysis.artist,
                              userLevel: userLevel,
                            );

                            if (!context.mounted) return;

                            final filename =
                                '${analysis.song.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')}_${analysis.artist}.apkg';

                            // Save file (trigger download)
                            await FileSaver.instance.saveFile(
                              name: filename,
                              bytes: bytes,
                            );

                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Export downloaded successfully'),
                              ),
                            );
                          } catch (e) {
                            unawaited(
                              analyticsService.logError(
                                'Export failed: $e',
                                'export_dialog',
                              ),
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Export failed: $e')),
                            );
                          }
                        },
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.file_upload_outlined,
                    color: Colors.white,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _VocabList extends StatefulWidget {
  const _VocabList({required this.vocabList});
  final List<Vocab> vocabList;

  @override
  State<_VocabList> createState() => _VocabListState();
}

class _VocabListState extends State<_VocabList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    if (widget.vocabList.isEmpty) {
      return Center(
        child: Text(
          'No vocabulary found.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: AppColors.textTertiary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
      cacheExtent: 100,
      itemCount: widget.vocabList.length,
      itemBuilder: (context, index) {
        return _VocabItem(
          index: index,
          vocab: widget.vocabList[index],
        );
      },
    );
  }
}

class _VocabItem extends ConsumerWidget {
  const _VocabItem({required this.index, required this.vocab});

  final int index;
  final Vocab vocab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSelected = ref.watch(
      selectionManagerProvider.select((s) => s.vocabIndices.contains(index)),
    );

    return _ResultCard(
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: vocab.word,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (vocab.partOfSpeech.isNotEmpty) ...[
              const WidgetSpan(child: SizedBox(width: 8)),
              TextSpan(
                text: '[${vocab.partOfSpeech}]',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.sakuraDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const WidgetSpan(child: SizedBox(width: 8)),
            TextSpan(
              text: vocab.reading,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
      details: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vocab.meaning,
            style: theme.textTheme.bodyMedium,
          ),
          if (vocab.context.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                vocab.context,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          if (vocab.nuanceNote.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Note: ${vocab.nuanceNote}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      trailingTag: vocab.jlptV.trim().isNotEmpty
          ? _Tag(
              label: vocab.jlptV,
              color: AppColors.sakuraDark,
            )
          : const _Tag(
              label: 'Other',
              color: AppColors.textTertiary,
            ),
      isSelected: isSelected,
      onToggle: () {
        ref
            .read(selectionManagerProvider.notifier)
            .toggle(SelectionType.vocab, index);
      },
      themeColor: AppColors.sakuraDark,
    );
  }
}

class _GrammarList extends StatefulWidget {
  const _GrammarList({required this.grammarList});
  final List<Grammar> grammarList;

  @override
  State<_GrammarList> createState() => _GrammarListState();
}

class _GrammarListState extends State<_GrammarList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    if (widget.grammarList.isEmpty) {
      return Center(
        child: Text(
          'No grammar points found.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: AppColors.textTertiary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
      cacheExtent: 100,
      itemCount: widget.grammarList.length,
      itemBuilder: (context, index) {
        return _GrammarItem(
          index: index,
          grammar: widget.grammarList[index],
        );
      },
    );
  }
}

class _GrammarItem extends ConsumerWidget {
  const _GrammarItem({required this.index, required this.grammar});

  final int index;
  final Grammar grammar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSelected = ref.watch(
      selectionManagerProvider.select((s) => s.grammarIndices.contains(index)),
    );

    return _ResultCard(
      title: Text(
        grammar.point,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      details: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            grammar.explanation,
            style: theme.textTheme.bodyMedium,
          ),
          if (grammar.usage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Usage: ${grammar.usage}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        ],
      ),
      trailingTag: grammar.level.trim().isNotEmpty
          ? _Tag(
              label: grammar.level,
              color: AppColors.sakuraDark,
            )
          : const _Tag(label: 'Other', color: AppColors.textTertiary),
      isSelected: isSelected,
      onToggle: () {
        ref
            .read(selectionManagerProvider.notifier)
            .toggle(SelectionType.grammar, index);
      },
      themeColor: AppColors.matcha, // Use matcha for Grammar
    );
  }
}

class _KanjiList extends StatefulWidget {
  const _KanjiList({required this.kanjiList});
  final List<Kanji> kanjiList;

  @override
  State<_KanjiList> createState() => _KanjiListState();
}

class _KanjiListState extends State<_KanjiList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    if (widget.kanjiList.isEmpty) {
      return Center(
        child: Text(
          'No kanji found.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: AppColors.textTertiary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
      cacheExtent: 100,
      itemCount: widget.kanjiList.length,
      itemBuilder: (context, index) {
        return _KanjiItem(
          index: index,
          kanji: widget.kanjiList[index],
        );
      },
    );
  }
}

class _KanjiItem extends ConsumerWidget {
  const _KanjiItem({required this.index, required this.kanji});

  final int index;
  final Kanji kanji;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSelected = ref.watch(
      selectionManagerProvider.select((s) => s.kanjiIndices.contains(index)),
    );

    return _ResultCard(
      leadingContent: CircleAvatar(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.textPrimary,
        child: Text(kanji.char, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(
        kanji.meanings,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        kanji.readings,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      trailingTag: kanji.level.trim().isNotEmpty
          ? _Tag(
              label: kanji.level,
              color: AppColors.sakuraDark,
            )
          : const _Tag(label: 'Other', color: AppColors.textTertiary),
      isSelected: isSelected,
      onToggle: () {
        ref
            .read(selectionManagerProvider.notifier)
            .toggle(SelectionType.kanji, index);
      },
      themeColor: const Color(0xFF8D6E63), // Brown for Kanji
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.8),
            color,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          height: 1,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    const themeColor = AppColors.sakuraDark;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: value ? themeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: themeColor,
            width: 1.5,
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: value ? Colors.white : themeColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.isSelected,
    required this.onToggle,
    required this.themeColor,
    this.subtitle,
    this.details,
    this.trailingTag,
    this.leadingContent,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? details;
  final Widget? trailingTag;
  final bool isSelected;
  final VoidCallback onToggle;
  final Color themeColor;
  final Widget? leadingContent;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: isSelected ? themeColor.withValues(alpha: 0.1) : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? themeColor : Colors.transparent,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: isSelected,
                    activeColor: themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (_) => onToggle(),
                  ),
                  if (leadingContent != null) ...[
                    leadingContent!,
                    const SizedBox(width: 8),
                  ],
                ],
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 4,
                    right: 8,
                    bottom: 8,
                    left: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: title),
                          if (trailingTag != null) ...[
                            const SizedBox(width: 8),
                            trailingTag!,
                          ],
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        subtitle!,
                      ],
                      if (details != null) ...[
                        const SizedBox(height: 8),
                        details!,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportDialog extends ConsumerStatefulWidget {
  const _ExportDialog({required this.onExport});

  final Future<void> Function(String userLevel) onExport;

  @override
  ConsumerState<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<_ExportDialog> {
  String _selectedLevel = 'N5';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = ref.read(settingsBoxProvider);
      final saved = box?.get('export_jlpt_level');
      if (saved != null && saved is String) {
        setState(() {
          _selectedLevel = saved;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(
        l10n.exportToAnki,
        style: theme.textTheme.titleLarge?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      content: _isLoading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.sakuraDark),
                const SizedBox(height: 16),
                Text(l10n.generatingApkg),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.selectJlptLevel),
                const SizedBox(height: 8),
                Text(
                  l10n.furiganaExplanation,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLevel,
                  dropdownColor: AppColors.white,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.cream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: ['N5', 'N4', 'N3', 'N2', 'N1'].map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedLevel = val);
                    }
                  },
                ),
              ],
            ),
      actions: _isLoading
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancelButton,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(settingsBoxProvider)
                      ?.put('export_jlpt_level', _selectedLevel);
                  setState(() => _isLoading = true);
                  await widget.onExport(_selectedLevel);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sakuraDark,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.exportButton),
              ),
            ],
    );
  }
}

class _LyricsView extends StatelessWidget {
  const _LyricsView({required this.lyrics});

  final String lyrics;

  @override
  Widget build(BuildContext context) {
    if (lyrics.isEmpty) {
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
      padding: const EdgeInsets.all(24),
      child: SelectableText(
        lyrics,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.8,
              fontSize: 16,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
