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

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);
    final l10n = context.l10n;

    // List of pages
    final pages = [
      HomePage(
        onNavigateToAnalyze: (
          title,
          artist,
          language, {
          customLyrics,
        }) async {
          // Switch to Lyrics Tab IMMEDIATELY
          ref.read(navIndexProvider.notifier).index = 1;
          // Clear any previous selection state
          ref.read(selectionManagerProvider.notifier).clear();

          // Trigger analysis (fire and forget for UI,
          // but provider handles state)
          unawaited(
            ref.read(lyricsProvider.notifier).analyzeSong(
                  title,
                  artist,
                  language,
                  customLyrics: customLyrics,
                ),
          );
        },
        onHistoryItemClick: (
          item,
        ) {
          // Switch to Lyrics Tab IMMEDIATELY
          ref.read(navIndexProvider.notifier).index = 1;
          // Clear any previous selection state
          ref.read(selectionManagerProvider.notifier).clear();

          // Load from history
          ref.read(lyricsProvider.notifier).loadFromHistory(item);
        },
      ),
      const LyricsPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
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
              onDestinationSelected: (index) {
                ref.read(navIndexProvider.notifier).index = index;
              },
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
