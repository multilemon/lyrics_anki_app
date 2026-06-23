import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lyrics_anki_app/core/providers/hive_provider.dart';
import 'package:lyrics_anki_app/core/services/backup_service.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/core/theme/app_text_styles.dart';
import 'package:lyrics_anki_app/core/widgets/animated_reveal_text.dart';
import 'package:lyrics_anki_app/core/widgets/neural_background.dart';
import 'package:lyrics_anki_app/core/widgets/neural_pulse_button.dart';
import 'package:lyrics_anki_app/features/home/presentation/providers/history_notifier.dart';
import 'package:lyrics_anki_app/features/home/presentation/widgets/song_suggestion_card.dart';
import 'package:lyrics_anki_app/features/home/presentation/widgets/storage_warning_banner.dart';
import 'package:lyrics_anki_app/features/lyrics/data/lyrics_repository.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/paste_lyrics_provider.dart';
import 'package:lyrics_anki_app/features/settings/presentation/providers/locale_notifier.dart';
import 'package:lyrics_anki_app/features/settings/presentation/providers/version_provider.dart';
import 'package:lyrics_anki_app/features/settings/presentation/providers/jlpt_level_notifier.dart';
import 'package:lyrics_anki_app/features/settings/presentation/providers/tts_autoplay_notifier.dart';
import 'package:lyrics_anki_app/features/srs/presentation/providers/srs_review_notifier.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimmer/shimmer.dart';

part 'home_page.g.dart';

@riverpod
class ClearHomeFormSignal extends _$ClearHomeFormSignal {
  @override
  int build() => 0;

  void increment() => state++;
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    super.key,
    this.onNavigateToAnalyze,
    this.onHistoryItemClick,
  });

  final void Function(
    String title,
    String artist,
    String language, {
    String? customLyrics,
  })?
  onNavigateToAnalyze;

  final void Function(HistoryItem item)? onHistoryItemClick;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _lyricsController = TextEditingController();
  String _selectedLanguage = 'English';
  bool _showLyricsInput = false;

  // ── Neural Expressive UI: staggered entry animations ─────────────────────
  late final AnimationController _entryController;
  late final Animation<double> _section0; // header
  late final Animation<double> _section1; // analyze card
  late final Animation<double> _section2; // SRS dashboard
  late final Animation<double> _section3; // history

  @override
  void initState() {
    super.initState();

    // Single controller drives all four staggered section reveals.
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _section0 = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0, 0.55, curve: Curves.easeOutCubic),
    );
    _section1 = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.18, 0.70, curve: Curves.easeOutCubic),
    );
    _section2 = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
    );
    _section3 = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.5, 1, curve: Curves.easeOutCubic),
    );

    unawaited(_entryController.forward());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = ref.read(settingsBoxProvider);
      final saved = box?.get('target_language');
      if (saved != null && saved is String) {
        setState(() {
          _selectedLanguage = saved;
        });
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _titleController.dispose();
    _artistController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  void _handleAnalyze() {
    final title = _titleController.text.trim();
    final artist = _artistController.text.trim();

    if (title.isEmpty || artist.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter both Song Title and Artist Name',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final customLyrics = _lyricsController.text.trim();

    if (widget.onNavigateToAnalyze != null) {
      widget.onNavigateToAnalyze!(
        title,
        artist,
        _selectedLanguage,
        customLyrics: customLyrics.isNotEmpty ? customLyrics : null,
      );
    } else {
      // Clear any previous selection state
      ref.read(selectionManagerProvider.notifier).clear();

      // Trigger analysis (fire and forget for UI,
      // but provider handles state)
      unawaited(
        ref
            .read(lyricsProvider.notifier)
            .analyzeSong(
              title,
              artist,
              _selectedLanguage,
              customLyrics: customLyrics.isNotEmpty ? customLyrics : null,
            ),
      );

      context.pushNamed('lyrics');
    }
  }

  void _onHistoryItemTap(HistoryItem item) {
    // Restore logic removed

    if (widget.onHistoryItemClick != null) {
      widget.onHistoryItemClick!(item);
    } else {
      // Clear any previous selection state
      ref.read(selectionManagerProvider.notifier).clear();

      // Load from history
      ref.read(lyricsProvider.notifier).loadFromHistory(item);

      context.pushNamed('lyrics');
    }
  }

  void _handleSuggestionTap(String title, String artist) {
    // Auto-fill the text fields
    _titleController.text = title;
    _artistController.text = artist;

    // Trigger analysis immediately
    if (widget.onNavigateToAnalyze != null) {
      widget.onNavigateToAnalyze!(
        title,
        artist,
        _selectedLanguage,
      );
    } else {
      ref.read(selectionManagerProvider.notifier).clear();

      unawaited(
        ref
            .read(lyricsProvider.notifier)
            .analyzeSong(
              title,
              artist,
              _selectedLanguage,
            ),
      );

      context.pushNamed('lyrics');
    }
  }

  Future<void> _showImportConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: const Text(
          'This will completely overwrite your current settings, '
          'search history, and SRS study list. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Overwrite & Restore'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await BackupService.importBackup(context, ref);
    }
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.settingsTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.sakura,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.qr_code, color: AppColors.sakura),
                title: const Text('Share App'),
                subtitle: const Text('Show QR Code'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  showDialog<void>(
                    context: context,
                    builder: (context) => const _ShareDialog(),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.cloud_upload_outlined,
                  color: AppColors.sakura,
                ),
                title: const Text('Export Backup'),
                subtitle: const Text(
                  'Download a JSON backup of your study data',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  BackupService.exportBackup(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.cloud_download_outlined,
                  color: AppColors.sakura,
                ),
                title: const Text('Restore Backup'),
                subtitle: const Text(
                  'Restore study data from a JSON backup file',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _showImportConfirmation(context, ref);
                },
              ),
              const Divider(indent: 16, endIndent: 16),
              Consumer(
                builder: (context, ref, child) {
                  final jlptLevel = ref.watch(jlptLevelProvider);
                  return ListTile(
                    leading: const Icon(
                      Icons.filter_list_rounded,
                      color: AppColors.sakura,
                    ),
                    title: const Text('JLPT Filter (Hide Known Words)'),
                    subtitle: Text(
                      jlptLevel == 'none'
                          ? 'Showing all words'
                          : 'Hiding words below $jlptLevel',
                    ),
                    trailing: DropdownButton<String>(
                      value: jlptLevel,
                      underline: const SizedBox.shrink(),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(jlptLevelProvider.notifier).setLevel(value);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'none',
                          child: Text('Show All'),
                        ),
                        DropdownMenuItem(
                          value: 'N5',
                          child: Text('N5 Level'),
                        ),
                        DropdownMenuItem(
                          value: 'N4',
                          child: Text('N4 Level'),
                        ),
                        DropdownMenuItem(
                          value: 'N3',
                          child: Text('N3 Level'),
                        ),
                        DropdownMenuItem(
                          value: 'N2',
                          child: Text('N2 Level'),
                        ),
                        DropdownMenuItem(
                          value: 'N1',
                          child: Text('N1 Level'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  final autoPlay = ref.watch(ttsAutoplayProvider);
                  return SwitchListTile(
                    secondary: const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.sakura,
                    ),
                    title: const Text('Auto-Play Pronunciation'),
                    subtitle: const Text('Speak word when card is flipped'),
                    activeColor: AppColors.sakura,
                    value: autoPlay,
                    onChanged: (value) {
                      ref.read(ttsAutoplayProvider.notifier).setAutoplay(value);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final versionAsync = ref.watch(versionProvider);
                  return versionAsync.when(
                    data: (version) => Text(
                      version,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (e, st) => const SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Section reveal helper ──────────────────────────────────────────────────
  /// Wraps [child] in a fade + upward slide driven by [animation].
  Widget _buildSectionReveal({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for clear signal
    ref.listen(clearHomeFormSignalProvider, (_, _) {
      _titleController.clear();
      _artistController.clear();
      _lyricsController.clear();
      setState(() => _showLyricsInput = false);
    });

    // Listen for "paste lyrics" signal from error view
    ref.listen<bool>(showPasteLyricsProvider, (prev, next) {
      if (next && prev != true) {
        setState(() => _showLyricsInput = true);
        // Reset the signal
        Future.microtask(
          () => ref.read(showPasteLyricsProvider.notifier).reset(),
        );
      }
    });

    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.sakura,
            onPressed: () => _showSettingsSheet(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          // ── Gradient base ─────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background,
                  AppColors.matcha.withValues(alpha: 0.15),
                  AppColors.background,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Neural ambient background ─────────────────────────────────────
          const NeuralNetworkBackground(),

          // ── Scrollable content ────────────────────────────────────────────
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                slivers: [
                  // ─── Header ───────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _buildSectionReveal(
                      animation: _section0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 100, 32, 36),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedRevealText(
                              text: l10n.appTitle,
                              style: theme.textTheme.displayLarge?.copyWith(
                                color: AppColors.sakura,
                                fontWeight: FontWeight.w800,
                              ),
                              duration: const Duration(milliseconds: 1100),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.homeSubtitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ─── Analysis Card ────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _buildSectionReveal(
                      animation: _section1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 12,
                              sigmaY: 12,
                            ),
                            child: AnimatedBuilder(
                              animation: _section1,
                              builder: (context, child) {
                                // Entry glow: bright on arrival, dims to rest.
                                final glow = 1.0 - _section1.value;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withValues(
                                      alpha: 0.85,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppColors.sakura.withValues(
                                        alpha: 0.15 + 0.22 * glow,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.sakura.withValues(
                                          alpha: 0.06 + 0.20 * glow,
                                        ),
                                        blurRadius: 32 + 28 * glow,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(28),
                                  child: child,
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.analyzeNewSong,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(
                                          Icons.more_horiz,
                                          color: AppColors.textSecondary,
                                        ),
                                        onSelected: (value) {
                                          if (value == 'paste_lyrics') {
                                            setState(() {
                                              _showLyricsInput =
                                                  !_showLyricsInput;
                                              if (!_showLyricsInput) {
                                                _lyricsController.clear();
                                              }
                                            });
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'paste_lyrics',
                                            child: Text(
                                              _showLyricsInput
                                                  ? 'Hide Paste Lyrics'
                                                  : 'Paste Lyrics (Optional)',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Song Title
                                  TextField(
                                    controller: _titleController,
                                    decoration: InputDecoration(
                                      labelText: l10n.songTitleLabel,
                                      hintText: l10n.songTitleHint,
                                      prefixIcon: const Icon(Icons.music_note),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Artist Name
                                  TextField(
                                    controller: _artistController,
                                    decoration: InputDecoration(
                                      labelText: l10n.artistNameLabel,
                                      hintText: l10n.artistNameHint,
                                      prefixIcon: const Icon(Icons.person),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  if (_showLyricsInput) ...[
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _lyricsController,
                                      maxLines: 5,
                                      minLines: 3,
                                      decoration: const InputDecoration(
                                        labelText: 'Custom Lyrics',
                                        hintText: 'Paste lyrics here...',
                                        alignLabelWithHint: true,
                                      ),
                                    ),
                                  ],

                                  // Target Language Selector
                                  const SizedBox(height: 16),
                                  InkWell(
                                    onTap: () async {
                                      final result =
                                          await showDialog<LanguageData>(
                                            context: context,
                                            builder: (context) =>
                                                const _LanguageSearchDialog(),
                                          );
                                      if (result != null) {
                                        setState(() {
                                          _selectedLanguage =
                                              result.englishName;
                                        });
                                        await ref
                                            .read(settingsBoxProvider)
                                            ?.put(
                                              'target_language',
                                              result.englishName,
                                            );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.language,
                                            color: AppColors.sakura,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  l10n.targetLanguageLabel,
                                                  style: theme
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color: AppColors
                                                            .textTertiary,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _selectedLanguage,
                                                  style: theme
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        color: AppColors
                                                            .textPrimary,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_drop_down,
                                            color: AppColors.textSecondary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // ─── Neural Pulse Analyze Button ───────────
                                  NeuralPulseButton(
                                    label: l10n.analyzeButton,
                                    onPressed: _handleAnalyze,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ─── SRS Dashboard ─────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _buildSectionReveal(
                      animation: _section2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: _SrsDashboard(),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 56)),

                  // ─── History Section ───────────────────────────────────────
                  // SliverFadeTransition applies the section3 opacity to the
                  // entire Consumer subtree (which returns sliver widgets).
                  SliverFadeTransition(
                    opacity: _section3,
                    sliver: Consumer(
                      builder: (context, ref, child) {
                        final historyAsync = ref.watch(historyProvider);
                        return historyAsync.when(
                          data: (items) {
                            if (items.isEmpty) {
                              // ─── Empty State: Song Suggestions ───
                              return SliverToBoxAdapter(
                                child: SongSuggestionCard(
                                  onSuggestionTap: _handleSuggestionTap,
                                ),
                              );
                            }

                            // ─── Has History: Show header + list ───
                            return SliverMainAxisGroup(
                              slivers: [
                                // Section title
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          l10n.recentAnalysisTitle,
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                                fontFamily: 'Serif',
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Storage warning (if applicable)
                                SliverToBoxAdapter(
                                  child: Consumer(
                                    builder: (context, ref, _) {
                                      final repo = ref.watch(
                                        lyricsRepositoryProvider,
                                      );
                                      if (!repo.isReady) {
                                        return const StorageWarningBanner();
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),

                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 16),
                                ),

                                // History list — items slide in from the right.
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final item = items[index];
                                      final artist = item.artist.isNotEmpty
                                          ? item.artist
                                          : l10n.unknownArtist;
                                      return TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0, end: 1),
                                        duration: Duration(
                                          milliseconds: 350 + index * 90,
                                        ),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, child) {
                                          return Opacity(
                                            opacity: value.clamp(0.0, 1.0),
                                            child: Transform.translate(
                                              offset: Offset(
                                                22 * (1 - value),
                                                0,
                                              ),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 8,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.sakura
                                                      .withValues(
                                                        alpha: 0.06,
                                                      ),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: AppColors.surface,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              clipBehavior: Clip.antiAlias,
                                              child: ListTile(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12,
                                                    ),
                                                hoverColor: AppColors.sakura
                                                    .withValues(alpha: 0.1),
                                                splashColor: AppColors.sakura
                                                    .withValues(alpha: 0.15),
                                                title: Text(
                                                  item.songTitle,
                                                  style: theme
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '$artist · '
                                                      '${item.targetLanguage}',
                                                      style: theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: AppColors
                                                                .sakura,
                                                          ),
                                                    ),
                                                    if (item
                                                            .vocabs
                                                            .isNotEmpty ||
                                                        item
                                                            .kanji
                                                            .isNotEmpty) ...[
                                                      const SizedBox(
                                                        height: 6,
                                                      ),
                                                      _HistoryDifficultyChip(
                                                        item: item,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                trailing: const Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 16,
                                                  color: AppColors.sakura,
                                                ),
                                                onTap: () =>
                                                    _onHistoryItemTap(item),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: items.length,
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Shimmer.fromColors(
                                baseColor: AppColors.surfaceLight,
                                highlightColor: AppColors.surface,
                                child: Column(
                                  children: List.generate(
                                    3,
                                    (index) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceLight,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          error: (e, s) => SliverToBoxAdapter(
                            child: Text('Error: $e'),
                          ),
                        );
                      },
                    ),
                  ),

                  // UI Language Settings
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.language,
                          color: AppColors.sakura,
                        ),
                        title: Text(l10n.uiLanguage),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.pushNamed('language');
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageData {
  const LanguageData({
    required this.englishName,
    required this.nativeName,
  });

  final String englishName;
  final String nativeName;
}

const _kLanguageList = [
  LanguageData(englishName: 'English', nativeName: 'English'),
  LanguageData(englishName: 'Chinese (Simplified)', nativeName: '简体中文'),
  LanguageData(englishName: 'Chinese (Traditional)', nativeName: '繁體中文'),
  LanguageData(englishName: 'Indonesian', nativeName: 'Bahasa Indonesia'),
  LanguageData(englishName: 'Korean', nativeName: '한국어'),
  LanguageData(englishName: 'Myanmar', nativeName: 'မြန်မာ'),
  LanguageData(englishName: 'Russian', nativeName: 'Русский'),
  LanguageData(englishName: 'Spanish', nativeName: 'Español'),
  LanguageData(englishName: 'Thai', nativeName: 'ไทย'),
  LanguageData(englishName: 'Uzbek', nativeName: 'Oʻzbek'),
  LanguageData(englishName: 'Vietnamese', nativeName: 'Tiếng Việt'),
];

class _LanguageSearchDialog extends StatefulWidget {
  const _LanguageSearchDialog();

  @override
  State<_LanguageSearchDialog> createState() => _LanguageSearchDialogState();
}

class _LanguageSearchDialogState extends State<_LanguageSearchDialog> {
  final _searchController = TextEditingController();
  List<LanguageData> _filteredLanguages = _kLanguageList;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    if (query.isEmpty) {
      setState(() => _filteredLanguages = _kLanguageList);
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredLanguages = _kLanguageList.where((l) {
        return l.englishName.toLowerCase().contains(lowerQuery) ||
            l.nativeName.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          children: [
            Text(
              l10n.selectLanguage,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.searchLanguageHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _filter,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _filteredLanguages.length,
                separatorBuilder: (c, i) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final lang = _filteredLanguages[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(lang.englishName),
                    subtitle: lang.englishName != lang.nativeName
                        ? Text(
                            lang.nativeName,
                            style: const TextStyle(color: AppColors.sakura),
                          )
                        : null,
                    onTap: () => Navigator.pop(context, lang),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareDialog extends StatelessWidget {
  const _ShareDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share HanaUta',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.sakura,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: 'https://multilemon.github.io/lyrics_anki_app/',
                size: 200,
                backgroundColor: AppColors.surfaceLight,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.sakura,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Scan to open app',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
//  History Difficulty Chip
// ─────────────────────────────────────────────────

class _HistoryDifficultyChip extends StatelessWidget {
  const _HistoryDifficultyChip({required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final difficulty = item.difficulty;

    final (label, color, icon) = switch (difficulty) {
      SongDifficulty.beginner => (
        'Beginner',
        AppColors.success,
        Icons.sentiment_satisfied_alt_rounded,
      ),
      SongDifficulty.intermediate => (
        'Intermediate',
        AppColors.sakura,
        Icons.trending_up_rounded,
      ),
      SongDifficulty.advanced => (
        'Advanced',
        AppColors.accent,
        Icons.local_fire_department_rounded,
      ),
    };

    final counts = <String>[];
    if (item.vocabs.isNotEmpty) {
      counts.add('${item.vocabs.length} vocab');
    }
    if (item.grammar.isNotEmpty) {
      counts.add('${item.grammar.length} grammar');
    }
    if (item.kanji.isNotEmpty) {
      counts.add('${item.kanji.length} kanji');
    }

    return Row(
      children: [
        // Difficulty badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        if (counts.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(
            counts.join(' · '),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }
}

class _SrsDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(srsStatsProvider);
    final theme = Theme.of(context);

    final dueCount = stats['due'] as int? ?? 0;
    final totalCount = stats['total'] as int? ?? 0;
    final newCount = stats['new'] as int? ?? 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.surface.withValues(alpha: 0.6),
        border: Border.all(
          color: AppColors.sakura.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: AppColors.sakura),
              const SizedBox(width: 12),
              Text(
                'Vocabulary Mastery',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (dueCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$dueCount due',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SrsStatItem(label: 'Total', value: totalCount.toString()),
              _SrsStatItem(
                label: 'New',
                value: newCount.toString(),
                color: AppColors.matcha,
              ),
              _SrsStatItem(
                label: 'Due',
                value: dueCount.toString(),
                color: dueCount > 0 ? AppColors.error : AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: dueCount > 0
                  ? () {
                      context.pushNamed('review');
                    }
                  : null,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                dueCount > 0 ? 'Start Review' : 'Nothing to review yet',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sakura,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (totalCount > 0) ...[
            const SizedBox(height: 24),
            Divider(color: AppColors.sakura.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            _LearningProgressSection(stats: stats),
          ],
        ],
      ),
    );
  }
}

class _SrsStatItem extends StatelessWidget {
  const _SrsStatItem({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

// ─── Learning Progress Section ───

const _jlptColors = {
  'N5': Color(0xFF6BCB77), // Green
  'N4': Color(0xFF97D98F), // Light green
  'N3': Color(0xFFE8A87C), // Amber (sakura)
  'N2': Color(0xFFD4749C), // Pink (accent)
  'N1': Color(0xFFE06060), // Red
};

class _LearningProgressSection extends StatelessWidget {
  const _LearningProgressSection({required this.stats});

  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalWords = stats['total'] as int? ?? 0;
    final totalSongs = stats['songs'] as int? ?? 0;
    final jlptCounts = stats['jlpt'] as Map<String, int>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.trending_up_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Learning Progress',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '$totalWords words learned from $totalSongs songs',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _HomeJlptBarChart(distribution: jlptCounts),
        const SizedBox(height: 8),
        _HomeJlptLegend(distribution: jlptCounts),
      ],
    );
  }
}

class _HomeJlptBarChart extends StatelessWidget {
  const _HomeJlptBarChart({required this.distribution});

  final Map<String, int> distribution;

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold(0, (s, v) => s + v);
    if (total == 0) {
      return Container(
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    final segments = <_BarSegment>[];
    for (final level in ['N5', 'N4', 'N3', 'N2', 'N1']) {
      final count = distribution[level] ?? 0;
      if (count > 0) {
        segments.add(
          _BarSegment(
            fraction: count / total,
            color: _jlptColors[level]!,
          ),
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            for (var i = 0; i < segments.length; i++)
              Flexible(
                flex: (segments[i].fraction * 1000).round(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: segments[i].color,
                    borderRadius: BorderRadius.horizontal(
                      left: i == 0 ? const Radius.circular(6) : Radius.zero,
                      right: i == segments.length - 1
                          ? const Radius.circular(6)
                          : Radius.zero,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BarSegment {
  const _BarSegment({
    required this.fraction,
    required this.color,
  });

  final double fraction;
  final Color color;
}

class _HomeJlptLegend extends StatelessWidget {
  const _HomeJlptLegend({required this.distribution});

  final Map<String, int> distribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: levels.map((level) {
        final count = distribution[level] ?? 0;
        final color = count > 0 ? _jlptColors[level]! : AppColors.surfaceLight;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              level,
              style: theme.textTheme.labelSmall?.copyWith(
                color: count > 0
                    ? AppColors.textSecondary
                    : AppColors.textTertiary,
                fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
                fontSize: 10,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
