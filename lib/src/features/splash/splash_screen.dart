import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heart_connect/src/features/contacts/contact_service.dart';
import 'package:heart_connect/src/features/home/home_view_model.dart';
import 'package:heart_connect/src/features/database/database_provider.dart';
import 'package:heart_connect/src/features/calendar/calendar_service.dart';
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
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _heartScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
    
    _heartRotate = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _heartController.repeat(reverse: true);
    _startLoading();
  }

  Future<void> _startLoading() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final db = ref.read(appDatabaseProvider);
      
      // 1. 사용자 이름 (즉시)
      final userName = prefs.getString('user_name') ?? '';
      if (mounted) setState(() => _userName = userName);
      
      // 2. 첫 실행 여부 확인
      final isFirstRun = !(prefs.getBool('initial_setup_done') ?? false);
      final lastSyncTime = prefs.getInt('last_sync_time') ?? 0;
      
      if (isFirstRun) {
        // === 첫 실행: 전체 초기화 ===
        debugPrint('[Splash] 첫 실행 - 전체 초기화');
        
        // 권한 요청
        if (Platform.isAndroid || Platform.isIOS) {
          _updateStatus('권한을 확인하는 중...');
          await Permission.contacts.request();
          await Permission.calendar.request();
        }
        
        // Mock 데이터 정리 (한 번만)
        await db.deleteMockPlans();
        
        // 연락처 동기화
        _updateStatus('연락처를 가져오는 중...');
        await ref.read(contactServiceProvider.notifier).syncContacts();
        
        // 공휴일/생일 일정 생성
        _updateStatus('일정을 생성하는 중...');
        await db.generateWeeklyPlans();
        
        // 초기화 완료 표시
        await prefs.setBool('initial_setup_done', true);
        await prefs.setInt('last_sync_time', DateTime.now().millisecondsSinceEpoch);
        
      } else {
        // === 재실행: 빠른 로딩 ===
        debugPrint('[Splash] 재실행 - 빠른 로딩');
        _updateStatus('환영합니다! 👋');
      }
      
      // 3. 홈 데이터 로드 (DB에서 빠르게)
      _updateStatus('화면을 준비하는 중...');
      ref.read(homeViewModelProvider.notifier).refresh();
      
      // 4. 로딩 완료 대기
      await _waitForHomeDataLoaded();
      
      debugPrint('[Splash] 로딩 완료: ${stopwatch.elapsedMilliseconds}ms');
      
      _updateStatus('준비 완료!');
      await Future.delayed(const Duration(milliseconds: 150));
      _finishLoading();
      
      // 5. 백그라운드 동기화 시작 (화면 표시 후)
      _startBackgroundSync(prefs, lastSyncTime);
      
    } catch (e) {
      debugPrint('[Splash] 로딩 오류: $e');
      _finishLoading();
    }
  }

  /// 백그라운드 동기화 (비동기, UI 차단 없음)
  void _startBackgroundSync(SharedPreferences prefs, int lastSyncTime) {
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        final db = ref.read(appDatabaseProvider);
        final calendarService = ref.read(calendarServiceProvider);
        final now = DateTime.now();
        final hoursSinceLastSync = (now.millisecondsSinceEpoch - lastSyncTime) / (1000 * 60 * 60);
        
        debugPrint('[BackgroundSync] 시작 (마지막 동기화: ${hoursSinceLastSync.toStringAsFixed(1)}시간 전)');
        
        // 1시간 이상 지났으면 동기화
        if (hoursSinceLastSync >= 1) {
          // 연락처 변경 확인 및 동기화
          await ref.read(contactServiceProvider.notifier).syncContacts();
          
          // 캘린더 이벤트 동기화 (비동기)
          final today = DateTime(now.year, now.month, now.day);
          final endDate = today.add(const Duration(days: 45));
          final calEvents = await calendarService.getEvents(today, endDate);
          
          // 새 이벤트만 DB에 추가
          await _syncCalendarEvents(db, calEvents, today);
          
          // 공휴일/생일 일정 업데이트
          await db.generateWeeklyPlans();
          
          // 홈 화면 갱신
          ref.read(homeViewModelProvider.notifier).refresh();
          
          // 동기화 시간 업데이트
          await prefs.setInt('last_sync_time', now.millisecondsSinceEpoch);
          
          debugPrint('[BackgroundSync] 완료');
        } else {
          debugPrint('[BackgroundSync] 스킵 (최근 동기화됨)');
        }
      } catch (e) {
        debugPrint('[BackgroundSync] 오류: $e');
      }
    });
  }

  /// 캘린더 이벤트 DB 동기화
  Future<void> _syncCalendarEvents(dynamic db, List<dynamic> calEvents, DateTime today) async {
    try {
      final plans = await db.getFuturePlans(today);
      
      for (var event in calEvents) {
        final eDate = DateTime(event.date.year, event.date.month, event.date.day);
        
        // 이미 존재하는지 확인
        bool exists = false;
        try {
          plans.firstWhere((p) => 
            p.date.year == eDate.year && 
            p.date.month == eDate.month && 
            p.date.day == eDate.day && 
            p.content == event.title
          );
          exists = true;
        } catch (_) {
          exists = false;
        }
        
        if (!exists) {
          // 새 이벤트 추가
          await db.insertPlanSimple(
            date: eDate,
            content: event.title,
            type: event.type,
          );
          debugPrint('[BackgroundSync] 새 이벤트 추가: ${event.title}');
        }
      }
    } catch (e) {
      debugPrint('[BackgroundSync] 이벤트 동기화 오류: $e');
    }
  }

  Future<void> _waitForHomeDataLoaded() async {
    final completer = Completer<void>();
    
    final currentState = ref.read(homeViewModelProvider);
    if (!currentState.isLoading) {
      return;
    }
    
    late final ProviderSubscription<HomeState> subscription;
    subscription = ref.listenManual<HomeState>(
      homeViewModelProvider,
      (previous, next) {
        if (!next.isLoading && !completer.isCompleted) {
          completer.complete();
          subscription.close();
        }
      },
    );
    
    // 타임아웃 5초
    Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        debugPrint('[Splash] 로딩 타임아웃');
        completer.complete();
        subscription.close();
      }
    });
    
    await completer.future;
  }
  
  void _updateStatus(String status) {
    if (mounted) setState(() => _loadingStatus = status);
  }

  void _finishLoading() async {
    if (!mounted || _isFinishing) return;
    _isFinishing = true;
    
    setState(() => _isLoading = false);
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
                colors: [Color(0xFFFFFCF9), Color(0xFFFFF5EE), Color(0xFFFFEBE0)],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  
                  // 하트 애니메이션
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
                                colors: [const Color(0xFFFF8A65).withAlpha(76), Colors.transparent],
                              ),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/icons/app_icon.png',
                                width: 80,
                                height: 80,
                                errorBuilder: (context, error, stackTrace) => const Text('💝', style: TextStyle(fontSize: 60)),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Heart-Connect',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF5D4037), letterSpacing: 1.2),
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
                        boxShadow: [BoxShadow(color: const Color(0xFFFF8A65).withAlpha(51), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: Text(
                        _userName.isNotEmpty ? '안녕하세요, $_userName 님! 👋' : '',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF795548)),
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
                            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFFF8A65).withAlpha(180)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(_loadingStatus, style: TextStyle(fontSize: 13, color: const Color(0xFF795548).withAlpha(180))),
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
