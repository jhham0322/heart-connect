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
import 'package:shared_preferences/shared_preferences.dart'; // Added for preferences
import '../../theme/app_theme.dart';
import '../contacts/contact_service.dart';
import 'home_view_model.dart';
import '../database/app_database.dart'; // Import for DailyPlan
import '../database/database_provider.dart'; // Added for appDatabaseProvider
import '../../utils/phone_formatter.dart'; // Added phone formatter utility
import '../../widgets/contact_picker_dialog.dart'; // Common contact picker dialog
import '../../l10n/app_strings.dart';

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
    
    // 앱 시작 시 권한 확인 (스플래시에서 데이터는 이미 로드됨)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
       try {
         // 캘린더 권한 확인 (Android/iOS만)
         if (Platform.isAndroid || Platform.isIOS) {
           await _checkCalendarPermission();
         }
       } catch (e) {
         debugPrint("Init Error: $e");
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
      // 지원 캘린더 안내 확인
      _checkCalendarGuide();
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
              '구글 캘린더, 삼성 캘린더의 일정을 가져오려면 캘린더 접근 권한이 필요합니다.',
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
                  // 지원 캘린더 안내 (잠시 후)
                  Future.delayed(const Duration(seconds: 1), () {
                    _checkCalendarGuide();
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
  
  // 지원 캘린더 안내 (처음 한 번만 표시)
  Future<void> _checkCalendarGuide() async {
    debugPrint('[HomeScreen] Checking calendar guide...');
    if (!Platform.isAndroid) {
      debugPrint('[HomeScreen] Not Android, skipping');
      return;
    }
    
    try {
      // SharedPreferences에서 이미 안내를 봤는지 확인
      final prefs = await SharedPreferences.getInstance();
      final hasSeenGuide = prefs.getBool('has_seen_calendar_guide') ?? false;
      
      if (hasSeenGuide) {
        debugPrint('[HomeScreen] Already seen calendar guide, skipping');
        return;
      }
      
      // 안내 다이얼로그 표시
      debugPrint('[HomeScreen] Showing calendar guide dialog');
      if (mounted) {
        showCalendarGuideDialog(context, markAsSeen: true);
      }
    } catch (e) {
      debugPrint('[HomeScreen] Calendar guide check error: $e');
    }
  }
  
  // 지원 캘린더 안내 다이얼로그 (정적 메서드 - 설정에서도 사용)
  static Future<void> showCalendarGuideDialog(BuildContext context, {bool markAsSeen = false}) async {
    // 확인 시 SharedPreferences에 저장
    if (markAsSeen) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_calendar_guide', true);
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(FontAwesomeIcons.calendarCheck, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('지원 캘린더 안내', style: TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 지원되는 캘린더
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
            const SizedBox(height: 16),
            // 미지원 캘린더
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
                  Text('❌ 미지원 캘린더', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
                  SizedBox(height: 8),
                  Text('• 네이버 캘린더', style: TextStyle(fontSize: 13)),
                  Text('• 카카오톡 캘린더', style: TextStyle(fontSize: 13)),
                  SizedBox(height: 8),
                  Text(
                    'Android 표준 캘린더 동기화를 지원하지 않아 일정을 읽을 수 없습니다.',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
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
    final strings = ref.watch(appStringsProvider);
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
                Text(
                   strings.homeNoEvents,
                   style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                   ),
                ),
                const SizedBox(height: 8),
                Text(
                   strings.scheduleAddToCalendar,
                   style: const TextStyle(
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
                   child: Text(strings.scheduleAdd),
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
              ref.watch(appStringsProvider).scheduleAdd,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ref.watch(appStringsProvider).scheduleAddToCalendar,
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
    final strings = ref.watch(appStringsProvider);
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedType = 'Normal'; // Default
    List<Map<String, String>> selectedRecipients = [];
    
    // Helper function to get localized icon type label
    String getIconTypeLabel(String type) {
      switch (type) {
        case 'Normal': return strings.iconNormal;
        case 'Holiday': return strings.iconHoliday;
        case 'Birthday': return strings.iconBirthday;
        case 'Anniversary': return strings.iconAnniversary;
        case 'Work': return strings.iconWork;
        case 'Personal': return strings.iconPersonal;
        case 'Important': return strings.iconImportant;
        default: return type;
      }
    }

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
              title: Text(strings.scheduleAddNew),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: strings.scheduleTitle,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(strings.scheduleRecipients, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        // 수신자 추가 버튼
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 16),
                          label: Text(strings.add),
                          onPressed: () async {
                            final selected = await ContactPickerDialog.show(context);
                            if (selected != null && selected.isNotEmpty) {
                              setDialogState(() {
                                for (final contact in selected) {
                                  final existing = selectedRecipients.any((r) => r['phone'] == contact.phone);
                                  if (!existing) {
                                    selectedRecipients.add({'name': contact.name, 'phone': contact.phone});
                                  }
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text("${strings.scheduleDate}: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
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
                    Text(strings.scheduleIconType, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                getIconTypeLabel(entry.key), 
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
                  child: Text(strings.cancel),
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
                        SnackBar(content: Text(strings.scheduleAddedSuccess)),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCoral, foregroundColor: Colors.white),
                  child: Text(strings.add),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 커스텀 달력 아이콘 위젯 (다국어 지원)
  Widget _buildCalendarIconWidget(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    
    // 월 이름을 짧은 형식으로 표시 (JAN, FEB, ... 또는 1월, 2월, ...)
    String monthName;
    if (locale == 'ko') {
      monthName = '${date.month}월';
    } else if (locale == 'ja') {
      monthName = '${date.month}月';
    } else if (locale == 'zh') {
      monthName = '${date.month}月';
    } else {
      // 영어 및 기타 - 짧은 월 이름
      const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
      monthName = months[date.month - 1];
    }
    
    return Container(
      width: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 빨간색 헤더 (월)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFEF5350),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              monthName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          // 흰색 바디 (일)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Text(
              '${date.day}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPlanCard(DailyPlan plan, bool isActive) {
    final strings = ref.watch(appStringsProvider);
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
          // 커스텀 달력 아이콘 (다국어 지원)
          _buildCalendarIconWidget(context, plan.date),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FontAwesomeIcons.penNib, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        strings.cardWrite,
                        style: const TextStyle(
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
    final strings = ref.watch(appStringsProvider);
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
    
    // Helper function for icon type labels
    String getIconTypeLabel(String type) {
      switch (type) {
        case 'Normal': return strings.iconNormal;
        case 'Holiday': return strings.iconHoliday;
        case 'Birthday': return strings.iconBirthday;
        case 'Anniversary': return strings.iconAnniversary;
        case 'Work': return strings.iconWork;
        case 'Personal': return strings.iconPersonal;
        case 'Important': return strings.iconImportant;
        default: return type;
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
              title: Text(strings.scheduleEdit),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: strings.scheduleTitle,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(strings.scheduleRecipients, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                          label: Text(strings.add),
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
                      title: Text("${strings.scheduleDate}: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
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
                    Text(strings.scheduleIconType, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                              Text(getIconTypeLabel(entry.key), style: TextStyle(fontSize: 10, color: isSelected ? typeColors[entry.key] : Colors.grey)),
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
                  child: Text(strings.cancel),
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
                  child: Text(strings.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPlanOptions(BuildContext context, DailyPlan plan) {
    final strings = ref.watch(appStringsProvider);
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
                title: Text(strings.planEdit),
                onTap: () {
                  Navigator.pop(context);
                  _showEditPlanDialog(context, plan);
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.trash, color: Colors.redAccent),
                title: Text(strings.planDelete, style: const TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, plan);
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.arrowDown),
                title: Text(strings.planMoveToEnd),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(homeViewModelProvider.notifier).movePlanToEnd(plan.id);
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.calendarDays),
                title: Text(strings.planReschedule),
                onTap: () {
                  Navigator.pop(context);
                  _pickNewDate(context, plan);
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.icons),
                title: Text(strings.planChangeIcon),
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
    final strings = ref.watch(appStringsProvider);
    
    // Helper function for icon type labels
    String getIconTypeLabel(String type) {
      switch (type) {
        case 'Normal': return strings.iconNormal;
        case 'Holiday': return strings.iconHoliday;
        case 'Birthday': return strings.iconBirthday;
        case 'Anniversary': return strings.iconAnniversary;
        case 'Work': return strings.iconWork;
        case 'Personal': return strings.iconPersonal;
        case 'Important': return strings.iconImportant;
        default: return type;
      }
    }
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(strings.planSelectIcon, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _iconOption(context, plan, 'Normal', FontAwesomeIcons.calendarDay, Colors.blue, getIconTypeLabel('Normal')),
                  _iconOption(context, plan, 'Holiday', FontAwesomeIcons.flag, Colors.redAccent, getIconTypeLabel('Holiday')),
                  _iconOption(context, plan, 'Birthday', FontAwesomeIcons.cakeCandles, Colors.orangeAccent, getIconTypeLabel('Birthday')),
                  _iconOption(context, plan, 'Anniversary', FontAwesomeIcons.heart, Colors.pinkAccent, getIconTypeLabel('Anniversary')),
                  _iconOption(context, plan, 'Work', FontAwesomeIcons.briefcase, Colors.brown, getIconTypeLabel('Work')),
                  _iconOption(context, plan, 'Personal', FontAwesomeIcons.user, Colors.green, getIconTypeLabel('Personal')),
                  _iconOption(context, plan, 'Important', FontAwesomeIcons.star, Colors.amber, getIconTypeLabel('Important')),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  
  Widget _iconOption(BuildContext context, DailyPlan plan, String type, IconData icon, Color color, String label) {
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
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, DailyPlan plan) {
    final strings = ref.watch(appStringsProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.planDelete),
        content: Text(strings.planDeleteConfirm(plan.content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(homeViewModelProvider.notifier).deletePlan(plan.id);
              Navigator.pop(context);
            },
            child: Text(strings.delete, style: const TextStyle(color: Colors.red)),
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
    final strings = ref.watch(appStringsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.homeUpcoming,
                style: const TextStyle(
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
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(strings.homeNoEvents, style: const TextStyle(color: AppTheme.textSecondary)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 120),
                  physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
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

  void _showContactPicker(BuildContext context, Function(List<Map<String, String>>) onSelected) async {
    final selected = await ContactPickerDialog.show(context);
    if (selected != null && selected.isNotEmpty) {
      onSelected(selected.map((c) => {'name': c.name, 'phone': c.phone}).toList());
    }
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
