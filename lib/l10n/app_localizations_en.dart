// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ConnectHeart';

  @override
  String get notifications => 'Notifications';

  @override
  String get receiveAlerts => 'Receive Alerts';

  @override
  String get setTime => 'Set Time';

  @override
  String get test => 'Test';

  @override
  String get designSending => 'Design & Sending';

  @override
  String get cardBranding => 'Card Footer Branding';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get syncContacts => 'Sync Contacts';

  @override
  String get backup => 'Backup';

  @override
  String get restore => 'Restore';

  @override
  String get export => 'Export';

  @override
  String get import => 'Import';

  @override
  String get calendarSync => 'Calendar Sync';

  @override
  String get openCalendarApp => 'Open Calendar App';

  @override
  String get supportedCalendar => 'Supported Calendars';

  @override
  String get appInfo => 'App Info & Support';

  @override
  String get version => 'Version';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get account => 'Account';

  @override
  String get language => 'Language';

  @override
  String get exit => 'Exit';

  @override
  String get myNameNickname => 'My Name/Nickname';

  @override
  String get nameOrNickname => 'Name or Nickname';

  @override
  String get cardDisplayName => 'Name displayed on card';

  @override
  String get nameUsedFooter =>
      'This name is used for the Footer (signature) on the card writing screen.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get languageSetting => 'Language Setting';

  @override
  String languageChanged(String language) {
    return 'Language changed to $language. (App restart required)';
  }

  @override
  String get backupComplete => 'Backup Complete';

  @override
  String get backupDataSaved => 'The following data has been backed up:';

  @override
  String get contacts => 'Contacts';

  @override
  String get schedules => 'Schedules';

  @override
  String get savedCards => 'Saved Cards';

  @override
  String get settings => 'Settings';

  @override
  String get included => 'Included';

  @override
  String get savePath => 'Save Path';

  @override
  String get restoreData => 'Restore Data';

  @override
  String get restoreWarning =>
      'Existing data will be replaced with backup data.\n\nDo you want to continue?';

  @override
  String get selectBackupFile => 'Select Backup File';

  @override
  String get noBackupFile => 'No backup file found. Please backup first.';

  @override
  String get doBackup => 'Backup Now';

  @override
  String restoreComplete(int count) {
    return 'Restore complete! $count contacts restored';
  }

  @override
  String get supportedCalendars => 'Supported Calendars';

  @override
  String get googleCalendar => 'Google Calendar';

  @override
  String get samsungCalendar => 'Samsung Calendar';

  @override
  String get calendarAutoDisplay =>
      'Events registered in the above calendars will be automatically displayed in the app.';

  @override
  String get unsupportedCalendars => 'Unsupported Calendars';

  @override
  String get naverCalendar => 'Naver Calendar';

  @override
  String get kakaoCalendar => 'Kakao Calendar';

  @override
  String get noStandardSync =>
      'Cannot read events as they do not support Android standard calendar sync.';

  @override
  String get notificationTitle => '💝 ConnectHeart';

  @override
  String get notificationBody => 'Send your heart to someone special today!';
}
