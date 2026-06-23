// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HanaUta';

  @override
  String get homeSubtitle => 'Learn Japanese from your favorite songs.';

  @override
  String get analyzeNewSong => 'Analyze New Song';

  @override
  String get songTitleLabel => 'Song Title';

  @override
  String get songTitleHint => 'e.g. First Love';

  @override
  String get artistNameLabel => 'Artist Name';

  @override
  String get artistNameHint => 'e.g. Utada Hikaru';

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

  @override
  String get vocabType => 'Vocabulary';

  @override
  String get grammarType => 'Grammar';

  @override
  String get kanjiType => 'Kanji';

  @override
  String get closeButton => 'Close';

  @override
  String get allFilter => 'All';

  @override
  String get otherFilter => 'Other';

  @override
  String get learningModeLabel => 'Learning Mode';

  @override
  String get modeJapanese => 'Learn Japanese';

  @override
  String get modeEnglish => 'Learn English\n(For JP)';

  @override
  String get modeKorean => 'Learn Korean\n(For JP)';

  @override
  String get ipaType => 'IPA';

  @override
  String get structureType => 'Structure';

  @override
  String get songTitleHintEn => 'e.g. Shape of You';

  @override
  String get artistNameHintEn => 'e.g. Ed Sheeran';

  @override
  String get songTitleHintKo => 'e.g. Gangnam Style';

  @override
  String get artistNameHintKo => 'e.g. PSY';

  @override
  String get romanizationType => 'Romanization';

  @override
  String get reverseLearningDescription =>
      'Reverse Learning Mode: For Japanese speakers learning English/Korean.';

  @override
  String get exportOptions => 'Export Options';

  @override
  String get exportAnkiOption => 'Export to Anki (.apkg)';

  @override
  String get exportAnkiDescription => 'Flashcard deck for Anki app';

  @override
  String get exportPlainTextOption => 'Export Word List (Text)';

  @override
  String get exportPlainTextDescription =>
      'Comma-separated words for Renshuu, etc.';

  @override
  String get wordListCopied => 'Word list copied to clipboard!';

  @override
  String get wordListDownloaded => 'Word list downloaded!';

  @override
  String get exportWordsTitle => 'Export Word List';

  @override
  String get includeVocab => 'Vocabulary';

  @override
  String get includeKanji => 'Kanji';

  @override
  String get includeGrammar => 'Grammar';

  @override
  String get copyToClipboard => 'Copy';

  @override
  String get downloadAsFile => 'Download';

  @override
  String get noWordsToExport =>
      'No words to export. Please select at least one category.';

  @override
  String get translationTab => 'Translation';

  @override
  String get nuanceExplanation => 'Nuance & Interpretation';

  @override
  String get noTranslationAvailable =>
      'Translation not available for this song. Try re-analyzing to generate verse translations.';
}
