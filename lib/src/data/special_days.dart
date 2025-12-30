/// 한국 기념일 및 특별한 날 데이터
/// 음력이 아닌 양력 기준의 법정 기념일 및 데이 문화
library;

class SpecialDay {
  final int month;
  final int day;
  final String name;
  final String category; // memorial, celebration, love, fun
  final String? description;
  final String? emoji;

  const SpecialDay({
    required this.month,
    required this.day,
    required this.name,
    required this.category,
    this.description,
    this.emoji,
  });

  /// 해당 날짜가 이 특별한 날인지 확인
  bool matches(DateTime date) => date.month == month && date.day == day;
  
  /// DateTime으로 변환 (특정 년도)
  DateTime toDateTime(int year) => DateTime(year, month, day);
}

/// 한국 기념일 데이터
class KoreanSpecialDays {
  KoreanSpecialDays._();

  // ==========================================
  // 1. 주요 법정 기념일 (공휴일 아님)
  // ==========================================
  static const List<SpecialDay> memorialDays = [
    SpecialDay(
      month: 3, day: 3,
      name: '납세자의 날',
      category: 'memorial',
      emoji: '💰',
    ),
    SpecialDay(
      month: 4, day: 3,
      name: '4.3 희생자 추념일',
      category: 'memorial',
      description: '제주 4.3 사건 희생자 추모',
      emoji: '🕯️',
    ),
    SpecialDay(
      month: 4, day: 5,
      name: '식목일',
      category: 'memorial',
      description: '나무 심는 날',
      emoji: '🌳',
    ),
    SpecialDay(
      month: 4, day: 20,
      name: '장애인의 날',
      category: 'memorial',
      emoji: '♿',
    ),
    SpecialDay(
      month: 4, day: 21,
      name: '과학의 날',
      category: 'memorial',
      emoji: '🔬',
    ),
    SpecialDay(
      month: 5, day: 1,
      name: '근로자의 날',
      category: 'memorial',
      description: '노동자의 날 (유급휴일)',
      emoji: '👷',
    ),
    SpecialDay(
      month: 5, day: 8,
      name: '어버이날',
      category: 'celebration',
      description: '부모님께 감사하는 날',
      emoji: '🌹',
    ),
    SpecialDay(
      month: 5, day: 15,
      name: '스승의 날',
      category: 'celebration',
      description: '선생님께 감사하는 날',
      emoji: '🍎',
    ),
    SpecialDay(
      month: 5, day: 18,
      name: '5.18 민주화운동 기념일',
      category: 'memorial',
      description: '광주 민주화운동 기념',
      emoji: '🕯️',
    ),
    SpecialDay(
      month: 5, day: 21,
      name: '부부의 날',
      category: 'love',
      description: '부부의 사랑을 확인하는 날',
      emoji: '💑',
    ),
    SpecialDay(
      month: 5, day: 31,
      name: '바다의 날',
      category: 'memorial',
      emoji: '🌊',
    ),
    SpecialDay(
      month: 6, day: 25,
      name: '6.25 전쟁일',
      category: 'memorial',
      description: '한국전쟁 발발일',
      emoji: '🕊️',
    ),
    SpecialDay(
      month: 7, day: 17,
      name: '제헌절',
      category: 'memorial',
      description: '대한민국 헌법 제정 기념일',
      emoji: '📜',
    ),
    SpecialDay(
      month: 10, day: 1,
      name: '국군의 날',
      category: 'memorial',
      emoji: '🎖️',
    ),
    SpecialDay(
      month: 10, day: 2,
      name: '노인의 날',
      category: 'celebration',
      description: '어르신께 감사하는 날',
      emoji: '👴',
    ),
    SpecialDay(
      month: 11, day: 11,
      name: '농업인의 날',
      category: 'memorial',
      emoji: '🌾',
    ),
    SpecialDay(
      month: 11, day: 17,
      name: '순국선열의 날',
      category: 'memorial',
      description: '순국선열 추모',
      emoji: '🕯️',
    ),
  ];

  // ==========================================
  // 2. 한국 '데이' 문화 (비공식 기념일)
  // ==========================================
  static const List<SpecialDay> cultureDays = [
    SpecialDay(
      month: 2, day: 14,
      name: '발렌타인데이',
      category: 'love',
      description: '여자가 남자에게 초콜릿 선물',
      emoji: '🍫',
    ),
    SpecialDay(
      month: 3, day: 3,
      name: '삼겹살데이',
      category: 'fun',
      description: '삼겹살 먹는 날',
      emoji: '🥓',
    ),
    SpecialDay(
      month: 3, day: 14,
      name: '화이트데이',
      category: 'love',
      description: '남자가 여자에게 사탕 선물',
      emoji: '🍬',
    ),
    SpecialDay(
      month: 4, day: 14,
      name: '블랙데이',
      category: 'fun',
      description: '솔로들이 짜장면 먹는 날',
      emoji: '🍜',
    ),
    SpecialDay(
      month: 5, day: 14,
      name: '로즈데이',
      category: 'love',
      description: '장미꽃 선물',
      emoji: '🌹',
    ),
    SpecialDay(
      month: 6, day: 14,
      name: '키스데이',
      category: 'love',
      emoji: '💋',
    ),
    SpecialDay(
      month: 7, day: 14,
      name: '실버데이',
      category: 'love',
      description: '은반지 선물',
      emoji: '💍',
    ),
    SpecialDay(
      month: 10, day: 24,
      name: '애플데이',
      category: 'love',
      description: '사과를 주며 화해하는 날',
      emoji: '🍎',
    ),
    SpecialDay(
      month: 11, day: 11,
      name: '빼빼로데이',
      category: 'love',
      description: '빼빼로/가래떡 선물',
      emoji: '🥢',
    ),
    SpecialDay(
      month: 11, day: 14,
      name: '무비데이',
      category: 'fun',
      description: '영화 보는 날',
      emoji: '🎬',
    ),
    SpecialDay(
      month: 12, day: 14,
      name: '허그데이',
      category: 'love',
      description: '포옹하는 날',
      emoji: '🤗',
    ),
    SpecialDay(
      month: 12, day: 25,
      name: '크리스마스',
      category: 'celebration',
      emoji: '🎄',
    ),
  ];

  /// 모든 특별한 날 목록
  static List<SpecialDay> get all => [...memorialDays, ...cultureDays];

  /// 특정 날짜의 특별한 날 조회
  static List<SpecialDay> getForDate(DateTime date) {
    return all.where((day) => day.matches(date)).toList();
  }

  /// 특정 월의 모든 특별한 날 조회
  static List<SpecialDay> getForMonth(int month) {
    return all.where((day) => day.month == month).toList();
  }

  /// 다가오는 특별한 날 조회 (오늘 포함, N일 이내)
  static List<SpecialDay> getUpcoming(DateTime from, {int withinDays = 30}) {
    final year = from.year;
    final upcoming = <SpecialDay>[];
    
    for (final day in all) {
      var date = day.toDateTime(year);
      
      // 이미 지난 날이면 내년으로
      if (date.isBefore(from) && date.day != from.day) {
        date = day.toDateTime(year + 1);
      }
      
      final diff = date.difference(from).inDays;
      if (diff >= 0 && diff <= withinDays) {
        upcoming.add(day);
      }
    }
    
    // 날짜순 정렬
    upcoming.sort((a, b) {
      final dateA = a.toDateTime(from.year);
      final dateB = b.toDateTime(from.year);
      return dateA.compareTo(dateB);
    });
    
    return upcoming;
  }

  /// 카테고리별 아이콘
  static String getCategoryIcon(String category) {
    switch (category) {
      case 'memorial':
        return '🕯️';
      case 'celebration':
        return '🎉';
      case 'love':
        return '❤️';
      case 'fun':
        return '🎮';
      default:
        return '📅';
    }
  }

  /// 카테고리별 색상
  static int getCategoryColor(String category) {
    switch (category) {
      case 'memorial':
        return 0xFF607D8B; // 회색
      case 'celebration':
        return 0xFFFF9800; // 주황
      case 'love':
        return 0xFFE91E63; // 핑크
      case 'fun':
        return 0xFF4CAF50; // 초록
      default:
        return 0xFF9E9E9E;
    }
  }
}
