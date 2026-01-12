import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/features/home/presentation/pages/home_page.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/pages/lyrics_page.dart';
import 'package:lyrics_anki_app/features/lyrics/presentation/providers/lyrics_notifier.dart';

// Simple state provider for the current tab index
final navIndexProvider = StateProvider<int>((ref) => 0);

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);

    // List of pages
    final pages = [
      HomePage(
        onNavigateToAnalyze: (title, artist, language) async {
          // Switch to Lyrics Tab IMMEDIATELY
          ref.read(navIndexProvider.notifier).state = 1;

          // Trigger analysis (fire and forget for UI, but provider handles state)
          await ref
              .read(lyricsNotifierProvider.notifier)
              .analyzeSong(title, artist, language);
        },
      ),
      const LyricsPage(),
      // Placeholder for future Profile/Settings or Anki Deck view
      const Center(child: Text('Settings (Coming Soon)')),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(navIndexProvider.notifier).state = index;
        },
        backgroundColor: Colors.white,
        elevation: 1,
        indicatorColor: const Color(0xFFD4A5A5).withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFFD4A5A5)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.music_note_outlined),
            selectedIcon: Icon(Icons.music_note, color: Color(0xFFD4A5A5)),
            label: 'Lyrics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: Color(0xFFD4A5A5)),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
