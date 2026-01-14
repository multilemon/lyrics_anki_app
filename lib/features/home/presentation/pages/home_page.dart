import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyrics_anki_app/core/providers/hive_provider.dart';
import 'package:lyrics_anki_app/core/theme/app_colors.dart';
import 'package:lyrics_anki_app/core/theme/app_text_styles.dart';
import 'package:lyrics_anki_app/features/home/presentation/providers/history_notifier.dart';
import 'package:lyrics_anki_app/features/home/presentation/providers/home_ui_providers.dart';
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

  @override
  void initState() {
    super.initState();
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
    _titleController.dispose();
    _artistController.dispose();
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

    widget.onNavigateToAnalyze(title, artist, _selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    // Listen for clear signal
    ref.listen(clearHomeFormSignalProvider, (_, __) {
      _titleController.clear();
      _artistController.clear();
    });

    final theme = Theme.of(context);

    return Scaffold(
      // backgroundColor: theme.scaffoldBackgroundColor, // Handled by theme
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
                      Text(
                        'HanaUta',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: AppColors.sakuraDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Learn Japanese from your favorite songs.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
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
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sakuraDark.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Analyze New Song',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Song Title
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Song Title',
                            hintText: 'e.g. Lemon',
                            prefixIcon: Icon(Icons.music_note),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Artist Name
                        TextField(
                          controller: _artistController,
                          decoration: const InputDecoration(
                            labelText: 'Artist Name',
                            hintText: 'e.g. Kenshi Yonezu',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Target Language Selector
                        InkWell(
                          onTap: () async {
                            final result = await showDialog<LanguageData>(
                              context: context,
                              builder: (context) =>
                                  const _LanguageSearchDialog(),
                            );
                            if (result != null) {
                              setState(() {
                                _selectedLanguage = result.englishName;
                              });
                              await ref
                                  .read(settingsBoxProvider)
                                  ?.put('target_language', result.englishName);
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Target Language',
                                      style: theme.textTheme.labelSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedLanguage,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.sakuraDark,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Analyze Button
                        ElevatedButton(
                          onPressed: _handleAnalyze,
                          child: const Text('Analyze Song'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 48)),

              // History Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Recent Analysis',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Serif',
                      color: AppColors.textSecondary,
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
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'No history yet.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
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
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  clipBehavior: Clip.antiAlias,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    hoverColor: AppColors.sakuraLight
                                        .withValues(alpha: 0.3),
                                    splashColor: AppColors.sakuraLight,
                                    title: Text(
                                      item.songTitle,
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '$artist • ${item.targetLanguage}',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: AppColors.sakuraDark,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: AppColors.sakuraDark,
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
  LanguageData(englishName: 'Thai', nativeName: 'ไทย'),
  LanguageData(englishName: 'Korean', nativeName: '한국어'),
  LanguageData(englishName: 'Indonesian', nativeName: 'Bahasa Indonesia'),
  LanguageData(englishName: 'Burmese', nativeName: 'ဗမာစာ'),
  LanguageData(englishName: 'Uzbek', nativeName: 'Oʻzbek'),
  LanguageData(englishName: 'Vietnamese', nativeName: 'Tiếng Việt'),
  LanguageData(englishName: 'Chinese (Simplified)', nativeName: '简体中文'),
  LanguageData(englishName: 'Chinese (Traditional)', nativeName: '繁體中文'),
  LanguageData(englishName: 'Spanish', nativeName: 'Español'),
  LanguageData(englishName: 'French', nativeName: 'Français'),
  LanguageData(englishName: 'Japanese', nativeName: '日本語'),
  LanguageData(englishName: 'German', nativeName: 'Deutsch'),
  LanguageData(englishName: 'Portuguese', nativeName: 'Português'),
  LanguageData(englishName: 'Italian', nativeName: 'Italiano'),
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
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          children: [
            Text(
              'Select Language',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search language...',
                prefixIcon: Icon(Icons.search),
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
                            style: TextStyle(color: AppColors.sakuraDark),
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
