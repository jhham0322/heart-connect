import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart_connect/l10n/app_localizations.dart';
import 'package:heart_connect/l10n/app_localizations_ko.dart';
import 'package:heart_connect/l10n/app_localizations_en.dart';
import 'package:heart_connect/l10n/app_localizations_ja.dart';
import 'package:heart_connect/l10n/app_localizations_zh.dart';
import 'package:heart_connect/l10n/app_localizations_fr.dart';
import 'package:heart_connect/l10n/app_localizations_de.dart';
import 'package:heart_connect/l10n/app_localizations_it.dart';
import 'package:heart_connect/l10n/app_localizations_es.dart';
import 'package:heart_connect/l10n/app_localizations_pt.dart';
import 'package:heart_connect/l10n/app_localizations_ru.dart';
import 'package:heart_connect/l10n/app_localizations_ar.dart';
import 'package:heart_connect/l10n/app_localizations_tr.dart';
import 'package:heart_connect/l10n/app_localizations_hi.dart';
import 'package:heart_connect/l10n/app_localizations_id.dart';
import 'package:heart_connect/src/providers/locale_provider.dart';

/// languageCode에 맞는 AppLocalizations 인스턴스 생성 (G20 지원)
AppLocalizations _getLocalizationsByCode(String languageCode) {
  switch (languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
    case 'fr':
      return AppLocalizationsFr();
    case 'de':
      return AppLocalizationsDe();
    case 'it':
      return AppLocalizationsIt();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'ar':
      return AppLocalizationsAr();
    case 'tr':
      return AppLocalizationsTr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'ko':
    default:
      return AppLocalizationsKo();
  }
}


/// AppStrings가 AppLocalizations를 래핑하여 기존 코드 호환성 유지
/// ref.watch(appStringsProvider)로 계속 사용 가능
class AppStrings {
  final AppLocalizations? _l10n;
  final String languageCode;
  
  AppStrings(this._l10n, this.languageCode);
  
  // Fallback getter (AppLocalizations가 null인 경우 대비)
  String _fallback(String? value, String defaultValue) => value ?? defaultValue;
  
  // ========== 공통 ==========
  String get appName => _fallback(_l10n?.appName, '마음이음');
  String get ok => _fallback(_l10n?.ok, '확인');
  String get cancel => _fallback(_l10n?.cancel, '취소');
  String get close => _fallback(_l10n?.close, '닫기');
  String get save => _fallback(_l10n?.save, '저장');
  String get delete => _fallback(_l10n?.delete, '삭제');
  String get edit => _fallback(_l10n?.edit, '편집');
  String get add => _fallback(_l10n?.add, '추가');
  String get search => _fallback(_l10n?.search, '검색');
  String get loading => _fallback(_l10n?.loading, '로딩 중...');
  String get error => _fallback(_l10n?.error, '오류');
  String get success => _fallback(_l10n?.success, '성공');
  String get warning => _fallback(_l10n?.warning, '경고');
  String get retry => _fallback(_l10n?.retry, '다시 시도');
  String get next => _fallback(_l10n?.next, '다음');
  String get previous => _fallback(_l10n?.previous, '이전');
  String get done => _fallback(_l10n?.done, '완료');
  String get all => _fallback(_l10n?.all, '전체');
  String get today => _fallback(_l10n?.today, '오늘');
  String get yesterday => _fallback(_l10n?.yesterday, '어제');
  String get tomorrow => _fallback(_l10n?.tomorrow, '내일');
  
  // ========== 온보딩 ==========
  String get onboardingStart => _fallback(_l10n?.onboardingStart, '시작하기');
  String get onboardingWelcome => _fallback(_l10n?.onboardingWelcome, '기쁨과 감사의 마음을\n주변 사람들과 나누세요');
  String get onboardingDesc1 => _fallback(_l10n?.onboardingDesc1, '마음이음은');
  String get onboardingDesc2 => _fallback(_l10n?.onboardingDesc2, '소중한 사람들에게');
  String get onboardingDesc3 => _fallback(_l10n?.onboardingDesc3, '따뜻한 카드와 메시지를');
  String get onboardingDesc4 => _fallback(_l10n?.onboardingDesc4, '보낼 수 있는 앱입니다.');
  String get onboardingDesc5 => _fallback(_l10n?.onboardingDesc5, '생일, 기념일, 특별한 날에');
  String get onboardingDesc6 => _fallback(_l10n?.onboardingDesc6, '진심을 담은 마음을');
  String get onboardingDesc7 => _fallback(_l10n?.onboardingDesc7, '전해보세요.');
  String get onboardingEnterName => _fallback(_l10n?.onboardingEnterName, '사용하실 이름을 입력하세요');
  String get onboardingNameHint => _fallback(_l10n?.onboardingNameHint, '이름 또는 별명');
  String get onboardingNameDesc => _fallback(_l10n?.onboardingNameDesc, '이 이름은 카드의 서명(Footer)에 표시됩니다.\n설정에서 언제든지 변경할 수 있습니다.');
  String get onboardingNameRequired => _fallback(_l10n?.onboardingNameRequired, '이름을 입력해주세요');
  String get onboardingContinue => _fallback(_l10n?.onboardingContinue, '계속하기');
  
  // ========== 권한 요청 ==========
  String get permissionContacts => _fallback(_l10n?.permissionContacts, '연락처 접근 권한');
  String get permissionCalendar => _fallback(_l10n?.permissionCalendar, '캘린더 접근 권한');
  String get permissionWhyNeeded => _fallback(_l10n?.permissionWhyNeeded, '왜 필요한가요?');
  String get permissionContactsDesc => _fallback(_l10n?.permissionContactsDesc, '연락처 정보는 가족, 친구들에게 카드를 보내기 위해 필요합니다.\n\n저장된 연락처에서 수신자를 쉽게 선택할 수 있어요.');
  String get permissionCalendarDesc => _fallback(_l10n?.permissionCalendarDesc, '캘린더 정보는 가족과 친구의 생일, 기념일, 이벤트 정보를 가져오기 위해 필요합니다.\n\n중요한 날을 놓치지 않고 미리 알림을 받을 수 있어요!');
  String get permissionPrivacy => _fallback(_l10n?.permissionPrivacy, '🔒 개인정보 보호 안내\n\n수집되는 정보는 사용자님의 핸드폰 안에서만 사용되며, 핸드폰 밖으로 반출되지 않습니다.');
  String get permissionAllow => _fallback(_l10n?.permissionAllow, '접근 허용');
  String get permissionAllowContacts => _fallback(_l10n?.permissionAllowContacts, '연락처 접근 허용');
  String get permissionAllowCalendar => _fallback(_l10n?.permissionAllowCalendar, '캘린더 접근 허용');
  String get permissionSkip => _fallback(_l10n?.permissionSkip, '나중에 설정하기');
  String get permissionSkipContacts => _fallback(_l10n?.permissionSkipContacts, '권한을 허용하지 않으시면 수동으로 연락처를 입력해야 합니다.');
  String get permissionSkipCalendar => _fallback(_l10n?.permissionSkipCalendar, '권한을 허용하지 않으시면 수동으로 일정을 입력해야 합니다.');
  String get permissionSms => _fallback(_l10n?.permissionSms, 'SMS 접근 권한');
  String get permissionSmsDesc => _fallback(_l10n?.permissionSmsDesc, 'SMS 정보는 연락처와 주고받은 문자 메시지 내역을 확인하기 위해 필요합니다.\n\n카드를 보낸 후 문자로 안부를 주고받은 기록을 볼 수 있어요!');
  String get permissionAllowSms => _fallback(_l10n?.permissionAllowSms, 'SMS 접근 허용');
  String get permissionSkipSms => _fallback(_l10n?.permissionSkipSms, '권한을 허용하지 않으시면 문자 메시지 내역을 볼 수 없습니다.');
  String get permissionSendSms => _fallback(_l10n?.permissionSendSms, 'SMS 발송 권한');
  String get permissionSendSmsDesc => _fallback(_l10n?.permissionSendSmsDesc, '카드를 문자로 직접 발송하려면 SMS 발송 권한이 필요합니다.\n\n이 권한이 없으면 문자 앱을 통해서만 발송할 수 있습니다.');
  String get permissionAllowSendSms => _fallback(_l10n?.permissionAllowSendSms, 'SMS 발송 허용');
  
  // ========== 네비게이션 ==========
  String get navHome => _fallback(_l10n?.navHome, '홈');
  String get navContacts => _fallback(_l10n?.navContacts, '연락처');
  String get navGallery => _fallback(_l10n?.navGallery, '갤러리');
  String get navMessages => _fallback(_l10n?.navMessages, '메시지');
  String get navSettings => _fallback(_l10n?.navSettings, '설정');
  
  // ========== 홈 화면 ==========
  String get homeUpcoming => _fallback(_l10n?.homeUpcoming, '다가오는 일정');
  String get homeNoEvents => _fallback(_l10n?.homeNoEvents, '예정된 일정이 없습니다');
  String get homeQuickSend => _fallback(_l10n?.homeQuickSend, '빠른 발송');
  String get homeRecentCards => _fallback(_l10n?.homeRecentCards, '최근 보낸 카드');
  String get homeWriteCard => _fallback(_l10n?.homeWriteCard, '카드 작성');
  String get homeDaysLeft => _fallback(_l10n?.homeDaysLeft, '일 남음');
  String get homeDDay => _fallback(_l10n?.homeDDay, 'D-Day');
  
  // ========== 연락처 ==========
  String get contactsTitle => _fallback(_l10n?.contactsTitle, '연락처');
  String get contactsAll => _fallback(_l10n?.contactsAll, '전체');
  String get contactsFamily => _fallback(_l10n?.contactsFamily, '가족');
  String get contactsFriends => _fallback(_l10n?.contactsFriends, '친구');
  String get contactsWork => _fallback(_l10n?.contactsWork, '직장');
  String get contactsOthers => _fallback(_l10n?.contactsOthers, '기타');
  String get contactsFavorites => _fallback(_l10n?.contactsFavorites, '즐겨찾기');
  String get contactsEmpty => _fallback(_l10n?.contactsEmpty, '연락처가 없습니다');
  String get contactsSearchHint => _fallback(_l10n?.contactsSearchHint, '이름 또는 전화번호 검색');
  String get contactsMyPeople => _fallback(_l10n?.contactsMyPeople, '내 사람들');
  String get contactsMemories => _fallback(_l10n?.contactsMemories, '추억 기록');
  String get contactsRecent => _fallback(_l10n?.contactsRecent, '최근 연락');
  String get contactsSearchPlaceholder => _fallback(_l10n?.contactsSearchPlaceholder, '이름, 태그 검색');
  String get contactsNoMemories => _fallback(_l10n?.contactsNoMemories, '아직 추억 기록이 없습니다.');
  String get contactsSendCard => _fallback(_l10n?.contactsSendCard, '카드 보내기');
  String get contactsCall => _fallback(_l10n?.contactsCall, '전화');
  String get contactsMessage => _fallback(_l10n?.contactsMessage, '문자');
  String get contactsBirthday => _fallback(_l10n?.contactsBirthday, '생일');
  String get contactsAnniversary => _fallback(_l10n?.contactsAnniversary, '기념일');
  String get contactsNoHistory => _fallback(_l10n?.contactsNoHistory, '주고받은 내역이 없습니다.');
  String get contactsSearchContent => _fallback(_l10n?.contactsSearchContent, '내용 검색');
  String get contactsNoSearchResult => _fallback(_l10n?.contactsNoSearchResult, '검색 결과가 없습니다.');
  String get contactsMessageSent => _fallback(_l10n?.contactsMessageSent, '보냄');
  String get contactsMessageReceived => _fallback(_l10n?.contactsMessageReceived, '받음');
  
  // ========== 공유하기 ==========
  String get shareTitle => _fallback(_l10n?.shareTitle, '공유하기');
  String get shareOtherApps => _fallback(_l10n?.shareOtherApps, '기타 앱으로 공유');
  String get shareKakaoTalk => _fallback(_l10n?.shareKakaoTalk, '카카오톡');
  String get shareInstagram => _fallback(_l10n?.shareInstagram, '인스타그램');
  String get shareFacebook => _fallback(_l10n?.shareFacebook, '페이스북');
  String get shareTwitter => _fallback(_l10n?.shareTwitter, 'X (트위터)');
  String get shareWhatsApp => _fallback(_l10n?.shareWhatsApp, 'WhatsApp');
  String get shareTelegram => _fallback(_l10n?.shareTelegram, '텔레그램');
  
  // ========== 갤러리/카드 선택 ==========
  String get galleryTitle => _fallback(_l10n?.galleryTitle, '카드 갤러리');
  String get galleryBirthday => _fallback(_l10n?.galleryBirthday, '생일');
  String get galleryChristmas => _fallback(_l10n?.galleryChristmas, '크리스마스');
  String get galleryNewYear => _fallback(_l10n?.galleryNewYear, '새해');
  String get galleryThanks => _fallback(_l10n?.galleryThanks, '감사');
  String get galleryMothersDay => _fallback(_l10n?.galleryMothersDay, '어버이날');
  String get galleryTeachersDay => _fallback(_l10n?.galleryTeachersDay, '스승의 날');
  String get galleryHalloween => _fallback(_l10n?.galleryHalloween, '할로윈');
  String get galleryThanksgiving => _fallback(_l10n?.galleryThanksgiving, '추수감사절');
  String get galleryTravel => _fallback(_l10n?.galleryTravel, '여행');
  String get galleryHobby => _fallback(_l10n?.galleryHobby, '취미');
  String get gallerySports => _fallback(_l10n?.gallerySports, '스포츠');
  String get galleryMyPhotos => _fallback(_l10n?.galleryMyPhotos, '내 사진');
  String get gallerySelectImage => _fallback(_l10n?.gallerySelectImage, '이미지 선택');
  String get galleryNoImages => _fallback(_l10n?.galleryNoImages, '이미지가 없습니다');
  String get selectCategory => _fallback(_l10n?.selectCategory, '카테고리 선택');
  
  // ========== 카드 편집 ==========
  String get cardEditorTitle => _fallback(_l10n?.cardEditorTitle, '카드 편집');
  String get cardEditorAddText => _fallback(_l10n?.cardEditorAddText, '텍스트 추가');
  String get cardEditorAddSticker => _fallback(_l10n?.cardEditorAddSticker, '스티커 추가');
  String get cardEditorAddImage => _fallback(_l10n?.cardEditorAddImage, '이미지 추가');
  String get cardEditorBackground => _fallback(_l10n?.cardEditorBackground, '배경');
  String get cardEditorFont => _fallback(_l10n?.cardEditorFont, '폰트');
  String get cardEditorColor => _fallback(_l10n?.cardEditorColor, '색상');
  String get cardEditorSize => _fallback(_l10n?.cardEditorSize, '크기');
  String get cardEditorPreview => _fallback(_l10n?.cardEditorPreview, '미리보기');
  String get cardEditorSend => _fallback(_l10n?.cardEditorSend, '발송');
  String get cardEditorSave => _fallback(_l10n?.cardEditorSave, '저장');
  String get cardEditorShare => _fallback(_l10n?.cardEditorShare, '공유');
  String get cardEditorEnterMessage => _fallback(_l10n?.cardEditorEnterMessage, '메시지를 입력하세요');
  String get cardEditorGenerateAI => _fallback(_l10n?.cardEditorGenerateAI, 'AI 메시지 생성');
  String get cardEditorTextBox => _fallback(_l10n?.cardEditorTextBox, '글상자');
  String get cardEditorZoomHint => _fallback(_l10n?.cardEditorZoomHint, '더블탭하시면 줌 모드로 전환됩니다');
  String get cardEditorRecipient => _fallback(_l10n?.cardEditorRecipient, '발송대상');
  String get cardEditorAddRecipient => _fallback(_l10n?.cardEditorAddRecipient, '대상 추가');
  
  // ========== 발송 대상 선택 다이얼로그 ==========
  String get recipientSelectTitle => _fallback(_l10n?.recipientSelectTitle, '발송 대상 선택');
  String get recipientSearchHint => _fallback(_l10n?.recipientSearchHint, '이름 또는 전화번호...');
  String get recipientAddNew => _fallback(_l10n?.recipientAddNew, '새 연락처 추가');
  String get recipientName => _fallback(_l10n?.recipientName, '이름');
  String get recipientPhone => _fallback(_l10n?.recipientPhone, '전화번호');
  String get recipientAdd => _fallback(_l10n?.recipientAdd, '추가');
  
  // ========== 카드 이미지 확인 다이얼로그 ==========
  String get cardPreviewTitle => _fallback(_l10n?.cardPreviewTitle, '카드 이미지 확인');
  String get cardPreviewDesc => _fallback(_l10n?.cardPreviewDesc, '수신자들에게 발송될 최종 이미지입니다.');
  String get cardPreviewZoomHint => _fallback(_l10n?.cardPreviewZoomHint, '더블탭으로 확대/축소, 드래그로 이동이 가능합니다.');
  String get cardPreviewCheckHint => _fallback(_l10n?.cardPreviewCheckHint, '발송 전 이미지 결과물을 확인해 주세요.');
  String get cardPreviewConfirm => _fallback(_l10n?.cardPreviewConfirm, '확인 (다음 단계)');
  
  // ========== 발송 ==========
  String get sendTitle => _fallback(_l10n?.sendTitle, '발송 관리');
  String get sendRecipients => _fallback(_l10n?.sendRecipients, '수신자');
  String get sendAddRecipient => _fallback(_l10n?.sendAddRecipient, '수신자 추가');
  String get sendStart => _fallback(_l10n?.sendStart, '발송 시작');
  String get sendStop => _fallback(_l10n?.sendStop, '발송 중지');
  String get sendContinue => _fallback(_l10n?.sendContinue, '계속 발송');
  String get sendProgress => _fallback(_l10n?.sendProgress, '발송 진행 중');
  String get sendComplete => _fallback(_l10n?.sendComplete, '발송 완료');
  String get sendFailed => _fallback(_l10n?.sendFailed, '발송 실패');
  String get sendPending => _fallback(_l10n?.sendPending, '대기 중');
  String get sendTotalRecipients => _fallback(_l10n?.sendTotalRecipients, '총 수신자');
  String get sendAutoResume => _fallback(_l10n?.sendAutoResume, '5건 발송 후 자동 계속');
  String get sendManagerTitle => _fallback(_l10n?.sendManagerTitle, '발송 대상 관리');
  String get sendTotal => _fallback(_l10n?.sendTotal, '총');
  String get sendPerson => _fallback(_l10n?.sendPerson, '명');
  String get sendSpamWarning => _fallback(_l10n?.sendSpamWarning, '단시간 다량 발송은 스팸 정책에 의해 제한될 수 있습니다.\n안전을 위해 자동 계속 해제를 권장합니다.');
  String totalPersonCount(int count) => _l10n?.totalPersonCount(count) ?? '총 $count명';
  
  // ========== 카드 에디터 힌트 메시지 ==========
  String get cardHintZoomMode => _fallback(_l10n?.cardHintZoomMode, '배경 이미지를 더블탭하시면 줌 모드로 전환됩니다. 줌 모드에서 이미지 크기와 위치를 조절하실 수 있습니다.');
  String get cardHintZoomEdit => _fallback(_l10n?.cardHintZoomEdit, '두 손가락으로 벌리거나 줄여서 이미지 크기를 조정하실 수 있습니다. 한 손가락으로 드래그하시면 이미지를 이동하실 수 있습니다. 편집이 완료되시면 더블탭 또는 줌 모드 버튼을 눌러 종료해 주세요.');
  String get cardHintDragging => _fallback(_l10n?.cardHintDragging, '이미지 이동 중...');
  String get cardHintPinching => _fallback(_l10n?.cardHintPinching, '이미지 크기 조절 중...');
  
  // ========== 저장된 카드 목록 다이얼로그 ==========
  String get savedCardsTitle => _fallback(_l10n?.savedCardsTitle, '저장된 카드 목록');
  String get savedCardsEmpty => _fallback(_l10n?.savedCardsEmpty, '저장된 메시지가 없습니다.');
  String get cardSaveTitle => _fallback(_l10n?.cardSaveTitle, '카드 저장');
  String get cardSaveName => _fallback(_l10n?.cardSaveName, '저장할 이름');
  String get cardSaveHint => _fallback(_l10n?.cardSaveHint, '카드의 이름을 입력하세요');
  String get cardNoTitle => _fallback(_l10n?.cardNoTitle, '제목 없음');
  String get cardImageFailed => _fallback(_l10n?.cardImageFailed, '카드 이미지 생성 실패');
  
  // ========== 메시지/기록 ==========
  String get messageHistory => _fallback(_l10n?.messageHistory, '발송 기록');
  String get messageNoHistory => _fallback(_l10n?.messageNoHistory, '발송 기록이 없습니다');
  String get messageSent => _fallback(_l10n?.messageSent, '발송 완료');
  String get messageViewed => _fallback(_l10n?.messageViewed, '확인함');
  
  // ========== 설정 ==========
  String get settingsTitle => _fallback(_l10n?.settingsTitle, '설정');
  String get settingsProfile => _fallback(_l10n?.settingsProfile, '프로필');
  String get settingsName => _fallback(_l10n?.settingsName, '이름');
  String get settingsLanguage => _fallback(_l10n?.settingsLanguage, '언어');
  String get settingsNotifications => _fallback(_l10n?.settingsNotifications, '알림');
  String get settingsNotificationTime => _fallback(_l10n?.settingsNotificationTime, '알림 시간');
  String get settingsReceiveAlerts => _fallback(_l10n?.settingsReceiveAlerts, '알림 받기');
  String get settingsSetTime => _fallback(_l10n?.settingsSetTime, '시간 설정');
  String get settingsDesignSending => _fallback(_l10n?.settingsDesignSending, '디자인/발송');
  String get settingsCardBranding => _fallback(_l10n?.settingsCardBranding, '카드 하단 브랜딩');
  String get settingsDataManage => _fallback(_l10n?.settingsDataManage, '데이터 관리');
  String get settingsBranding => _fallback(_l10n?.settingsBranding, '브랜딩 표시');
  String get settingsSync => _fallback(_l10n?.settingsSync, '동기화');
  String get settingsSyncContacts => _fallback(_l10n?.settingsSyncContacts, '연락처 동기화');
  String get settingsSyncCalendar => _fallback(_l10n?.settingsSyncCalendar, '캘린더 동기화');
  String get settingsBackup => _fallback(_l10n?.settingsBackup, '백업');
  String get settingsRestore => _fallback(_l10n?.settingsRestore, '복원');
  String get settingsExport => _fallback(_l10n?.settingsExport, '내보내기');
  String get settingsImport => _fallback(_l10n?.settingsImport, '가져오기');
  String get settingsCalendarSync => _fallback(_l10n?.settingsCalendarSync, '캘린더 연동');
  String get settingsOpenCalendar => _fallback(_l10n?.settingsOpenCalendar, '캘린더 열기');
  String get settingsCalendarGuide => _fallback(_l10n?.settingsCalendarGuide, '지원 캘린더 안내');
  String get settingsAppInfo => _fallback(_l10n?.settingsAppInfo, '앱 정보');
  String get settingsContactUs => _fallback(_l10n?.settingsContactUs, '문의하기');
  String get settingsAccount => _fallback(_l10n?.settingsAccount, '계정');
  String get settingsExit => _fallback(_l10n?.settingsExit, '나가기');
  String get settingsMyName => _fallback(_l10n?.settingsMyName, '내 이름/별명');
  String get settingsNameOrNickname => _fallback(_l10n?.settingsNameOrNickname, '이름 또는 별명');
  String get settingsNameHint => _fallback(_l10n?.settingsNameHint, '카드에 표시될 이름');
  String get settingsNameUsageInfo => _fallback(_l10n?.settingsNameUsageInfo, '이 이름은 카드 쓰기 화면의 Footer(서명)에 사용됩니다.');
  String get settingsAbout => _fallback(_l10n?.settingsAbout, '앱 정보');
  String get settingsVersion => _fallback(_l10n?.settingsVersion, '버전');
  String get settingsPrivacy => _fallback(_l10n?.settingsPrivacy, '개인정보 처리방침');
  String get settingsTerms => _fallback(_l10n?.settingsTerms, '이용약관');
  String get settingsHelp => _fallback(_l10n?.settingsHelp, '도움말');
  String get settingsExternalCalendarGuide => _fallback(_l10n?.settingsExternalCalendarGuide, '외부 캘린더 연동 안내');
  String get settingsTest => _fallback(_l10n?.settingsTest, '테스트');
  String get settingsGoogleCalendar => _fallback(_l10n?.settingsGoogleCalendar, 'Google 캘린더');
  String get settingsSamsungCalendar => _fallback(_l10n?.settingsSamsungCalendar, 'Samsung 캘린더');
  String get settingsDarkMode => _fallback(_l10n?.settingsDarkMode, '다크 모드');
  String get settingsDarkModeDesc => _fallback(_l10n?.settingsDarkModeDesc, '어두운 테마 사용');
  
  // ========== 스플래시/로딩 ==========
  String get splashPreparing => _fallback(_l10n?.splashPreparing, '준비 중...');
  String get splashLoadingData => _fallback(_l10n?.splashLoadingData, '데이터를 불러오는 중...');
  String get splashSyncingContacts => _fallback(_l10n?.splashSyncingContacts, '연락처를 동기화하는 중...');
  String get splashSyncingCalendar => _fallback(_l10n?.splashSyncingCalendar, '캘린더를 동기화하는 중...');
  String get splashGeneratingSchedules => _fallback(_l10n?.splashGeneratingSchedules, '일정을 생성하는 중...');
  String get splashPreparingScreen => _fallback(_l10n?.splashPreparingScreen, '화면을 준비하는 중...');
  String get splashReady => _fallback(_l10n?.splashReady, '준비 완료!');
  String helloUser(String name) => _l10n?.helloUser(name) ?? '안녕하세요, $name 님! 👋';
  
  // ========== 에러 메시지 ==========
  String get errorNetwork => _fallback(_l10n?.errorNetwork, '네트워크 오류가 발생했습니다');
  String get errorUnknown => _fallback(_l10n?.errorUnknown, '알 수 없는 오류가 발생했습니다');
  String get errorPermission => _fallback(_l10n?.errorPermission, '권한이 필요합니다');
  String get errorLoadFailed => _fallback(_l10n?.errorLoadFailed, '데이터를 불러오지 못했습니다');
  String get errorSaveFailed => _fallback(_l10n?.errorSaveFailed, '저장에 실패했습니다');
  String get errorSendFailed => _fallback(_l10n?.errorSendFailed, '발송에 실패했습니다');
  String get errorImageFailed => _fallback(_l10n?.errorImageFailed, '이미지 처리에 실패했습니다');
  
  // ========== 확인 다이얼로그 ==========
  String get confirmDelete => _fallback(_l10n?.confirmDelete, '정말 삭제하시겠습니까?');
  String get confirmExit => _fallback(_l10n?.confirmExit, '변경사항을 저장하지 않고 나가시겠습니까?');
  String get confirmSend => _fallback(_l10n?.confirmSend, '발송하시겠습니까?');
  
  // ========== 날짜/시간 ==========
  String get dateToday => _fallback(_l10n?.dateToday, '오늘');
  String get dateTomorrow => _fallback(_l10n?.dateTomorrow, '내일');
  String get dateYesterday => _fallback(_l10n?.dateYesterday, '어제');
  String get dateThisWeek => _fallback(_l10n?.dateThisWeek, '이번 주');
  String get dateNextWeek => _fallback(_l10n?.dateNextWeek, '다음 주');
  String get dateThisMonth => _fallback(_l10n?.dateThisMonth, '이번 달');
  String daysRemaining(int days) => _l10n?.daysRemaining(days) ?? '$days일 남음';
  String daysAgo(int days) => _l10n?.daysAgo(days) ?? '$days일 전';
  
  // ========== 발송 결과 다이얼로그 ==========
  String sendResultSuccess(int count) => _l10n?.sendResultSuccess(count) ?? '성공: $count건';
  String sendResultFailed(int count) => _l10n?.sendResultFailed(count) ?? '실패: $count건';
  
  // ========== 이벤트 종류 ==========
  String get eventBirthday => _fallback(_l10n?.eventBirthday, '생일');
  String get eventAnniversary => _fallback(_l10n?.eventAnniversary, '기념일');
  String get eventHoliday => _fallback(_l10n?.eventHoliday, '공휴일');
  String get eventMeeting => _fallback(_l10n?.eventMeeting, '모임');
  String get eventOther => _fallback(_l10n?.eventOther, '기타');
  
  // ========== 일정 관리 다이얼로그 ==========
  String get scheduleEdit => _fallback(_l10n?.scheduleEdit, '일정 수정');
  String get scheduleAdd => _fallback(_l10n?.scheduleAdd, '일정 추가');
  String get scheduleAddNew => _fallback(_l10n?.scheduleAddNew, '새 일정');
  String get scheduleTitle => _fallback(_l10n?.scheduleTitle, '제목');
  String get scheduleRecipients => _fallback(_l10n?.scheduleRecipients, '수신자');
  String get scheduleDate => _fallback(_l10n?.scheduleDate, '날짜');
  String get scheduleIconType => _fallback(_l10n?.scheduleIconType, '아이콘');
  String get scheduleAddToCalendar => _fallback(_l10n?.scheduleAddToCalendar, '캘린더에 추가');
  String get scheduleAddedSuccess => _fallback(_l10n?.scheduleAddedSuccess, '일정이 추가되었습니다!');
  
  // ========== 일정 옵션 메뉴 ==========
  String get planEdit => _fallback(_l10n?.planEdit, '수정');
  String get planDelete => _fallback(_l10n?.planDelete, '삭제');
  String get planMoveToEnd => _fallback(_l10n?.planMoveToEnd, '끝으로 이동');
  String get planReschedule => _fallback(_l10n?.planReschedule, '날짜 변경');
  String get planChangeIcon => _fallback(_l10n?.planChangeIcon, '아이콘 변경');
  String get planSelectIcon => _fallback(_l10n?.planSelectIcon, '아이콘 선택');
  String planDeleteConfirm(String title) => _l10n?.planDeleteConfirm(title) ?? '"$title"을(를) 삭제하시겠습니까?';
  
  // ========== 아이콘 타입 ==========
  String get iconNormal => _fallback(_l10n?.iconNormal, '일반');
  String get iconHoliday => _fallback(_l10n?.iconHoliday, '휴일');
  String get iconBirthday => _fallback(_l10n?.iconBirthday, '생일');
  String get iconAnniversary => _fallback(_l10n?.iconAnniversary, '기념일');
  String get iconWork => _fallback(_l10n?.iconWork, '업무');
  String get iconPersonal => _fallback(_l10n?.iconPersonal, '개인');
  String get iconImportant => _fallback(_l10n?.iconImportant, '중요');
  
  String get cardWrite => _fallback(_l10n?.cardWrite, '작성');
  
  // ========== 언어 선택 ==========
  String get languageSelection => _fallback(_l10n?.languageSelection, '언어 선택');
  String get previousLanguage => _fallback(_l10n?.previousLanguage, '이전 언어');
  String get nextLanguage => _fallback(_l10n?.nextLanguage, '다음 언어');
  
  // ========== 미리보기 ==========
  String get previewTitle => _fallback(_l10n?.previewTitle, '미리보기');
  String get previewConfirm => _fallback(_l10n?.previewConfirm, '이 이미지로 발송하시겠습니까?');
  
  // ========== 글상자 스타일 ==========
  String get textBoxStyleTitle => _fallback(_l10n?.textBoxStyleTitle, '글상자 스타일');
  String get textBoxPreviewText => _fallback(_l10n?.textBoxPreviewText, '스타일 미리보기');
  String get textBoxShapeRounded => _fallback(_l10n?.textBoxShapeRounded, '둥근');
  String get textBoxShapeSquare => _fallback(_l10n?.textBoxShapeSquare, '직각');
  String get textBoxShapeBevel => _fallback(_l10n?.textBoxShapeBevel, '모따기');
  String get textBoxShapeCircle => _fallback(_l10n?.textBoxShapeCircle, '원형');
  String get textBoxShapeBubble => _fallback(_l10n?.textBoxShapeBubble, '말풍선');
  String get textBoxBackgroundColor => _fallback(_l10n?.textBoxBackgroundColor, '배경 색상');
  String get textBoxOpacity => _fallback(_l10n?.textBoxOpacity, '투명도');
  String get textBoxBorderRadius => _fallback(_l10n?.textBoxBorderRadius, '둥근 모서리');
  String get textBoxBorder => _fallback(_l10n?.textBoxBorder, '테두리');
  String get textBoxBorderWidth => _fallback(_l10n?.textBoxBorderWidth, '테두리 두께');
  String get textBoxFooterStyle => _fallback(_l10n?.textBoxFooterStyle, '푸터 (보낸 사람) 배경 스타일');
  String get textBoxFooterHint => _fallback(_l10n?.textBoxFooterHint, '글자 크기와 색상은 푸터를 선택 후 상단 툴바에서 변경하세요.');
  String get textBoxPreview => _fallback(_l10n?.textBoxPreview, '스타일 미리보기');
  String get textBoxSender => _fallback(_l10n?.textBoxSender, '보낸 사람');
  String get textBoxShapeLabel => _fallback(_l10n?.textBoxShapeLabel, '글상자 모양');
  
  // 글상자 모양 옵션들
  String get shapeRounded => _fallback(_l10n?.shapeRounded, '둥근');
  String get shapeRectangle => _fallback(_l10n?.shapeRectangle, '직각');
  String get shapeBevel => _fallback(_l10n?.shapeBevel, '모따기');
  String get shapeCircle => _fallback(_l10n?.shapeCircle, '원형');
  String get shapeBubbleLeft => _fallback(_l10n?.shapeBubbleLeft, '말풍선(좌)');
  String get shapeBubbleCenter => _fallback(_l10n?.shapeBubbleCenter, '말풍선(중)');
  String get shapeBubbleRight => _fallback(_l10n?.shapeBubbleRight, '말풍선(우)');
  String get shapeHeart => _fallback(_l10n?.shapeHeart, '하트');
  String get shapeStar => _fallback(_l10n?.shapeStar, '별');
  String get shapeDiamond => _fallback(_l10n?.shapeDiamond, '다이아');
  String get shapeHexagon => _fallback(_l10n?.shapeHexagon, '육각형');
  String get shapeCloud => _fallback(_l10n?.shapeCloud, '구름');
  
  // 푸터 배경 스타일
  String get footerBgOpacity => _fallback(_l10n?.footerBgOpacity, '배경 투명도');
  String get footerBgRadius => _fallback(_l10n?.footerBgRadius, '배경 둥근 모서리');
  
  // ========== 연락처 피커 ==========
  String get contactPickerTitle => _fallback(_l10n?.contactPickerTitle, '발송 대상 선택');
  String get contactPickerSearchHint => _fallback(_l10n?.contactPickerSearchHint, '이름 또는 전화번호...');
  String get contactPickerAllContacts => _fallback(_l10n?.contactPickerAllContacts, '전체');
  String get contactPickerFavorites => _fallback(_l10n?.contactPickerFavorites, '즐겨찾기');
  String get contactPickerFamily => _fallback(_l10n?.contactPickerFamily, '가족');
  String get contactPickerAddNew => _fallback(_l10n?.contactPickerAddNew, '새 연락처 추가');
  
  // ========== 새 연락처 추가 다이얼로그 ==========
  String get addContactTitle => _fallback(_l10n?.addContactTitle, '새 연락처 추가');
  String get addContactName => _fallback(_l10n?.addContactName, '이름');
  String get addContactPhone => _fallback(_l10n?.addContactPhone, '전화번호');
  String get addContactAdd => _fallback(_l10n?.addContactAdd, '추가');
  
  // ========== 카드 에디터 상단 버튼 ==========
  String get editorBackground => _fallback(_l10n?.editorBackground, '배경');
  String get editorTextBox => _fallback(_l10n?.editorTextBox, '글상자');
  
  // ========== 사진 접근 권한 ==========
  String get photoPermissionTitle => _fallback(_l10n?.photoPermissionTitle, '사진 접근 권한 필요');
  String get photoPermissionDesc => _fallback(_l10n?.photoPermissionDesc, '기기의 사진을 카드 배경으로 사용하려면\n갤러리 접근 권한이 필요합니다.');
  String get photoPermissionHowTo => _fallback(_l10n?.photoPermissionHowTo, '📱 권한 설정 방법');
  String get photoPermissionStep1 => _fallback(_l10n?.photoPermissionStep1, '1. 아래 "설정 열기" 버튼을 누르세요');
  String get photoPermissionStep2 => _fallback(_l10n?.photoPermissionStep2, '2. "권한" 항목을 찾아 터치하세요');
  String get photoPermissionStep3 => _fallback(_l10n?.photoPermissionStep3, '3. "사진 및 동영상"을 터치하세요');
  String get photoPermissionStep4 => _fallback(_l10n?.photoPermissionStep4, '4. "허용" 또는 "모든 사진 허용"을 선택하세요');
  String get photoPermissionNote => _fallback(_l10n?.photoPermissionNote, '⚡ 권한을 허용한 후 이 화면으로 돌아오면\n자동으로 사진이 표시됩니다.');
  String get openSettings => _fallback(_l10n?.openSettings, '설정 열기');
}

/// AppStrings Provider - languageCode에 맞는 인스턴스 자동 생성
final appStringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(localeProvider);
  final l10n = _getLocalizationsByCode(locale.languageCode);
  return AppStrings(l10n, locale.languageCode);
});

/// Context-aware Provider
final appStringsWithContextProvider = Provider.family<AppStrings, BuildContext>((ref, context) {
  final locale = ref.watch(localeProvider);
  final l10n = AppLocalizations.of(context) ?? _getLocalizationsByCode(locale.languageCode);
  return AppStrings(l10n, locale.languageCode);
});

/// Context extension for easy access
extension AppStringsExtension on BuildContext {
  AppStrings get strings {
    final l10n = AppLocalizations.of(this);
    final langCode = l10n?.localeName ?? 'ko';
    return AppStrings(l10n ?? _getLocalizationsByCode(langCode), langCode);
  }
}

