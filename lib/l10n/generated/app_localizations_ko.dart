// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'HanaUta';

  @override
  String get homeSubtitle => '좋아하는 노래로 일본어를 배워보세요.';

  @override
  String get analyzeNewSong => '새 노래 분석';

  @override
  String get songTitleLabel => '노래 제목';

  @override
  String get songTitleHint => '예: Lemon';

  @override
  String get artistNameLabel => '아티스트 이름';

  @override
  String get artistNameHint => '예: 요네즈 켄시';

  @override
  String get targetLanguageLabel => '목표 언어';

  @override
  String get analyzeButton => '노래 분석';

  @override
  String get recentAnalysisTitle => '최근 분석';

  @override
  String get noHistory => '기록이 없습니다.';

  @override
  String get unknownArtist => '알 수 없는 아티스트';

  @override
  String get settingsTitle => '설정';

  @override
  String get uiLanguage => 'UI 언어';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get analysisInProgress => '분석 중입니다...\n몇 분 정도 걸릴 수 있습니다.';

  @override
  String get songNotFound => '노래를 찾을 수 없음';

  @override
  String songNotFoundMessage(String title, String artist) {
    return '\"$artist\"의 노래 \"$title\" 가사를 찾을 수 없습니다.\n이름이 정확한지 확인해 주세요.';
  }

  @override
  String get vocabTab => '단어';

  @override
  String get grammarTab => '문법';

  @override
  String get kanjiTab => '한자';

  @override
  String get watchOnYouTube => 'YouTube에서 보기';

  @override
  String get searchLanguageHint => '언어 검색...';

  @override
  String get homeTab => '홈';

  @override
  String get lyricsTab => '가사';

  @override
  String get exportToAnki => 'Anki로 내보내기';

  @override
  String get generatingApkg => '.apkg 파일 생성 중...';

  @override
  String get selectJlptLevel => 'JLPT 레벨 선택:';

  @override
  String get furiganaExplanation => '이 레벨 이상의 단어는 카드 앞면에 후리가나가 포함됩니다.';

  @override
  String get cancelButton => '취소';

  @override
  String get exportButton => '내보내기';

  @override
  String get noLyricsAvailable => '가사가 없습니다.';
}
