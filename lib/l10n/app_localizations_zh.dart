// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'ConnectHeart';

  @override
  String get notifications => '通知';

  @override
  String get receiveAlerts => '接收提醒';

  @override
  String get setTime => '设置时间';

  @override
  String get test => '测试';

  @override
  String get designSending => '设计与发送';

  @override
  String get cardBranding => '卡片页脚品牌';

  @override
  String get dataManagement => '数据管理';

  @override
  String get syncContacts => '同步联系人';

  @override
  String get backup => '备份';

  @override
  String get restore => '恢复';

  @override
  String get export => '导出';

  @override
  String get import => '导入';

  @override
  String get calendarSync => '日历同步';

  @override
  String get openCalendarApp => '打开日历应用';

  @override
  String get supportedCalendar => '支持的日历';

  @override
  String get appInfo => '应用信息与支持';

  @override
  String get version => '版本';

  @override
  String get contactUs => '联系我们';

  @override
  String get account => '账户';

  @override
  String get language => '语言';

  @override
  String get exit => '退出';

  @override
  String get myNameNickname => '我的名字/昵称';

  @override
  String get nameOrNickname => '名字或昵称';

  @override
  String get cardDisplayName => '卡片上显示的名字';

  @override
  String get nameUsedFooter => '此名字用于卡片编辑页面的页脚（签名）。';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get confirm => '确认';

  @override
  String get languageSetting => '语言设置';

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
  String get notificationBody => '今天向您珍貴的人传达心意吧！';
}
