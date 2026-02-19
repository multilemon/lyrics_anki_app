// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'HanaUta';

  @override
  String get homeSubtitle =>
      'Sevimli qoʻshiqlaringiz orqali yapon tilini oʻrganing.';

  @override
  String get analyzeNewSong => 'Yangi qoʻshiqni tahlil qilish';

  @override
  String get songTitleLabel => 'Qoʻshiq nomi';

  @override
  String get songTitleHint => 'masalan: Lemon';

  @override
  String get artistNameLabel => 'Ijrochi';

  @override
  String get artistNameHint => 'masalan: Kenshi Yonezu';

  @override
  String get targetLanguageLabel => 'Maqsadli til';

  @override
  String get analyzeButton => 'Tahlil qilish';

  @override
  String get recentAnalysisTitle => 'Soʻnggi tahlillar';

  @override
  String get noHistory => 'Hozircha tarix yoʻq.';

  @override
  String get unknownArtist => 'Nomaʼlum ijrochi';

  @override
  String get settingsTitle => 'Sozlamalar';

  @override
  String get uiLanguage => 'Ilova tili';

  @override
  String get selectLanguage => 'Tilni tanlang';

  @override
  String get analysisInProgress =>
      'Tahlil qilinmoqda...\nBu bir necha daqiqa vaqt olishi mumkin.';

  @override
  String get songNotFound => 'Qoʻshiq topilmadi';

  @override
  String songNotFoundMessage(String title, String artist) {
    return '\"$artist\" ijrosidagi \"$title\" qoʻshigʻi matni topilmadi.\nIltimos, nom toʻgʻriligini tekshiring.';
  }

  @override
  String get vocabTab => 'Soʻzlar';

  @override
  String get grammarTab => 'Grammatika';

  @override
  String get kanjiTab => 'Kanji';

  @override
  String get watchOnYouTube => 'YouTube-da koʻrish';

  @override
  String get searchLanguageHint => 'Tilni qidirish...';

  @override
  String get homeTab => 'Bosh sahifa';

  @override
  String get lyricsTab => 'Qoʻshiq matni';

  @override
  String get exportToAnki => 'Anki-ga eksport qilish';

  @override
  String get generatingApkg => '.apkg fayli yaratilmoqda...';

  @override
  String get selectJlptLevel => 'JLPT darajangizni tanlang:';

  @override
  String get furiganaExplanation =>
      'Ushbu darajadan yuqori soʻzlar kartaning old tomonida furiganani oʻz ichiga oladi.';

  @override
  String get cancelButton => 'Bekor qilish';

  @override
  String get exportButton => 'Eksport';

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
  String get modeEnglish => 'Learn English';

  @override
  String get modeKorean => 'Learn Korean';

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
}
