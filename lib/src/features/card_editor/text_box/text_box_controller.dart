import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'text_box_model.dart';
import 'text_box_style.dart';

/// 글상자 컨트롤러
/// 
/// 글상자의 상태 변경, 드래그, 크기 조절 등 모든 로직을 처리합니다.
class TextBoxController extends ChangeNotifier {
  /// 데이터 모델
  TextBoxModel _model;
  TextBoxModel get model => _model;

  /// 스타일
  TextBoxStyle _style;
  TextBoxStyle get style => _style;

  /// Quill 에디터 컨트롤러
  final QuillController quillController;

  /// 포커스 노드
  final FocusNode focusNode;

  /// 카드 영역 크기 (드래그 제한용)
  Size? cardSize;

  /// 아이콘 바 높이
  static const double iconBarHeight = 32;
  static const double iconBarSpacing = 8;

  /// 컨텐츠 높이 (자동 계산됨)
  double _contentHeight = 0;
  double get contentHeight => _contentHeight;
  
  /// 최대 줄 수 제한
  int maxLines;
  
  /// 이전 문서 내용 (줄 수 초과 시 롤백용)
  String _previousContent = '';
  int _previousSelectionOffset = 0;

  TextBoxController({
    TextBoxModel? model,
    TextBoxStyle? style,
    QuillController? quillController,
    FocusNode? focusNode,
    this.maxLines = 8, // 기본 최대 8줄
  })  : _model = model ?? TextBoxModel(),
        _style = style ?? const TextBoxStyle(),
        quillController = quillController ?? QuillController.basic(),
        focusNode = focusNode ?? FocusNode() {
    this.quillController.addListener(_onTextChanged);
    this.focusNode.addListener(_onFocusChanged);
    _previousContent = this.quillController.document.toPlainText();
  }

  @override
  void dispose() {
    quillController.removeListener(_onTextChanged);
    focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  // === 텍스트 변경 ===
  void _onTextChanged() {
    final newContent = quillController.document.toPlainText();
    final lineCount = '\n'.allMatches(newContent).length;
    
    // 최대 줄 수 초과 시 롤백
    if (lineCount > maxLines) {
      // 비동기로 롤백 (현재 이벤트 루프 완료 후)
      Future.microtask(() {
        if (quillController.document.toPlainText() != _previousContent) {
          // 이전 내용으로 복원
          quillController.document.delete(0, quillController.document.length - 1);
          quillController.document.insert(0, _previousContent.trimRight());
          
          // 커서 위치 복원
          final newLength = quillController.document.length - 1;
          final safeOffset = _previousSelectionOffset.clamp(0, newLength);
          quillController.updateSelection(
            TextSelection.collapsed(offset: safeOffset),
            ChangeSource.local,
          );
        }
      });
      return;
    }
    
    // 정상 입력 - 상태 저장
    _previousContent = newContent;
    _previousSelectionOffset = quillController.selection.baseOffset;
    
    final trimmedContent = newContent.trim();
    if (_model.content != trimmedContent) {
      _model = _model.copyWith(content: trimmedContent);
      notifyListeners();
    }
  }

  // === 포커스 변경 ===
  void _onFocusChanged() {
    final isActive = focusNode.hasFocus;
    if (_model.isActive != isActive) {
      _model = _model.copyWith(isActive: isActive);
      notifyListeners();
    }
  }

  // === 위치 변경 ===
  void updatePosition(Offset delta) {
    final newPosition = _model.position + delta;
    
    // 경계 제한 (카드 영역 내)
    final clampedPosition = _clampPosition(newPosition);
    
    if (_model.position != clampedPosition) {
      _model = _model.copyWith(position: clampedPosition);
      notifyListeners();
    }
  }

  void setPosition(Offset position) {
    final clampedPosition = _clampPosition(position);
    if (_model.position != clampedPosition) {
      _model = _model.copyWith(position: clampedPosition);
      notifyListeners();
    }
  }

  Offset _clampPosition(Offset position) {
    if (cardSize == null) return position;
    
    final boxHeight = _model.height ?? _contentHeight + style.contentPadding.vertical;
    
    // 글상자가 카드 영역 내에 있도록 제한
    final minX = 0.0;
    final maxX = cardSize!.width - _model.width;
    final minY = iconBarHeight + iconBarSpacing; // 아이콘바 공간 확보
    final maxY = cardSize!.height - boxHeight;
    
    return Offset(
      position.dx.clamp(minX, maxX),
      position.dy.clamp(minY, maxY),
    );
  }

  // === 크기 변경 ===
  void updateWidth(double width) {
    if (_model.width != width) {
      _model = _model.copyWith(width: width);
      notifyListeners();
    }
  }

  void updateContentHeight(double height) {
    if (_contentHeight != height) {
      _contentHeight = height;
      notifyListeners();
    }
  }

  // === 드래그 모드 ===
  void setDragMode(bool isDragMode) {
    if (_model.isDragMode != isDragMode) {
      _model = _model.copyWith(isDragMode: isDragMode);
      notifyListeners();
    }
  }

  // === 활성화 ===
  void activate() {
    focusNode.requestFocus();
  }

  void deactivate() {
    focusNode.unfocus();
  }

  // === 스타일 변경 ===
  void updateStyle(TextBoxStyle newStyle) {
    if (_style != newStyle) {
      _style = newStyle;
      notifyListeners();
    }
  }

  void setFrameImage(String? frameImage) {
    _style = _style.copyWith(frameImage: frameImage);
    notifyListeners();
  }

  void setFontFamily(String fontFamily) {
    _style = _style.copyWith(fontFamily: fontFamily);
    notifyListeners();
  }

  void setFontSize(double fontSize) {
    _style = _style.copyWith(fontSize: fontSize);
    notifyListeners();
  }

  void setTextColor(Color color) {
    _style = _style.copyWith(textColor: color);
    notifyListeners();
  }

  void setTextAlign(TextAlign align) {
    _style = _style.copyWith(textAlign: align);
    notifyListeners();
  }

  void toggleBold() {
    _style = _style.copyWith(isBold: !_style.isBold);
    notifyListeners();
  }

  void toggleItalic() {
    _style = _style.copyWith(isItalic: !_style.isItalic);
    notifyListeners();
  }

  void toggleUnderline() {
    _style = _style.copyWith(isUnderline: !_style.isUnderline);
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    _style = _style.copyWith(backgroundColor: color);
    notifyListeners();
  }

  void setBackgroundOpacity(double opacity) {
    _style = _style.copyWith(backgroundOpacity: opacity);
    notifyListeners();
  }

  void setBorderRadius(double radius) {
    _style = _style.copyWith(borderRadius: radius);
    notifyListeners();
  }

  // === 텍스트 내용 설정 ===
  void setContent(String content) {
    quillController.document = Document()..insert(0, content);
    _model = _model.copyWith(content: content);
    notifyListeners();
  }

  // === 직렬화 ===
  Map<String, dynamic> toJson() => {
    'model': _model.toJson(),
    'style': _style.toJson(),
    'quillDelta': quillController.document.toDelta().toJson(),
  };

  void fromJson(Map<String, dynamic> json) {
    if (json['model'] != null) {
      _model = TextBoxModel.fromJson(json['model']);
    }
    if (json['style'] != null) {
      _style = TextBoxStyle.fromJson(json['style']);
    }
    if (json['quillDelta'] != null) {
      quillController.document = Document.fromJson(json['quillDelta']);
    }
    notifyListeners();
  }

  /// 계산된 박스 전체 높이 (아이콘바 제외)
  double get boxHeight {
    final contentH = _contentHeight > 0 ? _contentHeight : _model.minHeight;
    final totalH = contentH + style.contentPadding.vertical;
    return totalH.clamp(_model.minHeight, _model.maxHeight);
  }

  /// 아이콘바 포함 전체 높이
  double get totalHeight => boxHeight + iconBarHeight + iconBarSpacing;

  /// 글자 수
  int get messageLength => _model.content.length;

  /// 중앙 위치 계산 (카드 크기 기준)
  Offset getCenterPosition() {
    if (cardSize == null) return Offset.zero;
    
    return Offset(
      (cardSize!.width - _model.width) / 2,
      (cardSize!.height - boxHeight) / 2 + iconBarHeight,
    );
  }

  /// 초기 위치를 중앙으로 설정
  void centerInCard() {
    setPosition(getCenterPosition());
  }
}
