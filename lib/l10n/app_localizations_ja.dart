// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ConnectHeart';

  @override
  String get notifications => '通知';

  @override
  String get receiveAlerts => 'アラートを受信';

  @override
  String get setTime => '時間設定';

  @override
  String get test => 'テスト';

  @override
  String get designSending => 'デザイン＆送信';

  @override
  String get cardBranding => 'カードフッターブランディング';

  @override
  String get dataManagement => 'データ管理';

  @override
  String get syncContacts => '連絡先同期';

  @override
  String get backup => 'バックアップ';

  @override
  String get restore => '復元';

  @override
  String get export => 'エクスポート';

  @override
  String get import => 'インポート';

  @override
  String get calendarSync => 'カレンダー同期';

  @override
  String get openCalendarApp => 'カレンダーアプリを開く';

  @override
  String get supportedCalendar => '対応カレンダー';

  @override
  String get appInfo => 'アプリ情報＆サポート';

  @override
  String get version => 'バージョン';

  @override
  String get contactUs => 'お問い合わせ';

  @override
  String get account => 'アカウント';

  @override
  String get language => '言語';

  @override
  String get exit => '終了';

  @override
  String get myNameNickname => '名前/ニックネーム';

  @override
  String get nameOrNickname => '名前またはニックネーム';

  @override
  String get cardDisplayName => 'カードに表示される名前';

  @override
  String get nameUsedFooter => 'この名前はカード作成画面のフッター（署名）に使用されます。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get confirm => '確認';

  @override
  String get languageSetting => '言語設定';

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
  String get notificationBody => '今日、大切な人に心を届けましょう！';
}
