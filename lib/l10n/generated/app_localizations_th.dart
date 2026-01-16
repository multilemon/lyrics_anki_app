// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'HanaUta';

  @override
  String get homeSubtitle => 'เรียนภาษาญี่ปุ่นจากเพลงโปรดของคุณ';

  @override
  String get analyzeNewSong => 'วิเคราะห์เพลงใหม่';

  @override
  String get songTitleLabel => 'ชื่อเพลง';

  @override
  String get songTitleHint => 'เช่น Lemon';

  @override
  String get artistNameLabel => 'ชื่อศิลปิน';

  @override
  String get artistNameHint => 'เช่น Kenshi Yonezu';

  @override
  String get targetLanguageLabel => 'ภาษาเป้าหมาย';

  @override
  String get analyzeButton => 'วิเคราะห์เพลง';

  @override
  String get recentAnalysisTitle => 'ประวัติการวิเคราะห์';

  @override
  String get noHistory => 'ยังไม่มีประวัติ';

  @override
  String get unknownArtist => 'ไม่ทราบศิลปิน';

  @override
  String get settingsTitle => 'การตั้งค่า';

  @override
  String get uiLanguage => 'ภาษาของแอป';

  @override
  String get selectLanguage => 'เลือกภาษา';

  @override
  String get analysisInProgress => 'กำลังวิเคราะห์...\nอาจใช้เวลาสักครู่';

  @override
  String get songNotFound => 'ไม่พบเพลง';

  @override
  String songNotFoundMessage(String title, String artist) {
    return 'เราไม่พบเนื้อเพลงสำหรับ \"$title\" โดย \"$artist\"\nโปรดตรวจสอบว่าชื่อถูกต้องหรือไม่';
  }

  @override
  String get vocabTab => 'คำศัพท์';

  @override
  String get grammarTab => 'ไวยากรณ์';

  @override
  String get kanjiTab => 'คันจิ';

  @override
  String get watchOnYouTube => 'ดูบน YouTube';

  @override
  String get searchLanguageHint => 'ค้นหาภาษา...';

  @override
  String get homeTab => 'หน้าแรก';

  @override
  String get lyricsTab => 'เนื้อเพลง';

  @override
  String get exportToAnki => 'ส่งออกไปยัง Anki';

  @override
  String get generatingApkg => 'กำลังสร้างไฟล์ .apkg...';

  @override
  String get selectJlptLevel => 'เลือกระดับ JLPT ของคุณ:';

  @override
  String get furiganaExplanation => 'คำศัพท์ที่สูงกว่าระดับนี้จะมีฟุริงานะที่ด้านหน้าของการ์ด';

  @override
  String get cancelButton => 'ยกเลิก';

  @override
  String get exportButton => 'ส่งออก';
}
