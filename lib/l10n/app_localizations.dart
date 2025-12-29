import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In ko, this message translates to:
  /// **'마음이음'**
  String get appName;

  /// No description provided for @ok.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ko, this message translates to:
  /// **'편집'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get add;

  /// No description provided for @search.
  ///
  /// In ko, this message translates to:
  /// **'검색'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In ko, this message translates to:
  /// **'로딩 중...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In ko, this message translates to:
  /// **'오류'**
  String get error;

  /// No description provided for @success.
  ///
  /// In ko, this message translates to:
  /// **'성공'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In ko, this message translates to:
  /// **'경고'**
  String get warning;

  /// No description provided for @retry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get retry;

  /// No description provided for @next.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In ko, this message translates to:
  /// **'이전'**
  String get previous;

  /// No description provided for @done.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get done;

  /// No description provided for @all.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get all;

  /// No description provided for @today.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In ko, this message translates to:
  /// **'어제'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In ko, this message translates to:
  /// **'내일'**
  String get tomorrow;

  /// No description provided for @onboardingStart.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get onboardingStart;

  /// No description provided for @onboardingWelcome.
  ///
  /// In ko, this message translates to:
  /// **'기쁨과 감사의 마음을\n주변 사람들과 나누세요'**
  String get onboardingWelcome;

  /// No description provided for @onboardingDesc1.
  ///
  /// In ko, this message translates to:
  /// **'마음이음은'**
  String get onboardingDesc1;

  /// No description provided for @onboardingDesc2.
  ///
  /// In ko, this message translates to:
  /// **'소중한 사람들에게'**
  String get onboardingDesc2;

  /// No description provided for @onboardingDesc3.
  ///
  /// In ko, this message translates to:
  /// **'따뜻한 카드와 메시지를'**
  String get onboardingDesc3;

  /// No description provided for @onboardingDesc4.
  ///
  /// In ko, this message translates to:
  /// **'보낼 수 있는 앱입니다.'**
  String get onboardingDesc4;

  /// No description provided for @onboardingDesc5.
  ///
  /// In ko, this message translates to:
  /// **'생일, 기념일, 특별한 날에'**
  String get onboardingDesc5;

  /// No description provided for @onboardingDesc6.
  ///
  /// In ko, this message translates to:
  /// **'진심을 담은 마음을'**
  String get onboardingDesc6;

  /// No description provided for @onboardingDesc7.
  ///
  /// In ko, this message translates to:
  /// **'전해보세요.'**
  String get onboardingDesc7;

  /// No description provided for @onboardingEnterName.
  ///
  /// In ko, this message translates to:
  /// **'사용하실 이름을 입력하세요'**
  String get onboardingEnterName;

  /// No description provided for @onboardingNameHint.
  ///
  /// In ko, this message translates to:
  /// **'이름 또는 별명'**
  String get onboardingNameHint;

  /// No description provided for @onboardingNameDesc.
  ///
  /// In ko, this message translates to:
  /// **'이 이름은 카드의 서명(Footer)에 표시됩니다.\n설정에서 언제든지 변경할 수 있습니다.'**
  String get onboardingNameDesc;

  /// No description provided for @onboardingNameRequired.
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력해주세요'**
  String get onboardingNameRequired;

  /// No description provided for @onboardingContinue.
  ///
  /// In ko, this message translates to:
  /// **'계속하기'**
  String get onboardingContinue;

  /// No description provided for @permissionContacts.
  ///
  /// In ko, this message translates to:
  /// **'연락처 접근 권한'**
  String get permissionContacts;

  /// No description provided for @permissionCalendar.
  ///
  /// In ko, this message translates to:
  /// **'캘린더 접근 권한'**
  String get permissionCalendar;

  /// No description provided for @permissionWhyNeeded.
  ///
  /// In ko, this message translates to:
  /// **'왜 필요한가요?'**
  String get permissionWhyNeeded;

  /// No description provided for @permissionContactsDesc.
  ///
  /// In ko, this message translates to:
  /// **'연락처 정보는 가족, 친구들에게 카드를 보내기 위해 필요합니다.\n\n저장된 연락처에서 수신자를 쉽게 선택할 수 있어요.'**
  String get permissionContactsDesc;

  /// No description provided for @permissionCalendarDesc.
  ///
  /// In ko, this message translates to:
  /// **'캘린더 정보는 가족과 친구의 생일, 기념일, 이벤트 정보를 가져오기 위해 필요합니다.\n\n중요한 날을 놓치지 않고 미리 알림을 받을 수 있어요!'**
  String get permissionCalendarDesc;

  /// No description provided for @permissionPrivacy.
  ///
  /// In ko, this message translates to:
  /// **'🔒 개인정보 보호 안내\n\n수집되는 정보는 사용자님의 핸드폰 안에서만 사용되며, 핸드폰 밖으로 반출되지 않습니다.'**
  String get permissionPrivacy;

  /// No description provided for @permissionAllow.
  ///
  /// In ko, this message translates to:
  /// **'접근 허용'**
  String get permissionAllow;

  /// No description provided for @permissionAllowContacts.
  ///
  /// In ko, this message translates to:
  /// **'연락처 접근 허용'**
  String get permissionAllowContacts;

  /// No description provided for @permissionAllowCalendar.
  ///
  /// In ko, this message translates to:
  /// **'캘린더 접근 허용'**
  String get permissionAllowCalendar;

  /// No description provided for @permissionSkip.
  ///
  /// In ko, this message translates to:
  /// **'나중에 설정하기'**
  String get permissionSkip;

  /// No description provided for @permissionSkipContacts.
  ///
  /// In ko, this message translates to:
  /// **'권한을 허용하지 않으시면 수동으로 연락처를 입력해야 합니다.'**
  String get permissionSkipContacts;

  /// No description provided for @permissionSkipCalendar.
  ///
  /// In ko, this message translates to:
  /// **'권한을 허용하지 않으시면 수동으로 일정을 입력해야 합니다.'**
  String get permissionSkipCalendar;

  /// No description provided for @permissionSms.
  ///
  /// In ko, this message translates to:
  /// **'SMS 접근 권한'**
  String get permissionSms;

  /// No description provided for @permissionSmsDesc.
  ///
  /// In ko, this message translates to:
  /// **'SMS 정보는 연락처와 주고받은 문자 메시지 내역을 확인하기 위해 필요합니다.\n\n카드를 보낸 후 문자로 안부를 주고받은 기록을 볼 수 있어요!'**
  String get permissionSmsDesc;

  /// No description provided for @permissionAllowSms.
  ///
  /// In ko, this message translates to:
  /// **'SMS 접근 허용'**
  String get permissionAllowSms;

  /// No description provided for @permissionSkipSms.
  ///
  /// In ko, this message translates to:
  /// **'권한을 허용하지 않으시면 문자 메시지 내역을 볼 수 없습니다.'**
  String get permissionSkipSms;

  /// No description provided for @permissionSendSms.
  ///
  /// In ko, this message translates to:
  /// **'SMS 발송 권한'**
  String get permissionSendSms;

  /// No description provided for @permissionSendSmsDesc.
  ///
  /// In ko, this message translates to:
  /// **'카드를 문자로 직접 발송하려면 SMS 발송 권한이 필요합니다.\n\n이 권한이 없으면 문자 앱을 통해서만 발송할 수 있습니다.'**
  String get permissionSendSmsDesc;

  /// No description provided for @permissionAllowSendSms.
  ///
  /// In ko, this message translates to:
  /// **'SMS 발송 허용'**
  String get permissionAllowSendSms;

  /// No description provided for @navHome.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get navHome;

  /// No description provided for @navContacts.
  ///
  /// In ko, this message translates to:
  /// **'연락처'**
  String get navContacts;

  /// No description provided for @navGallery.
  ///
  /// In ko, this message translates to:
  /// **'갤러리'**
  String get navGallery;

  /// No description provided for @navMessages.
  ///
  /// In ko, this message translates to:
  /// **'메시지'**
  String get navMessages;

  /// No description provided for @navSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get navSettings;

  /// No description provided for @homeUpcoming.
  ///
  /// In ko, this message translates to:
  /// **'다가오는 일정'**
  String get homeUpcoming;

  /// No description provided for @homeNoEvents.
  ///
  /// In ko, this message translates to:
  /// **'예정된 일정이 없습니다'**
  String get homeNoEvents;

  /// No description provided for @homeQuickSend.
  ///
  /// In ko, this message translates to:
  /// **'빠른 발송'**
  String get homeQuickSend;

  /// No description provided for @homeRecentCards.
  ///
  /// In ko, this message translates to:
  /// **'최근 보낸 카드'**
  String get homeRecentCards;

  /// No description provided for @homeWriteCard.
  ///
  /// In ko, this message translates to:
  /// **'카드 작성'**
  String get homeWriteCard;

  /// No description provided for @homeDaysLeft.
  ///
  /// In ko, this message translates to:
  /// **'일 남음'**
  String get homeDaysLeft;

  /// No description provided for @homeDDay.
  ///
  /// In ko, this message translates to:
  /// **'D-Day'**
  String get homeDDay;

  /// No description provided for @contactsTitle.
  ///
  /// In ko, this message translates to:
  /// **'연락처'**
  String get contactsTitle;

  /// No description provided for @contactsAll.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get contactsAll;

  /// No description provided for @contactsFamily.
  ///
  /// In ko, this message translates to:
  /// **'가족'**
  String get contactsFamily;

  /// No description provided for @contactsFriends.
  ///
  /// In ko, this message translates to:
  /// **'친구'**
  String get contactsFriends;

  /// No description provided for @contactsWork.
  ///
  /// In ko, this message translates to:
  /// **'직장'**
  String get contactsWork;

  /// No description provided for @contactsOthers.
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get contactsOthers;

  /// No description provided for @contactsFavorites.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기'**
  String get contactsFavorites;

  /// No description provided for @contactsEmpty.
  ///
  /// In ko, this message translates to:
  /// **'연락처가 없습니다'**
  String get contactsEmpty;

  /// No description provided for @contactsSearchHint.
  ///
  /// In ko, this message translates to:
  /// **'이름 또는 전화번호 검색'**
  String get contactsSearchHint;

  /// No description provided for @contactsMyPeople.
  ///
  /// In ko, this message translates to:
  /// **'내 사람들'**
  String get contactsMyPeople;

  /// No description provided for @contactsMemories.
  ///
  /// In ko, this message translates to:
  /// **'추억 기록'**
  String get contactsMemories;

  /// No description provided for @contactsRecent.
  ///
  /// In ko, this message translates to:
  /// **'최근 연락'**
  String get contactsRecent;

  /// No description provided for @contactsSearchPlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'이름, 태그 검색'**
  String get contactsSearchPlaceholder;

  /// No description provided for @contactsNoMemories.
  ///
  /// In ko, this message translates to:
  /// **'아직 추억 기록이 없습니다.'**
  String get contactsNoMemories;

  /// No description provided for @contactsSendCard.
  ///
  /// In ko, this message translates to:
  /// **'카드 보내기'**
  String get contactsSendCard;

  /// No description provided for @contactsCall.
  ///
  /// In ko, this message translates to:
  /// **'전화'**
  String get contactsCall;

  /// No description provided for @contactsMessage.
  ///
  /// In ko, this message translates to:
  /// **'문자'**
  String get contactsMessage;

  /// No description provided for @contactsBirthday.
  ///
  /// In ko, this message translates to:
  /// **'생일'**
  String get contactsBirthday;

  /// No description provided for @contactsAnniversary.
  ///
  /// In ko, this message translates to:
  /// **'기념일'**
  String get contactsAnniversary;

  /// No description provided for @contactsNoHistory.
  ///
  /// In ko, this message translates to:
  /// **'주고받은 내역이 없습니다.'**
  String get contactsNoHistory;

  /// No description provided for @contactsSearchContent.
  ///
  /// In ko, this message translates to:
  /// **'내용 검색'**
  String get contactsSearchContent;

  /// No description provided for @contactsNoSearchResult.
  ///
  /// In ko, this message translates to:
  /// **'검색 결과가 없습니다.'**
  String get contactsNoSearchResult;

  /// No description provided for @contactsMessageSent.
  ///
  /// In ko, this message translates to:
  /// **'보냄'**
  String get contactsMessageSent;

  /// No description provided for @contactsMessageReceived.
  ///
  /// In ko, this message translates to:
  /// **'받음'**
  String get contactsMessageReceived;

  /// No description provided for @contactsGroups.
  ///
  /// In ko, this message translates to:
  /// **'연락 그룹'**
  String get contactsGroups;

  /// No description provided for @groupManage.
  ///
  /// In ko, this message translates to:
  /// **'그룹 관리'**
  String get groupManage;

  /// No description provided for @groupAdd.
  ///
  /// In ko, this message translates to:
  /// **'그룹 추가'**
  String get groupAdd;

  /// No description provided for @groupEdit.
  ///
  /// In ko, this message translates to:
  /// **'그룹 편집'**
  String get groupEdit;

  /// No description provided for @groupDelete.
  ///
  /// In ko, this message translates to:
  /// **'그룹 삭제'**
  String get groupDelete;

  /// No description provided for @groupName.
  ///
  /// In ko, this message translates to:
  /// **'그룹 이름'**
  String get groupName;

  /// No description provided for @groupNameHint.
  ///
  /// In ko, this message translates to:
  /// **'그룹 이름을 입력하세요'**
  String get groupNameHint;

  /// No description provided for @groupNameRequired.
  ///
  /// In ko, this message translates to:
  /// **'그룹 이름을 입력해주세요'**
  String get groupNameRequired;

  /// No description provided for @groupDeleteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'\"{name}\" 그룹을 삭제하시겠습니까?'**
  String groupDeleteConfirm(String name);

  /// No description provided for @groupDeleteDesc.
  ///
  /// In ko, this message translates to:
  /// **'그룹만 삭제되며, 연락처는 유지됩니다.'**
  String get groupDeleteDesc;

  /// No description provided for @groupEmpty.
  ///
  /// In ko, this message translates to:
  /// **'그룹에 연락처가 없습니다'**
  String get groupEmpty;

  /// No description provided for @groupAddContact.
  ///
  /// In ko, this message translates to:
  /// **'연락처 추가'**
  String get groupAddContact;

  /// No description provided for @groupRemoveContact.
  ///
  /// In ko, this message translates to:
  /// **'그룹에서 제거'**
  String get groupRemoveContact;

  /// No description provided for @groupSelectGroups.
  ///
  /// In ko, this message translates to:
  /// **'그룹 선택'**
  String get groupSelectGroups;

  /// No description provided for @groupNoGroups.
  ///
  /// In ko, this message translates to:
  /// **'등록된 그룹이 없습니다'**
  String get groupNoGroups;

  /// No description provided for @groupCreateFirst.
  ///
  /// In ko, this message translates to:
  /// **'첫 번째 그룹을 만들어보세요!'**
  String get groupCreateFirst;

  /// No description provided for @groupMemberCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}명'**
  String groupMemberCount(int count);

  /// No description provided for @shareTitle.
  ///
  /// In ko, this message translates to:
  /// **'공유하기'**
  String get shareTitle;

  /// No description provided for @shareOtherApps.
  ///
  /// In ko, this message translates to:
  /// **'기타 앱으로 공유'**
  String get shareOtherApps;

  /// No description provided for @shareKakaoTalk.
  ///
  /// In ko, this message translates to:
  /// **'카카오톡'**
  String get shareKakaoTalk;

  /// No description provided for @shareInstagram.
  ///
  /// In ko, this message translates to:
  /// **'인스타그램'**
  String get shareInstagram;

  /// No description provided for @shareFacebook.
  ///
  /// In ko, this message translates to:
  /// **'페이스북'**
  String get shareFacebook;

  /// No description provided for @shareTwitter.
  ///
  /// In ko, this message translates to:
  /// **'X (트위터)'**
  String get shareTwitter;

  /// No description provided for @shareWhatsApp.
  ///
  /// In ko, this message translates to:
  /// **'WhatsApp'**
  String get shareWhatsApp;

  /// No description provided for @shareTelegram.
  ///
  /// In ko, this message translates to:
  /// **'텔레그램'**
  String get shareTelegram;

  /// No description provided for @galleryTitle.
  ///
  /// In ko, this message translates to:
  /// **'카드 갤러리'**
  String get galleryTitle;

  /// No description provided for @galleryBirthday.
  ///
  /// In ko, this message translates to:
  /// **'생일'**
  String get galleryBirthday;

  /// No description provided for @galleryChristmas.
  ///
  /// In ko, this message translates to:
  /// **'크리스마스'**
  String get galleryChristmas;

  /// No description provided for @galleryNewYear.
  ///
  /// In ko, this message translates to:
  /// **'새해'**
  String get galleryNewYear;

  /// No description provided for @galleryThanks.
  ///
  /// In ko, this message translates to:
  /// **'감사'**
  String get galleryThanks;

  /// No description provided for @galleryMothersDay.
  ///
  /// In ko, this message translates to:
  /// **'어버이날'**
  String get galleryMothersDay;

  /// No description provided for @galleryTeachersDay.
  ///
  /// In ko, this message translates to:
  /// **'스승의 날'**
  String get galleryTeachersDay;

  /// No description provided for @galleryHalloween.
  ///
  /// In ko, this message translates to:
  /// **'할로윈'**
  String get galleryHalloween;

  /// No description provided for @galleryThanksgiving.
  ///
  /// In ko, this message translates to:
  /// **'추수감사절'**
  String get galleryThanksgiving;

  /// No description provided for @galleryTravel.
  ///
  /// In ko, this message translates to:
  /// **'여행'**
  String get galleryTravel;

  /// No description provided for @galleryHobby.
  ///
  /// In ko, this message translates to:
  /// **'취미'**
  String get galleryHobby;

  /// No description provided for @gallerySports.
  ///
  /// In ko, this message translates to:
  /// **'스포츠'**
  String get gallerySports;

  /// No description provided for @galleryQute.
  ///
  /// In ko, this message translates to:
  /// **'귀여움'**
  String get galleryQute;

  /// No description provided for @galleryHeaven.
  ///
  /// In ko, this message translates to:
  /// **'천국'**
  String get galleryHeaven;

  /// No description provided for @galleryMyPhotos.
  ///
  /// In ko, this message translates to:
  /// **'내 사진'**
  String get galleryMyPhotos;

  /// No description provided for @gallerySelectImage.
  ///
  /// In ko, this message translates to:
  /// **'이미지 선택'**
  String get gallerySelectImage;

  /// No description provided for @galleryNoImages.
  ///
  /// In ko, this message translates to:
  /// **'이미지가 없습니다'**
  String get galleryNoImages;

  /// No description provided for @selectCategory.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 선택'**
  String get selectCategory;

  /// No description provided for @cardEditorTitle.
  ///
  /// In ko, this message translates to:
  /// **'카드 편집'**
  String get cardEditorTitle;

  /// No description provided for @cardEditorAddText.
  ///
  /// In ko, this message translates to:
  /// **'텍스트 추가'**
  String get cardEditorAddText;

  /// No description provided for @cardEditorAddSticker.
  ///
  /// In ko, this message translates to:
  /// **'스티커 추가'**
  String get cardEditorAddSticker;

  /// No description provided for @cardEditorAddImage.
  ///
  /// In ko, this message translates to:
  /// **'이미지 추가'**
  String get cardEditorAddImage;

  /// No description provided for @cardEditorBackground.
  ///
  /// In ko, this message translates to:
  /// **'배경'**
  String get cardEditorBackground;

  /// No description provided for @cardEditorFont.
  ///
  /// In ko, this message translates to:
  /// **'폰트'**
  String get cardEditorFont;

  /// No description provided for @cardEditorColor.
  ///
  /// In ko, this message translates to:
  /// **'색상'**
  String get cardEditorColor;

  /// No description provided for @cardEditorSize.
  ///
  /// In ko, this message translates to:
  /// **'크기'**
  String get cardEditorSize;

  /// No description provided for @cardEditorPreview.
  ///
  /// In ko, this message translates to:
  /// **'미리보기'**
  String get cardEditorPreview;

  /// No description provided for @cardEditorSend.
  ///
  /// In ko, this message translates to:
  /// **'발송'**
  String get cardEditorSend;

  /// No description provided for @cardEditorSave.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get cardEditorSave;

  /// No description provided for @cardEditorShare.
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get cardEditorShare;

  /// No description provided for @cardEditorEnterMessage.
  ///
  /// In ko, this message translates to:
  /// **'메시지를 입력하세요'**
  String get cardEditorEnterMessage;

  /// No description provided for @editorMessagePlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'보내실 내용을 입력하세요.'**
  String get editorMessagePlaceholder;

  /// No description provided for @cardEditorGenerateAI.
  ///
  /// In ko, this message translates to:
  /// **'AI 메시지 생성'**
  String get cardEditorGenerateAI;

  /// No description provided for @cardEditorTextBox.
  ///
  /// In ko, this message translates to:
  /// **'글상자'**
  String get cardEditorTextBox;

  /// No description provided for @cardEditorZoomHint.
  ///
  /// In ko, this message translates to:
  /// **'더블탭하시면 줌 모드로 전환됩니다'**
  String get cardEditorZoomHint;

  /// No description provided for @cardEditorRecipient.
  ///
  /// In ko, this message translates to:
  /// **'발송대상'**
  String get cardEditorRecipient;

  /// No description provided for @cardEditorAddRecipient.
  ///
  /// In ko, this message translates to:
  /// **'대상 추가'**
  String get cardEditorAddRecipient;

  /// No description provided for @recipientSelectTitle.
  ///
  /// In ko, this message translates to:
  /// **'발송 대상 선택'**
  String get recipientSelectTitle;

  /// No description provided for @recipientSearchHint.
  ///
  /// In ko, this message translates to:
  /// **'이름 또는 전화번호...'**
  String get recipientSearchHint;

  /// No description provided for @recipientAddNew.
  ///
  /// In ko, this message translates to:
  /// **'새 연락처 추가'**
  String get recipientAddNew;

  /// No description provided for @recipientName.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get recipientName;

  /// No description provided for @recipientPhone.
  ///
  /// In ko, this message translates to:
  /// **'전화번호'**
  String get recipientPhone;

  /// No description provided for @recipientAdd.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get recipientAdd;

  /// No description provided for @cardPreviewTitle.
  ///
  /// In ko, this message translates to:
  /// **'카드 이미지 확인'**
  String get cardPreviewTitle;

  /// No description provided for @cardPreviewDesc.
  ///
  /// In ko, this message translates to:
  /// **'수신자들에게 발송될 최종 이미지입니다.'**
  String get cardPreviewDesc;

  /// No description provided for @cardPreviewZoomHint.
  ///
  /// In ko, this message translates to:
  /// **'더블탭으로 확대/축소, 드래그로 이동이 가능합니다.'**
  String get cardPreviewZoomHint;

  /// No description provided for @cardPreviewCheckHint.
  ///
  /// In ko, this message translates to:
  /// **'발송 전 이미지 결과물을 확인해 주세요.'**
  String get cardPreviewCheckHint;

  /// No description provided for @cardPreviewConfirm.
  ///
  /// In ko, this message translates to:
  /// **'확인 (다음 단계)'**
  String get cardPreviewConfirm;

  /// No description provided for @sendTitle.
  ///
  /// In ko, this message translates to:
  /// **'발송 관리'**
  String get sendTitle;

  /// No description provided for @sendRecipients.
  ///
  /// In ko, this message translates to:
  /// **'수신자'**
  String get sendRecipients;

  /// No description provided for @sendAddRecipient.
  ///
  /// In ko, this message translates to:
  /// **'수신자 추가'**
  String get sendAddRecipient;

  /// No description provided for @sendStart.
  ///
  /// In ko, this message translates to:
  /// **'발송 시작'**
  String get sendStart;

  /// No description provided for @sendStop.
  ///
  /// In ko, this message translates to:
  /// **'발송 중지'**
  String get sendStop;

  /// No description provided for @sendContinue.
  ///
  /// In ko, this message translates to:
  /// **'계속 발송'**
  String get sendContinue;

  /// No description provided for @sendProgress.
  ///
  /// In ko, this message translates to:
  /// **'발송 진행 중'**
  String get sendProgress;

  /// No description provided for @sendComplete.
  ///
  /// In ko, this message translates to:
  /// **'발송 완료'**
  String get sendComplete;

  /// No description provided for @sendFailed.
  ///
  /// In ko, this message translates to:
  /// **'발송 실패'**
  String get sendFailed;

  /// No description provided for @sendPending.
  ///
  /// In ko, this message translates to:
  /// **'대기 중'**
  String get sendPending;

  /// No description provided for @sendTotalRecipients.
  ///
  /// In ko, this message translates to:
  /// **'총 수신자'**
  String get sendTotalRecipients;

  /// No description provided for @sendAutoResume.
  ///
  /// In ko, this message translates to:
  /// **'5건 발송 후 자동 계속'**
  String get sendAutoResume;

  /// No description provided for @sendManagerTitle.
  ///
  /// In ko, this message translates to:
  /// **'발송 대상 관리'**
  String get sendManagerTitle;

  /// No description provided for @sendTotal.
  ///
  /// In ko, this message translates to:
  /// **'총'**
  String get sendTotal;

  /// No description provided for @sendPerson.
  ///
  /// In ko, this message translates to:
  /// **'명'**
  String get sendPerson;

  /// No description provided for @sendSpamWarning.
  ///
  /// In ko, this message translates to:
  /// **'단시간 다량 발송은 스팸 정책에 의해 제한될 수 있습니다.\n안전을 위해 자동 계속 해제를 권장합니다.'**
  String get sendSpamWarning;

  /// No description provided for @totalPersonCount.
  ///
  /// In ko, this message translates to:
  /// **'총 {count}명'**
  String totalPersonCount(int count);

  /// No description provided for @cardHintZoomMode.
  ///
  /// In ko, this message translates to:
  /// **'배경 이미지를 더블탭하시면 줌 모드로 전환됩니다. 줌 모드에서 이미지 크기와 위치를 조절하실 수 있습니다.'**
  String get cardHintZoomMode;

  /// No description provided for @cardHintZoomEdit.
  ///
  /// In ko, this message translates to:
  /// **'두 손가락으로 벌리거나 줄여서 이미지 크기를 조정하실 수 있습니다. 한 손가락으로 드래그하시면 이미지를 이동하실 수 있습니다. 편집이 완료되시면 더블탭 또는 줌 모드 버튼을 눌러 종료해 주세요.'**
  String get cardHintZoomEdit;

  /// No description provided for @cardHintDragging.
  ///
  /// In ko, this message translates to:
  /// **'이미지 이동 중...'**
  String get cardHintDragging;

  /// No description provided for @cardHintPinching.
  ///
  /// In ko, this message translates to:
  /// **'이미지 크기 조절 중...'**
  String get cardHintPinching;

  /// No description provided for @savedCardsTitle.
  ///
  /// In ko, this message translates to:
  /// **'저장된 카드 목록'**
  String get savedCardsTitle;

  /// No description provided for @savedCardsEmpty.
  ///
  /// In ko, this message translates to:
  /// **'저장된 메시지가 없습니다.'**
  String get savedCardsEmpty;

  /// No description provided for @cardSaveTitle.
  ///
  /// In ko, this message translates to:
  /// **'카드 저장'**
  String get cardSaveTitle;

  /// No description provided for @cardSaveName.
  ///
  /// In ko, this message translates to:
  /// **'저장할 이름'**
  String get cardSaveName;

  /// No description provided for @cardSaveHint.
  ///
  /// In ko, this message translates to:
  /// **'카드의 이름을 입력하세요'**
  String get cardSaveHint;

  /// No description provided for @cardNoTitle.
  ///
  /// In ko, this message translates to:
  /// **'제목 없음'**
  String get cardNoTitle;

  /// No description provided for @cardImageFailed.
  ///
  /// In ko, this message translates to:
  /// **'카드 이미지 생성 실패'**
  String get cardImageFailed;

  /// No description provided for @messageHistory.
  ///
  /// In ko, this message translates to:
  /// **'발송 기록'**
  String get messageHistory;

  /// No description provided for @messageNoHistory.
  ///
  /// In ko, this message translates to:
  /// **'발송 기록이 없습니다'**
  String get messageNoHistory;

  /// No description provided for @messageSent.
  ///
  /// In ko, this message translates to:
  /// **'발송 완료'**
  String get messageSent;

  /// No description provided for @messageViewed.
  ///
  /// In ko, this message translates to:
  /// **'확인함'**
  String get messageViewed;

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In ko, this message translates to:
  /// **'프로필'**
  String get settingsProfile;

  /// No description provided for @settingsName.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get settingsName;

  /// No description provided for @settingsLanguage.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get settingsLanguage;

  /// No description provided for @settingsNotifications.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationTime.
  ///
  /// In ko, this message translates to:
  /// **'알림 시간'**
  String get settingsNotificationTime;

  /// No description provided for @settingsReceiveAlerts.
  ///
  /// In ko, this message translates to:
  /// **'알림 받기'**
  String get settingsReceiveAlerts;

  /// No description provided for @settingsSetTime.
  ///
  /// In ko, this message translates to:
  /// **'시간 설정'**
  String get settingsSetTime;

  /// No description provided for @settingsDesignSending.
  ///
  /// In ko, this message translates to:
  /// **'디자인/발송'**
  String get settingsDesignSending;

  /// No description provided for @settingsCardBranding.
  ///
  /// In ko, this message translates to:
  /// **'카드 하단 브랜딩'**
  String get settingsCardBranding;

  /// No description provided for @settingsDataManage.
  ///
  /// In ko, this message translates to:
  /// **'데이터 관리'**
  String get settingsDataManage;

  /// No description provided for @settingsBranding.
  ///
  /// In ko, this message translates to:
  /// **'브랜딩 표시'**
  String get settingsBranding;

  /// No description provided for @settingsSync.
  ///
  /// In ko, this message translates to:
  /// **'동기화'**
  String get settingsSync;

  /// No description provided for @settingsSyncContacts.
  ///
  /// In ko, this message translates to:
  /// **'연락처 동기화'**
  String get settingsSyncContacts;

  /// No description provided for @settingsSyncCalendar.
  ///
  /// In ko, this message translates to:
  /// **'캘린더 동기화'**
  String get settingsSyncCalendar;

  /// No description provided for @settingsBackup.
  ///
  /// In ko, this message translates to:
  /// **'백업'**
  String get settingsBackup;

  /// No description provided for @settingsRestore.
  ///
  /// In ko, this message translates to:
  /// **'복원'**
  String get settingsRestore;

  /// No description provided for @settingsExport.
  ///
  /// In ko, this message translates to:
  /// **'내보내기'**
  String get settingsExport;

  /// No description provided for @settingsImport.
  ///
  /// In ko, this message translates to:
  /// **'가져오기'**
  String get settingsImport;

  /// No description provided for @settingsCalendarSync.
  ///
  /// In ko, this message translates to:
  /// **'캘린더 연동'**
  String get settingsCalendarSync;

  /// No description provided for @settingsOpenCalendar.
  ///
  /// In ko, this message translates to:
  /// **'캘린더 열기'**
  String get settingsOpenCalendar;

  /// No description provided for @settingsCalendarGuide.
  ///
  /// In ko, this message translates to:
  /// **'지원 캘린더 안내'**
  String get settingsCalendarGuide;

  /// No description provided for @settingsAppInfo.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get settingsAppInfo;

  /// No description provided for @settingsContactUs.
  ///
  /// In ko, this message translates to:
  /// **'문의하기'**
  String get settingsContactUs;

  /// No description provided for @settingsAccount.
  ///
  /// In ko, this message translates to:
  /// **'계정'**
  String get settingsAccount;

  /// No description provided for @settingsExit.
  ///
  /// In ko, this message translates to:
  /// **'나가기'**
  String get settingsExit;

  /// No description provided for @settingsMyName.
  ///
  /// In ko, this message translates to:
  /// **'내 이름/별명'**
  String get settingsMyName;

  /// No description provided for @settingsNameOrNickname.
  ///
  /// In ko, this message translates to:
  /// **'이름 또는 별명'**
  String get settingsNameOrNickname;

  /// No description provided for @settingsNameHint.
  ///
  /// In ko, this message translates to:
  /// **'카드에 표시될 이름'**
  String get settingsNameHint;

  /// No description provided for @settingsNameUsageInfo.
  ///
  /// In ko, this message translates to:
  /// **'이 이름은 카드 쓰기 화면의 Footer(서명)에 사용됩니다.'**
  String get settingsNameUsageInfo;

  /// No description provided for @settingsAbout.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get settingsVersion;

  /// No description provided for @settingsPrivacy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침'**
  String get settingsPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get settingsTerms;

  /// No description provided for @settingsHelp.
  ///
  /// In ko, this message translates to:
  /// **'도움말'**
  String get settingsHelp;

  /// No description provided for @settingsExternalCalendarGuide.
  ///
  /// In ko, this message translates to:
  /// **'외부 캘린더 연동 안내'**
  String get settingsExternalCalendarGuide;

  /// No description provided for @settingsTest.
  ///
  /// In ko, this message translates to:
  /// **'테스트'**
  String get settingsTest;

  /// No description provided for @settingsGoogleCalendar.
  ///
  /// In ko, this message translates to:
  /// **'Google 캘린더'**
  String get settingsGoogleCalendar;

  /// No description provided for @settingsSamsungCalendar.
  ///
  /// In ko, this message translates to:
  /// **'Samsung 캘린더'**
  String get settingsSamsungCalendar;

  /// No description provided for @settingsDarkMode.
  ///
  /// In ko, this message translates to:
  /// **'다크 모드'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeDesc.
  ///
  /// In ko, this message translates to:
  /// **'어두운 테마 사용'**
  String get settingsDarkModeDesc;

  /// No description provided for @splashPreparing.
  ///
  /// In ko, this message translates to:
  /// **'준비 중...'**
  String get splashPreparing;

  /// No description provided for @splashLoadingData.
  ///
  /// In ko, this message translates to:
  /// **'데이터를 불러오는 중...'**
  String get splashLoadingData;

  /// No description provided for @splashSyncingContacts.
  ///
  /// In ko, this message translates to:
  /// **'연락처를 동기화하는 중...'**
  String get splashSyncingContacts;

  /// No description provided for @splashSyncingCalendar.
  ///
  /// In ko, this message translates to:
  /// **'캘린더를 동기화하는 중...'**
  String get splashSyncingCalendar;

  /// No description provided for @splashGeneratingSchedules.
  ///
  /// In ko, this message translates to:
  /// **'일정을 생성하는 중...'**
  String get splashGeneratingSchedules;

  /// No description provided for @splashPreparingScreen.
  ///
  /// In ko, this message translates to:
  /// **'화면을 준비하는 중...'**
  String get splashPreparingScreen;

  /// No description provided for @splashReady.
  ///
  /// In ko, this message translates to:
  /// **'준비 완료!'**
  String get splashReady;

  /// No description provided for @helloUser.
  ///
  /// In ko, this message translates to:
  /// **'안녕하세요, {name} 님! 👋'**
  String helloUser(String name);

  /// No description provided for @errorNetwork.
  ///
  /// In ko, this message translates to:
  /// **'네트워크 오류가 발생했습니다'**
  String get errorNetwork;

  /// No description provided for @errorUnknown.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 오류가 발생했습니다'**
  String get errorUnknown;

  /// No description provided for @errorPermission.
  ///
  /// In ko, this message translates to:
  /// **'권한이 필요합니다'**
  String get errorPermission;

  /// No description provided for @errorLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'데이터를 불러오지 못했습니다'**
  String get errorLoadFailed;

  /// No description provided for @errorSaveFailed.
  ///
  /// In ko, this message translates to:
  /// **'저장에 실패했습니다'**
  String get errorSaveFailed;

  /// No description provided for @errorSendFailed.
  ///
  /// In ko, this message translates to:
  /// **'발송에 실패했습니다'**
  String get errorSendFailed;

  /// No description provided for @errorImageFailed.
  ///
  /// In ko, this message translates to:
  /// **'이미지 처리에 실패했습니다'**
  String get errorImageFailed;

  /// No description provided for @confirmDelete.
  ///
  /// In ko, this message translates to:
  /// **'정말 삭제하시겠습니까?'**
  String get confirmDelete;

  /// No description provided for @confirmExit.
  ///
  /// In ko, this message translates to:
  /// **'변경사항을 저장하지 않고 나가시겠습니까?'**
  String get confirmExit;

  /// No description provided for @confirmSend.
  ///
  /// In ko, this message translates to:
  /// **'발송하시겠습니까?'**
  String get confirmSend;

  /// No description provided for @dateToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get dateToday;

  /// No description provided for @dateTomorrow.
  ///
  /// In ko, this message translates to:
  /// **'내일'**
  String get dateTomorrow;

  /// No description provided for @dateYesterday.
  ///
  /// In ko, this message translates to:
  /// **'어제'**
  String get dateYesterday;

  /// No description provided for @dateThisWeek.
  ///
  /// In ko, this message translates to:
  /// **'이번 주'**
  String get dateThisWeek;

  /// No description provided for @dateNextWeek.
  ///
  /// In ko, this message translates to:
  /// **'다음 주'**
  String get dateNextWeek;

  /// No description provided for @dateThisMonth.
  ///
  /// In ko, this message translates to:
  /// **'이번 달'**
  String get dateThisMonth;

  /// No description provided for @daysRemaining.
  ///
  /// In ko, this message translates to:
  /// **'{days}일 남음'**
  String daysRemaining(int days);

  /// No description provided for @daysAgo.
  ///
  /// In ko, this message translates to:
  /// **'{days}일 전'**
  String daysAgo(int days);

  /// No description provided for @sendResultSuccess.
  ///
  /// In ko, this message translates to:
  /// **'성공: {count}건'**
  String sendResultSuccess(int count);

  /// No description provided for @sendResultFailed.
  ///
  /// In ko, this message translates to:
  /// **'실패: {count}건'**
  String sendResultFailed(int count);

  /// No description provided for @eventBirthday.
  ///
  /// In ko, this message translates to:
  /// **'생일'**
  String get eventBirthday;

  /// No description provided for @eventAnniversary.
  ///
  /// In ko, this message translates to:
  /// **'기념일'**
  String get eventAnniversary;

  /// No description provided for @eventHoliday.
  ///
  /// In ko, this message translates to:
  /// **'공휴일'**
  String get eventHoliday;

  /// No description provided for @eventMeeting.
  ///
  /// In ko, this message translates to:
  /// **'모임'**
  String get eventMeeting;

  /// No description provided for @eventOther.
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get eventOther;

  /// No description provided for @scheduleEdit.
  ///
  /// In ko, this message translates to:
  /// **'일정 수정'**
  String get scheduleEdit;

  /// No description provided for @scheduleAdd.
  ///
  /// In ko, this message translates to:
  /// **'일정 추가'**
  String get scheduleAdd;

  /// No description provided for @scheduleAddNew.
  ///
  /// In ko, this message translates to:
  /// **'새 일정'**
  String get scheduleAddNew;

  /// No description provided for @scheduleTitle.
  ///
  /// In ko, this message translates to:
  /// **'제목'**
  String get scheduleTitle;

  /// No description provided for @scheduleRecipients.
  ///
  /// In ko, this message translates to:
  /// **'수신자'**
  String get scheduleRecipients;

  /// No description provided for @scheduleDate.
  ///
  /// In ko, this message translates to:
  /// **'날짜'**
  String get scheduleDate;

  /// No description provided for @scheduleIconType.
  ///
  /// In ko, this message translates to:
  /// **'아이콘'**
  String get scheduleIconType;

  /// No description provided for @scheduleAddToCalendar.
  ///
  /// In ko, this message translates to:
  /// **'캘린더에 추가'**
  String get scheduleAddToCalendar;

  /// No description provided for @scheduleAddedSuccess.
  ///
  /// In ko, this message translates to:
  /// **'일정이 추가되었습니다!'**
  String get scheduleAddedSuccess;

  /// No description provided for @planEdit.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get planEdit;

  /// No description provided for @planDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get planDelete;

  /// No description provided for @planMoveToEnd.
  ///
  /// In ko, this message translates to:
  /// **'끝으로 이동'**
  String get planMoveToEnd;

  /// No description provided for @planReschedule.
  ///
  /// In ko, this message translates to:
  /// **'날짜 변경'**
  String get planReschedule;

  /// No description provided for @planChangeIcon.
  ///
  /// In ko, this message translates to:
  /// **'아이콘 변경'**
  String get planChangeIcon;

  /// No description provided for @planSelectIcon.
  ///
  /// In ko, this message translates to:
  /// **'아이콘 선택'**
  String get planSelectIcon;

  /// No description provided for @planDeleteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'\"{title}\"을(를) 삭제하시겠습니까?'**
  String planDeleteConfirm(String title);

  /// No description provided for @iconNormal.
  ///
  /// In ko, this message translates to:
  /// **'일반'**
  String get iconNormal;

  /// No description provided for @iconHoliday.
  ///
  /// In ko, this message translates to:
  /// **'휴일'**
  String get iconHoliday;

  /// No description provided for @iconBirthday.
  ///
  /// In ko, this message translates to:
  /// **'생일'**
  String get iconBirthday;

  /// No description provided for @iconAnniversary.
  ///
  /// In ko, this message translates to:
  /// **'기념일'**
  String get iconAnniversary;

  /// No description provided for @iconWork.
  ///
  /// In ko, this message translates to:
  /// **'업무'**
  String get iconWork;

  /// No description provided for @iconPersonal.
  ///
  /// In ko, this message translates to:
  /// **'개인'**
  String get iconPersonal;

  /// No description provided for @iconImportant.
  ///
  /// In ko, this message translates to:
  /// **'중요'**
  String get iconImportant;

  /// No description provided for @cardWrite.
  ///
  /// In ko, this message translates to:
  /// **'작성'**
  String get cardWrite;

  /// No description provided for @languageSelection.
  ///
  /// In ko, this message translates to:
  /// **'언어 선택'**
  String get languageSelection;

  /// No description provided for @previousLanguage.
  ///
  /// In ko, this message translates to:
  /// **'이전 언어'**
  String get previousLanguage;

  /// No description provided for @nextLanguage.
  ///
  /// In ko, this message translates to:
  /// **'다음 언어'**
  String get nextLanguage;

  /// No description provided for @previewTitle.
  ///
  /// In ko, this message translates to:
  /// **'미리보기'**
  String get previewTitle;

  /// No description provided for @previewConfirm.
  ///
  /// In ko, this message translates to:
  /// **'이 이미지로 발송하시겠습니까?'**
  String get previewConfirm;

  /// No description provided for @textBoxStyleTitle.
  ///
  /// In ko, this message translates to:
  /// **'글상자 스타일'**
  String get textBoxStyleTitle;

  /// No description provided for @textBoxPreviewText.
  ///
  /// In ko, this message translates to:
  /// **'스타일 미리보기'**
  String get textBoxPreviewText;

  /// No description provided for @textBoxShapeRounded.
  ///
  /// In ko, this message translates to:
  /// **'둥근'**
  String get textBoxShapeRounded;

  /// No description provided for @textBoxShapeSquare.
  ///
  /// In ko, this message translates to:
  /// **'직각'**
  String get textBoxShapeSquare;

  /// No description provided for @textBoxShapeBevel.
  ///
  /// In ko, this message translates to:
  /// **'모따기'**
  String get textBoxShapeBevel;

  /// No description provided for @textBoxShapeCircle.
  ///
  /// In ko, this message translates to:
  /// **'원형'**
  String get textBoxShapeCircle;

  /// No description provided for @textBoxShapeBubble.
  ///
  /// In ko, this message translates to:
  /// **'말풍선'**
  String get textBoxShapeBubble;

  /// No description provided for @textBoxBackgroundColor.
  ///
  /// In ko, this message translates to:
  /// **'배경 색상'**
  String get textBoxBackgroundColor;

  /// No description provided for @textBoxOpacity.
  ///
  /// In ko, this message translates to:
  /// **'투명도'**
  String get textBoxOpacity;

  /// No description provided for @textBoxBorderRadius.
  ///
  /// In ko, this message translates to:
  /// **'둥근 모서리'**
  String get textBoxBorderRadius;

  /// No description provided for @textBoxBorder.
  ///
  /// In ko, this message translates to:
  /// **'테두리'**
  String get textBoxBorder;

  /// No description provided for @textBoxBorderWidth.
  ///
  /// In ko, this message translates to:
  /// **'테두리 두께'**
  String get textBoxBorderWidth;

  /// No description provided for @textBoxFooterStyle.
  ///
  /// In ko, this message translates to:
  /// **'푸터 (보낸 사람) 배경 스타일'**
  String get textBoxFooterStyle;

  /// No description provided for @textBoxFooterHint.
  ///
  /// In ko, this message translates to:
  /// **'글자 크기와 색상은 푸터를 선택 후 상단 툴바에서 변경하세요.'**
  String get textBoxFooterHint;

  /// No description provided for @textBoxPreview.
  ///
  /// In ko, this message translates to:
  /// **'스타일 미리보기'**
  String get textBoxPreview;

  /// No description provided for @textBoxSender.
  ///
  /// In ko, this message translates to:
  /// **'보낸 사람'**
  String get textBoxSender;

  /// No description provided for @textBoxShapeLabel.
  ///
  /// In ko, this message translates to:
  /// **'글상자 모양'**
  String get textBoxShapeLabel;

  /// No description provided for @shapeRounded.
  ///
  /// In ko, this message translates to:
  /// **'둥근'**
  String get shapeRounded;

  /// No description provided for @shapeRectangle.
  ///
  /// In ko, this message translates to:
  /// **'직각'**
  String get shapeRectangle;

  /// No description provided for @shapeBevel.
  ///
  /// In ko, this message translates to:
  /// **'모따기'**
  String get shapeBevel;

  /// No description provided for @shapeCircle.
  ///
  /// In ko, this message translates to:
  /// **'원형'**
  String get shapeCircle;

  /// No description provided for @shapeBubbleLeft.
  ///
  /// In ko, this message translates to:
  /// **'말풍선(좌)'**
  String get shapeBubbleLeft;

  /// No description provided for @shapeBubbleCenter.
  ///
  /// In ko, this message translates to:
  /// **'말풍선(중)'**
  String get shapeBubbleCenter;

  /// No description provided for @shapeBubbleRight.
  ///
  /// In ko, this message translates to:
  /// **'말풍선(우)'**
  String get shapeBubbleRight;

  /// No description provided for @shapeHeart.
  ///
  /// In ko, this message translates to:
  /// **'하트'**
  String get shapeHeart;

  /// No description provided for @shapeStar.
  ///
  /// In ko, this message translates to:
  /// **'별'**
  String get shapeStar;

  /// No description provided for @shapeDiamond.
  ///
  /// In ko, this message translates to:
  /// **'다이아'**
  String get shapeDiamond;

  /// No description provided for @shapeHexagon.
  ///
  /// In ko, this message translates to:
  /// **'육각형'**
  String get shapeHexagon;

  /// No description provided for @shapeCloud.
  ///
  /// In ko, this message translates to:
  /// **'구름'**
  String get shapeCloud;

  /// No description provided for @footerBgOpacity.
  ///
  /// In ko, this message translates to:
  /// **'배경 투명도'**
  String get footerBgOpacity;

  /// No description provided for @footerBgRadius.
  ///
  /// In ko, this message translates to:
  /// **'배경 둥근 모서리'**
  String get footerBgRadius;

  /// No description provided for @contactPickerTitle.
  ///
  /// In ko, this message translates to:
  /// **'발송 대상 선택'**
  String get contactPickerTitle;

  /// No description provided for @contactPickerSearchHint.
  ///
  /// In ko, this message translates to:
  /// **'이름 또는 전화번호...'**
  String get contactPickerSearchHint;

  /// No description provided for @contactPickerAllContacts.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get contactPickerAllContacts;

  /// No description provided for @contactPickerFavorites.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기'**
  String get contactPickerFavorites;

  /// No description provided for @contactPickerFamily.
  ///
  /// In ko, this message translates to:
  /// **'가족'**
  String get contactPickerFamily;

  /// No description provided for @contactPickerAddNew.
  ///
  /// In ko, this message translates to:
  /// **'새 연락처 추가'**
  String get contactPickerAddNew;

  /// No description provided for @addContactTitle.
  ///
  /// In ko, this message translates to:
  /// **'새 연락처 추가'**
  String get addContactTitle;

  /// No description provided for @addContactName.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get addContactName;

  /// No description provided for @addContactPhone.
  ///
  /// In ko, this message translates to:
  /// **'전화번호'**
  String get addContactPhone;

  /// No description provided for @addContactAdd.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get addContactAdd;

  /// No description provided for @editorBackground.
  ///
  /// In ko, this message translates to:
  /// **'배경'**
  String get editorBackground;

  /// No description provided for @editorTextBox.
  ///
  /// In ko, this message translates to:
  /// **'글상자'**
  String get editorTextBox;

  /// No description provided for @photoPermissionTitle.
  ///
  /// In ko, this message translates to:
  /// **'사진 접근 권한 필요'**
  String get photoPermissionTitle;

  /// No description provided for @photoPermissionDesc.
  ///
  /// In ko, this message translates to:
  /// **'기기의 사진을 카드 배경으로 사용하려면\n갤러리 접근 권한이 필요합니다.'**
  String get photoPermissionDesc;

  /// No description provided for @photoPermissionHowTo.
  ///
  /// In ko, this message translates to:
  /// **'📱 권한 설정 방법'**
  String get photoPermissionHowTo;

  /// No description provided for @photoPermissionStep1.
  ///
  /// In ko, this message translates to:
  /// **'1. 아래 \"설정 열기\" 버튼을 누르세요'**
  String get photoPermissionStep1;

  /// No description provided for @photoPermissionStep2.
  ///
  /// In ko, this message translates to:
  /// **'2. \"권한\" 항목을 찾아 터치하세요'**
  String get photoPermissionStep2;

  /// No description provided for @photoPermissionStep3.
  ///
  /// In ko, this message translates to:
  /// **'3. \"사진 및 동영상\"을 터치하세요'**
  String get photoPermissionStep3;

  /// No description provided for @photoPermissionStep4.
  ///
  /// In ko, this message translates to:
  /// **'4. \"허용\" 또는 \"모든 사진 허용\"을 선택하세요'**
  String get photoPermissionStep4;

  /// No description provided for @photoPermissionNote.
  ///
  /// In ko, this message translates to:
  /// **'⚡ 권한을 허용한 후 이 화면으로 돌아오면\n자동으로 사진이 표시됩니다.'**
  String get photoPermissionNote;

  /// No description provided for @openSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정 열기'**
  String get openSettings;

  /// No description provided for @premiumImage.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 이미지'**
  String get premiumImage;

  /// No description provided for @watchAdToUnlock.
  ///
  /// In ko, this message translates to:
  /// **'광고를 시청하고 잠금 해제'**
  String get watchAdToUnlock;

  /// No description provided for @unlockSuccess.
  ///
  /// In ko, this message translates to:
  /// **'잠금이 해제되었습니다!'**
  String get unlockSuccess;

  /// No description provided for @adNotReady.
  ///
  /// In ko, this message translates to:
  /// **'광고가 준비되지 않았습니다. 잠시 후 다시 시도해주세요.'**
  String get adNotReady;

  /// No description provided for @watchAd.
  ///
  /// In ko, this message translates to:
  /// **'광고 보기'**
  String get watchAd;

  /// No description provided for @premiumLocked.
  ///
  /// In ko, this message translates to:
  /// **'잠금'**
  String get premiumLocked;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'id',
        'it',
        'ja',
        'ko',
        'pt',
        'ru',
        'tr',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
