import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../contacts/contact_service.dart';
import 'home_view_model.dart';

// 템플릿 카드용 모델
class TemplateCard {
  final String emoji;
  final String title;
  final String subtitle;

  const TemplateCard({required this.emoji, required this.title, this.subtitle = ''});
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // 캐러셀 컨트롤러
  late PageController _pageController;
  int _currentPage = 0;
  
  // 템플릿 데이터 (하드코딩)
  final List<TemplateCard> _cards = const [
    TemplateCard(emoji: '🎂', title: 'Birthday', subtitle: 'Classic'),
    TemplateCard(emoji: '🎓', title: 'Graduation', subtitle: 'Celebration'),
    TemplateCard(emoji: '🎄', title: 'Christmas', subtitle: 'Season'),
    TemplateCard(emoji: '💖', title: 'Love', subtitle: 'Romantic'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85, 
      initialPage: 0,
    );
    
    // 앱 시작 시 데이터 동기화
    WidgetsBinding.instance.addPostFrameCallback((_) async {
       try {
         // 1. 주소록 동기화 (Windows는 Mock 데이터 생성)
         await ref.read(contactServiceProvider.notifier).syncContacts();
         // 2. 홈 모델 새로고침
         ref.read(homeViewModelProvider.notifier).refresh();
       } catch (e) {
         debugPrint("Init Sync Error: $e");
       }
    });
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // B. 온도 섹션 (Warmth Meter)
          _buildWarmthSection(homeState.sentCount, homeState.totalGoal, progress),
          
          const SizedBox(height: 24),

          // C. 카드 캐러셀
          _buildCardCarousel(),

          const SizedBox(height: 32),

          // D. 다가오는 일정
          _buildUpcomingEvents(homeState.upcomingEvents),
          
          // 하단 네비게이션 여백
          const SizedBox(height: 120),
        ],
      ),
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

  /// C. 카드 캐러셀 (템플릿 선택)
  Widget _buildCardCarousel() {
    return SizedBox(
      height: 340,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: _cards.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final card = _cards[index];
          final isActive = index == _currentPage;
          
          return AnimatedScale(
            scale: isActive ? 1.0 : 0.92,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: isActive ? 1.0 : 0.6,
              duration: const Duration(milliseconds: 300),
              child: _buildTemplateCard(card, isActive),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateCard(TemplateCard card, bool isActive) {
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
            card.emoji,
            style: const TextStyle(fontSize: 72),
          ),
          const SizedBox(height: 16),
          // 제목
          Text(
            card.subtitle.isNotEmpty 
                ? "${card.title}\n(${card.subtitle})" 
                : card.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.2
            ),
            textAlign: TextAlign.center,
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
                    // 선택된 템플릿 정보를 가지고 이동 (나중에 arguments로 넘길 수 있음)
                    context.push('/write');
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
              const SizedBox(width: 12),
              // Skip 버튼 (다음 카드)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _cards.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    }
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
                  child: const Icon(FontAwesomeIcons.chevronRight, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// D. 다가오는 일정 섹션 (Real Data)
  Widget _buildUpcomingEvents(List<EventItem> events) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming Events",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          if (events.isEmpty)
             const Center(
               child: Padding(
                 padding: EdgeInsets.all(20.0),
                 child: Text("No upcoming events.", style: TextStyle(color: AppTheme.textSecondary)),
               ),
             )
          else 
            ...events.map((event) => _buildEventItem(event)),
        ],
      ),
    );
  }

  Widget _buildEventItem(EventItem event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: event.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(event.icon, color: event.color, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          // 구분선
          Container(
            width: 2,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.grayLight,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.dateLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentCoral,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (event.source.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  event.source,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
