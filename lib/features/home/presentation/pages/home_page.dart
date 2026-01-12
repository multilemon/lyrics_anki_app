import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/features/home/presentation/providers/history_notifier.dart';
import 'package:lyrics_anki_app/features/lyrics/domain/entities/lyrics.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    required this.onNavigateToAnalyze,
    this.onHistoryItemClick,
    super.key,
  });

  final void Function(String title, String artist, String language)
      onNavigateToAnalyze;
  final void Function(HistoryItem item)? onHistoryItemClick;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'Thai',
    'Korean',
    'Indonesian',
    'Burmese',
    'Uzbek',
    'Vietnamese',
    'Chinese (Simplified)',
    'Chinese (Traditional)',
    'Spanish',
    'French',
  ];

  void _handleAnalyze() {
    final title = _titleController.text.trim();
    final artist = _artistController.text.trim();

    if (title.isEmpty || artist.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both Song Title and Artist Name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    widget.onNavigateToAnalyze(title, artist, _selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F7),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HanaUta',
                        style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 32,
                          color: Color(0xFFD4A5A5),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Learn Japanese from your favorite songs.',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF8E7F7F).withValues(alpha: 0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Analysis Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4A5A5).withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Analyze New Song',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF8E7F7F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Song Title
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Song Title',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            hintText: 'e.g. Lemon',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color(0xFFF9F6F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.music_note,
                              color: Color(0xFFD4A5A5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Artist Name
                        TextField(
                          controller: _artistController,
                          decoration: InputDecoration(
                            labelText: 'Artist Name',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            hintText: 'e.g. Kenshi Yonezu',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color(0xFFF9F6F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Color(0xFFD4A5A5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Target Language Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F6F7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLanguage,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFFD4A5A5),
                              ),
                              items: _languages.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedLanguage = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Analyze Button
                        ElevatedButton(
                          onPressed: _handleAnalyze,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4A5A5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Analyze Song',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 48)),

              // History Section Title
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Recent Analysis',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Serif',
                      color: Color(0xFF8E7F7F),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // History List
              Consumer(
                builder: (context, ref, child) {
                  final historyAsync = ref.watch(historyNotifierProvider);

                  return historyAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'No history yet.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = items[index];
                            final artist = item.artist.isNotEmpty
                                ? item.artist
                                : 'Unknown Artist';
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  title: Text(
                                    item.songTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF5D5D5D),
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$artist • ${item.targetLanguage}',
                                    style: const TextStyle(
                                      color: Color(0xFFD4A5A5),
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: Color(0xFFD4A5A5),
                                  ),
                                  onTap: () {
                                    if (widget.onHistoryItemClick != null) {
                                      widget.onHistoryItemClick!(item);
                                    } else {
                                      widget.onNavigateToAnalyze(
                                        item.songTitle,
                                        item.artist,
                                        item.targetLanguage,
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                          childCount: items.length,
                        ),
                      );
                    },
                    loading: () => SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Column(
                            children: List.generate(
                              3,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    error: (e, s) =>
                        SliverToBoxAdapter(child: Text('Error: $e')),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}
