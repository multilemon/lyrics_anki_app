// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'HanaUta';

  @override
  String get homeSubtitle =>
      'Học tiếng Nhật qua các bài hát yêu thích của bạn.';

  @override
  String get analyzeNewSong => 'Phân tích bài hát mới';

  @override
  String get songTitleLabel => 'Tên bài hát';

  @override
  String get songTitleHint => 'ví dụ: Lemon';

  @override
  String get artistNameLabel => 'Tên nghệ sĩ';

  @override
  String get artistNameHint => 'ví dụ: Kenshi Yonezu';

  @override
  String get targetLanguageLabel => 'Ngôn ngữ mục tiêu';

  @override
  String get analyzeButton => 'Phân tích ngay';

  @override
  String get recentAnalysisTitle => 'Phân tích gần đây';

  @override
  String get noHistory => 'Chưa có lịch sử.';

  @override
  String get unknownArtist => 'Nghệ sĩ không xác định';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get uiLanguage => 'Ngôn ngữ ứng dụng';

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';

  @override
  String get analysisInProgress =>
      'Đang phân tích...\nQuá trình này có thể mất vài phút.';

  @override
  String get songNotFound => 'Không tìm thấy bài hát';

  @override
  String songNotFoundMessage(String title, String artist) {
    return 'Chúng tôi không tìm thấy lời bài hát cho \"$title\" của \"$artist\".\nVui lòng kiểm tra lại tên.';
  }

  @override
  String get vocabTab => 'Từ vựng';

  @override
  String get grammarTab => 'Ngữ pháp';

  @override
  String get kanjiTab => 'Kanji';

  @override
  String get watchOnYouTube => 'Xem trên YouTube';

  @override
  String get searchLanguageHint => 'Tìm kiếm ngôn ngữ...';

  @override
  String get homeTab => 'Trang chủ';

  @override
  String get lyricsTab => 'Lời bài hát';

  @override
  String get exportToAnki => 'Xuất sang Anki';

  @override
  String get generatingApkg => 'Đang tạo tệp .apkg...';

  @override
  String get selectJlptLevel => 'Chọn cấp độ JLPT của bạn:';

  @override
  String get furiganaExplanation =>
      'Các từ trên cấp độ này sẽ bao gồm furigana ở mặt trước thẻ.';

  @override
  String get cancelButton => 'Hủy';

  @override
  String get exportButton => 'Xuất';

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
