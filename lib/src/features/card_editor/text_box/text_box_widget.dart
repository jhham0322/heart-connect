import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'text_box_controller.dart';
import 'text_box_style.dart';

/// 글상자 위젯
/// 
/// 글상자의 UI를 렌더링합니다.
/// 모든 자식 요소는 글상자 내부 로컬 좌표 (0,0) ~ (width, height) 기준으로 배치됩니다.
class TextBoxWidget extends StatefulWidget {
  /// 컨트롤러
  final TextBoxController controller;
  
  /// 상단 아이콘 관련
  final String? selectedTopic;
  final List<String> availableTopics;
  final VoidCallback? onTopicSelectorTap;
  final VoidCallback? onAiButtonTap;
  final int maxMessageLength;
  final int maxLines; // 최대 줄 수
  final bool isAiLoading;
  
  /// 캡처 모드 (아이콘 숨김)
  final bool isCapturing;
  
  /// 드래그 가능 여부
  final bool isDraggable;
  
  /// 줌 모드 (드래그 비활성화)
  final bool isZoomMode;

  /// 탭 콜백
  final VoidCallback? onTap;
  
  /// 드래그 완료 콜백
  final VoidCallback? onDragEnd;

  const TextBoxWidget({
    super.key,
    required this.controller,
    this.selectedTopic,
    this.availableTopics = const [],
    this.onTopicSelectorTap,
    this.onAiButtonTap,
    this.maxMessageLength = 75,
    this.maxLines = 5, // 최대 줄 수 (기본값 5줄)
    this.isAiLoading = false,
    this.isCapturing = false,
    this.isDraggable = true,
    this.isZoomMode = false,
    this.onTap,
    this.onDragEnd,
  });

  @override
  State<TextBoxWidget> createState() => _TextBoxWidgetState();
}

class _TextBoxWidgetState extends State<TextBoxWidget> {
  // 컨텐츠 높이 측정용
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeight());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(TextBoxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeight());
    }
  }

  void _measureHeight() {
    if (!mounted) return;
    final context = _contentKey.currentContext;
    if (context != null) {
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        widget.controller.updateContentHeight(box.size.height);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.controller.model;
    final style = widget.controller.style;
    
    return Positioned(
      left: model.position.dx,
      top: model.position.dy - TextBoxController.iconBarHeight - TextBoxController.iconBarSpacing - 36, // 드래그 핸들 높이 36
      child: SizedBox(
        width: model.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 0. 드래그 핸들 바 (항상 표시, 캡처 모드 제외)
            if (!widget.isCapturing)
              _buildDragHandle(),
            
            // 1. 상단 아이콘 바 (캡처 모드가 아닐 때만)
            if (!widget.isCapturing)
              _buildTopIconBar(),
            
            const SizedBox(height: TextBoxController.iconBarSpacing),
            
            // 2. 메인 컨텐츠 박스 (드래그 제거, 탭만 처리)
            GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onTap: widget.onTap ?? () => widget.controller.activate(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildMainBox(style),
                  
                  // 드래그 모드 인디케이터
                  if (model.isDragMode && !widget.isCapturing)
                    Positioned(
                      left: -12,
                      top: -12,
                      child: _buildDragIndicator(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 드래그 핸들 바 - 글상자 상단에 표시
  Widget _buildDragHandle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _canDrag ? _onPanStart : null,
      onPanUpdate: _canDrag ? _onPanUpdate : null,
      onPanEnd: _canDrag ? _onPanEnd : null,
      child: Container(
        width: double.infinity,
        height: 28,
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF29D86).withOpacity(0.9),
              const Color(0xFFFFB74D).withOpacity(0.9),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.drag_indicator,
              color: Colors.white.withOpacity(0.9),
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              '드래그하여 이동',
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.drag_indicator,
              color: Colors.white.withOpacity(0.9),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }


  bool get _canDrag => widget.isDraggable && !widget.isZoomMode;

  Widget _buildMainBox(TextBoxStyle style) {
    final model = widget.controller.model;
    
    return Container(
      width: model.width,
      constraints: BoxConstraints(
        minHeight: model.minHeight,
        maxHeight: model.maxHeight,
      ),
      decoration: style.boxDecoration,
      child: Padding(
        padding: style.contentPadding,
        child: IntrinsicHeight(
          child: Container(
            key: _contentKey,
            child: QuillEditor(
              controller: widget.controller.quillController,
              focusNode: widget.controller.focusNode,
              scrollController: ScrollController(),
              config: QuillEditorConfig(
                autoFocus: false,
                expands: false,
                scrollable: true,
                padding: EdgeInsets.zero,
                showCursor: true,
                placeholder: '여기를 탭하여 메시지 입력...',
                customStyleBuilder: (attribute) {
                  if (attribute.key == 'font') {
                    try {
                      return GoogleFonts.getFont(attribute.value);
                    } catch (e) {
                      return const TextStyle();
                    }
                  }
                  return const TextStyle();
                },
                customStyles: DefaultStyles(
                  paragraph: DefaultTextBlockStyle(
                    style.textStyle,
                    HorizontalSpacing.zero,
                    VerticalSpacing.zero,
                    VerticalSpacing.zero,
                    null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopIconBar() {
    final messageLength = widget.controller.messageLength;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 주제 선택 드롭다운
        if (widget.availableTopics.isNotEmpty)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTopicSelectorTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFF29D86).withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    FontAwesomeIcons.tag,
                    size: 10,
                    color: Color(0xFFF29D86),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.selectedTopic ?? '주제',
                    style: TextStyle(
                      fontSize: 10,
                      color: widget.selectedTopic != null
                          ? const Color(0xFFF29D86)
                          : Colors.grey[600],
                      fontWeight: widget.selectedTopic != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    FontAwesomeIcons.caretDown,
                    size: 8,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        
        if (widget.availableTopics.isNotEmpty) const SizedBox(width: 6),
        
        // 글자수 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "$messageLength / ${widget.maxMessageLength}",
            style: TextStyle(
              fontSize: 10,
              color: messageLength >= widget.maxMessageLength
                  ? Colors.red
                  : Colors.grey[700],
            ),
          ),
        ),
        
        const SizedBox(width: 6),
        
        // AI 버튼
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onAiButtonTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(6),
            ),
            child: widget.isAiLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFF29D86),
                    ),
                  )
                : const Icon(
                    FontAwesomeIcons.wandMagicSparkles,
                    size: 12,
                    color: Color(0xFFF29D86),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDragIndicator() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF29D86),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.open_with,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    widget.controller.setDragMode(true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    widget.controller.updatePosition(details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    widget.controller.setDragMode(false);
    widget.onDragEnd?.call();
  }
}
