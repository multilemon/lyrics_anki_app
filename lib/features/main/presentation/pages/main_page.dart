import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/features/home/presentation/pages/home_page.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/pages/lyrics_page.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';
import 'package:lyrics_anki_app/l10n/l10n.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main_page.g.dart';

@riverpod
class NavIndex extends _$NavIndex {
  @override
  int build() => 0;
  int get index => state;
  set index(int value) => state = value;
}

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..value = 1.0; // start fully visible
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Morphing cross-fade: fade-out + scale-down → update tab → fade-in + scale-up.
  Future<void> _switchTab(int index) async {
    final current = ref.read(navIndexProvider);
    if (current == index) return;

    // Phase 1: fade out current tab (180 ms, ease-in)
    await _fadeController.animateTo(
      0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeIn,
    );

    // Switch underlying content
    ref.read(navIndexProvider.notifier).index = index;

    // Phase 2: fade in new tab (280 ms, ease-out)
    await _fadeController.animateTo(
      1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navIndexProvider);
    final l10n = context.l10n;

    final pages = [
      HomePage(
        onNavigateToAnalyze:
            (
              title,
              artist,
              language, {
              customLyrics,
            }) {
              unawaited(_switchTab(1));
              // Clear any previous selection state
              ref.read(selectionManagerProvider.notifier).clear();
              unawaited(
                ref
                    .read(lyricsProvider.notifier)
                    .analyzeSong(
                      title,
                      artist,
                      language,
                      customLyrics: customLyrics,
                    ),
              );
            },
        onHistoryItemClick: (item) {
          unawaited(_switchTab(1));
          // Clear any previous selection state
          ref.read(selectionManagerProvider.notifier).clear();
          // Load from history
          ref.read(lyricsProvider.notifier).loadFromHistory(item);
        },
      ),
      const LyricsPage(),
    ];

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeController,
        child: ScaleTransition(
          scale:
              Tween<double>(
                begin: 0.97,
                end: 1,
              ).animate(
                CurvedAnimation(
                  parent: _fadeController,
                  curve: Curves.easeOut,
                ),
              ),
          child: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.85),
              border: Border(
                top: BorderSide(
                  color: AppColors.sakura.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: _switchTab,
              backgroundColor: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              indicatorColor: AppColors.sakura.withValues(alpha: 0.15),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(
                    Icons.home,
                    color: AppColors.sakura,
                  ),
                  label: l10n.homeTab,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.music_note_outlined),
                  selectedIcon: const Icon(
                    Icons.music_note,
                    color: AppColors.sakura,
                  ),
                  label: l10n.lyricsTab,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
