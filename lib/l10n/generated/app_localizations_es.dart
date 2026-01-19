// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'HanaUta';

  @override
  String get homeSubtitle => 'Learn Japanese from your favorite songs.';

  @override
  String get analyzeNewSong => 'Analyze New Song';

  @override
  String get songTitleLabel => 'Song Title';

  @override
  String get songTitleHint => 'e.g. Lemon';

  @override
  String get artistNameLabel => 'Artist Name';

  @override
  String get artistNameHint => 'e.g. Kenshi Yonezu';

  @override
  String get targetLanguageLabel => 'Target Language';

  @override
  String get analyzeButton => 'Analyze Song';

  @override
  String get recentAnalysisTitle => 'Recent Analysis';

  @override
  String get noHistory => 'No history yet.';

  @override
  String get unknownArtist => 'Unknown Artist';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get uiLanguage => 'UI Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get analysisInProgress =>
      'Analysis in progress...\nThis could take a few minutes.';

  @override
  String get songNotFound => 'Song Not Found';

  @override
  String songNotFoundMessage(String title, String artist) {
    return 'We couldn\'t find lyrics for \"$title\" by \"$artist\".\nPlease check if the name is correct.';
  }

  @override
  String get vocabTab => 'Vocab';

  @override
  String get grammarTab => 'Grammar';

  @override
  String get kanjiTab => 'Kanji';

  @override
  String get watchOnYouTube => 'Watch on YouTube';

  @override
  String get searchLanguageHint => 'Search language...';

  @override
  String get homeTab => 'Home';

  @override
  String get lyricsTab => 'Lyrics';

  @override
  String get exportToAnki => 'Export to Anki';

  @override
  String get generatingApkg => 'Generating .apkg file...';

  @override
  String get selectJlptLevel => 'Select your JLPT Level:';

  @override
  String get furiganaExplanation =>
      'Words above this level will include furigana on the front of the card.';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get exportButton => 'Export';

  @override
  String get noLyricsAvailable => 'No lyrics available.';
}
