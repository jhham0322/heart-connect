/// 글상자 모듈
/// 
/// 카드 편집기에서 사용하는 글상자(텍스트 박스) 관련 클래스들을 제공합니다.
/// 
/// 사용 예시:
/// ```dart
/// // 1. 컨트롤러 생성
/// final textBoxController = TextBoxController();
/// 
/// // 2. 카드 크기 설정
/// textBoxController.cardSize = Size(cardWidth, cardHeight);
/// 
/// // 3. 중앙 위치로 초기화
/// textBoxController.centerInCard();
/// 
/// // 4. 위젯 사용
/// TextBoxWidget(
///   controller: textBoxController,
///   selectedTopic: '새해',
///   onAiButtonTap: () => _showAiDialog(),
/// )
/// ```
library text_box;

export 'text_box_model.dart';
export 'text_box_style.dart';
export 'text_box_controller.dart';
export 'text_box_widget.dart';
