// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'ConnectHeart';

  @override
  String get notifications => '알림';

  @override
  String get receiveAlerts => '알림 받기';

  @override
  String get setTime => '시간 설정';

  @override
  String get test => '테스트';

  @override
  String get designSending => '디자인 & 발송';

  @override
  String get cardBranding => '카드 하단 브랜딩';

  @override
  String get dataManagement => '데이터 관리';

  @override
  String get syncContacts => '연락처 동기화';

  @override
  String get backup => '백업';

  @override
  String get restore => '복원';

  @override
  String get export => '내보내기';

  @override
  String get import => '가져오기';

  @override
  String get calendarSync => '캘린더 연동';

  @override
  String get openCalendarApp => '외부 캘린더 앱 열기';

  @override
  String get supportedCalendar => '지원 캘린더 안내';

  @override
  String get appInfo => '앱 정보 & 지원';

  @override
  String get version => '버전';

  @override
  String get contactUs => '문의하기';

  @override
  String get account => '계정';

  @override
  String get language => '언어';

  @override
  String get exit => '종료';

  @override
  String get myNameNickname => '내 이름/별명';

  @override
  String get nameOrNickname => '이름 또는 별명';

  @override
  String get cardDisplayName => '카드에 표시될 이름';

  @override
  String get nameUsedFooter => '이 이름은 카드 쓰기 화면의 Footer(서명)에 사용됩니다.';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

  @override
  String get confirm => '확인';

  @override
  String get languageSetting => '언어 설정';

  @override
  String languageChanged(String language) {
    return '언어가 $language로 변경되었습니다. (앱 재시작 필요)';
  }

  @override
  String get backupComplete => '백업 완료';

  @override
  String get backupDataSaved => '다음 데이터가 백업되었습니다:';

  @override
  String get contacts => '연락처';

  @override
  String get schedules => '일정';

  @override
  String get savedCards => '저장된 카드';

  @override
  String get settings => '설정';

  @override
  String get included => '포함';

  @override
  String get savePath => '저장 위치';

  @override
  String get restoreData => '데이터 복원';

  @override
  String get restoreWarning => '기존 데이터가 백업 데이터로 교체됩니다.\n\n계속하시겠습니까?';

  @override
  String get selectBackupFile => '백업 파일 선택';

  @override
  String get noBackupFile => '백업 파일이 없습니다. 먼저 백업을 진행해주세요.';

  @override
  String get doBackup => '백업하기';

  @override
  String restoreComplete(int count) {
    return '복원 완료! 연락처 $count명 복원됨';
  }

  @override
  String get supportedCalendars => '지원되는 캘린더';

  @override
  String get googleCalendar => '구글 캘린더';

  @override
  String get samsungCalendar => '삼성 캘린더';

  @override
  String get calendarAutoDisplay => '위 캘린더에 일정을 등록하시면 앱에서 자동으로 표시됩니다.';

  @override
  String get unsupportedCalendars => '미지원 캘린더';

  @override
  String get naverCalendar => '네이버 캘린더';

  @override
  String get kakaoCalendar => '카카오톡 캘린더';

  @override
  String get noStandardSync => 'Android 표준 캘린더 동기화를 지원하지 않아 일정을 읽을 수 없습니다.';

  @override
  String get notificationTitle => '💝 ConnectHeart';

  @override
  String get notificationBody => '오늘 소중한 사람에게 마음을 전해보세요!';
}
