import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heart_connect/src/features/contacts/contact_service.dart';
import 'package:heart_connect/src/features/home/home_view_model.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback onInitComplete;
  
  const SplashScreen({super.key, required this.onInitComplete});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _heartController;
  late AnimationController _fadeController;
  late Animation<double> _heartScale;
  late Animation<double> _heartRotate;
  late Animation<double> _fadeAnimation;
  
  String _userName = '';
  bool _isLoading = true;
  String _loadingStatus = '데이터를 불러오는 중...';

  @override
  void initState() {
    super.initState();
    
    // 하트 애니메이션 컨트롤러
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // 페이드 아웃 컨트롤러
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // 하트 크기 애니메이션 (펄스 효과)
    _heartScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _heartController,
        curve: Curves.easeInOut,
      ),
    );
    
    // 하트 회전 애니메이션
    _heartRotate = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _heartController,
        curve: Curves.easeInOut,
      ),
    );
    
    // 페이드 아웃 애니메이션
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );
    
    // 하트 애니메이션 반복
    _heartController.repeat(reverse: true);
    
    // 데이터 로드 시작
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      // 1. 사용자 이름 로드
      _updateStatus('설정을 불러오는 중...');
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name') ?? '';
      
      if (mounted) {
        setState(() {
          _userName = userName;
        });
      }
      
      // 2. 권한 확인 (Android/iOS)
      if (Platform.isAndroid || Platform.isIOS) {
        _updateStatus('권한을 확인하는 중...');
        await Permission.contacts.request();
        await Permission.calendar.request();
      }
      
      // 3. 연락처 동기화
      _updateStatus('연락처를 동기화하는 중...');
      await ref.read(contactServiceProvider.notifier).syncContacts();
      
      // 4. 홈 데이터 로드
      _updateStatus('일정을 불러오는 중...');
      await ref.read(homeViewModelProvider.notifier).refresh();
      
      // 5. 추가 대기 (UI가 렌더링될 시간)
      _updateStatus('화면을 준비하는 중...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // 페이드 아웃 후 완료 콜백
        await _fadeController.forward();
        widget.onInitComplete();
      }
    } catch (e) {
      debugPrint('[Splash] 로딩 오류: $e');
      // 에러가 있어도 진행
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        await Future.delayed(const Duration(milliseconds: 300));
        await _fadeController.forward();
        widget.onInitComplete();
      }
    }
  }
  
  void _updateStatus(String status) {
    if (mounted) {
      setState(() {
        _loadingStatus = status;
      });
    }
  }

  @override
  void dispose() {
    _heartController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            width: double.infinity,
            height: double.infinity,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  
                  // 애니메이션 하트 아이콘
                  AnimatedBuilder(
                    animation: _heartController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _heartScale.value,
                        child: Transform.rotate(
                          angle: _heartRotate.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFFF8A65).withOpacity(0.3),
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
                                  return const Text(
                                    '💝',
                                    style: TextStyle(fontSize: 60),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 앱 이름
                  const Text(
                    'Heart-Connect',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                      letterSpacing: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 환영 메시지
                  AnimatedOpacity(
                    opacity: _userName.isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF8A65).withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        _userName.isNotEmpty
                            ? '안녕하세요, $_userName 님! 👋'
                            : '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF795548),
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // 로딩 표시
                  if (_isLoading)
                    Column(
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFFFF8A65).withOpacity(0.7),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _loadingStatus,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF795548).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
