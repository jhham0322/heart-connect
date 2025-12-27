import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:heart_connect/src/services/localization_service.dart';
import 'package:heart_connect/src/providers/locale_provider.dart';

/// 첫 실행 시 온보딩 화면
class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _contactsGranted = false;
  bool _calendarGranted = false;


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  Future<void> _requestContactsPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.contacts.request();
      setState(() {
        _contactsGranted = status.isGranted;
      });
      if (status.isGranted) {
        _nextPage();
      }
    } else {
      setState(() => _contactsGranted = true);
      _nextPage();
    }
  }

  Future<void> _requestCalendarPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.calendar.request();
      setState(() {
        _calendarGranted = status.isGranted;
      });
      if (status.isGranted) {
        _nextPage();
      }
    } else {
      setState(() => _calendarGranted = true);
      _nextPage();
    }
  }

  /// 언어 변경 (offset: -1 이전, +1 다음)
  void _changeLanguage(int offset) {
    final currentCode = ref.read(localeProvider).languageCode;
    final codes = supportedLanguages.keys.toList();
    final currentIndex = codes.indexOf(currentCode);
    
    int nextIndex = (currentIndex + offset) % codes.length;
    if (nextIndex < 0) nextIndex += codes.length; // 음수 나머지 처리
    
    final nextCode = codes[nextIndex];
    ref.read(localeProvider.notifier).setLocale(nextCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFCF9),
              Color(0xFFFFF5EE),
              Color(0xFFFFEBE0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 페이지 인디케이터
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFFF29D86)
                            : const Color(0xFFF29D86).withAlpha(80),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
              
              // 페이지 콘텐츠
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildContactsPermissionPage(),
                    _buildCalendarPermissionPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. 앱 소개 페이지
  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          // 앱 아이콘 (큰 사이즈)
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF29D86).withAlpha(60),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/icons/onboarding_heart.png',
                width: 160,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white,
                    child: const Center(
                      child: Text('💝', style: TextStyle(fontSize: 80)),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 앱 이름
          Text(
            Tr.get(Texts.appName, ref),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            Tr.get(Texts.appNameEn, ref),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8D6E63),
              letterSpacing: 1.5,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // 앱 설명
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF29D86).withAlpha(30),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFF29D86),
                  size: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  Tr.get(Texts.onboardingWelcomeTitle, ref),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  Tr.get(Texts.onboardingWelcomeDesc, ref),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.brown[600],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          
          // 언어 선택 (좌우 스와이프 및 화살표)
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFF29D86).withAlpha(100)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 왼쪽 화살표
                IconButton(
                  onPressed: () => _changeLanguage(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: const Color(0xFFF29D86),
                  iconSize: 28,
                  splashRadius: 20,
                  tooltip: '이전 언어',
                ),
                
                // 언어 텍스트 (스와이프 감지)
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        _changeLanguage(-1); // 오른쪽으로 스와이프 -> 이전 (왼쪽)
                      } else if (details.primaryVelocity! < 0) {
                        _changeLanguage(1); // 왼쪽으로 스와이프 -> 다음 (오른쪽)
                      }
                    },
                    child: Container(
                      color: Colors.transparent, // 터치 영역 확보
                      height: 40,
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(scale: animation, child: child),
                          );
                        },
                        child: Text(
                          supportedLanguages[ref.watch(localeProvider).languageCode] ?? '한국어',
                          key: ValueKey(ref.watch(localeProvider).languageCode),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D4037),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // 오른쪽 화살표
                IconButton(
                  onPressed: () => _changeLanguage(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: const Color(0xFFF29D86),
                  iconSize: 28,
                  splashRadius: 20,
                  tooltip: '다음 언어',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 시작하기 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF29D86),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              child: Text(
                Tr.get(Texts.startButton, ref),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 2. 연락처 권한 요청 페이지
  Widget _buildContactsPermissionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // 아이콘
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.contacts_rounded,
              size: 50,
              color: Color(0xFF4CAF50),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            Tr.get(Texts.contactsPermTitle, ref),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 설명 박스
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF4CAF50).withAlpha(100)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      Tr.get(Texts.contactsPermWhy, ref),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  Tr.get(Texts.contactsPermDesc, ref),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.brown[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 개인정보 보호 안내
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_rounded, color: Color(0xFF2E7D32), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    Tr.get(Texts.contactsPermPrivacy, ref),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // 버튼들
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _requestContactsPermission,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(Tr.get(Texts.contactsPermButton, ref)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          TextButton(
            onPressed: _nextPage,
            child: Text(
              Tr.get(Texts.skipSettings, ref),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 3. 캘린더 권한 요청 페이지
  Widget _buildCalendarPermissionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // 아이콘
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 50,
              color: Color(0xFF2196F3),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            Tr.get(Texts.calendarPermTitle, ref),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 설명 박스
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2196F3).withAlpha(100)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      Tr.get(Texts.calendarPermWhy, ref),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  Tr.get(Texts.calendarPermDesc, ref),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.brown[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 개인정보 보호 안내
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_rounded, color: Color(0xFF1565C0), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    Tr.get(Texts.calendarPermPrivacy, ref),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // 버튼들
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _requestCalendarPermission,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(Tr.get(Texts.calendarPermButton, ref)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          TextButton(
            onPressed: _nextPage,
            child: Text(
              Tr.get(Texts.skipSettings, ref),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
