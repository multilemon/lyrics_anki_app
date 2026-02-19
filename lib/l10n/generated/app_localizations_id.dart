// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'HanaUta';

  @override
  String get homeSubtitle => 'Belajar bahasa Jepang dari lagu favorit Anda.';

  @override
  String get analyzeNewSong => 'Analisis Lagu Baru';

  @override
  String get songTitleLabel => 'Judul Lagu';

  @override
  String get songTitleHint => 'contoh: Lemon';

  @override
  String get artistNameLabel => 'Nama Artis';

  @override
  String get artistNameHint => 'contoh: Kenshi Yonezu';

  @override
  String get targetLanguageLabel => 'Bahasa Target';

  @override
  String get analyzeButton => 'Analisis Lagu';

  @override
  String get recentAnalysisTitle => 'Analisis Terbaru';

  @override
  String get noHistory => 'Belum ada riwayat.';

  @override
  String get unknownArtist => 'Artis Tidak Diketahui';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get uiLanguage => 'Bahasa Antarmuka';

  @override
  String get selectLanguage => 'Pilih Bahasa';

  @override
  String get analysisInProgress =>
      'Sedang menganalisis...\nIni mungkin memakan waktu beberapa menit.';

  @override
  String get songNotFound => 'Lagu Tidak Ditemukan';

  @override
  String songNotFoundMessage(String title, String artist) {
    return 'Kami tidak dapat menemukan lirik untuk \"$title\" oleh \"$artist\".\nSilakan periksa apakah namanya benar.';
  }

  @override
  String get vocabTab => 'Kosakata';

  @override
  String get grammarTab => 'Tata Bahasa';

  @override
  String get kanjiTab => 'Kanji';

  @override
  String get watchOnYouTube => 'Tonton di YouTube';

  @override
  String get searchLanguageHint => 'Cari bahasa...';

  @override
  String get homeTab => 'Beranda';

  @override
  String get lyricsTab => 'Lirik';

  @override
  String get exportToAnki => 'Ekspor ke Anki';

  @override
  String get generatingApkg => 'Membuat file .apkg...';

  @override
  String get selectJlptLevel => 'Pilih Level JLPT Anda:';

  @override
  String get furiganaExplanation =>
      'Kata-kata di atas level ini akan menyertakan furigana di bagian depan kartu.';

  @override
  String get cancelButton => 'Batal';

  @override
  String get exportButton => 'Ekspor';

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
