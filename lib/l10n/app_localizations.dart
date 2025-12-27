import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'ConnectHeart'**
  String get appTitle;

  /// No description provided for @notifications.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get notifications;

  /// No description provided for @receiveAlerts.
  ///
  /// In ko, this message translates to:
  /// **'알림 받기'**
  String get receiveAlerts;

  /// No description provided for @setTime.
  ///
  /// In ko, this message translates to:
  /// **'시간 설정'**
  String get setTime;

  /// No description provided for @test.
  ///
  /// In ko, this message translates to:
  /// **'테스트'**
  String get test;

  /// No description provided for @designSending.
  ///
  /// In ko, this message translates to:
  /// **'디자인 & 발송'**
  String get designSending;

  /// No description provided for @cardBranding.
  ///
  /// In ko, this message translates to:
  /// **'카드 하단 브랜딩'**
  String get cardBranding;

  /// No description provided for @dataManagement.
  ///
  /// In ko, this message translates to:
  /// **'데이터 관리'**
  String get dataManagement;

  /// No description provided for @syncContacts.
  ///
  /// In ko, this message translates to:
  /// **'연락처 동기화'**
  String get syncContacts;

  /// No description provided for @backup.
  ///
  /// In ko, this message translates to:
  /// **'백업'**
  String get backup;

  /// No description provided for @restore.
  ///
  /// In ko, this message translates to:
  /// **'복원'**
  String get restore;

  /// No description provided for @export.
  ///
  /// In ko, this message translates to:
  /// **'내보내기'**
  String get export;

  /// No description provided for @import.
  ///
  /// In ko, this message translates to:
  /// **'가져오기'**
  String get import;

  /// No description provided for @calendarSync.
  ///
  /// In ko, this message translates to:
  /// **'캘린더 연동'**
  String get calendarSync;

  /// No description provided for @openCalendarApp.
  ///
  /// In ko, this message translates to:
  /// **'외부 캘린더 앱 열기'**
  String get openCalendarApp;

  /// No description provided for @supportedCalendar.
  ///
  /// In ko, this message translates to:
  /// **'지원 캘린더 안내'**
  String get supportedCalendar;

  /// No description provided for @appInfo.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보 & 지원'**
  String get appInfo;

  /// No description provided for @version.
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get version;

  /// No description provided for @contactUs.
  ///
  /// In ko, this message translates to:
  /// **'문의하기'**
  String get contactUs;

  /// No description provided for @account.
  ///
  /// In ko, this message translates to:
  /// **'계정'**
  String get account;

  /// No description provided for @language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get language;

  /// No description provided for @exit.
  ///
  /// In ko, this message translates to:
  /// **'종료'**
  String get exit;

  /// No description provided for @myNameNickname.
  ///
  /// In ko, this message translates to:
  /// **'내 이름/별명'**
  String get myNameNickname;

  /// No description provided for @nameOrNickname.
  ///
  /// In ko, this message translates to:
  /// **'이름 또는 별명'**
  String get nameOrNickname;

  /// No description provided for @cardDisplayName.
  ///
  /// In ko, this message translates to:
  /// **'카드에 표시될 이름'**
  String get cardDisplayName;

  /// No description provided for @nameUsedFooter.
  ///
  /// In ko, this message translates to:
  /// **'이 이름은 카드 쓰기 화면의 Footer(서명)에 사용됩니다.'**
  String get nameUsedFooter;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @languageSetting.
  ///
  /// In ko, this message translates to:
  /// **'언어 설정'**
  String get languageSetting;

  /// No description provided for @languageChanged.
  ///
  /// In ko, this message translates to:
  /// **'언어가 {language}로 변경되었습니다. (앱 재시작 필요)'**
  String languageChanged(String language);

  /// No description provided for @backupComplete.
  ///
  /// In ko, this message translates to:
  /// **'백업 완료'**
  String get backupComplete;

  /// No description provided for @backupDataSaved.
  ///
  /// In ko, this message translates to:
  /// **'다음 데이터가 백업되었습니다:'**
  String get backupDataSaved;

  /// No description provided for @contacts.
  ///
  /// In ko, this message translates to:
  /// **'연락처'**
  String get contacts;

  /// No description provided for @schedules.
  ///
  /// In ko, this message translates to:
  /// **'일정'**
  String get schedules;

  /// No description provided for @savedCards.
  ///
  /// In ko, this message translates to:
  /// **'저장된 카드'**
  String get savedCards;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @included.
  ///
  /// In ko, this message translates to:
  /// **'포함'**
  String get included;

  /// No description provided for @savePath.
  ///
  /// In ko, this message translates to:
  /// **'저장 위치'**
  String get savePath;

  /// No description provided for @restoreData.
  ///
  /// In ko, this message translates to:
  /// **'데이터 복원'**
  String get restoreData;

  /// No description provided for @restoreWarning.
  ///
  /// In ko, this message translates to:
  /// **'기존 데이터가 백업 데이터로 교체됩니다.\n\n계속하시겠습니까?'**
  String get restoreWarning;

  /// No description provided for @selectBackupFile.
  ///
  /// In ko, this message translates to:
  /// **'백업 파일 선택'**
  String get selectBackupFile;

  /// No description provided for @noBackupFile.
  ///
  /// In ko, this message translates to:
  /// **'백업 파일이 없습니다. 먼저 백업을 진행해주세요.'**
  String get noBackupFile;

  /// No description provided for @doBackup.
  ///
  /// In ko, this message translates to:
  /// **'백업하기'**
  String get doBackup;

  /// No description provided for @restoreComplete.
  ///
  /// In ko, this message translates to:
  /// **'복원 완료! 연락처 {count}명 복원됨'**
  String restoreComplete(int count);

  /// No description provided for @supportedCalendars.
  ///
  /// In ko, this message translates to:
  /// **'지원되는 캘린더'**
  String get supportedCalendars;

  /// No description provided for @googleCalendar.
  ///
  /// In ko, this message translates to:
  /// **'구글 캘린더'**
  String get googleCalendar;

  /// No description provided for @samsungCalendar.
  ///
  /// In ko, this message translates to:
  /// **'삼성 캘린더'**
  String get samsungCalendar;

  /// No description provided for @calendarAutoDisplay.
  ///
  /// In ko, this message translates to:
  /// **'위 캘린더에 일정을 등록하시면 앱에서 자동으로 표시됩니다.'**
  String get calendarAutoDisplay;

  /// No description provided for @unsupportedCalendars.
  ///
  /// In ko, this message translates to:
  /// **'미지원 캘린더'**
  String get unsupportedCalendars;

  /// No description provided for @naverCalendar.
  ///
  /// In ko, this message translates to:
  /// **'네이버 캘린더'**
  String get naverCalendar;

  /// No description provided for @kakaoCalendar.
  ///
  /// In ko, this message translates to:
  /// **'카카오톡 캘린더'**
  String get kakaoCalendar;

  /// No description provided for @noStandardSync.
  ///
  /// In ko, this message translates to:
  /// **'Android 표준 캘린더 동기화를 지원하지 않아 일정을 읽을 수 없습니다.'**
  String get noStandardSync;

  /// No description provided for @notificationTitle.
  ///
  /// In ko, this message translates to:
  /// **'💝 ConnectHeart'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In ko, this message translates to:
  /// **'오늘 소중한 사람에게 마음을 전해보세요!'**
  String get notificationBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
