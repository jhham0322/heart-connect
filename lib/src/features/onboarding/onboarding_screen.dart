import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// 첫 실행 시 온보딩 화면
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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
          const SizedBox(height: 40),
          
          // 앱 아이콘
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFF29D86).withAlpha(50),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/app_icon.png',
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('💝', style: TextStyle(fontSize: 60));
                },
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 앱 이름
          const Text(
            '마음이음',
            style: TextStyle(
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
                const Text(
                  '기쁨과 감사의 마음을\n주변 사람들과 나누세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '마음이음은\n소중한 사람들에게\n따뜻한 카드와 메시지를\n보낼 수 있는 앱입니다.\n\n생일, 기념일, 특별한 날에\n진심을 담은 마음을\n전해보세요.',
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
          
          const SizedBox(height: 60),
          
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
              child: const Text(
                '시작하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          
          const Text(
            '연락처 접근 권한',
            style: TextStyle(
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
                      '왜 필요한가요?',
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
                  '연락처 정보는 가족, 친구들에게 카드를 보내기 위해 필요합니다.\n\n'
                  '저장된 연락처에서 수신자를 쉽게 선택할 수 있어요.',
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
                    '🔒 개인정보 보호 안내\n\n'
                    '수집되는 정보는 사용자님의 핸드폰 안에서만 사용되며, '
                    '핸드폰 밖으로 반출되지 않습니다.\n\n'
                    '권한을 허용하지 않으시면 수동으로 연락처를 입력해야 합니다.',
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
              label: const Text('연락처 접근 허용'),
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
              '나중에 설정하기',
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
          
          const Text(
            '캘린더 접근 권한',
            style: TextStyle(
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
                      '왜 필요한가요?',
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
                  '캘린더 정보는 가족과 친구의 생일, 기념일, 이벤트 정보를 가져오기 위해 필요합니다.\n\n'
                  '중요한 날을 놓치지 않고 미리 알림을 받을 수 있어요!',
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
                    '🔒 개인정보 보호 안내\n\n'
                    '수집되는 정보는 사용자님의 핸드폰 안에서만 사용되며, '
                    '핸드폰 밖으로 반출되지 않습니다.\n\n'
                    '권한을 허용하지 않으시면 수동으로 일정을 입력해야 합니다.',
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
              label: const Text('캘린더 접근 허용'),
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
              '나중에 설정하기',
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
