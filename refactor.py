import os
import re

file_path = 'lib/features/home/presentation/pages/home_page.dart'
with open(file_path, 'r') as f:
    content = f.read()

# 1. Imports
content = content.replace(
    "import 'package:lyrics_anki_app/features/settings/presentation/pages/settings_page.dart';",
    """import 'package:lyrics_anki_app/features/settings/presentation/pages/language_selection_page.dart';
import 'package:lyrics_anki_app/features/settings/presentation/providers/version_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';"""
)

# 2. Settings button in AppBar
content = content.replace(
    """          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.sakura,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
          ),""",
    """          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.sakura,
            onPressed: () => _showSettingsSheet(context),
          ),"""
)

# 3. Analyze New Song Row + Menu
analyze_song_old = """                            Text(
                              l10n.analyzeNewSong,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),"""
analyze_song_new = """                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.analyzeNewSong,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
                                  onSelected: (value) {
                                    if (value == 'paste_lyrics') {
                                      setState(() {
                                        _showLyricsInput = !_showLyricsInput;
                                        if (!_showLyricsInput) {
                                          _lyricsController.clear();
                                        }
                                      });
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'paste_lyrics',
                                      child: Text(_showLyricsInput ? 'Hide Paste Lyrics' : 'Paste Lyrics (Optional)'),
                                    ),
                                  ],
                                ),
                              ],
                            ),"""
content = content.replace(analyze_song_old, analyze_song_new)

# 4. Remove old Custom Lyrics Toggle
custom_lyrics_old = """                            // Custom Lyrics Toggle
                            _LyricsInputSection(
                              controller: _lyricsController,
                              isExpanded: _showLyricsInput,
                              onToggle: () {
                                setState(() {
                                  _showLyricsInput = !_showLyricsInput;
                                  if (!_showLyricsInput) {
                                    _lyricsController.clear();
                                  }
                                });
                              },
                            ),"""
custom_lyrics_new = """                            if (_showLyricsInput) ...[
                              const SizedBox(height: 12),
                              TextField(
                                controller: _lyricsController,
                                maxLines: 5,
                                minLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'Custom Lyrics',
                                  hintText: 'Paste lyrics here...',
                                  alignLabelWithHint: true,
                                ),
                              ),
                            ],"""
content = content.replace(custom_lyrics_old, custom_lyrics_new)

# 5. Add UI Language Selector below history
history_bottom_old = """              const SliverToBoxAdapter(child: SizedBox(height: 100)),"""
history_bottom_new = """              // UI Language Settings
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ListTile(
                    leading: const Icon(Icons.language, color: AppColors.sakura),
                    title: Text(l10n.uiLanguage),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const LanguageSelectionPage(),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),"""
content = content.replace(history_bottom_old, history_bottom_new)

# 6. Replace _LyricsInputSection at bottom with _ShareDialog and add _showSettingsSheet to _HomePageState
# First, insert _showSettingsSheet before the end of _HomePageState
settings_sheet_code = """  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
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
"""
content = content.replace("  Widget build(BuildContext context) {", settings_sheet_code + "\n  @override\n  Widget build(BuildContext context) {")

# Delete _LyricsInputSection
section_start = content.find("class _LyricsInputSection extends StatelessWidget {")
if section_start != -1:
    content = content[:section_start]

# Add _ShareDialog
share_dialog_code = """class _ShareDialog extends StatelessWidget {
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
"""
content += share_dialog_code

# 7. Update language list
old_lang_list = """const _kLanguageList = [
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
  LanguageData(englishName: 'Russian', nativeName: 'Русский'),
];"""

new_lang_list = """const _kLanguageList = [
  LanguageData(englishName: 'English', nativeName: 'English'),
  LanguageData(englishName: 'Thai', nativeName: 'ไทย'),
  LanguageData(englishName: 'Chinese (Simplified)', nativeName: '简体中文'),
  LanguageData(englishName: 'Korean', nativeName: '한국어'),
  LanguageData(englishName: 'Vietnamese', nativeName: 'Tiếng Việt'),
  LanguageData(englishName: 'Spanish', nativeName: 'Español'),
  LanguageData(englishName: 'Uzbek', nativeName: 'Oʻzbek'),
];"""
content = content.replace(old_lang_list, new_lang_list)

with open(file_path, 'w') as f:
    f.write(content)

