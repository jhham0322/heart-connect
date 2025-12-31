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
  
  // ===== Cards =====
  
  /// 메인 카드 프레임 (구름 모양 등)
  String get mainCardFrame => '$_basePath/cards/main_card_frame.png';
  
  /// 일정 카드 배경
  String get eventCardBg => '$_basePath/cards/event_card_bg.png';
  
  // ===== Icons =====
  
  /// 앱 로고
  String get appLogo => '$_basePath/icons/app_logo.png';
  
  /// 하트 아이콘
  String get heartIcon => '$_basePath/icons/heart_icon.png';
  
  /// 캘린더 아이콘
  String get calendarIcon => '$_basePath/icons/calendar_icon.png';
  
  /// 벨 아이콘 (알림)
  String get bellIcon => '$_basePath/icons/bell_icon.png';
  
  /// 설정 아이콘
  String get settingsIcon => '$_basePath/icons/settings_icon.png';
  
  // ===== Buttons =====
  
  /// 작성 버튼
  String get btnWrite => '$_basePath/icons/btn_write.png';
  
  /// 편집 버튼
  String get btnEdit => '$_basePath/icons/btn_edit.png';
  
  /// 더보기 버튼
  String get btnMore => '$_basePath/icons/btn_more.png';
  
  // ===== Avatars =====
  
  /// 곰 아바타
  String get avatarBear => '$_basePath/icons/avatar_bear.png';
  
  /// 토끼 아바타
  String get avatarRabbit => '$_basePath/icons/avatar_rabbit.png';
  
  /// 고양이 아바타
  String get avatarCat => '$_basePath/icons/avatar_cat.png';
  
  /// 강아지 아바타
  String get avatarDog => '$_basePath/icons/avatar_dog.png';
  
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
  
  /// 홈 네비 아이콘
  String get navHome => '$_basePath/navigation/nav_home.png';
  
  /// 연락처 네비 아이콘
  String get navContacts => '$_basePath/navigation/nav_contacts.png';
  
  /// 갤러리 네비 아이콘
  String get navGallery => '$_basePath/navigation/nav_gallery.png';
  
  /// 메시지 네비 아이콘
  String get navMessage => '$_basePath/navigation/nav_message.png';
  
  /// FAB 작성 버튼
  String get fabWrite => '$_basePath/navigation/fab_write.png';
  
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
