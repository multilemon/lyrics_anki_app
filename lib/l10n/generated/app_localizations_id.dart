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
  String get noLyricsAvailable => 'Lirik tidak tersedia.';

  @override
  String get vocabType => 'Kosakata';

  @override
  String get grammarType => 'Tata Bahasa';

  @override
  String get kanjiType => 'Kanji';

  @override
  String get closeButton => 'Tutup';

  @override
  String get allFilter => 'Semua';

  @override
  String get otherFilter => 'Lainnya';

  @override
  String get learningModeLabel => 'Mode Belajar';

  @override
  String get modeJapanese => 'Belajar Bahasa Jepang';

  @override
  String get modeEnglish => 'Belajar Bahasa Inggris\n(For JP)';

  @override
  String get modeKorean => 'Belajar Bahasa Korea\n(For JP)';

  @override
  String get ipaType => 'IPA';

  @override
  String get structureType => 'Struktur';

  @override
  String get songTitleHintEn => 'cth. Shape of You';

  @override
  String get artistNameHintEn => 'cth. Ed Sheeran';

  @override
  String get songTitleHintKo => 'cth. Gangnam Style';

  @override
  String get artistNameHintKo => 'cth. PSY';

  @override
  String get romanizationType => 'Romanisasi';

  @override
  String get reverseLearningDescription =>
      'Mode Terbalik: untuk penutur Jepang belajar bahasa Inggris/Korea.';

  @override
  String get exportOptions => 'Opsi Ekspor';

  @override
  String get exportAnkiOption => 'Ekspor ke Anki (.apkg)';

  @override
  String get exportAnkiDescription => 'Dek flashcard untuk aplikasi Anki';

  @override
  String get exportPlainTextOption => 'Ekspor Daftar Kata (Teks)';

  @override
  String get exportPlainTextDescription =>
      'Kata dipisahkan koma untuk Renshuu, dll.';

  @override
  String get wordListCopied => 'Daftar kata disalin ke clipboard!';

  @override
  String get wordListDownloaded => 'Daftar kata berhasil diunduh!';

  @override
  String get exportWordsTitle => 'Ekspor Daftar Kata';

  @override
  String get includeVocab => 'Kosakata';

  @override
  String get includeKanji => 'Kanji';

  @override
  String get includeGrammar => 'Tata Bahasa';

  @override
  String get copyToClipboard => 'Salin';

  @override
  String get downloadAsFile => 'Unduh';

  @override
  String get noWordsToExport =>
      'Tidak ada kata untuk diekspor. Pilih setidaknya satu kategori.';
}
