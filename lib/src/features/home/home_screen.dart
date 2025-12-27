import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for TextInputFormatter
import 'dart:convert'; // Added for JSON decoding
import 'dart:io'; // Added for Platform check
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column; // Added for Value
import 'package:permission_handler/permission_handler.dart'; // Added for permissions
import 'package:url_launcher/url_launcher.dart'; // Added for opening URLs
import '../../theme/app_theme.dart';
import '../contacts/contact_service.dart';
import 'home_view_model.dart';
import '../database/app_database.dart'; // Import for DailyPlan
import '../database/database_provider.dart'; // Added for appDatabaseProvider
import '../../utils/phone_formatter.dart'; // Added phone formatter utility

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // 캐러셀 컨트롤러
  late PageController _pageController;
  int _currentPage = 0;
  bool _hasCalendarPermission = true; // 권한 상태
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85, 
      initialPage: 0,
    );
    
    // 앱 시작 시 데이터 동기화 및 권한 확인
    WidgetsBinding.instance.addPostFrameCallback((_) async {
       try {
         // 0. 캘린더 권한 확인 (Android/iOS만)
         if (Platform.isAndroid || Platform.isIOS) {
           await _checkCalendarPermission();
         }
         
         // 1. 주소록 동기화 (Windows는 Mock 데이터 생성)
         await ref.read(contactServiceProvider.notifier).syncContacts();
         // 2. 홈 모델 새로고침
         ref.read(homeViewModelProvider.notifier).refresh();
       } catch (e) {
         debugPrint("Init Sync Error: $e");
       }
    });
  }
  
  // 캘린더 권한 확인 및 요청
  Future<void> _checkCalendarPermission() async {
    final status = await Permission.calendar.status;
    debugPrint('[HomeScreen] Calendar permission status: $status');
    
    if (status.isGranted) {
      setState(() => _hasCalendarPermission = true);
      debugPrint('[HomeScreen] Calendar permission already granted');
      // 네이버 캘린더 동기화 확인
      _checkNaverCalendarSync();
    } else {
      setState(() => _hasCalendarPermission = false);
      
      // 권한이 허용되지 않았으면 다이얼로그 표시
      if (mounted) {
        debugPrint('[HomeScreen] Showing calendar permission dialog');
        _showCalendarPermissionDialog();
      }
    }
  }
  
  // 캘린더 권한 요청 다이얼로그
  void _showCalendarPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(FontAwesomeIcons.calendar, color: AppTheme.accentCoral),
            const SizedBox(width: 12),
            const Text('캘린더 연동'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '구글 캘린더, 네이버 캘린더의 일정을 가져오려면 캘린더 접근 권한이 필요합니다.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentCoral.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.circleInfo, size: 16, color: AppTheme.accentCoral),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '기념일, 생일 등의 일정을 자동으로 표시합니다.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 나중에 설정에서 허용하도록 안내
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('설정 > 권한에서 캘린더 권한을 허용할 수 있습니다.')),
              );
            },
            child: const Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Permission.calendar.request();
              
              if (result.isGranted) {
                setState(() => _hasCalendarPermission = true);
                // 권한 허용 후 데이터 새로고침
                ref.read(homeViewModelProvider.notifier).refresh();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ 캘린더가 연동되었습니다!')),
                  );
                  // 네이버 캘린더 동기화 확인 (잠시 후)
                  Future.delayed(const Duration(seconds: 1), () {
                    _checkNaverCalendarSync();
                  });
                }
              } else if (result.isPermanentlyDenied) {
                // 영구 거부된 경우 설정으로 이동 안내
                _showOpenSettingsDialog();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('권한 허용'),
          ),
        ],
      ),
    );
  }
  
  // 설정으로 이동 다이얼로그
  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('권한 설정 필요'),
        content: const Text(
          '캘린더 권한이 거부되었습니다.\n설정에서 직접 권한을 허용해주세요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCoral,
              foregroundColor: Colors.white,
            ),
            child: const Text('설정 열기'),
          ),
        ],
      ),
    );
  }
  
  // 네이버 캘린더 채널
  static const _calendarChannel = MethodChannel('com.heartconnect/calendar');
  
  // 네이버 캘린더 동기화 확인 및 안내
  Future<void> _checkNaverCalendarSync() async {
    debugPrint('[HomeScreen] Checking Naver calendar sync...');
    if (!Platform.isAndroid) {
      debugPrint('[HomeScreen] Not Android, skipping');
      return;
    }
    
    try {
      // 1. 네이버 캘린더 앱 설치 확인
      final isInstalled = await _calendarChannel.invokeMethod('isNaverCalendarInstalled');
      debugPrint('[HomeScreen] Naver calendar installed: $isInstalled');
      if (isInstalled != true) {
        debugPrint('[HomeScreen] Naver calendar not installed, skipping');
        return;
      }
      
      // 2. 시스템 캘린더에 네이버 계정 있는지 확인
      final hasNaver = await _calendarChannel.invokeMethod('hasNaverCalendarEvents');
      debugPrint('[HomeScreen] Has Naver in system calendar: $hasNaver');
      if (hasNaver == true) {
        debugPrint('[HomeScreen] Naver already synced, skipping');
        return;
      }
      
      // 3. 네이버 캘린더가 설치되어 있지만 동기화 안 됨 -> 안내
      debugPrint('[HomeScreen] Showing Naver calendar sync dialog');
      if (mounted) {
        _showNaverCalendarSyncDialog();
      }
    } catch (e) {
      debugPrint('[HomeScreen] Naver calendar check error: $e');
    }
  }
  
  // 네이버 캘린더 동기화 안내 다이얼로그
  void _showNaverCalendarSyncDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(FontAwesomeIcons.triangleExclamation, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('네이버 캘린더 안내', style: TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 미지원 이유 설명
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('❌ 네이버 캘린더 미지원', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
                  SizedBox(height: 8),
                  Text(
                    '네이버 캘린더는 Android 표준 캘린더 동기화(CalendarContract)를 지원하지 않아 앱에서 일정을 읽을 수 없습니다.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 대안 안내
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('✅ 지원되는 캘린더', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                  SizedBox(height: 8),
                  Text('• 구글 캘린더', style: TextStyle(fontSize: 13)),
                  Text('• 삼성 캘린더', style: TextStyle(fontSize: 13)),
                  Text('• 기본 기기 캘린더', style: TextStyle(fontSize: 13)),
                  SizedBox(height: 8),
                  Text(
                    '위 캘린더에 일정을 등록하시면 앱에서 자동으로 표시됩니다.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ViewModel 구독
    final homeState = ref.watch(homeViewModelProvider);
    final progress = (homeState.totalGoal > 0) 
        ? (homeState.sentCount / homeState.totalGoal).clamp(0.0, 1.0)
        : 0.0;
    
    // Today Plans (Filtered by completion status already in VM)
    final todayPlans = homeState.todayPlans;

    return Column(
      children: [
        const SizedBox(height: 16),

        // B. 온도 섹션 (Warmth Meter)
        if (homeState.totalGoal > 0)
           _buildWarmthSection(homeState.sentCount, homeState.totalGoal, progress)
        else 
           const SizedBox(height: 10), // Minimal spacing if no goal
        
        if (homeState.totalGoal > 0) const SizedBox(height: 24),

        // C. 카드 캐러셀 (오늘 계획)
        if (todayPlans.isNotEmpty)
          _buildCardCarousel(todayPlans)
        else
          _buildEmptyTodayState(), 

        if (todayPlans.isNotEmpty) const SizedBox(height: 32),

        // D. 다가오는 일정
        Expanded(child: _buildUpcomingEvents(homeState.upcomingEvents)),
      ],
    );
  }

  /// B. 온도 섹션
  Widget _buildWarmthSection(int count, int goal, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Warmth",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                "$count/$goal Sent",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.textPrimary.withOpacity(0.1)),
            ),
            child: Stack(
              children: [
                // 진행률 바
                LayoutBuilder(
                  builder: (context, constraints) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Container(
                          width: constraints.maxWidth * value,
                          decoration: BoxDecoration(
                            color: AppTheme.accentYellow,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(15),
                              bottomLeft: const Radius.circular(15),
                              topRight: Radius.circular(value >= 1.0 ? 15 : 0),
                              bottomRight: Radius.circular(value >= 1.0 ? 15 : 0),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                // 퍼센트 텍스트
                Center(
                  child: Text(
                    "${(progress * 100).toInt()}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTodayState() {
     return Center(
       child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.grayLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
                const Icon(FontAwesomeIcons.calendarCheck, size: 40, color: AppTheme.accentCoral),
                const SizedBox(height: 16),
                const Text(
                   "No plans for today",
                   style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                   ),
                ),
                const SizedBox(height: 8),
                const Text(
                   "Check upcoming events or create a new plan.",
                   style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                   ),
                   textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                   onPressed: () {
                      // 일정 추가 다이얼로그 열기
                      _showAddEventDialog(context);
                   },
                   style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCoral,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                   ),
                   child: const Text("Add Schedule"),
                )
             ],
          ),
       ),
     );
  }

  /// C. 카드 캐러셀 (오늘 계획)
  Widget _buildCardCarousel(List<DailyPlan> plans) {
    return SizedBox(
      height: 340,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        // +1 for the "Add Schedule" card at the end
        itemCount: plans.length + 1,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final isActive = index == _currentPage;

          // If last item, show Add Schedule Card
          if (index == plans.length) {
            return AnimatedScale(
              scale: isActive ? 1.0 : 0.92,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.6,
                duration: const Duration(milliseconds: 300),
                child: _buildAddScheduleCard(isActive),
              ),
            );
          }
          
          final plan = plans[index];
          return AnimatedScale(
            scale: isActive ? 1.0 : 0.92,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: isActive ? 1.0 : 0.6,
              duration: const Duration(milliseconds: 300),
              child: _buildDailyPlanCard(plan, isActive),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddScheduleCard(bool isActive) {
    return GestureDetector(
      onTap: () {
        _showAddEventDialog(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.cardBg : AppTheme.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppTheme.accentCoral : AppTheme.grayBtn,
            width: isActive ? 2 : 1,
            style: BorderStyle.solid
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.textPrimary.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.plus,
              size: 50,
              color: isActive ? AppTheme.accentCoral : AppTheme.grayBtn,
            ),
            const SizedBox(height: 16),
            Text(
              "Add Schedule",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add to Calendar & App",
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedType = 'Normal'; // Default
    List<Map<String, String>> selectedRecipients = [];

    // Icons map for selection
    final Map<String, IconData> typeIcons = {
      'Normal': FontAwesomeIcons.calendarDay,
      'Holiday': FontAwesomeIcons.flag,
      'Birthday': FontAwesomeIcons.cakeCandles,
      'Anniversary': FontAwesomeIcons.heart,
      'Work': FontAwesomeIcons.briefcase,
      'Personal': FontAwesomeIcons.user,
      'Important': FontAwesomeIcons.star,
    };

    final Map<String, Color> typeColors = {
      'Normal': Colors.blue,
      'Holiday': Colors.redAccent,
      'Birthday': Colors.orangeAccent,
      'Anniversary': Colors.pinkAccent,
      'Work': Colors.brown,
      'Personal': Colors.green,
      'Important': Colors.amber,
    };
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add New Schedule"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Recipients", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...selectedRecipients.map((r) => Chip(
                          label: Text(r['name'] ?? ''),
                          onDeleted: () {
                            setDialogState(() {
                              selectedRecipients.remove(r);
                            });
                          },
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                      trailing: const Icon(FontAwesomeIcons.calendar),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Icon Type", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: typeIcons.entries.map((entry) {
                        final isSelected = selectedType == entry.key;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedType = entry.key;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? typeColors[entry.key]!.withOpacity(0.2) 
                                      : Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: isSelected 
                                      ? Border.all(color: typeColors[entry.key]!, width: 2) 
                                      : null,
                                ),
                                child: Icon(
                                  entry.value, 
                                  size: 20, 
                                  color: isSelected ? typeColors[entry.key] : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.key, 
                                style: TextStyle(
                                  fontSize: 10, 
                                  color: isSelected ? typeColors[entry.key] : Colors.grey
                                )
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      ref.read(homeViewModelProvider.notifier).addSchedule(
                        titleController.text,
                        selectedDate,
                        type: selectedType,
                        recipients: selectedRecipients,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Schedule added to Calendar & App!")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCoral, foregroundColor: Colors.white),
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDailyPlanCard(DailyPlan plan, bool isActive) {
    // Determine Icon and Emoji based on plan type
    String emoji = '📅';
    String subtitle = 'Event';
    
    switch(plan.type) {
       case 'Birthday': 
          emoji = '🎂'; 
          subtitle = 'Birthday';
          break;
       case 'Holiday': 
          emoji = '🎉'; 
          subtitle = 'Holiday';
          break;
       case 'Anniversary': 
          emoji = '💖'; 
          subtitle = 'Anniversary';
          break;
       case 'Work':
          emoji = '💼';
          subtitle = 'Work';
          break;
       case 'Personal':
          emoji = '🏠';
          subtitle = 'Personal';
          break;
       case 'Important':
          emoji = '⭐';
          subtitle = 'Important';
          break;
       case 'Normal':
          emoji = '📝';
          subtitle = 'Daily Task';
          break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.cardBg : AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive ? AppTheme.accentCoral : AppTheme.grayBtn,
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.textPrimary.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 이모지
          Text(
            emoji,
            style: const TextStyle(fontSize: 72),
          ),
          const SizedBox(height: 16),
          // 제목
          Text(
            "${plan.content}\n($subtitle)",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.2
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          // 버튼들
          Row(
            children: [
              // Write 버튼
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    // 일정의 수신자 목록을 파싱하여 전달
                    List<Map<String, String>> recipients = [];
                    if (plan.recipients != null) {
                      try {
                        final decoded = jsonDecode(plan.recipients!) as List;
                        recipients = decoded.map((e) => Map<String, String>.from(e)).toList();
                      } catch (e) {
                        debugPrint('Error parsing recipients: $e');
                      }
                    }
                    context.push('/write', extra: {'recipients': recipients});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCoral,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.pen, size: 14),
                      SizedBox(width: 8),
                      Text(
                        "Write",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Edit 버튼 (New)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showEditPlanDialog(context, plan);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCoral.withOpacity(0.1),
                    foregroundColor: AppTheme.accentCoral,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 0,
                  ),
                  child: const Icon(FontAwesomeIcons.penToSquare, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              // Option 버튼 (제거/연기)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showPlanOptions(context, plan);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.grayBtn,
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 0,
                  ),
                  child: const Icon(FontAwesomeIcons.ellipsis, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditPlanDialog(BuildContext context, DailyPlan plan) {
    final titleController = TextEditingController(text: plan.content);
    DateTime selectedDate = plan.date;
    String selectedType = plan.type;
    List<Map<String, String>> selectedRecipients = [];
    if (plan.recipients != null) {
      try {
        final decoded = jsonDecode(plan.recipients!) as List;
        selectedRecipients = decoded.map((e) => Map<String, String>.from(e)).toList();
      } catch (e) {
        debugPrint('Error parsing recipients: $e');
      }
    }

    // Icons map for selection (Same as Add)
    final Map<String, IconData> typeIcons = {
      'Normal': FontAwesomeIcons.calendarDay,
      'Holiday': FontAwesomeIcons.flag,
      'Birthday': FontAwesomeIcons.cakeCandles,
      'Anniversary': FontAwesomeIcons.heart,
      'Work': FontAwesomeIcons.briefcase,
      'Personal': FontAwesomeIcons.user,
      'Important': FontAwesomeIcons.star,
    };

    final Map<String, Color> typeColors = {
      'Normal': Colors.blue,
      'Holiday': Colors.redAccent,
      'Birthday': Colors.orangeAccent,
      'Anniversary': Colors.pinkAccent,
      'Work': Colors.brown,
      'Personal': Colors.green,
      'Important': Colors.amber,
    };
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Schedule"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Recipients", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...selectedRecipients.map((r) => Chip(
                          label: Text(r['name'] ?? ''),
                          onDeleted: () {
                            setDialogState(() {
                              selectedRecipients.remove(r);
                            });
                          },
                        )),
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 16),
                          label: const Text("Add"),
                          onPressed: () {
                            _showContactPicker(context, (selected) {
                              setDialogState(() {
                                for (var s in selected) {
                                  if (!selectedRecipients.any((existing) => existing['phone'] == s['phone'])) {
                                    selectedRecipients.add(s);
                                  }
                                }
                              });
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                      trailing: const Icon(FontAwesomeIcons.calendar),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Icon Type", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: typeIcons.entries.map((entry) {
                        final isSelected = selectedType == entry.key;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedType = entry.key;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? typeColors[entry.key]!.withOpacity(0.2) 
                                      : Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: isSelected 
                                      ? Border.all(color: typeColors[entry.key]!, width: 2) 
                                      : null,
                                ),
                                child: Icon(
                                  entry.value, 
                                  size: 20, 
                                  color: isSelected ? typeColors[entry.key] : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(entry.key, style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                    onPressed: () {
                      print('Save Button Clicked');
                      if (titleController.text.isNotEmpty) {
                         print('Updating plan ${plan.id} with recipients: $selectedRecipients');
                         ref.read(homeViewModelProvider.notifier).updateScheduleDetails(
                           plan.id,
                           titleController.text,
                           selectedDate,
                           selectedType,
                           recipients: selectedRecipients,
                         );
                         Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCoral,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPlanOptions(BuildContext context, DailyPlan plan) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(FontAwesomeIcons.pen),
                title: const Text('Edit Plan'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditPlanDialog(context, plan);
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.trash, color: Colors.redAccent),
                title: const Text('Delete Plan', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, plan);
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.arrowDown),
                title: const Text('Move to End of Today'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(homeViewModelProvider.notifier).movePlanToEnd(plan.id);
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.calendarDays),
                title: const Text('Reschedule Date'),
                onTap: () {
                  Navigator.pop(context);
                  _pickNewDate(context, plan);
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.icons),
                title: const Text('Change Icon'),
                onTap: () {
                  Navigator.pop(context);
                  _pickNewIcon(context, plan);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickNewIcon(BuildContext context, DailyPlan plan) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Select Icon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _iconOption(context, plan, 'Normal', FontAwesomeIcons.calendarDay, Colors.blue),
                  _iconOption(context, plan, 'Holiday', FontAwesomeIcons.flag, Colors.redAccent),
                  _iconOption(context, plan, 'Birthday', FontAwesomeIcons.cakeCandles, Colors.orangeAccent),
                  _iconOption(context, plan, 'Anniversary', FontAwesomeIcons.heart, Colors.pinkAccent),
                  _iconOption(context, plan, 'Work', FontAwesomeIcons.briefcase, Colors.brown),
                  _iconOption(context, plan, 'Personal', FontAwesomeIcons.user, Colors.green),
                  _iconOption(context, plan, 'Important', FontAwesomeIcons.star, Colors.amber),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  
  Widget _iconOption(BuildContext context, DailyPlan plan, String type, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        ref.read(homeViewModelProvider.notifier).updatePlanIcon(plan.id, type);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(type, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, DailyPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan'),
        content: Text('Are you sure you want to delete "${plan.content}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(homeViewModelProvider.notifier).deletePlan(plan.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickNewDate(BuildContext context, DailyPlan plan) async {
    final now = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: plan.date.isBefore(now) ? now : plan.date,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (newDate != null) {
      ref.read(homeViewModelProvider.notifier).reschedulePlan(plan.id, newDate);
    }
  }

  /// D. 다가오는 일정 섹션 (Real Data)
  Widget _buildUpcomingEvents(List<EventItem> events) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Upcoming Events",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => _showAddEventDialog(context),
                icon: const Icon(FontAwesomeIcons.plus, size: 18, color: AppTheme.textSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Expanded(
            child: events.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No upcoming events.", style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  physics: const BouncingScrollPhysics(),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return _buildEventItem(events[index]);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(EventItem event) {
    return GestureDetector(
      onTap: () async {
        // 1. Capture current state before update
        final homeState = ref.read(homeViewModelProvider);
        final currentPlans = homeState.todayPlans;
        int? currentPlanId;
        
        if (_currentPage < currentPlans.length) {
          currentPlanId = currentPlans[_currentPage].id;
        } else {
          // We are at Add Card (last index)
          currentPlanId = null; 
        }
        
        // 2. Perform Action (Update State)
        await ref.read(homeViewModelProvider.notifier).activateFuturePlan(event.id);
        
        // 3. Post-Update Animation Logic
        if (_pageController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_pageController.hasClients) return;

            // Get updated state
            final newHomeState = ref.read(homeViewModelProvider);
            final newPlans = newHomeState.todayPlans;
            
            int targetJumpIndex = 0;
            
            if (currentPlanId != null) {
              // Find where the previously visible plan went
              final newIndex = newPlans.indexWhere((p) => p.id == currentPlanId);
              if (newIndex != -1) {
                targetJumpIndex = newIndex;
              } else {
                // Plan disappeared? Fallback to safely stay near current
                targetJumpIndex = _currentPage.clamp(0, newPlans.length);
              }
            } else {
              // We were at Add Card. Add Card is now at newPlans.length
              targetJumpIndex = newPlans.length;
            }
            
            // Jump to maintain visual stability of what user was looking at
             _pageController.jumpToPage(targetJumpIndex);
             
             // Animate to the activated plan
             WidgetsBinding.instance.addPostFrameCallback((_) {
               if (_pageController.hasClients) {
                 // Find the index of the activated plan in the new list
                 final activatedPlanIndex = newPlans.indexWhere((p) => p.id == event.id);
                 final targetIndex = activatedPlanIndex != -1 ? activatedPlanIndex : 0;

                 _pageController.animateToPage(
                   targetIndex, 
                   duration: const Duration(milliseconds: 600), 
                   curve: Curves.easeInOutCubic
                 );
               }
             });
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8), // Reduced from 12
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Reduced vertical padding from 16
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12), // Slightly reduced radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36, // Reduced from 40
              height: 36, // Reduced from 40
              decoration: BoxDecoration(
                color: event.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(event.icon, color: event.color, size: 16),
              ),
            ),
            const SizedBox(width: 12), // Reduced from 16
            // 구분선
            Container(
              width: 2,
              height: 20, // Reduced from 24
              decoration: BoxDecoration(
                color: AppTheme.grayLight,
                borderRadius: BorderRadius.circular(1),
              ),
              child: Center(child: Container()), // Empty center to satisfy widget tree
            ),
            const SizedBox(width: 12), // Reduced from 16
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                       Text(
                        event.dateLabel,
                        style: const TextStyle(
                          fontSize: 11, // Reduced from 12
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentCoral,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (event.source.isNotEmpty) 
                        Text(
                          event.source,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 14, // Reduced from 15
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            // Edit Button
            IconButton(
              icon: const Icon(FontAwesomeIcons.penToSquare, size: 16, color: AppTheme.textSecondary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                // TODO: Show edit dialog
                _showEditEventDialog(context, event);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditEventDialog(BuildContext context, EventItem event) {
    final titleController = TextEditingController(text: event.title);
    DateTime selectedDate = event.date;
    String selectedType = event.type;
    List<Map<String, String>> selectedRecipients = List.from(event.recipients);

    // Reuse maps (ideally these should be constants or in ViewModel)
    final Map<String, IconData> typeIcons = {
      'Normal': FontAwesomeIcons.calendarDay,
      'Holiday': FontAwesomeIcons.flag,
      'Birthday': FontAwesomeIcons.cakeCandles,
      'Anniversary': FontAwesomeIcons.heart,
      'Work': FontAwesomeIcons.briefcase,
      'Personal': FontAwesomeIcons.user,
      'Important': FontAwesomeIcons.star,
    };

    final Map<String, Color> typeColors = {
      'Normal': Colors.blue,
      'Holiday': Colors.redAccent,
      'Birthday': Colors.orangeAccent,
      'Anniversary': Colors.pinkAccent,
      'Work': Colors.brown,
      'Personal': Colors.green,
      'Important': Colors.amber,
    };
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Schedule"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Recipients", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...selectedRecipients.map((r) => Chip(
                          label: Text(r['name'] ?? ''),
                          onDeleted: () {
                            setDialogState(() {
                              selectedRecipients.remove(r);
                            });
                          },
                        )),
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 16),
                          label: const Text("Add"),
                          onPressed: () {
                            _showContactPicker(context, (selected) {
                              setDialogState(() {
                                for (var s in selected) {
                                  if (!selectedRecipients.any((existing) => existing['phone'] == s['phone'])) {
                                    selectedRecipients.add(s);
                                  }
                                }
                              });
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                      trailing: const Icon(FontAwesomeIcons.calendar),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Icon Type", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: typeIcons.entries.map((entry) {
                        final isSelected = selectedType == entry.key;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedType = entry.key;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? typeColors[entry.key]!.withOpacity(0.2) 
                                      : Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: isSelected 
                                      ? Border.all(color: typeColors[entry.key]!, width: 2) 
                                      : null,
                                ),
                                child: Icon(
                                  entry.value, 
                                  size: 20, 
                                  color: isSelected ? typeColors[entry.key] : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.key, 
                                style: TextStyle(
                                  fontSize: 10, 
                                  color: isSelected ? typeColors[entry.key] : Colors.grey
                                )
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      ref.read(homeViewModelProvider.notifier).updateScheduleDetails(
                        event.id, 
                        titleController.text,
                        selectedDate,
                        selectedType,
                        recipients: selectedRecipients,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showContactPicker(BuildContext context, Function(List<Map<String, String>>) onSelected) {
    showDialog(
      context: context,
      builder: (context) => _ContactPickerDialog(
        onSelected: onSelected,
      ),
    );
  }

  static Future<String?> _showManualContactDialog(BuildContext context, AppDatabase db) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Contact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
              inputFormatters: [PhoneInputFormatter()],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.replaceAll('-', '').trim();
              if (name.isNotEmpty && phone.isNotEmpty) {
                await db.insertContact(
                  ContactsCompanion.insert(
                    phone: phone,
                    name: name,
                    isFavorite: Value(false),
                  ),
                );
                Navigator.pop(context, name);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF29D86),
              foregroundColor: Colors.white,
            ),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class _ContactPickerDialog extends ConsumerStatefulWidget {
  final Function(List<Map<String, String>>) onSelected;

  const _ContactPickerDialog({
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  @override
  ConsumerState<_ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends ConsumerState<_ContactPickerDialog> {
  String _searchQuery = "";
  String _selectedFilter = '전체';
  final Set<String> _selectedPhones = {};
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
    // 다이얼로그 열 때 키보드 숨기기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  Future<void> _loadContacts() async {
    final db = ref.read(appDatabaseProvider);
    final contacts = await db.getAllContacts();
    if (mounted) {
      setState(() {
        _contacts = contacts;
      });
    }
  }

  Future<void> _handleAddNew() async {
    final db = ref.read(appDatabaseProvider);
    final newName = await _HomeScreenState._showManualContactDialog(context, db);
    if (newName != null) {
      await _loadContacts();
      // Auto-select the new contact
      final newContact = _contacts.firstWhere(
        (c) => c.name == newName, 
        orElse: () => _contacts.isNotEmpty ? _contacts.last : _contacts.first
      );
      setState(() {
        _selectedPhones.add(newContact.phone);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 필터링된 연락처 목록
    final filtered = _contacts.where((contact) {
      // 검색어 필터
      final matchesSearch = _searchQuery.isEmpty ||
          contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          contact.phone.contains(_searchQuery);
      
      // 카테고리 필터
      bool matchesCategory = true;
      if (_selectedFilter == '즐겨찾기') {
        matchesCategory = contact.isFavorite;
      } else if (_selectedFilter == '가족') {
        final tag = contact.groupTag?.toLowerCase() ?? '';
        matchesCategory = tag.contains('가족') || tag.contains('family');
      }
      
      return matchesSearch && matchesCategory;
    }).toList();

    return AlertDialog(
      title: const Text("발송 대상 선택"),
      content: SizedBox(
        width: double.maxFinite,
        height: 450,
        child: Column(
          children: [
            // 검색창
            TextField(
              autofocus: false,
              decoration: InputDecoration(
                hintText: '이름 또는 전화번호 검색',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFF29D86)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFF29D86)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFF29D86), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 10),
            
            // 필터 버튼들
            Row(
              children: [
                _buildFilterChip('전체', Icons.people),
                const SizedBox(width: 8),
                _buildFilterChip('즐겨찾기', Icons.star),
                const SizedBox(width: 8),
                _buildFilterChip('가족', Icons.family_restroom),
              ],
            ),
            const SizedBox(height: 10),
            
            // 연락처 목록
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isNotEmpty 
                            ? "검색 결과가 없습니다."
                            : "저장된 연락처가 없습니다.",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final contact = filtered[index];
                        final isSelected = _selectedPhones.contains(contact.phone);
                        return CheckboxListTile(
                          value: isSelected,
                          title: Row(
                            children: [
                              Expanded(child: Text(contact.name)),
                              if (contact.isFavorite == true)
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                            ],
                          ),
                          subtitle: Text(formatPhone(contact.phone)),
                          activeColor: const Color(0xFFF29D86),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedPhones.add(contact.phone);
                              } else {
                                _selectedPhones.remove(contact.phone);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            
            // 새 연락처 추가 버튼
            OutlinedButton.icon(
              onPressed: _handleAddNew,
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text("새 연락처 추가"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF29D86),
                side: const BorderSide(color: Color(0xFFF29D86)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("취소", style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            final selected = _contacts.where((c) => _selectedPhones.contains(c.phone)).map((c) => {
              'name': c.name,
              'phone': c.phone,
            }).toList();
            widget.onSelected(selected);
            Navigator.pop(context);
          },
          child: const Text("확인", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF29D86))),
        ),
      ],
    );
  }
  
  Widget _buildFilterChip(String label, IconData icon) {
    final isActive = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon, size: 16, color: isActive ? Colors.white : Colors.grey[700]),
      selected: isActive,
      selectedColor: const Color(0xFFF29D86),
      labelStyle: TextStyle(
        color: isActive ? Colors.white : Colors.grey[700],
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        setState(() => _selectedFilter = label);
      },
    );
  }
}
