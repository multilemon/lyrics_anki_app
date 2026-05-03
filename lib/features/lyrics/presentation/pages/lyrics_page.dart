import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/learning_mode.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/export_options_sheet.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/lyrics_header.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/lyrics_tab_bar.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/lyrics_tab_bar_view.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/native_video_player.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/quick_select_filters.dart';


class LyricsPage extends ConsumerStatefulWidget {
  const LyricsPage({super.key});

  @override
  ConsumerState<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends ConsumerState<LyricsPage> {
  bool _showPlayer = false;
  bool _isDragging = false;
  Offset? _playerOffset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Reset video player when song changes
    ref.listen(lyricsProvider, (_, __) {
      if (_showPlayer) {
        setState(() => _showPlayer = false);
      }
    });

    // Watch the async state for data
    final analysis = ref.watch(lyricsProvider).asData?.value;

    // Use currentMode to determine tab layout even during loading
    final notifier = ref.read(lyricsProvider.notifier);
    final currentMode = notifier.currentMode;

    // Logic: Trust data if present, otherwise use intended mode
    final bool isReverseLearning;
    if (analysis != null) {
      isReverseLearning = analysis.enVocab != null;
    } else {
      isReverseLearning = currentMode == LearningMode.english ||
          currentMode == LearningMode.korean;
    }

    final tabCount = isReverseLearning ? 3 : 4;

    return DefaultTabController(
      length: tabCount,
      key: ValueKey(tabCount),
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: const Column(
                    children: [
                      SizedBox(height: 8),

                      // Song Title & Artist Header
                      LyricsHeader(),

                      // Filters (Quick Select) - Applies to all tabs
                      QuickSelectFilters(),
                      SizedBox(height: 8),

                      // Tabs
                      LyricsTabBar(),
                      SizedBox(height: 8),

                      // Results Area
                      Expanded(
                        child: LyricsTabBarView(),
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
                  final analysis = ref.watch(lyricsProvider).asData?.value;
                  if (analysis?.youtubeId == null) {
                    return const SizedBox.shrink();
                  }

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
                      color: AppColors.surface,
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
                                color: AppColors.surface,
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
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
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
                                        // Keep _playerOffset to remember
                                        // position
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
                                      child:
                                          Container(color: Colors.transparent),
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

            // FABs positioned above the bottom navigation bar
            Positioned(
              right: 16,
              bottom: MediaQuery.paddingOf(context).bottom + 16,
              child: Consumer(
                builder: (context, ref, child) {
                  final analysis = ref.watch(lyricsProvider).asData?.value;
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
                          backgroundColor: AppColors.sakura,
                          onPressed: () =>
                              setState(() => _showPlayer = !_showPlayer),
                          child: _showPlayer
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.smart_display_rounded,
                                      color: Colors.white,
                                    ),
                                    // Masking "Eraser" to separate slash
                                    // from icon
                                    Transform.rotate(
                                      angle: -0.785, // -45 degrees
                                      child: Container(
                                        width: 4.5,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: AppColors.sakura,
                                          borderRadius:
                                              BorderRadius.circular(2),
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
                                          borderRadius:
                                              BorderRadius.circular(1),
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
                          backgroundColor: AppColors.sakura,
                          onPressed: () => showExportOptionsSheet(
                            context: context,
                            ref: ref,
                          ),
                          child: const Icon(
                            Icons.file_upload_outlined,
                            color: Colors.white,
                          ),
                        ),
                    ],
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
