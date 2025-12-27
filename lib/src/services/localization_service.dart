import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart_connect/src/providers/locale_provider.dart';

class Texts {
  // Common
  static const String appName = 'appName';
  static const String appNameEn = 'appNameEn';
  static const String ok = 'ok';
  static const String cancel = 'cancel';
  static const String save = 'save';
  static const String close = 'close';
  static const String loading = 'loading';
  static const String confirm = 'confirm';
  static const String error = 'error';
  
  // Onboarding
  static const String onboardingWelcomeTitle = 'onboardingWelcomeTitle';
  static const String onboardingWelcomeDesc = 'onboardingWelcomeDesc';
  static const String startButton = 'startButton';
  static const String contactsPermTitle = 'contactsPermTitle';
  static const String contactsPermDesc = 'contactsPermDesc';
  static const String contactsPermWhy = 'contactsPermWhy';
  static const String contactsPermPrivacy = 'contactsPermPrivacy';
  static const String contactsPermButton = 'contactsPermButton';
  static const String calendarPermTitle = 'calendarPermTitle';
  static const String calendarPermDesc = 'calendarPermDesc';
  static const String calendarPermWhy = 'calendarPermWhy';
  static const String calendarPermPrivacy = 'calendarPermPrivacy';
  static const String calendarPermButton = 'calendarPermButton';
  static const String skipSettings = 'skipSettings';
  
  // Splash
  static const String splashWelcome = 'splashWelcome';
  static const String dataSyncing = 'dataSyncing';
  static const String readyComplete = 'readyComplete';
  
  // Home
  static const String tabHome = 'tabHome';
  static const String tabContacts = 'tabContacts';
  static const String tabCalendar = 'tabCalendar';
  static const String tabSettings = 'tabSettings';
  static const String recentContacts = 'recentContacts';
  static const String upcomingEvents = 'upcomingEvents';
  static const String noEvents = 'noEvents';
  
  // Card Editor
  static const String editCard = 'editCard';
  static const String writeMessage = 'writeMessage';
  static const String selectRecipients = 'selectRecipients';
  static const String share = 'share';
  static const String send = 'send';
  static const String preview = 'preview';
  
  // Settings
  static const String settingsTitle = 'settingsTitle';
  static const String language = 'language';
  static const String notifications = 'notifications';
  static const String theme = 'theme';
  static const String version = 'version';
  static const String privacyPolicy = 'privacyPolicy';
  static const String contactUs = 'contactUs';
}

final Map<String, Map<String, String>> _translations = {
  'ko': {
    Texts.appName: '마음이음',
    Texts.appNameEn: 'Heart-Connect',
    Texts.ok: '확인',
    Texts.cancel: '취소',
    Texts.save: '저장',
    Texts.close: '닫기',
    Texts.loading: '로딩 중...',
    Texts.confirm: '확인',
    Texts.error: '오류',
    
    Texts.onboardingWelcomeTitle: '기쁨과 감사의 마음을\n주변 사람들과 나누세요',
    Texts.onboardingWelcomeDesc: '마음이음은\n소중한 사람들에게\n따뜻한 카드와 메시지를\n보낼 수 있는 앱입니다.\n\n생일, 기념일, 특별한 날에\n진심을 담은 마음을\n전해보세요.',
    Texts.startButton: '시작하기',
    
    Texts.contactsPermTitle: '연락처 접근 권한',
    Texts.contactsPermDesc: '연락처 정보는 가족, 친구들에게 카드를 보내기 위해 필요합니다.',
    Texts.contactsPermWhy: '왜 필요한가요?',
    Texts.contactsPermPrivacy: '수집되는 정보는 사용자님의 핸드폰 안에서만 사용되며, 핸드폰 밖으로 반출되지 않습니다.',
    Texts.contactsPermButton: '연락처 접근 허용',
    
    Texts.calendarPermTitle: '캘린더 접근 권한',
    Texts.calendarPermDesc: '캘린더 정보는 가족과 친구의 생일, 기념일, 이벤트 정보를 가져오기 위해 필요합니다.',
    Texts.calendarPermWhy: '왜 필요한가요?',
    Texts.calendarPermPrivacy: '수집되는 정보는 사용자님의 핸드폰 안에서만 사용되며, 핸드폰 밖으로 반출되지 않습니다.',
    Texts.calendarPermButton: '캘린더 접근 허용',
    Texts.skipSettings: '나중에 설정하기',
    
    Texts.splashWelcome: '안녕하세요, {name} 님! 👋',
    Texts.dataSyncing: '데이터를 동기화하는 중...',
    Texts.readyComplete: '준비 완료!',
    
    Texts.tabHome: '홈',
    Texts.tabContacts: '연락처',
    Texts.tabCalendar: '캘린더',
    Texts.tabSettings: '설정',
    Texts.recentContacts: '최근 연락처',
    Texts.upcomingEvents: '다가오는 일정',
    Texts.noEvents: '일정이 없습니다.',
    
    Texts.editCard: '카드 편집',
    Texts.writeMessage: '메시지 작성',
    Texts.selectRecipients: '받는 사람 선택',
    Texts.share: '공유',
    Texts.send: '보내기',
    Texts.preview: '미리보기',
    
    Texts.settingsTitle: '설정',
    Texts.language: '언어',
    Texts.notifications: '알림',
    Texts.theme: '테마',
    Texts.version: '버전',
    Texts.privacyPolicy: '개인정보 처리방침',
    Texts.contactUs: '문의하기',
  },
  'en': {
    Texts.appName: 'Heart-Connect',
    Texts.appNameEn: 'Heart-Connect',
    Texts.ok: 'OK',
    Texts.cancel: 'Cancel',
    Texts.save: 'Save',
    Texts.close: 'Close',
    Texts.loading: 'Loading...',
    Texts.confirm: 'Confirm',
    Texts.error: 'Error',
    
    Texts.onboardingWelcomeTitle: 'Share joy and gratitude\nwith those around you',
    Texts.onboardingWelcomeDesc: 'Heart-Connect allows you to\nsend warm cards and messages\nto your loved ones.\n\nExpress your sincere feelings\non birthdays and special days.',
    Texts.startButton: 'Get Started',
    
    Texts.contactsPermTitle: 'Contact Access',
    Texts.contactsPermDesc: 'Contact info is needed to send cards to family and friends.',
    Texts.contactsPermWhy: 'Why is it needed?',
    Texts.contactsPermPrivacy: 'Your data is used only on your device and is never uploaded externally.',
    Texts.contactsPermButton: 'Allow Contacts',
    
    Texts.calendarPermTitle: 'Calendar Access',
    Texts.calendarPermDesc: 'Calendar info is needed to fetch birthdays and events of family and friends.',
    Texts.calendarPermWhy: 'Why is it needed?',
    Texts.calendarPermPrivacy: 'Your data is used only on your device and is never uploaded externally.',
    Texts.calendarPermButton: 'Allow Calendar',
    Texts.skipSettings: 'Setup Later',
    
    Texts.splashWelcome: 'Hello, {name}! 👋',
    Texts.dataSyncing: 'Syncing data...',
    Texts.readyComplete: 'Ready!',
    
    Texts.tabHome: 'Home',
    Texts.tabContacts: 'Contacts',
    Texts.tabCalendar: 'Calendar',
    Texts.tabSettings: 'Settings',
    Texts.recentContacts: 'Recent',
    Texts.upcomingEvents: 'Upcoming',
    Texts.noEvents: 'No events',
    
    Texts.editCard: 'Edit Card',
    Texts.writeMessage: 'Write Message',
    Texts.selectRecipients: 'Select Recipients',
    Texts.share: 'Share',
    Texts.send: 'Send',
    Texts.preview: 'Preview',
    
    Texts.settingsTitle: 'Settings',
    Texts.language: 'Language',
    Texts.notifications: 'Notifications',
    Texts.theme: 'Theme',
    Texts.version: 'Version',
    Texts.privacyPolicy: 'Privacy Policy',
    Texts.contactUs: 'Contact Us',
  },
   // Add other languages with English fallback or translations
};

class Tr {
  static String get(String key, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final langCode = locale.languageCode;
    final map = _translations[langCode] ?? _translations['en']!;
    return map[key] ?? _translations['en']?[key] ?? key;
  }
  
  static String getWithArgs(String key, Map<String, String> args, WidgetRef ref) {
    String text = get(key, ref);
    args.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }
}
