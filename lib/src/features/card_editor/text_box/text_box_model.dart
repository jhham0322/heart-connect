import 'dart:ui';

/// 글상자 데이터 모델
/// 
/// 글상자의 위치, 크기, 내용 등 모든 상태 데이터를 관리합니다.
/// 좌측상단 (0,0) 기준의 로컬 좌표계를 사용합니다.
class TextBoxModel {
  /// 글상자 위치 (카드 좌측상단 기준 절대 좌표)
  Offset position;
  
  /// 글상자 크기
  double width;
  double? height; // null이면 자동 높이
  
  /// 크기 제약
  final double minHeight;
  double maxHeight; // mutable하게 변경하여 리사이즈 가능
  
  /// 텍스트 내용 (플레인 텍스트)
  String content;
  
  /// 글상자 활성화 상태
  bool isActive;
  
  /// 드래그 모드
  bool isDragMode;

  TextBoxModel({
    this.position = Offset.zero,
    this.width = 300,
    this.height,
    this.minHeight = 80,
    this.maxHeight = 400,
    this.content = '',
    this.isActive = false,
    this.isDragMode = false,
  });

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() => {
    'positionX': position.dx,
    'positionY': position.dy,
    'width': width,
    'height': height,
    'content': content,
  };

  /// JSON에서 역직렬화
  factory TextBoxModel.fromJson(Map<String, dynamic> json) {
    return TextBoxModel(
      position: Offset(
        (json['positionX'] as num?)?.toDouble() ?? 0,
        (json['positionY'] as num?)?.toDouble() ?? 0,
      ),
      width: (json['width'] as num?)?.toDouble() ?? 300,
      height: (json['height'] as num?)?.toDouble(),
      content: json['content'] as String? ?? '',
    );
  }

  /// 복사본 생성
  TextBoxModel copyWith({
    Offset? position,
    double? width,
    double? height,
    double? minHeight,
    double? maxHeight,
    String? content,
    bool? isActive,
    bool? isDragMode,
  }) {
    return TextBoxModel(
      position: position ?? this.position,
      width: width ?? this.width,
      height: height ?? this.height,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      content: content ?? this.content,
      isActive: isActive ?? this.isActive,
      isDragMode: isDragMode ?? this.isDragMode,
    );
  }

  /// 글상자 영역 (Rect)
  Rect get bounds => Rect.fromLTWH(
    position.dx,
    position.dy,
    width,
    height ?? minHeight,
  );

  /// 텍스트 줄 수 (대략적)
  int get estimatedLineCount {
    if (content.isEmpty) return 1;
    // 한 줄당 약 15자 정도 (폰트 크기에 따라 달라질 수 있음)
    final charsPerLine = (width / 20).floor().clamp(10, 30);
    return (content.length / charsPerLine).ceil().clamp(1, 20);
  }
}
