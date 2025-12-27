import 'dart:convert';
import 'dart:async'; // Added for Timer
import 'dart:io';
import 'dart:math' as math; // Import math with alias
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../ai/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for rootBundle
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/phone_formatter.dart';
import '../gallery/gallery_data.dart'; // Import gallery data
import '../gallery/favorites_provider.dart'; // Import favorites provider
import 'package:drift/drift.dart' hide Column;
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../../widgets/contact_picker_dialog.dart'; // Common contact picker
import 'package:flutter_quill/flutter_quill.dart'; // Rich Text Editor
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_selector/file_selector.dart'; // File Picker
import 'package:image/image.dart' as img; // JPEG 변환용
import 'package:heart_connect/src/services/social_share_service.dart'; // 소셜 미디어 공유
import 'package:heart_connect/src/services/mms_intent_service.dart'; // MMS Intent 발송
import 'package:heart_connect/src/l10n/app_strings.dart';
import 'package:heart_connect/src/providers/locale_provider.dart';

class AutoScrollingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;
  final double height;

  const AutoScrollingText({
    Key? key,
    required this.text,
    required this.style,
    this.maxLines = 3,
    this.height = 60,
  }) : super(key: key);

  @override
  State<AutoScrollingText> createState() => _AutoScrollingTextState();
}

class _AutoScrollingTextState extends State<AutoScrollingText> {
  final ScrollController _scrollController = ScrollController();
  late Timer _timer;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.maxScrollExtent > 0) {
      _isScrolling = true;
      _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (!mounted || !_scrollController.hasClients) {
          timer.cancel();
          return;
        }
        double newOffset = _scrollController.offset + 1.0;
        if (newOffset >= _scrollController.position.maxScrollExtent) {
          // Reached bottom, pause and reset
          timer.cancel();
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && _scrollController.hasClients) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOut,
              ).then((_) {
                Future.delayed(const Duration(seconds: 2), () {
                   if (mounted) _startAutoScroll();
                });
              });
            }
          });
        } else {
          _scrollController.jumpTo(newOffset);
        }
      });
    }
  }

  @override
  void dispose() {
    if (_isScrolling) _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(), // Disable manual scroll during auto-scroll
        child: Text(
          widget.text,
          style: widget.style,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}


class WriteCardScreen extends ConsumerStatefulWidget {
  final String? initialImage;
  final Contact? initialContact; // Added initialContact parameter
  final String? originalMessage; // Added originalMessage parameter
  final List<Map<String, String>>? initialRecipients; // 일정에서 전달받은 수신자 목록
  const WriteCardScreen({super.key, this.initialImage, this.initialContact, this.originalMessage, this.initialRecipients});

  @override
  ConsumerState<WriteCardScreen> createState() => _WriteCardScreenState();
}

class _WriteCardScreenState extends ConsumerState<WriteCardScreen> {
  // State for Editing
  String _message = "Happy Birthday,\ndear Emma!\nWith love, Anna.";
  late final TextEditingController _messageController;
  late final TextEditingController _footerController;
  String _footerText = "HEART-CONNECT";
  
  // Default placeholder matching the Nativity scene
  String _selectedImage = "assets/images/cards/christmas/baecb8cc-2d6e-40a3-9754-95eae4022ab7.png"; 
  
  // Frame Logic
  bool _isFrameMode = false;
  String? _selectedFrame;
  List<String> _frameImages = [];
  bool _isLoadingFrames = false;

  // Style State
  TextStyle _currentStyle = GoogleFonts.greatVibes(fontSize: 24, color: const Color(0xFF1A1A1A), height: 1.2);
  TextAlign _textAlign = TextAlign.center;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  double _fontSize = 24.0;
  String _fontName = 'Great Vibes';
  
  // Templates (Loaded Dynamically)
  List<String> _templates = [];
  bool _isLoading = true;
  
  // AI Service
  final _aiService = AiService();
  bool _isAiLoading = false;
  
  // Send State
  bool _isSending = false;
  bool _isCapturing = false; // 캡쳐 중인지 여부
  bool _isZoomMode = false; // 줌 모드 (배경 이미지 편집 중)
  bool _isDragMode = false; // 글상자 이동 모드 (롱프레스 시)
  bool _showZoomHint = false; // 줌 모드 안내 문구 표시
  bool _showInitialHint = true; // 첫 진입 시 더블탭 안내
  bool _isPanning = false; // 이미지 드래그 중
  bool _isPinching = false; // 이미지 핀치(확대/축소) 중
  String _currentHintMessage = ''; // 현재 표시할 안내 메시지
  bool _hasShownTextBoxDragHint = false; // 글상자 드래그 안내 표시 여부
  bool _hasShownAiHint = false; // AI 문구 교정 안내 표시 여부

  // Text Box Style State (글상자 스타일)
  Color _boxColor = Colors.white;
  String _boxShape = 'rounded'; // rounded, rectangle, circle, bubble, heart, star
  double _boxOpacity = 0.5; // 기본 투명도 약간 높임
  double _boxRadius = 12.0;
  bool _hasBorder = true;
  Color _borderColor = Colors.white;
  double _borderWidth = 1.0;

  // Footer Style State
  Color _footerColor = Colors.white;
  double _footerFontSize = 10.0;
  String _footerFont = 'Roboto'; // 푸터 폰트 (기본값)
  bool _isFooterBold = true;
  bool _isFooterItalic = false;
  bool _isFooterUnderline = false;
  
  // Track active input for styling
  bool _isFooterActive = false;
  
  // Footer Box Style
  Color _footerBgColor = Colors.transparent;
  double _footerBgOpacity = 0.0;
  double _footerRadius = 0.0;

  // Footer Position
  Offset _footerOffset = Offset.zero; // Relative to bottom-right

  // 발송 관련 상태
  List<String> _recipients = []; // Modified to non-final to allow reassignment
  final Set<String> _sentRecipients = {}; // 이미 발송된 수신자 목록
  List<String> _pendingRecipients = [];
  int _sentCount = 0;
  bool _autoContinue = false; // 자동 발송 여부

  final List<String> _fontList = [
    'Great Vibes', 'Caveat', 'Dancing Script', 'Pacifico', 'Indie Flower',
    'Roboto', 'Montserrat', 'Playfair Display',
    'Nanum Pen Script', 'Nanum Gothic', 'Gowun Batang', 'Song Myung',
    'Dongle', 'Gowun Dodum', 'Noto Sans KR', 'Hi Melody', 'Gamja Flower', 'Single Day', 'Jua', 'Do Hyeon',
    'Sunflower', 'Black Han Sans', 'Cute Font', 'Gaegu', 'Yeon Sung', 'Poor Story'
  ];

  final Map<String, String> _fontDisplayNames = {
    'Nanum Pen Script': '나눔 펜 (Nanum Pen)',
    'Nanum Gothic': '나눔 고딕 (Nanum Gothic)',
    'Gowun Batang': '고운 바탕 (Gowun Batang)',
    'Song Myung': '송명 (Song Myung)',
    'Dongle': '동글 (Dongle)',
    'Gowun Dodum': '고운 돋움 (Gowun Dodum)',
    'Noto Sans KR': '본고딕 (Noto Sans)',
    'Hi Melody': '하이 멜로디 (Hi Melody)',
    'Gamja Flower': '감자 꽃 (Gamja Flower)',
    'Single Day': '싱글 데이 (Single Day)',
    'Jua': '주아 (Jua)',
    'Do Hyeon': '도현 (Do Hyeon)',
    'Sunflower': '해바라기 (Sunflower)',
    'Black Han Sans': '검은 고딕 (Black Han Sans)',
    'Cute Font': '큐트 (Cute Font)',
    'Gaegu': '개구쟁이 (Gaegu)',
    'Yeon Sung': '연성 (Yeon Sung)',
    'Poor Story': '푸어 스토리 (Poor Story)',
  };
  
  // Font size dropdown options (6~32)
  final List<double> _fontSizeOptions = [6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32];

  // Text Drag Offset - 이제 위치 유지됨
  Offset _dragOffset = Offset.zero;
  
  // Zoom & Pan State
  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  // Scroll Controller for Template Selector
  final ScrollController _scrollController = ScrollController();
  
  // Scroll Controller for Main Content (Initial scroll to bottom)
  final ScrollController _mainScrollController = ScrollController();

  // Quill Editor Controller
  late QuillController _quillController;
  late QuillController _footerQuillController;
  
  // Document Default Styles (for HTML wrapper and "Apply All" logic)
  String _defaultFontName = 'Great Vibes';
  double _defaultFontSize = 24.0;
  Color _defaultColor = const Color(0xFF1A1A1A);
  TextAlign _defaultTextAlign = TextAlign.center;

  // Focus Node for Quill Editor
  final FocusNode _editorFocusNode = FocusNode();
  final FocusNode _footerFocusNode = FocusNode(); // 푸터 포커스 노드 추가
  
  // GlobalKey for RepaintBoundary (이미지 캡처용)
  final GlobalKey _captureKey = GlobalKey();
  final GlobalKey _backgroundKey = GlobalKey(); // Background Zoom/Pan Capture Key
  final GlobalKey _textBoxKey = GlobalKey(); // Main Message Box Key
  final GlobalKey _footerKey = GlobalKey(); // Footer Box Key

  // List of saved cards for swipe navigation
  List<SavedCard> _savedCards = [];
  int? _currentCardId;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: _message);
    _footerController = TextEditingController(text: _footerText);
    _quillController = QuillController(
      document: Document()..insert(0, _message),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _footerQuillController = QuillController(
      document: Document()..insert(0, _footerText),
      selection: const TextSelection.collapsed(offset: 0),
    );
    
    _quillController.addListener(_onEditorChanged);
    _footerQuillController.addListener(_onFooterEditorChanged);
    
    // 포커스 리스너 추가
    _footerFocusNode.addListener(_onFocusChanged);
    _editorFocusNode.addListener(_onFocusChanged);

    print("[WriteCardScreen] initState at ${DateTime.now()}");
    print("[WriteCardScreen] Received InitialImage: ${widget.initialImage}");
    
    if (widget.initialImage != null) {
      // Normalize path for Windows compatibility
      _selectedImage = widget.initialImage!.replaceAll('\\', '/');
      print("[WriteCardScreen] Set _selectedImage: $_selectedImage");
    } else {
      print("[WriteCardScreen] InitialImage is NULL!");
    }

    // Add initial contact if provided
    if (widget.initialContact != null) {
      _recipients.insert(0, "${widget.initialContact!.name} (${widget.initialContact!.phone})");
      print("[WriteCardScreen] Added initialContact: ${widget.initialContact!.name} to _recipients");
      print("[WriteCardScreen] _recipients now: $_recipients");
    } else if (widget.initialRecipients != null && widget.initialRecipients!.isNotEmpty) {
      // 일정에서 전달받은 수신자 목록 처리
      for (var r in widget.initialRecipients!) {
        final name = r['name'] ?? '';
        final phone = r['phone'] ?? '';
        if (name.isNotEmpty) {
          _recipients.add("$name ($phone)");
        }
      }
      print("[WriteCardScreen] Added initialRecipients: ${widget.initialRecipients} to _recipients");
      print("[WriteCardScreen] _recipients now: $_recipients");
    } else {
      print("[WriteCardScreen] initialContact is NULL");
    }

    _loadTemplateAssets();
    _loadFrameAssets();
    _loadDraft(); // Load full draft including footer

    // 더미 수신자 데이터 생성 삭제 (사용자 요청: 1명만 있어야 함)
    // for (int i = 1; i <= 20; i++) {
    //   _recipients.add("수신자 $i 010-0000-${i.toString().padLeft(4, '0')}");
    // }
    _pendingRecipients = List.from(_recipients);
    
    // 화면 진입 시 텍스트 에디터 자동 포커스 방지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }
  
  // --- Draft Persistence ---

  Future<void> _saveDraft() async {
    if (!mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftData = {
        'message': _quillController.document.toDelta().toJson(),
        'footer': _footerQuillController.document.toDelta().toJson(),
        'image': _selectedImage,
        'frame': _selectedFrame,
        'isFrameMode': _isFrameMode,
        'boxStyle': {
          'color': _boxColor.value,
          'opacity': _boxOpacity,
          'radius': _boxRadius,
          'hasBorder': _hasBorder,
          'borderColor': _borderColor.value,
          'borderWidth': _borderWidth,
        },
        'footerStyle': {
          'bgColor': _footerBgColor.value,
          'bgOpacity': _footerBgOpacity,
          'radius': _footerRadius,
          'color': _footerColor.value,
          'fontSize': _footerFontSize,
          'font': _footerFont,
          'isBold': _isFooterBold,
          'isItalic': _isFooterItalic,
          'isUnderline': _isFooterUnderline,
          'offsetX': _footerOffset.dx,
          'offsetY': _footerOffset.dy,
        },
        'mainStyle': {
          'dragOffsetX': _dragOffset.dx,
          'dragOffsetY': _dragOffset.dy,
          'fontName': _fontName,
          'fontSize': _fontSize,
          'color': _defaultColor.value,
          'textAlign': _textAlign.name,
          'transformMatrix': _transformationController.value.storage.toList(), // Save Zoom/Pan State
        },
        'isFooterActive': _isFooterActive,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString('card_draft_v2', jsonEncode(draftData));
      // print("[Draft] Saved draft successfully.");
    } catch (e) {
      print("[Draft] Error saving draft: $e");
    }
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftJson = prefs.getString('card_draft_v2');
      
      if (draftJson == null || draftJson.isEmpty) {
        _loadSavedFooter(); // Fallback to old footer save if no full draft
        return;
      }

      final data = jsonDecode(draftJson) as Map<String, dynamic>;
      
      if (mounted) {
        setState(() {
          // Restore simple values
          if (data['image'] != null) _selectedImage = data['image'];
          _selectedFrame = data['frame'];
          _isFrameMode = data['isFrameMode'] ?? false;
          _isFooterActive = data['isFooterActive'] ?? false;

          // Restore Quill
          if (data['message'] != null) {
            _quillController.document = Document.fromJson(data['message']);
            // Update plain text message for length check
            _message = _quillController.document.toPlainText().trim();
          }
          if (data['footer'] != null) {
            _footerQuillController.document = Document.fromJson(data['footer']);
            _footerText = _footerQuillController.document.toPlainText().trim();
          }

          // Restore Box Style
          final box = data['boxStyle'];
          if (box != null) {
            _boxColor = Color(box['color']);
            _boxOpacity = box['opacity'];
            _boxRadius = box['radius'];
            _hasBorder = box['hasBorder'];
            _borderColor = Color(box['borderColor']);
            _borderWidth = box['borderWidth'];
          }

          // Restore Footer Style
          final footer = data['footerStyle'];
          if (footer != null) {
            _footerBgColor = Color(footer['bgColor']);
            _footerBgOpacity = footer['bgOpacity'];
            _footerRadius = footer['radius'];
            _footerColor = Color(footer['color']);
            _footerFontSize = footer['fontSize'];
            _footerFont = footer['font'];
            _isFooterBold = footer['isBold'];
            _isFooterItalic = footer['isItalic'];
            _isFooterUnderline = footer['isUnderline'];
            _footerOffset = Offset(footer['offsetX'], footer['offsetY']);
          }

          // Restore Main Style
          final main = data['mainStyle'];
          if (main != null) {
            _dragOffset = Offset(main['dragOffsetX'], main['dragOffsetY']);
            _fontName = main['fontName'];
            _fontSize = main['fontSize'];
            _defaultColor = Color(main['color']);
            _textAlign = TextAlign.values.firstWhere((e) => e.name == main['textAlign'], orElse: () => TextAlign.center);
            _defaultTextAlign = _textAlign;
            
            if (main['transformMatrix'] != null) {
              final List<dynamic> matrixList = main['transformMatrix'];
              _transformationController.value = Matrix4.fromList(matrixList.map((e) => (e as num).toDouble()).toList());
            }

            // Safety check: If loaded image is a thumbnail/capture, reset transformation to avoid double-scaling
            if (_selectedImage.contains('card_bg_')) {
               _transformationController.value = Matrix4.identity();
            }

            // Reconstruct current style
            try {
              _currentStyle = GoogleFonts.getFont(_fontName, fontSize: _fontSize, color: _defaultColor);
            } catch (e) {
              _currentStyle = GoogleFonts.greatVibes(fontSize: _fontSize, color: _defaultColor);
            }
          }
        });
        
        // Ensure UI reflects state
        _updateToolbarState();
      }
    } catch (e) {
      print("[Draft] Error loading draft: $e");
      _loadSavedFooter();
    }
  }


  // Fallback for legacy footer save - user_name을 기본값으로 사용
  Future<void> _loadSavedFooter() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFooter = prefs.getString('footer_text');
    
    if (savedFooter != null && savedFooter.isNotEmpty && mounted) {
      _updateFooterController(savedFooter);
    } else {
      // user_name이 설정되어 있으면 그것을 사용
      final userName = prefs.getString('user_name');
      if (userName != null && userName.isNotEmpty && mounted) {
        _footerText = userName;
        _footerQuillController.document = Document()..insert(0, userName);
      }
    }
  }

  void _updateFooterController(String textOrJson) {
    try {
      final json = jsonDecode(textOrJson);
      _footerQuillController.document = Document.fromJson(json);
    } catch (e) {
      // Not JSON, treat as plain text
      _footerQuillController.document = Document()..insert(0, textOrJson);
    }
  }

  Future<void> _fetchAllSavedCards() async {
    final db = ref.read(appDatabaseProvider);
    final cards = await db.getAllSavedCards(); // Assuming this method returns all cards sorted by date DESC
    if (mounted) {
      setState(() {
        _savedCards = cards;
        // Sort by createdAt DESC just in case
        _savedCards.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });
    }
  }

  void _handleSwipeNavigation(DragEndDetails details) {
    if (_savedCards.isEmpty) return;
    
    // Check if zoomed in
    if (_transformationController.value != Matrix4.identity()) return;

    final velocity = details.primaryVelocity;
    if (velocity == null) return;

    // Threshold for swipe
    if (velocity.abs() < 500) return;

    int currentIndex = -1;
    if (_currentCardId != null) {
      currentIndex = _savedCards.indexWhere((c) => c.id == _currentCardId);
    }

    if (velocity > 0) {
      // Swipe Right (Left to Right) -> Past (Older) -> Next Index
      // "왼쪽에서 오른쪽은 과거"
      if (currentIndex < _savedCards.length - 1) {
        _loadCard(_savedCards[currentIndex + 1]);
      } else if (currentIndex == -1 && _savedCards.isNotEmpty) {
        // If currently on new/unsaved card, go to the latest saved card (Index 0)
        _loadCard(_savedCards[0]);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("더 이상 이전 카드가 없습니다."), duration: Duration(milliseconds: 1000)),
        );
      }
    } else {
      // Swipe Left (Right to Left) -> Recent (Newer) -> Prev Index
      // "오른쪽에서 왼쪽은 최신"
      if (currentIndex > 0) {
        _loadCard(_savedCards[currentIndex - 1]);
      } else if (currentIndex == 0) {
        // At the newest saved card. 
        // User might want to go to "New Card" mode?
        // Let's implement a reset to new card if user swipes left from the newest saved card
        _resetToNewCard();
      } else {
         // Already at new card or error
      }
    }
  }

  void _resetToNewCard() {
    if (_currentCardId == null) return; // Already new

    setState(() {
      _currentCardId = null;
      _message = "Happy Birthday,\ndear Emma!\nWith love, Anna.";
      _quillController.document = Document()..insert(0, _message);
      _selectedFrame = null;
      _boxColor = Colors.white.withOpacity(0.4);
      _hasBorder = false;
      // Reset other properties as needed
      // Maybe keep the image?
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("새로운 카드를 작성합니다."), duration: Duration(milliseconds: 1000)),
    );
  }
  
  // _saveFooter removed in favor of _saveDraft


  void _onQuillChanged() {
    setState(() {
      _message = _quillController.document.toPlainText().trim();
    });
    _saveDraft();
  }

  @override
  void didUpdateWidget(WriteCardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImage != null && widget.initialImage != oldWidget.initialImage) {
      setState(() {
         _selectedImage = widget.initialImage!.replaceAll('\\', '/');
      });
      // Scroll to new image after build
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _footerController.dispose();
    _footerFocusNode.removeListener(_onFocusChanged);
    _editorFocusNode.removeListener(_onFocusChanged);
    _editorFocusNode.dispose();
    _footerFocusNode.dispose();
    _quillController.removeListener(_onEditorChanged);
    _footerQuillController.removeListener(_onFooterEditorChanged);
    _quillController.dispose();
    _footerQuillController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    // Prevent setState during build/layout by deferring to post frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
         // Focus change tracking
         if (_footerFocusNode.hasFocus) {
           _isFooterActive = true;
           // Clear selection in main editor
           _quillController.updateSelection(const TextSelection.collapsed(offset: 0), ChangeSource.local);
         } else if (_editorFocusNode.hasFocus) {
           _isFooterActive = false;
           // Clear selection in footer editor
           _footerQuillController.updateSelection(const TextSelection.collapsed(offset: 0), ChangeSource.local);
           
           // 처음 텍스트 영역 포커스 시 AI 문구 교정 안내
           if (!_hasShownAiHint) {
             _hasShownAiHint = true;
             // 상단 힌트 영역에 표시
             _currentHintMessage = '💡 오른쪽 상단 AI 버튼으로 문구를 자동 교정할 수 있어요!';
             Future.delayed(const Duration(seconds: 4), () {
               if (mounted && _currentHintMessage.contains('AI')) {
                 setState(() {
                   _currentHintMessage = '';
                 });
               }
             });
           }
         }
         _updateToolbarState();
      });
    });
  }

  QuillController get _activeController => _isFooterActive ? _footerQuillController : _quillController;

  void _onEditorChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateToolbarState();
      _onQuillChanged();
    });
  }

  void _onFooterEditorChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateToolbarState();
      setState(() {
        // Delta를 일반 텍스트로 변환하여 저장 (미리보기 등에서 사용)
        _footerText = _footerQuillController.document.toPlainText().trim();
      });
      // 전체 상태 저장
      _saveDraft();
    });
  }

  // 커서 위치나 선택 영역 변경 시 툴바 상태 업데이트
  void _updateToolbarState() {
    final controller = _activeController;
    final style = controller.getSelectionStyle();
    
    setState(() {
      _isBold = style.containsKey(Attribute.bold.key);
      _isItalic = style.containsKey(Attribute.italic.key);
      _isUnderline = style.containsKey(Attribute.underline.key);
      
      // 정렬 상태 확인
      if (style.containsKey(Attribute.leftAlignment.key)) {
        _textAlign = TextAlign.left;
      } else if (style.containsKey(Attribute.centerAlignment.key)) {
        _textAlign = TextAlign.center;
      } else if (style.containsKey(Attribute.rightAlignment.key)) {
        _textAlign = TextAlign.right;
      } else {
        // Default alignments
        _textAlign = _isFooterActive ? TextAlign.right : TextAlign.center;
      }

      // 폰트 사이즈 확인
      if (style.containsKey('size')) {
        final sizeStr = style.attributes['size']?.value;
        if (sizeStr != null) {
             final parsed = double.tryParse(sizeStr.toString());
             if (parsed != null) _fontSize = parsed;
        }
      } else {
        _fontSize = _isFooterActive ? _footerFontSize : 24.0;
      }
      
      // 폰트 패밀리 확인
      if (style.containsKey('font')) {
         _fontName = style.attributes['font']?.value ?? 'Great Vibes';
      } else {
         _fontName = _isFooterActive ? _footerFont : 'Great Vibes';
      }
      
      // 색상 확인
      // Quill uses hex strings
    });
  }

  void _scrollToSelected() {
    final list = _isFrameMode ? _frameImages : _templates;
    final selected = _isFrameMode ? _selectedFrame : _selectedImage;

    if (list.isEmpty || selected == null || selected.isEmpty) return;
    
    final index = list.indexOf(selected);
    if (index != -1 && _scrollController.hasClients) {
      final screenWidth = MediaQuery.of(context).size.width;
      final offset = (index * 92.0) - (screenWidth / 2) + 40; // 40 is half item width
      
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickImage() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'jpeg', 'png', 'gif'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file != null) {
      setState(() {
        _selectedImage = file.path.replaceAll('\\', '/');
        // Reset zoom when new image loaded
        _transformationController.value = Matrix4.identity();
        _saveDraft();
      });
    }
  }

  // ★ Assets 폴더의 이미지를 동적으로 읽어오는 함수
  Future<void> _loadTemplateAssets() async {
    List<String> allAssets = [];
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      allAssets = manifest.listAssets();
    } catch (e) {
      print("AssetManifest load error: $e");
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final paths = allAssets
        .where((String key) => key.startsWith('assets/images/cards/') && 
              (key.toLowerCase().endsWith('.png') || key.toLowerCase().endsWith('.jpg') || key.toLowerCase().endsWith('.jpeg')))
        .toList();

    if (mounted) {
      setState(() {
        _templates = paths;
        if (_templates.isNotEmpty && _selectedImage.isEmpty) {
          _selectedImage = _templates.first;
        }
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }
  
  // ★ Frame 폴더의 이미지를 읽어오는 함수
  Future<void> _loadFrameAssets() async {
    setState(() => _isLoadingFrames = true);
    List<String> allAssets = [];
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      allAssets = manifest.listAssets();
    } catch (e) {
      print("Frame AssetManifest load error: $e");
      if (mounted) setState(() => _isLoadingFrames = false);
      return;
    }

    final paths = allAssets
        .where((String key) => key.startsWith('assets/images/frame/') && 
              (key.toLowerCase().endsWith('.png') || key.toLowerCase().endsWith('.jpg') || key.toLowerCase().endsWith('.jpeg')))
        .toList();

    if (mounted) {
      setState(() {
        _frameImages = paths;
        _isLoadingFrames = false;
      });
    }
  }

  // --- SAVE & LOAD DRAFTS ---

  String _convertToHtml(String text) {
    // Convert Quill Delta to HTML
    final converter = QuillDeltaToHtmlConverter(
      _quillController.document.toDelta().toJson(),
      ConverterOptions(multiLineParagraph: false),
    );
    String html = converter.convert();

    // Apply custom styles not directly handled by Quill (like text alignment for the whole block)
    final colorHex = _defaultColor.value.toRadixString(16).padLeft(8, '0').substring(2);
    final align = _defaultTextAlign.name;
    // Use _defaultFontName to ensure canonical name is saved as wrapper
    final fontFamily = _defaultFontName; 
    final fontSize = _defaultFontSize;
    
    // Wrap the generated HTML in a div with overall styles
    return '<div style="font-family: \'$fontFamily\'; font-size: ${fontSize}px; color: #$colorHex; text-align: $align;">$html</div>';
  }

  void _loadFromHtml(String html) {
    final fontMatch = RegExp(r"font-family:\s*'([^']+)'").firstMatch(html);
    final sizeMatch = RegExp(r"font-size:\s*([\d.]+)px").firstMatch(html);
    final colorMatch = RegExp(r"color:\s*#([0-9a-fA-F]+)").firstMatch(html);
    final alignMatch = RegExp(r"text-align:\s*(\w+)").firstMatch(html);
    
    final plainText = html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();

    setState(() {
      String fontFamily = fontMatch?.group(1) ?? 'Great Vibes';
      
      // Fix for legacy saved cards with internal font names
      if (fontFamily == 'GreatVibes_regular') {
        fontFamily = 'Great Vibes';
      }
      
      final double fontSize = double.tryParse(sizeMatch?.group(1) ?? '24.0') ?? 24.0;
      final Color textColor = Color(int.parse("FF${colorMatch?.group(1) ?? '1A1A1A'}", radix: 16));
      
      // Set Defaults
      _defaultFontName = fontFamily;
      _defaultFontSize = fontSize;
      _defaultColor = textColor;

      // Set Toolbar UI State
      _fontName = fontFamily;
      _fontSize = fontSize;
      try {
        _currentStyle = GoogleFonts.getFont(fontFamily, fontSize: fontSize, color: textColor);
      } catch (e) {
        // Fallback if font not found
        print("Font not found: $fontFamily, falling back to Great Vibes");
        _fontName = 'Great Vibes';
        _currentStyle = GoogleFonts.greatVibes(fontSize: fontSize, color: textColor);
      }

      if (alignMatch != null) {
        final alignStr = alignMatch.group(1);
        final align = TextAlign.values.firstWhere((e) => e.name == alignStr, orElse: () => TextAlign.center);
        _defaultTextAlign = align;
        _textAlign = align;
      }
      
      _message = plainText;
      _quillController.document = Document()..insert(0, plainText);
    });
  }

  // 볼드 토글
  void _toggleBold() {
    final controller = _activeController;
    final isBold = controller.getSelectionStyle().containsKey(Attribute.bold.key);
    controller.formatSelection(
      isBold ? Attribute.clone(Attribute.bold, null) : Attribute.bold
    );
  }
  
  // 이탤릭 토글
  void _toggleItalic() {
    final controller = _activeController;
    final isItalic = controller.getSelectionStyle().containsKey(Attribute.italic.key);
    controller.formatSelection(
      isItalic ? Attribute.clone(Attribute.italic, null) : Attribute.italic
    );
  }
  
  // 밑줄 토글
  void _toggleUnderline() {
    final controller = _activeController;
    final isUnder = controller.getSelectionStyle().containsKey(Attribute.underline.key);
    controller.formatSelection(
      isUnder ? Attribute.clone(Attribute.underline, null) : Attribute.underline
    );
  }
  
  // 텍스트 정렬 적용
  void _applyAlignment(TextAlign align) {
    final controller = _activeController;
    Attribute alignAttr;
    switch (align) {
      case TextAlign.left:
        alignAttr = Attribute.leftAlignment;
        break;
      case TextAlign.center:
        alignAttr = Attribute.centerAlignment;
        break;
      case TextAlign.right:
        alignAttr = Attribute.rightAlignment;
        break;
      default:
        alignAttr = Attribute.leftAlignment;
    }
    
    // Apply Logic:
    // If No Selection -> Apply to Whole Doc & Update Defaults
    // If Selection -> Apply to Selection Only (Mixed alignment in one card is rare but possible)
    if (controller.selection.isCollapsed) {
       final len = controller.document.length;
       controller.formatText(0, len, alignAttr);
       setState(() {
         _defaultTextAlign = align;
         _textAlign = align;
       });
    } else {
       controller.formatSelection(alignAttr);
       // Do not update defaults
    }
    _saveDraft();
  }

  // 폰트 변경
  void _applyFont(String fontName, {bool? isFooterOverride}) {
    final isFooter = isFooterOverride ?? _isFooterActive;
    final controller = isFooter ? _footerQuillController : _quillController;
    
    // Logic: No Selection -> Apply All & Update Default. Selection -> Apply Selection Only.
    if (controller.selection.isCollapsed) {
       final len = controller.document.length;
       controller.formatText(0, len, Attribute.fromKeyValue('font', fontName));
       
       setState(() {
          if (isFooter) {
             _footerFont = fontName;
          } else {
             _defaultFontName = fontName;
             _fontName = fontName;
             try {
                _currentStyle = GoogleFonts.getFont(fontName, fontSize: _fontSize, color: _currentStyle.color);
             } catch (e) {
                _currentStyle = GoogleFonts.greatVibes(fontSize: _fontSize, color: _currentStyle.color);
             }
          }
       });
    } else {
       controller.formatSelection(Attribute.fromKeyValue('font', fontName));
       // For selection, we rely on _updateToolbarState to update UI (_fontName), 
       // but we do NOT update _defaultFontName.
    }
    _saveDraft();
  }
  
  // 폰트 사이즈 변경
  void _applyFontSize(double size, {bool? isFooterOverride}) {
    final isFooter = isFooterOverride ?? _isFooterActive;
    final controller = isFooter ? _footerQuillController : _quillController;
    
    if (controller.selection.isCollapsed) {
       final len = controller.document.length;
       controller.formatText(0, len, Attribute.fromKeyValue('size', size.toString()));
       
       setState(() {
          if (isFooter) {
             _footerFontSize = size;
          } else {
             _defaultFontSize = size;
             _fontSize = size;
             _currentStyle = _currentStyle.copyWith(fontSize: size);
          }
       });
    } else {
       controller.formatSelection(Attribute.fromKeyValue('size', size.toString()));
    }
    _saveDraft();
  }
  
  // 색상 변경
  void _applyColor(Color color, {bool? isFooterOverride}) {
    final isFooter = isFooterOverride ?? _isFooterActive;
    final controller = isFooter ? _footerQuillController : _quillController;
    final hex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    
    if (controller.selection.isCollapsed) {
       final len = controller.document.length;
       controller.formatText(0, len, Attribute.fromKeyValue('color', hex));
       
       setState(() {
          if (isFooter) {
             _footerColor = color;
          } else {
             _defaultColor = color;
             _currentStyle = _currentStyle.copyWith(color: color);
          }
       });
    } else {
       controller.formatSelection(Attribute.fromKeyValue('color', hex));
    }
    _saveDraft();
  }

  // 되돌리기
  void _undo() {
    final controller = _activeController;
    if (controller.hasUndo) controller.undo();
  }

  // 다시실행
  void _redo() {
    final controller = _activeController;
    if (controller.hasRedo) controller.redo();
  }

  Future<void> _saveCurrentCard() async {
    // 저장 이름 기본값 로직 수정: 첫 줄만 추출 (빈 줄 제외)
    final strings = ref.read(appStringsProvider);
    String defaultName = strings.cardNoTitle;
    final cleanMessage = _message.trim();
    if (cleanMessage.isNotEmpty) {
      final lines = cleanMessage.split('\n');
      for (var line in lines) {
        if (line.trim().isNotEmpty) {
          defaultName = line.trim();
          break;
        }
      }
      if (defaultName.length > 20) defaultName = "${defaultName.substring(0, 20)}...";
    }
    
    final nameController = TextEditingController(text: defaultName);
    
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.cardSaveTitle),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: strings.cardSaveName,
            hintText: strings.cardSaveHint,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(strings.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(strings.save)),
        ],
      ),
    );

    if (proceed != true) return;

    // 배경 이미지 확대/이동 상태가 있으면 캡처하여 저장
    String imagePathToSave = _selectedImage;
    // 원본 이미지 경로 저장 (편집 복원용)
    // 주의: _selectedImage가 이미 캡처된 파일(card_bg_)일 경우, 원본이 소실된 상태일 수 있음.
    String originalImagePath = _selectedImage; 
    
    if (_transformationController.value != Matrix4.identity()) {
       final bgBytes = await _captureBackground();
       if (bgBytes != null) {
          try {
            final directory = await getApplicationDocumentsDirectory();
            final fileName = 'card_bg_${DateTime.now().millisecondsSinceEpoch}.png';
            final savedPath = '${directory.path}/$fileName';
            final file = File(savedPath);
            await file.writeAsBytes(bgBytes);
            imagePathToSave = savedPath; // 썸네일/미리보기용 크롭 이미지
          } catch (e) {
            print("배경 이미지 저장 실패: $e");
          }
       }
    }

    final db = ref.read(appDatabaseProvider);
    final html = _convertToHtml(_message);
    final footerJson = jsonEncode(_footerQuillController.document.toDelta().toJson());
    
    // 스타일 데이터 직렬화
    final mainStyle = {
      'dragOffsetX': _dragOffset.dx,
      'dragOffsetY': _dragOffset.dy,
      'fontName': _fontName,
      'fontSize': _fontSize,
      'color': _defaultColor.value,
      'textAlign': _textAlign.name,
      'transformMatrix': _transformationController.value.storage.toList(),
      'originalImage': originalImagePath, // 원본 이미지 경로 저장
      'isFrameMode': _isFrameMode,
      'frame': _selectedFrame,
    };
    
    final boxStyle = {
      'color': _boxColor.value,
      'opacity': _boxOpacity,
      'radius': _boxRadius,
      'hasBorder': _hasBorder,
      'borderColor': _borderColor.value,
      'borderWidth': _borderWidth,
    };

    final footerStyle = {
      'bgColor': _footerBgColor.value,
      'bgOpacity': _footerBgOpacity,
      'radius': _footerRadius,
      'color': _footerColor.value,
      'fontSize': _footerFontSize,
      'font': _footerFont,
      'isBold': _isFooterBold,
      'isItalic': _isFooterItalic,
      'isUnderline': _isFooterUnderline,
      'offsetX': _footerOffset.dx,
      'offsetY': _footerOffset.dy,
    };

    final newId = await db.insertSavedCard(SavedCardsCompanion.insert(
      name: Value(nameController.text),
      htmlContent: html,
      footerText: Value(footerJson),
      imagePath: Value(imagePathToSave), // 썸네일용
      mainStyle: Value(jsonEncode(mainStyle)), // 편집 복원용
      boxStyle: Value(jsonEncode(boxStyle)),
      footerStyle: Value(jsonEncode(footerStyle)),
      frame: Value(_selectedFrame),
      isFooterActive: Value(_isFooterActive),
    ));
    
    await _fetchAllSavedCards();
    setState(() {
      _currentCardId = newId;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("현재 내용이 저장되었습니다.")));
    }
  }

  Future<void> _showSavedCardsDialog() async {
    final db = ref.read(appDatabaseProvider);
    List<SavedCard> savedCards = await db.getAllSavedCards();
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(ref.watch(appStringsProvider).savedCardsTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                       IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                     ],
                   ),
                  const Divider(),
                  Expanded(
                    child: savedCards.isEmpty 
                      ? Center(child: Text(ref.watch(appStringsProvider).savedCardsEmpty, style: const TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: savedCards.length,
                          itemBuilder: (context, index) {
                            final card = savedCards[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              leading: Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: card.imagePath != null ? ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildImage(card.imagePath!, fit: BoxFit.cover)) : const Icon(Icons.image_not_supported),
                              ),
                              title: Text(card.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(card.createdAt.toString().substring(0, 16), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () async {
                                  await db.deleteSavedCard(card.id);
                                  final newList = await db.getAllSavedCards();
                                  setModalState(() {
                                    savedCards = newList;
                                  });
                                },
                              ),
                              onTap: () {
                                _loadCard(card);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
    await _fetchAllSavedCards(); // Refresh list after dialog closes (e.g. deletions)
  }

  void _loadCard(SavedCard card) {
    _loadFromHtml(card.htmlContent);
    setState(() {
      _currentCardId = card.id;
      
      // 기본값 설정 (legacy 데이터 호환용)
      bool imageLoaded = false;

      // 1. Main Style 복원 (원본 이미지 및 변환 행렬)
      if (card.mainStyle != null) {
        try {
          final mainStyle = jsonDecode(card.mainStyle!);
          
          // 원본 이미지 복원
          if (mainStyle['originalImage'] != null) {
            _selectedImage = mainStyle['originalImage'];
            imageLoaded = true;
          }
          
          // 변환 행렬 복원
          if (mainStyle['transformMatrix'] != null) {
            final List<dynamic> matrixList = mainStyle['transformMatrix'];
            _transformationController.value = Matrix4.fromList(matrixList.map((e) => (e as num).toDouble()).toList());
          }
          
          // 기타 스타일
          if (mainStyle['fontName'] != null) _fontName = mainStyle['fontName'];
          if (mainStyle['fontSize'] != null) _fontSize = (mainStyle['fontSize'] as num).toDouble();
          if (mainStyle['color'] != null) _defaultColor = Color(mainStyle['color']);
          if (mainStyle['textAlign'] != null) {
             _textAlign = TextAlign.values.firstWhere(
               (e) => e.name == mainStyle['textAlign'], 
               orElse: () => TextAlign.center
             );
          }
          if (mainStyle['isFrameMode'] != null) _isFrameMode = mainStyle['isFrameMode'];
          if (mainStyle['frame'] != null) _selectedFrame = mainStyle['frame'];
          
        } catch (e) {
          print("MainStyle Load Error: $e");
        }
      }

      // 2. Legacy Fallback (이미지)
      if (!imageLoaded && card.imagePath != null) {
        _selectedImage = card.imagePath!;
        _transformationController.value = Matrix4.identity(); // Legacy는 변환 정보가 없으므로 초기화
      }
      
      // 3. 안전장치: 캡처된 이미지가 로드된 경우 변환 행렬 초기화
      // (캡처된 이미지는 이미 변환이 적용된 상태이므로, 또 다시 변환을 적용하면 이중 확대됨)
      if (_selectedImage.contains('card_bg_')) {
        _transformationController.value = Matrix4.identity();
      }

      // 4. Box Style 복원
      if (card.boxStyle != null) {
        try {
          final boxStyle = jsonDecode(card.boxStyle!);
          if (boxStyle['color'] != null) _boxColor = Color(boxStyle['color']);
          if (boxStyle['opacity'] != null) _boxOpacity = (boxStyle['opacity'] as num).toDouble();
          if (boxStyle['radius'] != null) _boxRadius = (boxStyle['radius'] as num).toDouble();
          if (boxStyle['hasBorder'] != null) _hasBorder = boxStyle['hasBorder'];
          if (boxStyle['borderColor'] != null) _borderColor = Color(boxStyle['borderColor']);
          if (boxStyle['borderWidth'] != null) _borderWidth = (boxStyle['borderWidth'] as num).toDouble();
        } catch (e) {
           print("BoxStyle Load Error: $e");
        }
      }
      
      // 4. Footer Style 복원
      _isFooterActive = card.isFooterActive;
      if (card.footerStyle != null) {
         try {
           final fStyle = jsonDecode(card.footerStyle!);
           if (fStyle['bgColor'] != null) _footerBgColor = Color(fStyle['bgColor']);
           if (fStyle['bgOpacity'] != null) _footerBgOpacity = (fStyle['bgOpacity'] as num).toDouble();
           if (fStyle['radius'] != null) _footerRadius = (fStyle['radius'] as num).toDouble();
           if (fStyle['color'] != null) _footerColor = Color(fStyle['color']);
           if (fStyle['fontSize'] != null) _footerFontSize = (fStyle['fontSize'] as num).toDouble();
           if (fStyle['font'] != null) _footerFont = fStyle['font'];
           if (fStyle['isBold'] != null) _isFooterBold = fStyle['isBold'];
           if (fStyle['isItalic'] != null) _isFooterItalic = fStyle['isItalic'];
           if (fStyle['isUnderline'] != null) _isFooterUnderline = fStyle['isUnderline'];
           if (fStyle['offsetX'] != null && fStyle['offsetY'] != null) {
             _footerOffset = Offset((fStyle['offsetX'] as num).toDouble(), (fStyle['offsetY'] as num).toDouble());
           }
         } catch (e) {
            print("FooterStyle Load Error: $e");
         }
      }
    });
    
    if (card.footerText != null) {
      _updateFooterController(card.footerText!);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("메시지를 불러왔습니다."), duration: Duration(milliseconds: 500)));
  }

  void _showFontPicker() {
    final bool isFooter = _isFooterActive;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("글꼴 선택", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _fontList.length,
                  itemBuilder: (context, index) {
                    final font = _fontList[index];
                    final isSelected = isFooter ? (_footerFont == font) : (_fontName == font);
                    final displayName = _fontDisplayNames[font] ?? font;
                    return ListTile(
                      title: Text(displayName, style: GoogleFonts.getFont(font, fontSize: 18)),
                      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFF29D86)) : null,
                      onTap: () {
                        _applyFont(font, isFooterOverride: isFooter);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// AI 톤 선택 팝업 표시
  void _showAiToneSelector() {
    if (_isAiLoading) return;
    if (_message.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("메시지를 먼저 입력해주세요.")));
        return;
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text("AI 감성 변환 (Gemini)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              _buildToneOption("정중하게 (Polite)", "polite, formal, and respectful", FontAwesomeIcons.userTie),
              _buildToneOption("위트있게 (Witty)", "witty, humorous, and fun", FontAwesomeIcons.faceLaughBeam),
              _buildToneOption("친근하게 (Friendly)", "friendly, warm, and casual", FontAwesomeIcons.handshakeSimple),
              _buildToneOption("감동적인 시처럼 (Poetic)", "poetic, emotional, and touching", FontAwesomeIcons.featherPointed),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToneOption(String label, String toneParam, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFFFF0EB), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFFF29D86), size: 20),
      ),
      title: Text(label),
      onTap: () {
        if (_isAiLoading) return;
        // Set loading state immediately to prevent multiple clicks
        setState(() => _isAiLoading = true);
        Navigator.pop(context);
        _refineMessageWithAi(tone: toneParam);
      },
    );
  }

  void _showBoxStylePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 600, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ref.watch(appStringsProvider).textBoxStyleTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // 0. 미리보기 영역 (고정)
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 배경 이미지
                          _buildImage(_selectedImage, fit: BoxFit.cover),
                          
                          // 글상자 미리보기
                          Center(
                            child: Container(
                              width: 200,
                              height: 120, // 높이 고정
                              padding: const EdgeInsets.all(16),
                              decoration: ShapeDecoration(
                                color: _boxColor.withOpacity(_boxOpacity),
                                shape: _getShapeBorder(
                                  overrideSide: _hasBorder 
                                    ? BorderSide(color: _borderColor.withOpacity(0.5), width: _borderWidth)
                                    : BorderSide.none
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Preview Text\n${ref.watch(appStringsProvider).textBoxPreview}",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.getFont(_fontName, fontSize: 16, color: _currentStyle.color),
                                    ),
                                  ),
                                  // 푸터 미리보기 추가
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _footerBgColor.withOpacity(_footerBgOpacity),
                                        borderRadius: BorderRadius.circular(_footerRadius),
                                      ),
                                      child: Text(
                                        ref.watch(appStringsProvider).textBoxSender,
                                        style: GoogleFonts.getFont(
                                          _footerFont,
                                          color: _footerColor,
                                          fontSize: _footerFontSize, // 1:1 크기로 변경
                                          fontWeight: _isFooterBold ? FontWeight.bold : FontWeight.normal,
                                          fontStyle: _isFooterItalic ? FontStyle.italic : FontStyle.normal,
                                          decoration: _isFooterUnderline ? TextDecoration.underline : TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 설정 영역 (스크롤 가능)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 0. 글상자 모양
                          Text(ref.watch(appStringsProvider).textBoxShapeLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 60,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                {'type': 'rounded', 'icon': Icons.rounded_corner, 'label': ref.watch(appStringsProvider).shapeRounded},
                                {'type': 'rectangle', 'icon': Icons.crop_square, 'label': ref.watch(appStringsProvider).shapeRectangle},
                                {'type': 'beveled', 'icon': Icons.change_history, 'label': ref.watch(appStringsProvider).shapeBevel},
                                {'type': 'circle', 'icon': Icons.circle_outlined, 'label': ref.watch(appStringsProvider).shapeCircle},
                                {'type': 'bubble_left', 'icon': Icons.chat_bubble_outline, 'label': ref.watch(appStringsProvider).shapeBubbleLeft},
                                {'type': 'bubble_center', 'icon': Icons.chat_bubble_outline, 'label': ref.watch(appStringsProvider).shapeBubbleCenter},
                                {'type': 'bubble_right', 'icon': Icons.chat_bubble_outline, 'label': ref.watch(appStringsProvider).shapeBubbleRight},
                                {'type': 'heart', 'icon': Icons.favorite_border, 'label': ref.watch(appStringsProvider).shapeHeart},
                                {'type': 'star', 'icon': Icons.star_border, 'label': ref.watch(appStringsProvider).shapeStar},
                                {'type': 'diamond', 'icon': FontAwesomeIcons.gem, 'label': ref.watch(appStringsProvider).shapeDiamond},
                                {'type': 'hexagon', 'icon': FontAwesomeIcons.drawPolygon, 'label': ref.watch(appStringsProvider).shapeHexagon},
                                {'type': 'cloud', 'icon': Icons.cloud_queue, 'label': ref.watch(appStringsProvider).shapeCloud},
                              ].map((item) {
                                final isSelected = _boxShape == item['type'] || (_boxShape == 'bubble' && item['type'] == 'bubble_right');
                                
                                Widget iconWidget = Icon(item['icon'] as IconData, color: isSelected ? const Color(0xFFF29D86) : Colors.grey, size: 24);
                                
                                // Flip icon for right bubble to show tail on right (assuming default is left)
                                // or flip for left if default is right.
                                // Material chat_bubble_outline has tail on bottom-left.
                                if (item['type'] == 'bubble_right') {
                                   iconWidget = Transform(
                                     alignment: Alignment.center,
                                     transform: Matrix4.rotationY(math.pi),
                                     child: iconWidget,
                                   );
                                }
                                
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() => _boxShape = item['type'] as String);
                                    this.setState(() {}); // 메인 화면 갱신
                                    _saveDraft();
                                  },
                                  child: Container(
                                    width: 60, 
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFFFF0EB) : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: isSelected ? const Color(0xFFF29D86) : Colors.grey[300]!),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        iconWidget,
                                        const SizedBox(height: 4),
                                        Text(item['label'] as String, style: TextStyle(fontSize: 10, color: isSelected ? const Color(0xFFF29D86) : Colors.grey)),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 1. 배경 색상
                          Text(ref.watch(appStringsProvider).textBoxBackgroundColor, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Colors.white, Colors.black, 
                                const Color(0xFFFFF3E0), const Color(0xFFE8F5E9), const Color(0xFFE3F2FD), const Color(0xFFF3E5F5),
                                const Color(0xFFFFEBEE), const Color(0xFFEFEBE9), const Color(0xFFFAFAFA), Colors.transparent
                              ].map((color) {
                                final isSelected = _boxColor.value == color.value;
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() => _boxColor = color);
                                    this.setState(() {}); // 메인 화면 갱신
                                    _saveDraft();
                                  },
                                  child: Container(
                                    width: 40, height: 40,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey[300]!, width: 1),
                                      boxShadow: isSelected ? [const BoxShadow(color: Color(0xFFF29D86), blurRadius: 4, spreadRadius: 1)] : null,
                                    ),
                                    child: color == Colors.transparent 
                                      ? const Icon(Icons.block, color: Colors.grey, size: 20)
                                      : (isSelected ? Icon(Icons.check, color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 20) : null),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // 2. 투명도 슬라이더
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(ref.watch(appStringsProvider).textBoxOpacity, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text("${(_boxOpacity * 100).toInt()}%", style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          Slider(
                            value: _boxOpacity,
                            min: 0.0,
                            max: 1.0,
                            activeColor: const Color(0xFFF29D86),
                            inactiveColor: Colors.grey[200],
                            onChanged: (val) {
                              setModalState(() => _boxOpacity = val);
                              this.setState(() {});
                              _saveDraft();
                            },
                          ),
                          
                          // 3. 둥근 모서리 슬라이더
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(ref.watch(appStringsProvider).textBoxBorderRadius, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text("${_boxRadius.toInt()}px", style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          Slider(
                            value: _boxRadius,
                            min: 0.0,
                            max: 50.0,
                            activeColor: const Color(0xFFF29D86),
                            inactiveColor: Colors.grey[200],
                            onChanged: (val) {
                              setModalState(() => _boxRadius = val);
                              this.setState(() {});
                              _saveDraft();
                            },
                          ),

                          // 4. 테두리 설정
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(ref.watch(appStringsProvider).textBoxBorder, style: const TextStyle(fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Switch(
                                value: _hasBorder,
                                activeColor: const Color(0xFFF29D86),
                                onChanged: (val) {
                                  setModalState(() => _hasBorder = val);
                                  this.setState(() {});
                                  _saveDraft();
                                },
                              ),
                            ],
                          ),
                          if (_hasBorder) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(ref.watch(appStringsProvider).textBoxBorderWidth, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                Text("${_borderWidth.toStringAsFixed(1)}px", style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            Slider(
                              value: _borderWidth,
                              min: 1.0,
                              max: 10.0,
                              activeColor: const Color(0xFFF29D86),
                              inactiveColor: Colors.grey[200],
                              onChanged: (val) {
                                setModalState(() => _borderWidth = val);
                                this.setState(() {});
                                _saveDraft();
                              },
                            ),
                          ],

                          const Divider(height: 30),

                          // 5. 푸터 스타일 (Footer Style)
                          Text(ref.watch(appStringsProvider).textBoxFooterStyle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          
                          // 안내 문구
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                SizedBox(width: 8),
                                Expanded(child: Text(ref.watch(appStringsProvider).textBoxFooterHint, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 푸터 배경 색상
                          Text(ref.watch(appStringsProvider).textBoxBackgroundColor, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Colors.transparent, Colors.white, Colors.black, 
                                const Color(0xFFFFF3E0), const Color(0xFFE8F5E9), const Color(0xFFE3F2FD),
                                const Color(0xFFF3E5F5), const Color(0xFFFFEBEE)
                              ].map((color) {
                                final isSelected = _footerBgColor.value == color.value;
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() => _footerBgColor = color);
                                    this.setState(() {}); // 메인 화면 갱신
                                    _saveDraft();
                                  },
                                  child: Container(
                                    width: 40, height: 40,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey[300]!, width: 1),
                                      boxShadow: isSelected ? [const BoxShadow(color: Color(0xFFF29D86), blurRadius: 4, spreadRadius: 1)] : null,
                                    ),
                                    child: color == Colors.transparent 
                                      ? const Icon(Icons.block, color: Colors.grey, size: 20)
                                      : (isSelected ? Icon(Icons.check, color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 20) : null),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 20),
                          
                          // 푸터 배경 투명도
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(ref.watch(appStringsProvider).footerBgOpacity, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text("${(_footerBgOpacity * 100).toInt()}%", style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          Slider(
                            value: _footerBgOpacity,
                            min: 0.0,
                            max: 1.0,
                            activeColor: const Color(0xFFF29D86),
                            inactiveColor: Colors.grey[200],
                            onChanged: (val) {
                              setModalState(() => _footerBgOpacity = val);
                              this.setState(() {});
                              _saveDraft();
                            },
                          ),

                          // 푸터 둥근 모서리
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(ref.watch(appStringsProvider).footerBgRadius, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text("${_footerRadius.toInt()}px", style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          Slider(
                            value: _footerRadius,
                            min: 0.0,
                            max: 30.0,
                            activeColor: const Color(0xFFF29D86),
                            inactiveColor: Colors.grey[200],
                            onChanged: (val) {
                              setModalState(() => _footerRadius = val);
                              this.setState(() {});
                              _saveDraft();
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF29D86),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(ref.watch(appStringsProvider).done),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// AI를 사용해 메시지를 더 감성적으로 다듬는 기능
  Future<void> _refineMessageWithAi({String tone = 'warm and emotional'}) async {
    if (_message.trim().isEmpty) return;
    
    // Ensure loading state is set (in case it wasn't set by the caller)
    if (!_isAiLoading) {
      setState(() => _isAiLoading = true);
    }
    
    try {
      final refined = await _aiService.refineMessage(_message, tone: tone);
      if (refined != null && mounted) {
        setState(() {
          _message = refined;
          _quillController.document = Document()..insert(0, refined);
        });
      }
    } catch (e) {
      debugPrint('AI Refinement failed: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AI 변환 실패")));
    } finally {
      if (mounted) {
        setState(() => _isAiLoading = false);
      }
    }
  }

  // 배경 이미지 캡처 (Zoom/Pan 상태 저장용)
  Future<Uint8List?> _captureBackground() async {
    try {
      if (_backgroundKey.currentContext == null) return null;
      RenderRepaintBoundary boundary = _backgroundKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("배경 캡처 오류: $e");
      return null;
    }
  }

  // 이미지 캐처 함수 - 배경이미지 + 글씨박스 + 글씨만 캐처
  Future<Uint8List?> _captureCardImage() async {
    try {
      RenderRepaintBoundary boundary = _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // PNG 형식으로 캡처 (바이트 순서 문제 방지)
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("캐처 오류: $e");
      return null;
    }
  }
  
  // PNG를 JPEG로 변환하여 저장 (MMS 전송용 파일 크기 최적화)
  Future<Uint8List?> _convertPngToJpeg(Uint8List pngBytes) async {
    try {
      // PNG 디코딩
      final image = img.decodeImage(pngBytes);
      if (image == null) {
        print("PNG 디코딩 실패");
        return null;
      }
      
      // JPEG로 인코딩 (품질 85% - 파일 크기와 화질 균형)
      final jpegBytes = img.encodeJpg(image, quality: 85);
      return Uint8List.fromList(jpegBytes);
    } catch (e) {
      print("JPEG 변환 오류: $e");
      return null;
    }
  }
  
  // 캐처한 이미지 저장 (JPEG로 변환하여 MMS 전송 가능한 파일 크기로 최적화)
  Future<String?> _saveCardImage() async {
    if (!mounted) return null;

    // 캐쳐 전에 UI 요소 숨기기
    setState(() => _isCapturing = true);
    
    // UI 업데이트 및 리페인트를 위해 충분히 대기
    await Future.delayed(const Duration(milliseconds: 500));

    final imageBytes = await _captureCardImage();

    // 캐쳐 후 UI 복구
    if (mounted) {
      setState(() => _isCapturing = false);
    }

    if (imageBytes == null) return null;
    
    try {
      // PNG를 JPEG로 변환 (MMS 전송을 위해 파일 크기 최적화)
      final jpegBytes = await _convertPngToJpeg(imageBytes);
      if (jpegBytes == null) return null;
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'card_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(jpegBytes);
      
      // 파일 크기 로깅 (MMS 전송 가능 여부 확인용)
      final fileSize = await file.length();
      print("[카드 이미지 저장] JPEG 파일 크기: ${(fileSize / 1024).toStringAsFixed(1)}KB");
      if (fileSize > 1024 * 1024) {
        print("⚠️ 경고: 파일 크기가 1MB를 초과합니다. MMS 전송이 어려울 수 있습니다.");
      }
      
      return filePath;
    } catch (e) {
      print("저장 오류: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFFCF9),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFF29D86))),
      );
    }

    // 발송 버튼 높이
    final sendButtonHeight = 90.0 + MediaQuery.of(context).padding.bottom;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF9),
      resizeToAvoidBottomInset: false, // 키보드가 올라와도 화면 리사이즈 안함 (직접 스크롤로 처리)
      body: Stack(
        children: [
          // 전체 콘텐츠를 하단에 고정 (배경 이미지 + 툴바 + 썸네일)
          Positioned(
            left: 0,
            right: 0,
            bottom: keyboardHeight > 0 ? keyboardHeight : sendButtonHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Card Preview (캡쳐 가능 영역)
                _buildCardPreview(),
                // Toolbar
                _buildToolbar(),
                // Template Selector (썸네일)
                _buildTemplateSelector(),
              ],
            ),
          ),

          // 상단 페이드 그라데이션 오버레이 (이미지 잘림 부드럽게 처리)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).padding.top + 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFFCF9),
                    const Color(0xFFFFFCF9).withOpacity(0.95),
                    const Color(0xFFFFFCF9).withOpacity(0.7),
                    const Color(0xFFFFFCF9).withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Floating Header (이미지 위에 오버레이)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _buildHeaderButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => context.pop(),
                ),
                const SizedBox(width: 8),
                _buildHeaderButton(
                  icon: Icons.folder_open, 
                  onTap: _showSavedCardsDialog,
                ),
                const SizedBox(width: 8),
                _buildHeaderButton(
                  icon: Icons.save, 
                  onTap: _saveCurrentCard,
                ),
                
                const Spacer(),
                
                // 배경 버튼 (상단 고정) - 좁은 화면에서는 아이콘만 표시
                LayoutBuilder(
                  builder: (context, constraints) {
                    final strings = ref.watch(appStringsProvider);
                    final isActive = !_isFrameMode;
                    return Tooltip(
                      message: strings.editorBackground,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                             _isFrameMode = false;
                             WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
                          });
                          _showCategoryPicker();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFFF29D86) : Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.5)),
                          ),
                          child: Icon(Icons.image, color: isActive ? Colors.white : const Color(0xFFF29D86), size: 18),
                        ),
                      ),
                    );
                  },
                ),
                /* 
                const SizedBox(width: 8),
                // 프레임 버튼 (상단 고정)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFrameMode = true;
                      // Switch to frame thumbnails
                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isFrameMode ? const Color(0xFFF29D86) : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.crop_free, color: _isFrameMode ? Colors.white : const Color(0xFFF29D86), size: 18),
                        const SizedBox(width: 6),
                        Text("프레임", style: TextStyle(color: _isFrameMode ? Colors.white : const Color(0xFF555555), fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                */
                const SizedBox(width: 8),
                // 글상자 스타일 버튼 (상단 고정) - 아이콘만 표시
                Tooltip(
                  message: ref.watch(appStringsProvider).editorTextBox,
                  child: GestureDetector(
                    onTap: _showBoxStylePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                      ),
                      child: const Icon(Icons.style, color: Color(0xFFF29D86), size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Undo/Redo Buttons (Fixed below Text Box button)
          Positioned(
            top: MediaQuery.of(context).padding.top + 54, 
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSquareButton(Icons.undo, _undo),
                const SizedBox(width: 8),
                _buildSquareButton(Icons.redo, _redo),
              ],
            ),
          ),
          
          // 줌 모드 표시 아이콘 (클릭하면 줌 모드 종료)
          if (_isZoomMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 100,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // 줌 버튼 클릭 시 줌 모드 종료
                    setState(() {
                      _isZoomMode = false;
                      _showZoomHint = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_in, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text("줌 모드", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        SizedBox(width: 6),
                        Icon(Icons.close, color: Colors.white70, size: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          
          // 안내 메시지 영역 (undo/redo 버튼 영역 침범 방지, right: 110)
          // - 초기: 더블탭 안내
          // - 줌 모드: 드래그/확대축소 방법 안내
          // - 드래그 중: 이동 가능 표시
          // - 핀치 중: 확대/축소 가능 표시
          if (_showInitialHint && !_isZoomMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 50,
              left: 16,
              right: 110, // undo/redo 버튼 영역 피함
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF29D86).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.hardEdge,
                child: _MarqueeText(
                  text: ref.watch(appStringsProvider).cardHintZoomMode,
                  durationSeconds: 0, // 텍스트 길이에 따라 자동 계산
                  onComplete: () {
                    if (mounted) setState(() => _showInitialHint = false);
                  },
                ),
              ),
            ),
          
          if (_showZoomHint && _isZoomMode && !_isPanning && !_isPinching)
            Positioned(
              top: MediaQuery.of(context).padding.top + 50,
              left: 16,
              right: 110, // undo/redo 버튼 영역 피함
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF29D86).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.hardEdge,
                child: _MarqueeText(
                  text: ref.watch(appStringsProvider).cardHintZoomEdit,
                  durationSeconds: 0, // 텍스트 길이에 따라 자동 계산
                  onComplete: () {
                    if (mounted) setState(() => _showZoomHint = false);
                  },
                ),
              ),
            ),
          
          // 드래그 중 안내
          if (_isPanning && _isZoomMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 50,
              left: 16,
              right: 110,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.hardEdge,
                child: _MarqueeText(
                  text: ref.watch(appStringsProvider).cardHintDragging,
                  durationSeconds: 0, // 텍스트 길이에 따라 자동 계산
                ),
              ),
            ),
          
          // 핀치(확대/축소) 중 안내
          if (_isPinching && _isZoomMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 50,
              left: 16,
              right: 110,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.hardEdge,
                child: _MarqueeText(
                  text: ref.watch(appStringsProvider).cardHintPinching,
                  durationSeconds: 0, // 텍스트 길이에 따라 자동 계산
                ),
              ),
            ),
          
          // 하단 고정 전송 버튼 및 수신자 목록
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16, // SafeArea 패딩 적용
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 전송 버튼 및 카운터
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 중앙 정렬을 위한 Spacer (왼쪽) 또는 원본 메시지
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(right: 16),
                        alignment: Alignment.centerRight,
                        child: widget.originalMessage != null 
                          ? GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("받은 메시지"),
                                    content: SingleChildScrollView(child: Text(widget.originalMessage!)),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("닫기")),
                                    ],
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text("받은 메시지", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  AutoScrollingText(
                                    text: widget.originalMessage!,
                                    style: const TextStyle(fontSize: 15, color: Color(0xFF555555), height: 1.3),
                                    height: 60, // 약 3줄 높이
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                      ),
                    ), 

                    Hero(
                      tag: 'write-fab',
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF8A65), Color(0xFFFF7043)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8A65).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isSending ? null : _handleSend,
                            borderRadius: BorderRadius.circular(35),
                            child: Center(
                              child: _isSending 
                                ? const SizedBox(
                                    width: 28, height: 28,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                  )
                                : const Icon(FontAwesomeIcons.paperPlane, color: Colors.white, size: 26),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // 발송 대상 카운터 (오른쪽)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ref.watch(appStringsProvider).cardEditorRecipient, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            if (_recipients.isEmpty)
                              InkWell(
                                onTap: _showRecipientPicker,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF29D86),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.person_add, size: 14, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        ref.watch(appStringsProvider).cardEditorAddRecipient,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: _showRecipientPicker, // Allow adding more even if not empty
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 수신자 이름 표시 (1명이면 이름만, 여러명이면 "이름 외 N명")
                                    Flexible(
                                      child: Text(
                                        _recipients.length == 1
                                            ? _recipients.first.split(' (')[0] // 이름만 추출
                                            : "${_recipients.first.split(' (')[0]} 외 ${_recipients.length - 1}명",
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFF29D86)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.edit, size: 14, color: Color(0xFFF29D86)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Center(
            child: Icon(icon, size: 18, color: const Color(0xFF555555)),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton({required IconData icon, String? label, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withOpacity(0.8),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: const Color(0xFFF29D86)),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper to get ShapeBorder for icon preview
  OutlinedBorder _getShapeByType(String type, {Color color = Colors.grey}) {
    final side = BorderSide(color: color, width: 1.5);
    const radius = 8.0;
    
    switch (type) {
      case 'rectangle':
        return RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: side);
      case 'circle':
        return EnclosingCircleBorder(side: side);
      case 'bubble_right':
        return BubbleBorder(side: side, borderRadius: radius, tailPosition: 'right');
      case 'bubble_left':
        return BubbleBorder(side: side, borderRadius: radius, tailPosition: 'left');
      case 'bubble_center':
        return BubbleBorder(side: side, borderRadius: radius, tailPosition: 'center');
      case 'heart':
        return HeartBorder(side: side);
      case 'star':
        return CustomStarBorder(side: side, points: 5, innerRadiusRatio: 0.4);
      case 'diamond':
        return DiamondBorder(side: side);
      case 'hexagon':
        return HexagonBorder(side: side);
      case 'cloud':
        return CloudBorder(side: side);
      case 'beveled':
        return BeveledRectangleBorder(borderRadius: BorderRadius.circular(radius), side: side);
      case 'rounded':
      default:
        return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: side);
    }
  }

  // Helper to get ShapeBorder based on selection
  OutlinedBorder _getShapeBorder({BorderSide? overrideSide}) {
    BorderSide side;
    if (overrideSide != null) {
      side = overrideSide;
    } else if (_selectedFrame == null && _hasBorder) {
      side = BorderSide(color: _borderColor, width: _borderWidth);
    } else if (!_isFooterActive && !_isCapturing) {
      side = const BorderSide(color: Color(0xFFF29D86), width: 2.0);
    } else {
      side = BorderSide.none;
    }

    switch (_boxShape) {
      case 'rectangle':
        return RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: side);
      case 'circle':
        return EnclosingCircleBorder(side: side);
      case 'bubble': // default (right)
      case 'bubble_right':
        return BubbleBorder(side: side, borderRadius: _boxRadius, tailPosition: 'right');
      case 'bubble_left':
        return BubbleBorder(side: side, borderRadius: _boxRadius, tailPosition: 'left');
      case 'bubble_center':
        return BubbleBorder(side: side, borderRadius: _boxRadius, tailPosition: 'center');
      case 'heart':
        return HeartBorder(side: side);
      case 'star':
        return CustomStarBorder(side: side, points: 5, innerRadiusRatio: 0.4);
      case 'diamond':
        return DiamondBorder(side: side);
      case 'hexagon':
        return HexagonBorder(side: side);
      case 'cloud':
        return CloudBorder(side: side);
      case 'beveled':
        return BeveledRectangleBorder(borderRadius: BorderRadius.circular(_boxRadius), side: side);
      case 'rounded':
      default:
        return RoundedRectangleBorder(borderRadius: BorderRadius.circular(_boxRadius), side: side);
    }
  }

  // Helper to load image securely (Asset, Network, or File)
  Widget _buildImage(String path, {BoxFit fit = BoxFit.cover, double? width, double? height}) {
    if (path.isEmpty) return Container(color: Colors.grey[200]);
    
    if (path.startsWith('http') || path.startsWith('https')) {
      return Image.network(path, fit: fit, width: width, height: height,
        errorBuilder: (_, __, ___) => _buildErrorPlaceholder());
    } 
    
    // Check if it's an asset path
    if (path.startsWith('assets/')) {
       return Image.asset(path, fit: fit, width: width, height: height,
        errorBuilder: (_, error, stack) {
             print("Asset load failed: $error");
             return _buildErrorPlaceholder();
        }
       );
    }

    // Try as local file
    try {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: fit, width: width, height: height,
           errorBuilder: (_, error, stack) => _buildErrorPlaceholder());
      }
    } catch (e) {
      print("File check error: $e");
    }

    return Image.asset(path, fit: fit, width: width, height: height,
      errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
    );
  }

  void _handleDoubleTap() {
    setState(() {
      // 줌 모드 토글 (이미지 크기는 유지, 사용자가 직접 조절)
      _isZoomMode = !_isZoomMode;
      
      // 초기 안내 숨기기
      _showInitialHint = false;
      
      // 줌 모드 진입 시 안내 문구 표시
      if (_isZoomMode) {
        _showZoomHint = true;
        // 20초 후 안내 문구 숨김
        Future.delayed(const Duration(seconds: 20), () {
          if (mounted) {
            setState(() => _showZoomHint = false);
          }
        });
      } else {
        _showZoomHint = false;
      }
    });
  }

  Widget _buildCardPreview() {
    return Container(
      padding: EdgeInsets.zero,
      child: Center(
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.92,
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 25,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GestureDetector(
              // 줌 모드일 때는 스와이프 비활성화 (InteractiveViewer가 터치 처리)
              onHorizontalDragEnd: _isZoomMode ? null : _handleSwipeNavigation,
              onDoubleTapDown: (details) => _doubleTapDetails = details,
              onDoubleTap: _handleDoubleTap,
              child: Stack(
                children: [
                  // RepaintBoundary로 캡처 영역 감싸기 (버튼 제외)
                  RepaintBoundary(
                    key: _captureKey,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 1. Full Background Image with InteractiveViewer (Zoom/Pan Background Only)
                        Positioned.fill(
                          child: RepaintBoundary(
                            key: _backgroundKey,
                            child: InteractiveViewer(
                              transformationController: _transformationController,
                              minScale: 1.0, // 이미지가 보이는 영역보다 작아지지 않음
                              maxScale: 5.0,
                              constrained: true, // 이미지가 경계를 벗어나지 않음
                              clipBehavior: Clip.hardEdge, // 경계를 벗어난 부분 클립
                              panEnabled: _isZoomMode, // 줌 모드일 때만 이동 가능
                              scaleEnabled: _isZoomMode, // 줌 모드일 때만 줌 가능
                              interactionEndFrictionCoefficient: 0.0001, // 부드러운 제스처
                              onInteractionStart: (details) {
                                if (_isZoomMode) {
                                  setState(() {
                                    // 터치 시작 즉시 상태 업데이트
                                    if (details.pointerCount == 1) {
                                      _isPanning = true;
                                      _isPinching = false;
                                    } else if (details.pointerCount >= 2) {
                                      _isPanning = false;
                                      _isPinching = true;
                                    }
                                  });
                                }
                              },
                              onInteractionUpdate: (details) {
                                if (_isZoomMode && details.pointerCount >= 2 && !_isPinching) {
                                  setState(() {
                                    _isPanning = false;
                                    _isPinching = true;
                                  });
                                }
                              },
                              onInteractionEnd: (details) {
                                setState(() {
                                  _isPanning = false;
                                  _isPinching = false;
                                });
                                _saveDraft(); // 줌/이동 후 저장
                              },
                              child: _buildImage(_selectedImage, fit: BoxFit.cover),
                            ),
                          ),
                        ),

                        // 2. Draggable Text Area (줌 모드가 아닐 때만 드래그 가능)
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: _isZoomMode, // 줌 모드일 때 글상자 터치 무시
                            child: Center(
                              child: Transform.translate(
                                offset: _dragOffset,
                                child: GestureDetector(
                                  onPanUpdate: _isZoomMode ? null : (details) {
                                  // Calculate constraints
                                  final cardW = MediaQuery.of(context).size.width * 0.92;
                                  final cardH = cardW * (4 / 3); // AspectRatio 3/4 => H = W / 0.75

                                  final boxContext = _textBoxKey.currentContext;
                                  double boxW = MediaQuery.of(context).size.width * 0.78;
                                  double boxH = 0;

                                  if (boxContext != null) {
                                    final RenderBox box = boxContext.findRenderObject() as RenderBox;
                                    boxH = box.size.height;
                                    boxW = box.size.width;
                                  }

                                  // Calculate Max Offsets (from center)
                                  final maxDx = (cardW - boxW) / 2;
                                  final maxDy = (cardH - boxH) / 2;

                                  setState(() {
                                    final newOffset = _dragOffset + details.delta;
                                    _dragOffset = Offset(
                                      newOffset.dx.clamp(-maxDx.abs(), maxDx.abs()),
                                      newOffset.dy.clamp(-maxDy.abs(), maxDy.abs()),
                                    );
                                  });
                                },
                                onPanStart: (details) {
                                  // 드래그 시작 시 이동 모드 활성화
                                  setState(() => _isDragMode = true);
                                },
                                onPanEnd: (details) {
                                  // 드래그 종료 시 이동 모드 비활성화
                                  setState(() => _isDragMode = false);
                                  _saveDraft();
                                },
                                onPanCancel: () {
                                  // 드래그 취소 시 이동 모드 비활성화
                                  setState(() => _isDragMode = false);
                                },
                                onDoubleTap: () {
                                  // 글상자 영역에서 더블탭 시 줌 모드 진입 방지 (아무 동작 안함)
                                },
                                onTap: () {
                                  _editorFocusNode.requestFocus();
                                  setState(() {
                                    _isFooterActive = false;
                                  });
                                  _updateToolbarState();
                                  _saveDraft();
                                  
                                  // 처음 글상자 클릭 시 드래그 안내
                                  if (!_hasShownTextBoxDragHint) {
                                    _hasShownTextBoxDragHint = true;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(Icons.open_with, color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text('💡 글상자를 드래그하면 위치를 이동할 수 있어요!'),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: const Color(0xFFF29D86),
                                        duration: const Duration(seconds: 3),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  key: _textBoxKey,
                                  width: MediaQuery.of(context).size.width * 0.78,
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.width * 0.90 * 0.85,
                                ),
                                padding: const EdgeInsets.fromLTRB(20, 20, 30, 20),
                                decoration: ShapeDecoration(
                                  // 프레임 이미지가 있으면 이미지 배경, 없으면 사용자 정의 스타일
                                  color: _selectedFrame != null ? null : _boxColor.withOpacity(_boxOpacity),
                                  image: _selectedFrame != null ? DecorationImage(
                                    image: AssetImage(_selectedFrame!),
                                    fit: BoxFit.fill, // 프레임은 늘려서 채움
                                  ) : null,
                                  shape: _getShapeBorder(),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // 드래그 모드일 때 이동 아이콘 표시 (왼쪽 상단)
                                    if (_isDragMode && !_isCapturing)
                                      Positioned(
                                        left: -30,
                                        top: -10,
                                        child: Container(
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
                                          child: const Icon(Icons.open_with, color: Colors.white, size: 18),
                                        ),
                                      ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // 2. 편집 가능한 QuillEditor (최소 4줄, 최대 7줄)
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight: _fontSize * 1.5 * 4, // 최소 4줄
                                            maxHeight: _fontSize * 1.5 * 7, // 최대 7줄
                                          ),
                                          child: QuillEditor(
                                            controller: _quillController,
                                            focusNode: _editorFocusNode,
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
                                                  _currentStyle,
                                                  HorizontalSpacing.zero,
                                                  VerticalSpacing.zero,
                                                  VerticalSpacing.zero,
                                                  null,
                                                ),
                                              ),
                                            ), 
                                          ),
                                        ),
                                        // Footer space placeholder if needed? No, it floats.
                                        const SizedBox(height: 40), // Reserve some space so main text doesn't overlap footer initially
                                      ],
                                    ),
                                    
                                    // 1. 글자수 & AI 버튼 (글상자 바로 위쪽에 고정) - 캡쳐 시 숨김
                                    if (!_isCapturing)
                                      Positioned(
                                        top: -28,
                                        right: 0,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.85),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                "${_message.length} / 75",
                                                style: TextStyle(fontSize: 10, color: _message.length >= 75 ? Colors.red : Colors.grey[700]),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            GestureDetector(
                                              onTap: _showAiToneSelector,
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.85),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: _isAiLoading 
                                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF29D86)))
                                                  : const Icon(FontAwesomeIcons.wandMagicSparkles, size: 12, color: Color(0xFFF29D86)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    
                                    // 3. Footer (Floating & Draggable)
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: Transform.translate(
                                          offset: _footerOffset,
                                          child: GestureDetector(
                                            onPanUpdate: (details) {
                                              setState(() {
                                                _footerOffset += details.delta;
                                              });
                                            },
                                            onPanEnd: (details) {
                                              _saveDraft();
                                            },
                                            onTap: () {
                                              _footerFocusNode.requestFocus();
                                              setState(() {
                                                _isFooterActive = true;
                                              });
                                              _updateToolbarState();
                                              _saveDraft();
                                            },
                                            child: IntrinsicWidth(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _footerBgColor.withOpacity(_footerBgOpacity),
                                                  borderRadius: BorderRadius.circular(_footerRadius),
                                                  border: (_isFooterActive && !_isCapturing)
                                                      ? Border.all(color: const Color(0xFFF29D86), width: 2.0)
                                                      : Border.all(color: Colors.transparent, width: 2.0),
                                                ),
                                                child: QuillEditor(
                                                  controller: _footerQuillController,
                                                  focusNode: _footerFocusNode,
                                                  scrollController: ScrollController(),
                                                  config: QuillEditorConfig(
                                                    autoFocus: false,
                                                    expands: false,
                                                    scrollable: false, // Auto-size height
                                                    padding: EdgeInsets.zero,
                                                    showCursor: true,
                                                    placeholder: '보낸 사람',
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
                                                        GoogleFonts.getFont(
                                                          _footerFont,
                                                          color: _footerColor,
                                                          fontSize: _footerFontSize,
                                                          fontWeight: FontWeight.normal, // Controlled by Quill attributes now
                                                          fontStyle: FontStyle.normal,
                                                          decoration: TextDecoration.none,
                                                        ),
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
                
                // 3. Change BG / Frame Toggle (Top Right) - 캡처에서 제외
                // 상단 고정으로 이동됨
              ],
            ),
          ),
        ),
      ),
        ),
      ),
    );
  }

  // 툴바 (이미지와 썸네일 사이)
  Widget _buildToolbar() {
    final bool isFooterForToolbar = _isFooterActive;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 글자 크기 콤보박스 (6~32)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDDDDDD)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<double>(
                  value: _fontSizeOptions.contains(_fontSize) ? _fontSize : 24,
                  isDense: true,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
                  icon: const Icon(Icons.arrow_drop_down, size: 16),
                  items: _fontSizeOptions.map((size) {
                    return DropdownMenuItem<double>(
                      value: size,
                      child: Text('${size.toInt()}', style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _applyFontSize(value, isFooterOverride: isFooterForToolbar);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Bold
            _buildToolbarButton(icon: FontAwesomeIcons.bold, isActive: _isBold, onTap: _toggleBold),
            // Italic
            _buildToolbarButton(icon: FontAwesomeIcons.italic, isActive: _isItalic, onTap: _toggleItalic),
            // Underline
            _buildToolbarButton(icon: FontAwesomeIcons.underline, isActive: _isUnderline, onTap: _toggleUnderline),
            const SizedBox(width: 4),
            // Color
            _buildToolbarButton(icon: FontAwesomeIcons.palette, onTap: _showColorPicker),
            const SizedBox(width: 4),
            Container(width: 1, height: 24, color: Colors.grey[300]),
            const SizedBox(width: 4),
            // Align Left
            _buildToolbarButton(icon: FontAwesomeIcons.alignLeft, isActive: _textAlign == TextAlign.left, onTap: () => _applyAlignment(TextAlign.left)),
            // Align Center
            _buildToolbarButton(icon: FontAwesomeIcons.alignCenter, isActive: _textAlign == TextAlign.center, onTap: () => _applyAlignment(TextAlign.center)),
            // Align Right
            _buildToolbarButton(icon: FontAwesomeIcons.alignRight, isActive: _textAlign == TextAlign.right, onTap: () => _applyAlignment(TextAlign.right)),
            const SizedBox(width: 4),
            Container(width: 1, height: 24, color: Colors.grey[300]),
            const SizedBox(width: 4),
            // Font Picker
            _buildToolbarButton(icon: FontAwesomeIcons.font, onTap: _showFontPicker),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelector() {
    final list = _isFrameMode ? _frameImages : _templates;
    final isLoading = _isFrameMode ? _isLoadingFrames : false;

    // Show empty state if no templates
    if (list.isEmpty && !isLoading) {
        return SizedBox(
            height: 100,
            child: Center(child: Text(_isFrameMode ? "No frame images found." : "No card images found."))
        );
    }

    return SizedBox(
      height: 90,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: list.length + 1,
        itemBuilder: (context, index) {
          if (index == list.length) {
            // Upload button placeholder (only for background mode?)
            // Or maybe "No Frame" button for frame mode
            if (_isFrameMode) {
               return _buildThumbItem(null, isNoFrame: true, isActive: _selectedFrame == null, onTap: () {
                 setState(() {
                    _selectedFrame = null;
                    _saveDraft();
                 });
               });
            }
            return _buildThumbItem(null, isUpload: true, onTap: _pickImage);
          }
          final idx = index;
          final imgPath = list[idx];
          final isActive = _isFrameMode ? (_selectedFrame == imgPath) : (_selectedImage == imgPath);
          
          return _buildThumbItem(imgPath, isActive: isActive, onTap: () {
            setState(() {
              if (_isFrameMode) {
                _selectedFrame = imgPath;
              } else {
                _selectedImage = imgPath;
              }
              _saveDraft();
            });
          });
        },
      ),
    );
  }

  Widget _buildThumbItem(String? imgUrl, {bool isActive = false, bool isUpload = false, bool isNoFrame = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? const Color(0xFFF29D86) : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  if (isActive) BoxShadow(color: const Color(0xFFF29D86).withOpacity(0.3), blurRadius: 8)
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: isUpload 
                  ? Container(
                      color: const Color(0xFFFFF0EB),
                      child: const Icon(Icons.add_photo_alternate, color: Color(0xFFF29D86), size: 30),
                    )
                  : isNoFrame
                    ? Container(
                        color: Colors.grey[200],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Icon(Icons.block, color: Colors.grey, size: 24),
                             Text("없음", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      )
                    : imgUrl != null ? _buildImage(imgUrl, fit: BoxFit.cover) : Container(color: Colors.grey[200]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker() {
    final bool isFooter = _isFooterActive;
    
    // Get current selection color logic
    final controller = isFooter ? _footerQuillController : _quillController;
    Color? currentColor;
    
    if (controller.selection.isCollapsed) {
       currentColor = isFooter ? _footerColor : _defaultColor;
    } else {
       final style = controller.getSelectionStyle();
       final colorAttr = style.attributes['color'];
       if (colorAttr != null && colorAttr.value != null) {
          try {
             String hex = colorAttr.value;
             if (hex.startsWith('#')) hex = hex.substring(1);
             currentColor = Color(int.parse("FF$hex", radix: 16));
          } catch (_) {}
       }
       currentColor ??= (isFooter ? _footerColor : _defaultColor);
    }

    final colors = [
      const Color(0xFF1A1A1A), const Color(0xFFD81B60), const Color(0xFFC2185B), const Color(0xFF8E24AA),
      const Color(0xFF512DA8), const Color(0xFF1976D2), const Color(0xFF0288D1), const Color(0xFF0097A7),
      const Color(0xFF00796B), const Color(0xFF388E3C), const Color(0xFF689F38), const Color(0xFFFBC02D),
      const Color(0xFFFFA000), const Color(0xFFF57C00), const Color(0xFFE64A19), const Color(0xFF5D4037),
      Colors.white, const Color(0xFFFFFFCC), const Color(0xFFFFCCCC), const Color(0xFFCCFFCC),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("글자색 선택 (${isFooter ? '푸터' : '내용'})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: colors.map((color) {
                  final isSelected = currentColor?.value == color.value;
                  return GestureDetector(
                    onTap: () {
                      _applyColor(color, isFooterOverride: isFooter);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: isSelected ? const Color(0xFFF29D86) : Colors.grey.withOpacity(0.3), width: isSelected ? 3 : 1),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolbarButton({required IconData icon, bool isActive = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEEF2FF) : Colors.white,
          border: Border.all(color: isActive ? const Color(0xFFF29D86) : const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Icon(icon, size: 16, color: isActive ? const Color(0xFFF29D86) : const Color(0xFF555555))),
      ),
    );
  }
  
  // Footer 입력 영역 제거됨


  // --- Sending Logic ---

  Future<void> _handleSend() async {
    if (_isSending) return;
    
    // 수신자가 없으면 초기화 (테스트용) - 삭제
    // if (_recipients.isEmpty) {
    //    for (int i = 1; i <= 20; i++) {
    //     _recipients.add("수신자 $i (010-0000-${i.toString().padLeft(4, '0')})");
    //   }
    // }

    // 1. 발송 전 이미지 생성 및 확인
    final savedPath = await _saveCardImage();
    
    if (savedPath == null) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("카드 이미지 생성 실패")),
        );
      }
      return;
    }

    if (!mounted) return;

    // 2. 발송 확인 다이얼로그 (이미지 미리보기)
    final confirmImage = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final transformationController = TransformationController();
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Color(0xFFF29D86), size: 28),
                      const SizedBox(width: 8),
                      Text(ref.watch(appStringsProvider).cardPreviewTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        ref.watch(appStringsProvider).cardPreviewDesc, 
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 14)
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F7FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFB2EBF2)),
                        ),
                        child: Text(
                          "${ref.watch(appStringsProvider).cardPreviewZoomHint}\n${ref.watch(appStringsProvider).cardPreviewCheckHint}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF006064), fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: GestureDetector(
                              onDoubleTap: () {
                                if (transformationController.value.getMaxScaleOnAxis() > 1.0) {
                                  transformationController.value = Matrix4.identity();
                                } else {
                                  // 중앙에서 확대
                                  transformationController.value = Matrix4.identity()
                                    ..translate(-100.0, -200.0)
                                    ..scale(2.0);
                                }
                              },
                              child: InteractiveViewer(
                                transformationController: transformationController,
                                minScale: 0.5,
                                maxScale: 4.0,
                                panEnabled: true,
                                scaleEnabled: true,
                                child: Image.file(
                                  File(savedPath),
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actions
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(ref.watch(appStringsProvider).cancel, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF29D86), 
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(ref.watch(appStringsProvider).cardPreviewConfirm),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmImage != true) return;

    if (!mounted) return;

    // 3. 수신자 관리 및 발송 팝업
    _showRecipientManagerDialog(savedPath);
  }

  void _showRecipientManagerDialog(String savedPath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RecipientManagerDialog(
        recipients: _recipients,
        savedPath: savedPath,
        messageContent: _message,
        database: ref.read(appDatabaseProvider),
        onRecipientsChanged: (updatedList) {
          setState(() {
            _recipients = updatedList;
          });
        },
      ),
    );
  }



  // --- Gallery Popup Logic ---

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final strings = context.strings;
        return Container(
        height: 500,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(strings.selectCategory, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: galleryCategories.length,
                itemBuilder: (context, index) {
                  final cat = galleryCategories[index];
                  // Skip system categories if needed, but let's show all for now except maybe Favorites if logic is complex
                  if (cat.id == 'my_photos' || cat.id == 'favorites' || cat.id == 'letters') {
                      // Option: Show disabled or implement logic for these
                      // For now, let's just skip "my_photos" as it needs device permission logic
                      if (cat.id == 'my_photos') return const SizedBox.shrink(); 
                  }
                  
                  // 카테고리 타이틀 다국어 처리
                  String localizedTitle;
                  switch (cat.id) {
                    case 'christmas': localizedTitle = strings.galleryChristmas; break;
                    case 'newyear': localizedTitle = strings.galleryNewYear; break;
                    case 'birthday': localizedTitle = strings.galleryBirthday; break;
                    case 'thanks': localizedTitle = strings.galleryThanks; break;
                    case 'motherDay': localizedTitle = strings.galleryMothersDay; break;
                    case 'teachersDay': localizedTitle = strings.galleryTeachersDay; break;
                    case 'tour': localizedTitle = strings.galleryTravel; break;
                    case 'hobby': localizedTitle = strings.galleryHobby; break;
                    case 'sports': localizedTitle = strings.gallerySports; break;
                    case 'favorites': localizedTitle = strings.contactsFavorites; break;
                    default: localizedTitle = cat.title;
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context); // Close category picker
                      _showImagePickerForCategory(cat); // Open image picker
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            color: cat.color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(cat.icon, color: cat.color, size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(localizedTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
      },
    );
  }

  void _showImagePickerForCategory(CategoryItem category) {
    // Filter templates for this category
    // NOTE: If _templates contains all assets, we filter by path.
    // If category is 'favorites', we might need to fetch from provider. Use simple path filter for now.
    
    List<String> categoryImages = [];
    if (category.id == 'favorites') {
        // Simple fallback if favorites not loaded here. 
        // In real app, we should use ref.read(favoritesProvider)
        // For now, let's show empty or implement provider read if possible.
        // Since we are inside ConsumerState, we can use ref!
        final favorites = ref.read(favoritesProvider);
        categoryImages = favorites.toList();
    } else {
        final targetPath = '/${category.id}/';
        categoryImages = _templates.where((path) => path.toLowerCase().contains(targetPath.toLowerCase())).toList();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 600,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                      _showCategoryPicker(); // Back to categories
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(category.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: categoryImages.isEmpty
                  ? const Center(child: Text("No images found"))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: categoryImages.length,
                      itemBuilder: (context, index) {
                        final imagePath = categoryImages[index];
                        final isFilePath = imagePath.startsWith('/') || imagePath.contains(':\\');
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImage = imagePath;
                              // 파일 경로인 경우 줌 리셋
                              if (isFilePath) {
                                _transformationController.value = Matrix4.identity();
                              }
                              _saveDraft();
                            });
                            Navigator.pop(context);
                            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: isFilePath 
                                ? Image.file(File(imagePath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]))
                                : Image.asset(imagePath, fit: BoxFit.cover),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecipientPicker() async {
    // Helper to extract phone from "Name (Phone)" format
    String getPhone(String r) {
      final match = RegExp(r'\(([^)]+)\)').firstMatch(r);
      return match?.group(1) ?? '';
    }

    // Current selected phones
    final currentPhones = _recipients.map(getPhone).toList();
    
    if (!mounted) return;

    final selected = await ContactPickerDialog.show(
      context,
      initialSelectedPhones: currentPhones,
    );
    
    if (selected != null) {
      setState(() {
        _recipients.clear();
        for (final contact in selected) {
          _recipients.add('${contact.name} (${formatPhone(contact.phone)})');
        }
      });
    }
  }


  Future<String?> _showManualRecipientDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("새 연락처 추가"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "이름",
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF29D86))),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "전화번호",
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF29D86))),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [PhoneInputFormatter()], 
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              
              if (name.isEmpty || phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("이름과 전화번호를 모두 입력해주세요.")),
                );
                return;
              }

              try {
                final db = ref.read(appDatabaseProvider);
                await db.insertContact(ContactsCompanion.insert(
                  name: name,
                  phone: phone,
                  isFavorite: Value(false),
                ));
                
                if (context.mounted) {
                  Navigator.pop(context, "$name ($phone)");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("연락처가 추가되었습니다.")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("추가 실패: $e")),
                  );
                }
              }
            },
            child: const Text("추가", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF29D86))),
          ),
        ],
      ),
    );
  }
}

class RecipientManagerDialog extends ConsumerStatefulWidget {
  final List<String> recipients;
  final String savedPath;
  final String messageContent; // Added message content
  final AppDatabase database;
  final Function(List<String>) onRecipientsChanged;

  const RecipientManagerDialog({
    Key? key,
    required this.recipients,
    required this.savedPath,
    required this.messageContent,
    required this.database,
    required this.onRecipientsChanged,
  }) : super(key: key);

  @override
  ConsumerState<RecipientManagerDialog> createState() => _RecipientManagerDialogState();
}

class _RecipientManagerDialogState extends ConsumerState<RecipientManagerDialog> {
  List<String> _pendingRecipients = [];
  bool _isSending = false;
  int _sentCount = 0;
  int _successCount = 0;
  int _failureCount = 0;
  bool _autoContinue = false;
  
  // Local list to manage UI before sync
  late List<String> _localRecipients;

  @override
  void initState() {
    super.initState();
    _localRecipients = List.from(widget.recipients);
    
    // 다이얼로그 열 때 키보드 숨기기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  /// 마우스 트래커 재진입 에러 방지: addPostFrameCallback 사용
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(fn);
    });
  }
  
  /// 전화번호 포맷팅 (010-1234-5678 형식)
  String _formatPhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 11) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    } else if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return phone; // 포맷팅 불가 시 원본 반환
  }
  
  /// 수동 연락처 추가 다이얼로그
  Future<String?> _showManualAddDialog(BuildContext parentContext) async {
    final textController = TextEditingController();
    return showDialog<String>(
      context: parentContext,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("새 연락처 추가"),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: "이름 010-0000-0000",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          autofocus: true,
          inputFormatters: [RecipientInputFormatter()],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, null),
            child: const Text("취소", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final raw = textController.text.trim();
              if (raw.isEmpty) {
                Navigator.pop(c, null);
                return;
              }
              final parsed = _parseRecipient(raw);
              if (parsed == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("형식이 올바르지 않습니다. 예: 홍길동 010-1234-5678")),
                );
                return;
              }
              Navigator.pop(c, parsed['display']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF29D86),
              foregroundColor: Colors.white,
            ),
            child: const Text("추가"),
          ),
        ],
      ),
    );
  }

  void _showResultPopup() {
    if (!mounted) return;
    final strings = ref.read(appStringsProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(strings.sendComplete),
        content: Text("${strings.sendResultSuccess(_successCount)}\n${strings.sendResultFailed(_failureCount)}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 팝업 닫기
              if (mounted) Navigator.pop(context); // 발송 관리 화면 닫기
            },
            child: Text(strings.ok),
          ),
        ],
      ),
    );
  }

  int _firstDigitIndex(String text) {
    for (int i = 0; i < text.length; i++) {
      final c = text.codeUnitAt(i);
      if (c >= 48 && c <= 57) return i;
    }
    return -1;
  }

  String _extractPhoneDigits(String text) {
    final dashed = _extractDashedPhone(text);
    if (dashed != null) return dashed.replaceAll('-', '');
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 11) return digits.substring(digits.length - 11);
    return digits;
  }

  String _formatPhoneDigits(String digits) {
    if (digits.isEmpty) return '';
    if (digits.length <= 3) return digits;
    if (digits.length <= 7) return '${digits.substring(0, 3)}-${digits.substring(3)}';
    final clipped = digits.length > 11 ? digits.substring(0, 11) : digits;
    final midLen = clipped.length == 10 ? 3 : 4;
    final first = clipped.substring(0, 3);
    final mid = clipped.substring(3, 3 + midLen);
    final last = clipped.substring(3 + midLen);
    if (last.isEmpty) return '$first-$mid';
    return '$first-$mid-$last';
  }

  Map<String, String>? _parseRecipient(String input) {
    final cleaned = input.replaceAll(RegExp(r'[()]'), '').trim();
    final digitIndex = _firstDigitIndex(cleaned);
    if (digitIndex <= 0) return null;
    final name = cleaned.substring(0, digitIndex).trimRight();
    if (name.isEmpty) return null;
    final digits = _extractPhoneDigits(cleaned.substring(digitIndex));
    if (digits.length != 11) return null;
    final dashed = _formatPhoneDigits(digits);
    if (!RegExp(r'^\d{2,3}-\d{3,4}-\d{4}$').hasMatch(dashed)) return null;
    return {
      'name': name,
      'digits': digits,
      'dashed': dashed,
      'display': '$name $dashed',
    };
  }

  String? _extractDashedPhone(String text) {
    final match = RegExp(r'\d{2,3}-\d{3,4}-\d{4}').firstMatch(text);
    return match?.group(0);
  }

  void _updateRecipients() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onRecipientsChanged(_localRecipients);
    });
  }

  void _addRecipient(String name) {
    _safeSetState(() {
      _localRecipients.add(name);
    });
    _updateRecipients();
  }

  void _removeRecipient(int index) {
    _safeSetState(() {
      final item = _localRecipients[index];
      _localRecipients.removeAt(index);
      if (_pendingRecipients.contains(item)) {
        _pendingRecipients.remove(item);
      }
    });
    _updateRecipients();
  }

  Future<void> _startSending() async {
    if (_isSending) return;
    
    // 1. 즉시 상태 업데이트
    setState(() {
      _isSending = true;
      if (_pendingRecipients.isEmpty) {
        _pendingRecipients = List.from(_localRecipients);
        _sentCount = 0;
        _successCount = 0;
        _failureCount = 0;
      }
    });
    
    // 2. MMS Intent 순차 발송
    await _executeMmsIntentSending();
  }
  
  /// MMS Intent 순차 발송 - 한 명씩 문자 앱을 열어 사용자가 발송
  Future<void> _executeMmsIntentSending() async {
    while (_pendingRecipients.isNotEmpty && _isSending) {
      if (!mounted) break;

      final item = _pendingRecipients.first;
      
      // 전화번호 추출
      String? phoneNumber = _extractDashedPhone(item);
      if (phoneNumber == null) {
        final parenMatch = RegExp(r'\(([^)]+)\)').firstMatch(item);
        String rawDigits = parenMatch != null ? (parenMatch.group(1) ?? item) : item;
        final digits = rawDigits.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.length >= 10 && digits.length <= 11) {
          phoneNumber = digits;
        }
      }
      
      if (phoneNumber != null) {
        debugPrint('[MMS발송] 수신자: $item, 전화번호: $phoneNumber');
        
        // MMS Intent로 문자 앱 열기
        final success = await MmsIntentService.sendMmsIntent(
          phoneNumber: phoneNumber,
          imagePath: widget.savedPath,
          message: widget.messageContent,
        );
        
        if (success) {
          // DB에 발송 기록 저장
          try {
            final phoneForDb = _formatPhoneDigits(phoneNumber.replaceAll('-', ''));
            var contact = await (widget.database.select(widget.database.contacts)
              ..where((t) => t.phone.equals(phoneForDb))).getSingleOrNull();
            
            if (contact == null) {
              // 연락처가 없으면 새로 생성
              String extractedName = item;
              final phoneIndex = item.indexOf(phoneForDb);
              if (phoneIndex > 0) {
                extractedName = item.substring(0, phoneIndex).replaceAll(RegExp(r'[()]'), '').trim();
              }
              if (extractedName.isEmpty) extractedName = phoneForDb;
              
              final newId = await widget.database.insertContact(ContactsCompanion(
                name: Value(extractedName),
                phone: Value(phoneForDb),
              ));
              
              // 새로 생성된 연락처로 History 저장
              await widget.database.insertHistory(HistoryCompanion(
                contactId: Value(newId),
                type: const Value('SENT'),
                message: Value(widget.messageContent),
                imagePath: Value(widget.savedPath),
                eventDate: Value(DateTime.now()),
              ));
              _successCount++;
            } else {
              await widget.database.insertHistory(HistoryCompanion(
                contactId: Value(contact.id),
                type: const Value('SENT'),
                message: Value(widget.messageContent),
                imagePath: Value(widget.savedPath),
                eventDate: Value(DateTime.now()),
              ));
              _successCount++;
            }
          } catch (e) {
            debugPrint('[MMS발송] DB 저장 오류: $e');
            _failureCount++;
          }
        } else {
          _failureCount++;
        }
        
        // 현재 수신자 완료
        _pendingRecipients.remove(item);
        _sentCount++;
        
        // UI 업데이트
        if (mounted) {
          setState(() {});
        }
        
        // 다음 수신자가 있으면 사용자에게 확인
        if (_pendingRecipients.isNotEmpty && _isSending) {
          // 다음 발송 대기 (사용자가 문자 앱에서 발송 후 돌아올 시간)
          if (!_autoContinue) {
            // 자동 계속이 아니면 중지
            _isSending = false;
            if (mounted) setState(() {});
            break;
          } else {
            // 자동 계속이면 잠시 대기 후 다음 발송
            await Future.delayed(const Duration(seconds: 2));
          }
        }
      } else {
        // 전화번호 추출 실패
        _pendingRecipients.remove(item);
        _failureCount++;
        _sentCount++;
        if (mounted) setState(() {});
      }
    }
    
    // 발송 완료
    if (mounted && _pendingRecipients.isEmpty) {
      _isSending = false;
      setState(() {
        _showResultPopup();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // 투명 배경으로 설정하여 Container의 radius 적용
      insetPadding: const EdgeInsets.all(16),
      child: RepaintBoundary(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.85,
          constraints: const BoxConstraints(maxWidth: 500), // 최대 너비 제한
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24), // 더 둥근 모서리
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF29D86), Color(0xFFE88B70)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_alt_rounded, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(ref.watch(appStringsProvider).sendManagerTitle, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (_isSending)
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.25), 
                         borderRadius: BorderRadius.circular(30),
                         border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                       ),
                       child: Row(
                         children: [
                           const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                           const SizedBox(width: 8),
                           Text(ref.watch(appStringsProvider).sendProgress, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                         ],
                       ),
                     ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: const Color(0xFFF9F9F9), // 리스트 배경색 약간 어둡게
                child: Column(
                  children: [
                    // Top Info & Add Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(ref.watch(appStringsProvider).totalPersonCount(_localRecipients.length), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF5D4037))),
                          ),
                          if (!_isSending)
                          ElevatedButton.icon(
                            onPressed: () async {
                               // 공통 연락처 선택 다이얼로그 사용
                               final selected = await ContactPickerDialog.show(context);
                               if (selected != null && selected.isNotEmpty) {
                                 for (final contact in selected) {
                                   final formatted = "${contact.name} (${_formatPhoneNumber(contact.phone)})";
                                   if (!_localRecipients.any((r) => r.contains(contact.phone.replaceAll('-', '')))) {
                                     _addRecipient(formatted);
                                   }
                                 }
                               }
                            },
                            icon: const Icon(Icons.person_add, size: 18),
                            label: Text(ref.watch(appStringsProvider).cardEditorAddRecipient),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFF29D86),
                              elevation: 0,
                              side: const BorderSide(color: Color(0xFFF29D86)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // List
                    Expanded(
                      child: IgnorePointer(
                        ignoring: _isSending,
                        child: ListView.separated(
                          physics: _isSending ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          itemCount: _localRecipients.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final recipient = _localRecipients[index];
                            bool isSent = false;
                            if (_isSending || _sentCount > 0) {
                                isSent = !_pendingRecipients.contains(recipient);
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isSent ? Colors.green.withOpacity(0.1) : const Color(0xFFFFF0EB),
                                  child: Icon(Icons.person, size: 20, color: isSent ? Colors.green : const Color(0xFFF29D86)),
                                ),
                                title: Text(
                                  recipient, 
                                  style: TextStyle(
                                    color: isSent ? Colors.grey : const Color(0xFF333333), 
                                    decoration: isSent ? TextDecoration.lineThrough : null,
                                    fontWeight: isSent ? FontWeight.normal : FontWeight.w500,
                                  ),
                                ),
                                trailing: !_isSending
                                  ? IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFFF8A80)),
                                      onPressed: () => _removeRecipient(index),
                                    )
                                  : (isSent ? const Icon(Icons.check_circle, color: Colors.green) : null),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    if (_isSending || _sentCount > 0)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("발송 진행률", style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                Text("$_sentCount / ${_localRecipients.length}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFF29D86))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _localRecipients.isEmpty ? 0 : (_sentCount / _localRecipients.length),
                                backgroundColor: Colors.grey[200],
                                color: const Color(0xFFF29D86),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFE082), width: 1),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Color(0xFFFFA000), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ref.watch(appStringsProvider).sendSpamWarning,
                                style: TextStyle(fontSize: 13, color: Colors.brown[700], height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
                ],
              ),
              child: Row(
                children: [
                    Expanded(
                      child: InkWell(
                        onTap: _isSending ? null : () {
                           _safeSetState(() => _autoContinue = !_autoContinue);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _autoContinue,
                                  onChanged: _isSending ? null : (v) => _safeSetState(() => _autoContinue = v!),
                                  activeColor: const Color(0xFFF29D86),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  ref.watch(appStringsProvider).sendAutoResume, 
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 공유 버튼 - 아이콘만 표시
                    IconButton(
                      onPressed: _isSending ? null : () async {
                        // 소셜 미디어 공유 다이얼로그 표시
                        final platformId = await SocialShareService.showShareDialog(context, strings: ref.read(appStringsProvider));
                        if (platformId != null) {
                          await SocialShareService.shareImage(
                            imagePath: widget.savedPath,
                            platformId: platformId,
                            text: widget.messageContent.isNotEmpty ? widget.messageContent : '마음을 전합니다 💝',
                          );
                        }
                      },
                      icon: const Icon(Icons.share, size: 22),
                      style: IconButton.styleFrom(
                        foregroundColor: const Color(0xFF1877F2),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF1877F2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(10),
                      ),
                      tooltip: '공유',
                    ),
                    const SizedBox(width: 8),
                    // 닫기 버튼 - 아이콘만 표시  
                    IconButton(
                      onPressed: _isSending ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 22),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(10),
                      ),
                      tooltip: '닫기',
                    ),
                    const SizedBox(width: 8),
                    // 발송 버튼
                    if (_isSending)
                      ElevatedButton.icon(
                         onPressed: () {
                           _safeSetState(() => _isSending = false);
                         },
                         icon: const Icon(Icons.stop_circle_outlined, size: 20),
                         label: Text(ref.watch(appStringsProvider).sendStop),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.white,
                           foregroundColor: Colors.red,
                           elevation: 0,
                           side: const BorderSide(color: Colors.red),
                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                         ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_isSending) return;
                          _startSending();
                        },
                        icon: Icon(
                          _sentCount > 0 && _pendingRecipients.isNotEmpty ? Icons.play_arrow_rounded : Icons.send_rounded, 
                          size: 20
                        ),
                        label: Text(
                          _sentCount > 0 && _pendingRecipients.isNotEmpty 
                            ? ref.watch(appStringsProvider).sendContinue
                            : ref.watch(appStringsProvider).sendStart,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF29D86),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

}

class RecipientInputFormatter extends TextInputFormatter {
  int _firstDigitIndex(String text) {
    for (int i = 0; i < text.length; i++) {
      final c = text.codeUnitAt(i);
      if (c >= 48 && c <= 57) return i;
    }
    return -1;
  }

  String _extractPhoneDigits(String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 11) return digits.substring(0, 11);
    return digits;
  }

  String _formatPhoneDigits(String digits) {
    if (digits.isEmpty) return '';
    if (digits.length <= 3) return digits;
    if (digits.length <= 7) return '${digits.substring(0, 3)}-${digits.substring(3)}';
    final clipped = digits.length > 11 ? digits.substring(0, 11) : digits;
    final midLen = clipped.length == 10 ? 3 : 4;
    final first = clipped.substring(0, 3);
    final mid = clipped.substring(3, 3 + midLen);
    final last = clipped.substring(3 + midLen);
    if (last.isEmpty) return '$first-$mid';
    return '$first-$mid-$last';
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final cleaned = newValue.text.replaceAll(RegExp(r'[()]'), '');
    
    // 숫자가 없는 경우 (이름만 입력 중인 경우)
    final digitIndex = _firstDigitIndex(cleaned);
    if (digitIndex == -1) {
      // 괄호 등 변경사항이 있다면 반영하되, 없다면 newValue 그대로 반환 (한글 조합 유지)
      if (cleaned != newValue.text) {
        return newValue.copyWith(
          text: cleaned,
          selection: TextSelection.collapsed(offset: cleaned.length),
        );
      }
      return newValue; 
    }

    final name = cleaned.substring(0, digitIndex).trimRight();
    final digits = _extractPhoneDigits(cleaned.substring(digitIndex));
    final dashed = _formatPhoneDigits(digits);

    final resultText = name.isEmpty ? dashed : '$name $dashed';
    
    // 결과가 같다면 newValue 반환 (커서/조합 상태 보존)
    if (resultText == newValue.text) {
      return newValue;
    }

    return newValue.copyWith(
      text: resultText,
      selection: TextSelection.collapsed(offset: resultText.length),
    );
  }
}



class BubbleBorder extends OutlinedBorder {
  final double arrowHeight;
  final double arrowWidth;
  final double borderRadius;
  final String tailPosition; // 'left', 'center', 'right'

  const BubbleBorder({
    BorderSide side = BorderSide.none,
    this.arrowHeight = 10.0,
    this.arrowWidth = 15.0,
    this.borderRadius = 12.0,
    this.tailPosition = 'right',
  }) : super(side: side);

  @override
  BubbleBorder copyWith({BorderSide? side, double? arrowHeight, double? arrowWidth, double? borderRadius, String? tailPosition}) {
    return BubbleBorder(
      side: side ?? this.side,
      arrowHeight: arrowHeight ?? this.arrowHeight,
      arrowWidth: arrowWidth ?? this.arrowWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      tailPosition: tailPosition ?? this.tailPosition,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect.deflate(side.width), textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // The main body rect (excluding the tail height at the bottom)
    final r = Rect.fromPoints(rect.topLeft, rect.bottomRight - Offset(0, arrowHeight));
    
    double arrowX;
    if (tailPosition == 'left') {
      arrowX = r.left + 30.0;
    } else if (tailPosition == 'center') {
      arrowX = r.center.dx;
    } else { // right
      arrowX = r.right - 30.0;
    }
    
    // Clamp arrowX to ensure it doesn't overlap with corners
    final double minArrowX = r.left + borderRadius + arrowWidth / 2.0;
    final double maxArrowX = r.right - borderRadius - arrowWidth / 2.0;
    
    if (minArrowX > maxArrowX) {
        arrowX = r.center.dx;
    } else {
        arrowX = arrowX.clamp(minArrowX, maxArrowX);
    }

    final path = Path();
    
    // Top Left Corner
    path.moveTo(r.left, r.top + borderRadius);
    path.arcToPoint(Offset(r.left + borderRadius, r.top), radius: Radius.circular(borderRadius), clockwise: true);
    
    // Top Edge
    path.lineTo(r.right - borderRadius, r.top);
    
    // Top Right Corner
    path.arcToPoint(Offset(r.right, r.top + borderRadius), radius: Radius.circular(borderRadius), clockwise: true);
    
    // Right Edge
    path.lineTo(r.right, r.bottom - borderRadius);
    
    // Bottom Right Corner
    path.arcToPoint(Offset(r.right - borderRadius, r.bottom), radius: Radius.circular(borderRadius), clockwise: true);
    
    // Bottom Edge (Right to Left) with Tail
    path.lineTo(arrowX + arrowWidth / 2, r.bottom);
    path.lineTo(arrowX, r.bottom + arrowHeight); // Tail Tip
    path.lineTo(arrowX - arrowWidth / 2, r.bottom);
    path.lineTo(r.left + borderRadius, r.bottom);
    
    // Bottom Left Corner
    path.arcToPoint(Offset(r.left, r.bottom - borderRadius), radius: Radius.circular(borderRadius), clockwise: true);
    
    // Left Edge
    path.close(); 
    
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    final path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, side.toPaint());
  }

  @override
  ShapeBorder scale(double t) {
    return BubbleBorder(
      side: side.scale(t),
      arrowHeight: arrowHeight * t,
      arrowWidth: arrowWidth * t,
      borderRadius: borderRadius * t,
      tailPosition: tailPosition,
    );
  }
}

class HeartBorder extends OutlinedBorder {
  const HeartBorder({BorderSide side = BorderSide.none}) : super(side: side);

  @override
  HeartBorder copyWith({BorderSide? side}) {
    return HeartBorder(side: side ?? this.side);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect.deflate(side.width), textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // 1:1 비율 유지하면서 텍스트(rect)를 포함하도록 크기 계산
    // 텍스트 영역을 포함하는 가장 작은 1:1 사각형 계산 (단, width/height 중 큰 값 기준)
    // 하지만 하트 모양 특성상 위쪽이 넓고 아래가 좁으므로 여백을 더 줘야 함
    
    // 단순하게 width, height 중 큰 값을 기준으로 정사각형을 만들고, 
    // 그 정사각형을 rect의 중심에 배치
    final double maxSize = math.max(rect.width, rect.height);
    final double size = maxSize * 1.2; // 여백 확보
    
    final double width = size;
    final double height = size; // 1:1 ratio
    
    // rect 중심
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    
    final double x = cx - width / 2;
    final double y = cy - height / 2;

    final path = Path();
    // Simplified Heart Shape
    path.moveTo(x + width * 0.5, y + height * 0.25);
    path.cubicTo(x + width * 0.1, y, x - width * 0.1, y + height * 0.5, x + width * 0.5, y + height);
    path.moveTo(x + width * 0.5, y + height * 0.25);
    path.cubicTo(x + width * 0.9, y, x + width * 1.1, y + height * 0.5, x + width * 0.5, y + height);
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    final path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, side.toPaint());
  }

  @override
  ShapeBorder scale(double t) {
    return HeartBorder(side: side.scale(t));
  }
}

class CustomStarBorder extends OutlinedBorder {
  final int points;
  final double innerRadiusRatio;

  const CustomStarBorder({
    BorderSide side = BorderSide.none,
    this.points = 5,
    this.innerRadiusRatio = 0.4,
  }) : super(side: side);

  @override
  CustomStarBorder copyWith({BorderSide? side, int? points, double? innerRadiusRatio}) {
    return CustomStarBorder(
      side: side ?? this.side,
      points: points ?? this.points,
      innerRadiusRatio: innerRadiusRatio ?? this.innerRadiusRatio,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect.deflate(side.width), textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // 1:1 비율 유지
    final double maxSize = math.max(rect.width, rect.height);
    final double size = maxSize * 1.3; // 별은 뾰족하므로 여백 더 필요
    
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    
    // 외접원 반지름
    final double outerRadius = size / 2;
    final double innerRadius = outerRadius * innerRadiusRatio;

    final path = Path();
    double angle = -math.pi / 2;
    final double angleStep = math.pi / points;

    path.moveTo(
      cx + outerRadius * math.cos(angle),
      cy + outerRadius * math.sin(angle),
    );

    for (int i = 0; i < points; i++) {
      angle += angleStep;
      path.lineTo(
        cx + innerRadius * math.cos(angle),
        cy + innerRadius * math.sin(angle),
      );
      angle += angleStep;
      path.lineTo(
        cx + outerRadius * math.cos(angle),
        cy + outerRadius * math.sin(angle),
      );
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    final path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, side.toPaint());
  }

  @override
  ShapeBorder scale(double t) {
    return CustomStarBorder(
      side: side.scale(t),
      points: points,
      innerRadiusRatio: innerRadiusRatio,
    );
  }
}

class DiamondBorder extends OutlinedBorder {
  const DiamondBorder({BorderSide side = BorderSide.none}) : super(side: side);

  @override
  DiamondBorder copyWith({BorderSide? side}) => DiamondBorder(side: side ?? this.side);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect.deflate(side.width), textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // Gem (Diamond Icon) Shape
    //   _______  (top width = 50% of full width)
    //  /       \ (height = 30% of full height)
    //  \       /
    //   \     /  (height = 70% of full height)
    //    \   /
    //     \ /
    
    // 비율 유지하지 않고 꽉 채우되 Gem 모양으로 (사용자가 아이콘 같은 모양을 원함)
    // 하지만 "아이콘의 비율을 그대로 만들어줘" 라고 했으므로 1:1 비율 유지 필요할 수도?
    // "하트나 원형, 별 모양들은... 비율 유지" 라고 했고 다이아몬드는 별도 언급 없었으나 
    // "다이아 아이콘 같은 모양" 이라 했으므로 비율 유지하는게 안전함.
    
    final double maxSize = math.max(rect.width, rect.height);
    final double size = maxSize * 1.1;
    
    final double width = size;
    final double height = size;
    
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    
    final double left = cx - width / 2;
    final double right = cx + width / 2;
    final double top = cy - height / 2;
    final double bottom = cy + height / 2;
    
    // Gem shape
    final double topFlatWidth = width * 0.5;
    final double midY = top + height * 0.25; // 상단 25% 지점이 가장 넓은 부분
    
    final path = Path();
    path.moveTo(cx - topFlatWidth / 2, top); // Top Left of flat top
    path.lineTo(cx + topFlatWidth / 2, top); // Top Right of flat top
    path.lineTo(right, midY); // Mid Right
    path.lineTo(cx, bottom); // Bottom Point
    path.lineTo(left, midY); // Mid Left
    path.close();
    
    // Facet lines (optional detailed look) - let's keep outline simple for border
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(getOuterPath(rect, textDirection: textDirection), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) => DiamondBorder(side: side.scale(t));
}

class EnclosingCircleBorder extends OutlinedBorder {
  const EnclosingCircleBorder({BorderSide side = BorderSide.none}) : super(side: side);

  @override
  EnclosingCircleBorder copyWith({BorderSide? side}) => EnclosingCircleBorder(side: side ?? this.side);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect.deflate(side.width), textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // 텍스트를 모두 포함하는 가장 작은 원 (외접원)
    // 직사각형의 외접원 지름 = sqrt(w^2 + h^2)
    final double diameter = math.sqrt(rect.width * rect.width + rect.height * rect.height);
    // 여백 약간 추가
    final double size = diameter * 1.05;
    
    return Path()..addOval(Rect.fromCenter(center: rect.center, width: size, height: size));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(getOuterPath(rect, textDirection: textDirection), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) => EnclosingCircleBorder(side: side.scale(t));
}

class HexagonBorder extends OutlinedBorder {
  const HexagonBorder({BorderSide side = BorderSide.none}) : super(side: side);

  @override
  HexagonBorder copyWith({BorderSide? side}) => HexagonBorder(side: side ?? this.side);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect.deflate(side.width), textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    final width = rect.width;
    final height = rect.height;
    final x = rect.left;
    final y = rect.top;
    
    path.moveTo(x + width * 0.25, y);
    path.lineTo(x + width * 0.75, y);
    path.lineTo(x + width, y + height * 0.5);
    path.lineTo(x + width * 0.75, y + height);
    path.lineTo(x + width * 0.25, y + height);
    path.lineTo(x, y + height * 0.5);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(getOuterPath(rect, textDirection: textDirection), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) => HexagonBorder(side: side.scale(t));
}

class CloudBorder extends OutlinedBorder {
  const CloudBorder({BorderSide side = BorderSide.none}) : super(side: side);

  @override
  CloudBorder copyWith({BorderSide? side}) => CloudBorder(side: side ?? this.side);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect.deflate(side.width), textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // Cloud Icon Shape: Flat bottom with rounded corners, and puffy top.
    // Ensure 1.5 aspect ratio to look like the icon
    final double maxSize = math.max(rect.width, rect.height);
    // Expand size to ensure text fits
    final double width = maxSize * 1.4;
    final double height = width * 0.65; // Approx cloud aspect ratio
    
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    
    // Cloud bounding box
    final double left = cx - width / 2;
    final double right = cx + width / 2;
    final double top = cy - height / 2;
    final double bottom = cy + height / 2;
    
    // Geometry based on standard cloud icon
    final double bottomFlatY = bottom;
    final double sideRadius = height * 0.25; // Radius for bottom corners
    final double topRadius = height * 0.35; // Radius for top puff
    
    final path = Path();
    
    // Start at bottom-left corner (start of flat line)
    path.moveTo(left + sideRadius, bottomFlatY);
    
    // Bottom flat line to bottom-right corner
    path.lineTo(right - sideRadius, bottomFlatY);
    
    // Bottom-right corner arc (up to side)
    path.arcToPoint(Offset(right, bottomFlatY - sideRadius), radius: Radius.circular(sideRadius), clockwise: false);
    
    // Right Puff (Small)
    // From (right, bottom-sideRadius) to somewhere up
    // Actually, let's use circle centers for cleaner arcs.
    
    // Re-approaching with Circle Centers to emulate the icon exactly:
    // 1. Bottom-Left Circle
    // 2. Top-Left (Main) Circle
    // 3. Top-Right Circle
    // 4. Bottom-Right Circle
    // But the icon has a FLAT bottom.
    
    // Improved Path Construction:
    // 1. Flat bottom line
    // 2. Right arc (semicircle-ish)
    // 3. Top right arc
    // 4. Top left arc
    // 5. Left arc
    
    final double r1 = height * 0.25; // Side radius
    final double r2 = height * 0.38; // Top big radius
    
    // Bottom Line
    path.moveTo(left + r1, bottom);
    path.lineTo(right - r1, bottom);
    
    // Right Arc (Small) - goes from bottom to mid-right
    // Center at (right - r1, bottom - r1)
    path.arcTo(
      Rect.fromCircle(center: Offset(right - r1, bottom - r1), radius: r1),
      math.pi / 2, // Start at bottom (90 deg)
      -math.pi,    // Sweep 180 deg counter-clockwise to top
      false
    );
    
    // Now at (right - r1, bottom - 2*r1)
    // We need a top puff.
    // Let's create a big arc on top.
    // Center roughly at (cx, top + r2)
    // But let's just use cubicTo for smooth connection if circles don't align perfectly.
    
    // Alternative: explicit arcs for "Cloud Queue" look
    // The icon is basically a big circle on top-left, smaller on top-right, connected to a flat rounded rect base.
    
    // Let's use a standard vector path approximation
    final p = Path();
    p.moveTo(left + width * 0.15, bottom);
    p.lineTo(right - width * 0.15, bottom);
    
    // Right rounded corner + side
    p.cubicTo(right + width * 0.05, bottom, right + width * 0.05, bottom - height * 0.5, right - width * 0.1, bottom - height * 0.5);
    
    // Top right bump
    p.cubicTo(right, top, cx + width * 0.1, top, cx, top + height * 0.1);
    
    // Top left bump (Main)
    p.cubicTo(cx - width * 0.1, top - height * 0.1, left, top, left + width * 0.1, bottom - height * 0.4);
    
    // Left side
    p.cubicTo(left - width * 0.05, bottom - height * 0.4, left - width * 0.05, bottom, left + width * 0.15, bottom);
    
    p.close();
    return p;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(getOuterPath(rect, textDirection: textDirection), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) => CloudBorder(side: side.scale(t));
}

// 가로 스크롤 애니메이션 텍스트 위젯
class _MarqueeText extends StatefulWidget {
  final String text;
  final VoidCallback? onComplete;
  final int durationSeconds;
  
  const _MarqueeText({
    required this.text, 
    this.onComplete,
    this.durationSeconds = 12,
  });

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasCompleted = false;
  double _textWidth = 0;
  double _containerWidth = 0;

  @override
  void initState() {
    super.initState();
    
    // 텍스트 너비 계산
    _textWidth = _calculateTextWidth(widget.text, 12.0);
    
    // 임시 containerWidth 가정 (실제 값은 build에서 업데이트됨)
    // 모바일 화면 평균 너비 ~350px 가정
    final estimatedContainerWidth = 350.0;
    final estimatedTotalDistance = estimatedContainerWidth + _textWidth + (estimatedContainerWidth / 2);
    
    // 애니메이션 시간: 이동 거리에 비례 (40px/초 속도)
    // 마지막 글자가 중앙까지 도달하는 데 충분한 시간 확보
    final calculatedDuration = (estimatedTotalDistance / 40).clamp(8.0, 60.0).toInt();
    final duration = widget.durationSeconds > 0 ? widget.durationSeconds : calculatedDuration;
    
    _controller = AnimationController(
      duration: Duration(seconds: duration),
      vsync: this,
    );
    
    // 0.0 (오른쪽 끝) ~ 1.0 (왼쪽 끝)
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    
    // 한 바퀴 돌면 콜백 호출
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_hasCompleted) {
        _hasCompleted = true;
        widget.onComplete?.call();
      }
    });
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  double _calculateTextWidth(String text, double fontSize) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _containerWidth = constraints.maxWidth;
        // 마지막 글자가 화면 중앙(containerWidth/2)까지 이동하도록 설정
        final totalDistance = _containerWidth + _textWidth + (_containerWidth / 2);
        
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // 오른쪽 끝에서 시작해서 왼쪽으로 이동 (마지막 글자가 중앙까지)
            final offset = _containerWidth - (_animation.value * totalDistance);
            
            return Align(
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              ),
            );
          },
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        );
      },
    );
  }
}
