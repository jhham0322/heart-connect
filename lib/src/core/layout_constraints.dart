import 'package:flutter/material.dart';

/// 레이아웃 제약조건 정의
/// 
/// 이미지가 교체되어도 레이아웃이 깨지지 않도록 크기와 비율을 정의합니다.
/// 디자이너와 개발자 간의 "계약" 역할을 합니다.
class LayoutConstraints {
  // ===== Home Screen =====
  
  /// 메인 카드 가로세로 비율 (구름 카드)
  static const double homeCardAspectRatio = 4 / 3;
  
  /// 메인 카드 최대 너비
  static const double homeCardMaxWidth = 340.0;
  
  /// 메인 카드 최소 높이
  static const double homeCardMinHeight = 280.0;
  
  /// 메인 카드 패딩
  static const EdgeInsets homeCardPadding = EdgeInsets.fromLTRB(24, 30, 24, 20);
  
  /// 캘린더 아이콘 크기
  static const double calendarIconSize = 100.0;
  
  /// 액션 버튼 너비 (작성 버튼)
  static const double actionButtonWidth = 120.0;
  
  /// 액션 버튼 높이
  static const double actionButtonHeight = 48.0;
  
  /// 작은 액션 버튼 크기 (편집, 더보기)
  static const double smallActionButtonSize = 48.0;
  
  // ===== Event Item =====
  
  /// 일정 아이템 아바타 크기
  static const double eventAvatarSize = 48.0;
  
  /// 일정 아이템 높이
  static const double eventItemHeight = 72.0;
  
  /// 일정 아이템 간격
  static const double eventItemSpacing = 12.0;
  
  /// 일정 아이템 모서리 반경
  static const double eventItemRadius = 36.0;
  
  // ===== Navigation =====
  
  /// 네비게이션 아이콘 크기
  static const double navIconSize = 28.0;
  
  /// 네비게이션 높이
  static const double navHeight = 80.0;
  
  /// FAB 버튼 크기
  static const double fabSize = 64.0;
  
  // ===== Decorations =====
  
  /// 작은 장식 크기
  static const double decorationSmall = 16.0;
  
  /// 중간 장식 크기
  static const double decorationMedium = 24.0;
  
  /// 큰 장식 크기
  static const double decorationLarge = 32.0;
  
  // ===== Header =====
  
  /// 헤더 높이
  static const double headerHeight = 70.0;
  
  /// 로고 높이
  static const double logoHeight = 32.0;
  
  /// 헤더 아이콘 크기
  static const double headerIconSize = 24.0;
  
  // ===== Common =====
  
  /// 화면 가로 패딩
  static const double screenHorizontalPadding = 24.0;
  
  /// 섹션 간 간격
  static const double sectionSpacing = 24.0;
  
  /// 아이템 간 간격
  static const double itemSpacing = 16.0;
  
  // ===== Border Radius Presets =====
  
  /// 작은 모서리 반경
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(8));
  
  /// 중간 모서리 반경
  static const BorderRadius radiusMedium = BorderRadius.all(Radius.circular(16));
  
  /// 큰 모서리 반경
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(24));
  
  /// 완전 둥근 모서리 (pill 형태)
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(999));
}
