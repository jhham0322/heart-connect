import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heart_connect/src/providers/locale_provider.dart';
import 'package:heart_connect/src/l10n/app_strings.dart';

/// 첫 실행 시 온보딩 화면
class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;
  bool _contactsGranted = false;
  bool _calendarGranted = false;
  String _userName = '';


  @override
  void initState() {
    super.initState();
    _loadDeviceOwnerName();
  }

  /// 기기에 등록된 사용자 이름 가져오기
  Future<void> _loadDeviceOwnerName() async {
    if (Platform.isAndroid) {
      try {
        const channel = MethodChannel('com.hamm.heart_connect/device_info');
        final String? ownerName = await channel.invokeMethod('getOwnerName');
        if (ownerName != null && ownerName.isNotEmpty && mounted) {
          setState(() {
            _nameController.text = ownerName;
          });
        }
      } catch (e) {
        debugPrint('[Onboarding] Failed to get device owner name: $e');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    // 총 4 페이지: 환영, 이름입력, 연락처권한, 캘린더권한
    if (_currentPage < 3) {
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

  Future<void> _saveUserName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(appStringsProvider).onboardingNameRequired),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }
    
    // 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    setState(() {
      _userName = name;
    });
    
    _nextPage();
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
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentPage == index ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFFF29D86)
                            : const Color(0xFFF29D86).withAlpha(80),
                        borderRadius: BorderRadius.circular(3),
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
                    _buildWelcomePage(),           // 0: 환영
                    _buildNameInputPage(),         // 1: 이름 입력
                    _buildContactsPermissionPage(),// 2: 연락처 권한
                    _buildCalendarPermissionPage(),// 3: 캘린더 권한 (마지막)
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
          
          // 앱 아이콘 (큰 사이즈) - 투명 배경 그대로 표시
          Image.asset(
            'assets/icons/onboarding_heart.png',
            width: 160,
            height: 160,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Text('💝', style: TextStyle(fontSize: 80));
            },
          ),
          
          const SizedBox(height: 32),
          
          // 앱 이름
          Text(
            ref.watch(appStringsProvider).appName,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Heart-Connect',
            style: TextStyle(
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
                  ref.watch(appStringsProvider).onboardingWelcome,
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
                  '${ref.watch(appStringsProvider).onboardingDesc1}\n${ref.watch(appStringsProvider).onboardingDesc2}\n${ref.watch(appStringsProvider).onboardingDesc3}\n${ref.watch(appStringsProvider).onboardingDesc4}\n\n${ref.watch(appStringsProvider).onboardingDesc5}\n${ref.watch(appStringsProvider).onboardingDesc6}\n${ref.watch(appStringsProvider).onboardingDesc7}',
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
                ref.watch(appStringsProvider).onboardingStart,
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
      physics: const ClampingScrollPhysics(),
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
            ref.watch(appStringsProvider).permissionContacts,
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
                      ref.watch(appStringsProvider).permissionWhyNeeded,
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
                  ref.watch(appStringsProvider).permissionContactsDesc,
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
                    '${ref.watch(appStringsProvider).permissionPrivacy}\n\n${ref.watch(appStringsProvider).permissionSkipContacts}',
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
              label: Text(ref.watch(appStringsProvider).permissionAllowContacts),
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
              ref.watch(appStringsProvider).permissionSkip,
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
      physics: const ClampingScrollPhysics(),
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
            ref.watch(appStringsProvider).permissionCalendar,
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
                      ref.watch(appStringsProvider).permissionWhyNeeded,
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
                  ref.watch(appStringsProvider).permissionCalendarDesc,
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
                    '${ref.watch(appStringsProvider).permissionPrivacy}\n\n${ref.watch(appStringsProvider).permissionSkipCalendar}',
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
              label: Text(ref.watch(appStringsProvider).permissionAllowCalendar),
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
              ref.watch(appStringsProvider).permissionSkip,
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

  /// 2. 사용자 이름 입력 페이지 (필수)
  Widget _buildNameInputPage() {
    final strings = ref.watch(appStringsProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // 아이콘
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 60,
              color: Color(0xFF4CAF50),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 제목
          Text(
            strings.onboardingEnterName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // 이름 입력 필드
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: strings.onboardingNameHint,
              hintText: strings.onboardingNameHint,
              prefixIcon: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF4CAF50)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
            // textCapitalization 제거: 한글 조합형 입력 시 키보드 버퍼와 충돌하여
            // 삭제한 텍스트가 다시 나타나는 버그 발생
          ),
          
          const SizedBox(height: 24),
          
          // 설명
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF388E3C), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.onboardingNameDesc,
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
          
          // 계속하기 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveUserName,
              icon: const Icon(Icons.arrow_forward),
              label: Text(strings.onboardingContinue),
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
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
