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
  String _loadingStatus = '시작하는 중...';

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
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // 하트 크기 애니메이션 (펄스 효과)
    _heartScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _heartController,
        curve: Curves.easeInOut,
      ),
    );
    
    // 하트 회전 애니메이션
    _heartRotate = Tween<double>(begin: -0.03, end: 0.03).animate(
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
    
    // 빠른 로딩 시작
    _fastLoad();
  }

  /// 빠른 로딩 - 로컬 캐시 데이터만 로드
  Future<void> _fastLoad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. 사용자 이름 로드 (즉시)
      final userName = prefs.getString('user_name') ?? '';
      if (mounted) {
        setState(() {
          _userName = userName;
        });
      }
      
      // 2. 이전에 동기화된 적 있는지 확인
      final lastSyncTime = prefs.getInt('last_sync_time') ?? 0;
      final hasData = lastSyncTime > 0;
      
      if (hasData) {
        // 이미 데이터가 있으면 로컬 DB에서 빠르게 로드
        _updateStatus('환영합니다! 👋');
        
        // 홈 데이터만 빠르게 새로고침 (DB에서 로드)
        ref.read(homeViewModelProvider.notifier).refresh();
        
        // 짧은 대기 후 화면 표시
        await Future.delayed(const Duration(milliseconds: 800));
        
        // 화면 표시 후 백그라운드에서 동기화
        _finishAndStartBackgroundSync(prefs);
      } else {
        // 첫 실행 - 전체 동기화 필요
        await _firstTimeFullSync(prefs);
      }
    } catch (e) {
      debugPrint('[Splash] 로딩 오류: $e');
      _finishLoading();
    }
  }

  /// 첫 실행 시 전체 동기화
  Future<void> _firstTimeFullSync(SharedPreferences prefs) async {
    try {
      // 권한 확인 (Android/iOS)
      if (Platform.isAndroid || Platform.isIOS) {
        _updateStatus('권한을 확인하는 중...');
        await Permission.contacts.request();
        await Permission.calendar.request();
      }
      
      // 연락처 동기화
      _updateStatus('연락처를 가져오는 중...');
      await ref.read(contactServiceProvider.notifier).syncContacts();
      
      // 홈 데이터 로드
      _updateStatus('일정을 불러오는 중...');
      ref.read(homeViewModelProvider.notifier).refresh();
      
      // 동기화 시간 저장
      await prefs.setInt('last_sync_time', DateTime.now().millisecondsSinceEpoch);
      
      _updateStatus('준비 완료!');
      await Future.delayed(const Duration(milliseconds: 300));
      
      _finishLoading();
    } catch (e) {
      debugPrint('[Splash] 첫 동기화 오류: $e');
      _finishLoading();
    }
  }

  /// 화면 표시 후 백그라운드 동기화 시작
  void _finishAndStartBackgroundSync(SharedPreferences prefs) {
    _finishLoading();
    
    // 백그라운드에서 천천히 동기화 (UI 표시 후)
    Future.delayed(const Duration(seconds: 2), () {
      _backgroundSync(prefs);
    });
  }

  /// 백그라운드 동기화 - UI에 영향 없이 천천히 실행
  Future<void> _backgroundSync(SharedPreferences prefs) async {
    try {
      debugPrint('[BackgroundSync] 백그라운드 동기화 시작');
      
      // 마지막 동기화 시간 확인
      final lastSync = prefs.getInt('last_sync_time') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final hoursSinceLastSync = (now - lastSync) / (1000 * 60 * 60);
      
      // 1시간 이상 지났으면 연락처 동기화
      if (hoursSinceLastSync >= 1) {
        debugPrint('[BackgroundSync] 연락처 동기화 중...');
        await ref.read(contactServiceProvider.notifier).syncContacts();
        
        debugPrint('[BackgroundSync] 홈 데이터 새로고침...');
        ref.read(homeViewModelProvider.notifier).refresh();
        
        // 동기화 시간 업데이트
        await prefs.setInt('last_sync_time', now);
        debugPrint('[BackgroundSync] 동기화 완료');
      } else {
        debugPrint('[BackgroundSync] 최근 동기화됨, 스킵 (${hoursSinceLastSync.toStringAsFixed(1)}시간 전)');
      }
    } catch (e) {
      debugPrint('[BackgroundSync] 동기화 오류: $e');
    }
  }
  
  void _updateStatus(String status) {
    if (mounted) {
      setState(() {
        _loadingStatus = status;
      });
    }
  }

  void _finishLoading() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
    });
    
    await _fadeController.forward();
    widget.onInitComplete();
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
                                  const Color(0xFFFF8A65).withAlpha(76),
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
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(180),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF8A65).withAlpha(51),
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
                  AnimatedOpacity(
                    opacity: _isLoading ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFFFF8A65).withAlpha(180),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _loadingStatus,
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF795548).withAlpha(180),
                          ),
                        ),
                      ],
                    ),
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
