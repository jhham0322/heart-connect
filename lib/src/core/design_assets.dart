import 'package:flutter/foundation.dart';

/// 디자인 테마 관리
/// 
/// 여러 디자인 세트(테마)를 관리하고 런타임에 전환할 수 있습니다.
/// 각 테마는 assets/design/{themeName}/ 폴더에 이미지 세트를 가집니다.
class DesignAssets extends ChangeNotifier {
  static DesignAssets? _instance;
  static DesignAssets get instance => _instance ??= DesignAssets._();
  
  DesignAssets._();
  
  /// 사용 가능한 테마 목록
  static const List<String> availableThemes = [
    'default',      // 기본 테마 (현재 디자인)
    'pink_kawaii',  // 핑크 카와이 테마 (새 디자인)
  ];
  
  /// 현재 활성 테마
  String _currentTheme = 'default';
  String get currentTheme => _currentTheme;
  
  /// 테마 변경
  void setTheme(String themeName) {
    if (availableThemes.contains(themeName)) {
      _currentTheme = themeName;
      notifyListeners();
    }
  }
  
  /// 테마별 기본 경로
  String get _basePath => 'assets/design/$_currentTheme';
  
  // ===== Backgrounds =====
  
  /// 홈 화면 배경
  String get homeBg => '$_basePath/backgrounds/home_bg.png';
  
  /// 기본 그라데이션 배경
  String get gradientBg => '$_basePath/backgrounds/gradient_bg.png';
  
  /// 앱바 배경 배경
  String get appBarBg => '$_basePath/backgrounds/app_bar_bg.png';
  
  // ===== Cards =====
  
  /// 메인 카드 프레임 (구름 모양 등)
  String get mainCardFrame => '$_basePath/cards/main_card_frame.png';
  
  /// 일정 카드 배경
  String get eventCardBg => '$_basePath/cards/event_card_bg.png';
  
  // ===== Icons =====
  
  /// 앱 로고
  String get appLogo => '$_basePath/icons/app_logo.png';
  
  /// 앱 아이콘 (스플래시, 런처)
  String get appIcon => '$_basePath/icons/app_icon.png';
  
  /// 온보딩 하트 아이콘
  String get onboardingHeart => '$_basePath/icons/onboarding_heart.png';
  
  /// 하트 아이콘
  String get heartIcon => '$_basePath/icons/heart_icon.png';
  
  /// 캘린더 아이콘
  String get calendarIcon => '$_basePath/icons/calendar_icon.png';
  
  /// 벨 아이콘 (알림)
  String get bellIcon => '$_basePath/icons/bell_icon.png';
  
  /// 설정 아이콘
  String get settingsIcon => '$_basePath/icons/settings_icon.png';
  
  // ===== Frames (카드 테두리) =====
  
  /// 프레임 폴더 경로
  String get framesPath => '$_basePath/frames/';
  
  // ===== Buttons =====
  
  /// 작성 버튼 이미지 (하트 모양 등)
  String get btnWrite => '$_basePath/buttons/btn_write.png';
  
  /// 편집 버튼 이미지
  String get btnEdit => '$_basePath/buttons/btn_edit.png';
  
  /// 더보기 버튼 이미지
  String get btnMore => '$_basePath/buttons/btn_more.png';
  
  // ===== Avatars =====
  
  /// 곰 아바타
  String get avatarBear => '$_basePath/avatars/avatar_bear.png';
  
  /// 토끼 아바타
  String get avatarRabbit => '$_basePath/avatars/avatar_rabbit.png';
  
  /// 고양이 아바타
  String get avatarCat => '$_basePath/avatars/avatar_cat.png';
  
  /// 강아지 아바타
  String get avatarDog => '$_basePath/avatars/avatar_dog.png';
  
  /// 아바타 목록
  List<String> get avatars => [
    avatarBear,
    avatarRabbit,
    avatarCat,
    avatarDog,
  ];
  
  /// 인덱스로 아바타 가져오기 (순환)
  String getAvatarByIndex(int index) {
    return avatars[index % avatars.length];
  }
  
  // ===== Decorations =====
  
  /// 작은 하트 장식
  String get decorHeartSmall => '$_basePath/decorations/heart_small.png';
  
  /// 큰 하트 장식
  String get decorHeartLarge => '$_basePath/decorations/heart_large.png';
  
  /// 작은 별 장식
  String get decorStarSmall => '$_basePath/decorations/star_small.png';
  
  // ===== Navigation =====
  
  /// 네비게이션 바 배경
  String get navBarBg => '$_basePath/navigation/nav_bar_bg.png';
  
  /// 홈 네비 아이콘
  String get navHome => '$_basePath/navigation/nav_home.png';
  
  /// 연락처 네비 아이콘
  String get navContacts => '$_basePath/navigation/nav_contacts.png';
  
  /// 갤러리 네비 아이콘
  String get navGallery => '$_basePath/navigation/nav_gallery.png';
  
  /// 메시지 네비 아이콘
  String get navMessage => '$_basePath/navigation/nav_message.png';
  
  /// FAB 배경 이미지
  String get fabBg => '$_basePath/navigation/fab_bg.png';
  
  /// FAB 아이콘 이미지
  String get fabIcon => '$_basePath/navigation/fab_icon.png';
  
  // ===== Common Icons =====
  
  /// 추가 아이콘
  String get iconPlus => '$_basePath/icons/icon_plus.png';
  
  /// 편집 아이콘
  String get iconEdit => '$_basePath/icons/icon_edit.png';
  
  /// 삭제 아이콘
  String get iconDelete => '$_basePath/icons/icon_delete.png';
  
  /// 체크 아이콘
  String get iconCheck => '$_basePath/icons/icon_check.png';
  
  /// 더보기 아이콘
  String get iconMore => '$_basePath/icons/icon_more.png';
  
  /// 검색 아이콘
  String get iconSearch => '$_basePath/icons/icon_search.png';
  
  // ===== Event Type Icons =====
  
  /// 일반 일정 아이콘
  String get eventNormal => '$_basePath/icons/event_normal.png';
  
  /// 공휴일 아이콘
  String get eventHoliday => '$_basePath/icons/event_holiday.png';
  
  /// 생일 아이콘
  String get eventBirthday => '$_basePath/icons/event_birthday.png';
  
  /// 기념일 아이콘
  String get eventAnniversary => '$_basePath/icons/event_anniversary.png';
  
  /// 업무 아이콘
  String get eventWork => '$_basePath/icons/event_work.png';
  
  /// 개인 아이콘
  String get eventPersonal => '$_basePath/icons/event_personal.png';
  
  /// 중요 아이콘
  String get eventImportant => '$_basePath/icons/event_important.png';
  
  /// 일정 타입별 아이콘 맵
  Map<String, String> get eventTypeIcons => {
    'Normal': eventNormal,
    'Holiday': eventHoliday,
    'Birthday': eventBirthday,
    'Anniversary': eventAnniversary,
    'Work': eventWork,
    'Personal': eventPersonal,
    'Important': eventImportant,
  };
  
  // ===== Static Constants (Fallback / 테마 무관) =====
  
  /// 기본 아이콘 폴더 (테마와 무관하게 항상 사용 가능)
  static const String iconsPath = 'assets/icons';
  
  /// 기본 앱 로고 (fallback)
  static const String fallbackAppLogo = '$iconsPath/app_logo.png';
  
  /// 기본 하트 아이콘 (fallback)
  static const String fallbackHeartIcon = '$iconsPath/heart_icon.png';
  
  /// 기본 앱 아이콘 (fallback)
  static const String fallbackAppIcon = '$iconsPath/app_icon.png';
}

/// 편의를 위한 글로벌 접근자
DesignAssets get $assets => DesignAssets.instance;
