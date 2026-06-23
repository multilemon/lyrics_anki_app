import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/export_options_sheet.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/lyrics_header.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/lyrics_tab_bar.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/lyrics_tab_bar_view.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/widgets/quick_select_filters.dart';

class LyricsPage extends ConsumerStatefulWidget {
  const LyricsPage({
    super.key,
    this.title,
    this.artist,
    this.language,
  });

  final String? title;
  final String? artist;
  final String? language;

  @override
  ConsumerState<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends ConsumerState<LyricsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.title != null && widget.artist != null) {
        final currentAnalysis = ref.read(lyricsProvider).asData?.value;
        final needsAnalysis =
            currentAnalysis == null ||
            currentAnalysis.song.toLowerCase() != widget.title!.toLowerCase() ||
            currentAnalysis.artist.toLowerCase() !=
                widget.artist!.toLowerCase();

        if (needsAnalysis) {
          ref
              .read(lyricsProvider.notifier)
              .analyzeSong(
                widget.title!,
                widget.artist!,
                widget.language ?? 'English',
              );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const tabCount = 5;

    return DefaultTabController(
      length: tabCount,
      key: const ValueKey(tabCount),
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
            // FABs positioned above the bottom navigation bar
            Positioned(
              right: 16,
              bottom: MediaQuery.paddingOf(context).bottom + 16,
              child: Consumer(
                builder: (context, ref, child) {
                  final analysis = ref.watch(lyricsProvider).asData?.value;
                  final selectedState = ref.watch(selectionManagerProvider);
                  final hasSelection =
                      selectedState.vocabIndices.isNotEmpty ||
                      selectedState.grammarIndices.isNotEmpty ||
                      selectedState.kanjiIndices.isNotEmpty;

                  if (analysis == null) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
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
