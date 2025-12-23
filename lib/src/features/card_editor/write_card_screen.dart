import 'dart:convert';
import 'dart:io';
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
import '../gallery/gallery_data.dart'; // Import gallery data
import '../gallery/favorites_provider.dart'; // Import favorites provider
import 'package:drift/drift.dart' hide Column;
import '../database/app_database.dart';
import '../database/database_provider.dart';
import 'package:flutter_quill/flutter_quill.dart'; // Rich Text Editor
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_selector/file_selector.dart'; // File Picker

class WriteCardScreen extends ConsumerStatefulWidget {
  final String? initialImage;
  const WriteCardScreen({super.key, this.initialImage});

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

  // Text Box Style State (글상자 스타일)
  Color _boxColor = Colors.white;
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
    _loadTemplateAssets();
    _loadFrameAssets();
    _loadDraft(); // Load full draft including footer

    // 더미 수신자 데이터 생성 (20명)
    for (int i = 1; i <= 20; i++) {
      _recipients.add("수신자 $i 010-0000-${i.toString().padLeft(4, '0')}");
    }
    _pendingRecipients = List.from(_recipients);
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


  // Fallback for legacy footer save
  Future<void> _loadSavedFooter() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFooter = prefs.getString('footer_text');
    if (savedFooter != null && savedFooter.isNotEmpty && mounted) {
      _updateFooterController(savedFooter);
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
    // 저장 이름 기본값 로직 수정: 첫 줄만 추출
    String defaultName = "제목 없음";
    if (_message.trim().isNotEmpty) {
      defaultName = _message.trim().split('\n').first;
      if (defaultName.length > 20) defaultName = "${defaultName.substring(0, 20)}...";
    }
    final nameController = TextEditingController(text: defaultName);
    
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("카드 저장"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "저장할 이름"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("저장")),
        ],
      ),
    );

    if (proceed != true) return;

    // 배경 이미지 확대/이동 상태가 있으면 캡처하여 저장
    String imagePathToSave = _selectedImage;
    if (_transformationController.value != Matrix4.identity()) {
       final bgBytes = await _captureBackground();
       if (bgBytes != null) {
          try {
            final directory = await getApplicationDocumentsDirectory();
            final fileName = 'card_bg_${DateTime.now().millisecondsSinceEpoch}.png';
            final savedPath = '${directory.path}/$fileName';
            final file = File(savedPath);
            await file.writeAsBytes(bgBytes);
            imagePathToSave = savedPath;
          } catch (e) {
            print("배경 이미지 저장 실패: $e");
          }
       }
    }

    final db = ref.read(appDatabaseProvider);
    final html = _convertToHtml(_message);
    final footerJson = jsonEncode(_footerQuillController.document.toDelta().toJson());
    
    final newId = await db.insertSavedCard(SavedCardsCompanion.insert(
      name: Value(nameController.text),
      htmlContent: html,
      footerText: Value(footerJson),
      imagePath: Value(imagePathToSave),
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
                       const Text("저장된 카드 목록", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                       IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                     ],
                   ),
                  const Divider(),
                  Expanded(
                    child: savedCards.isEmpty 
                      ? const Center(child: Text("저장된 메시지가 없습니다.", style: TextStyle(color: Colors.grey)))
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
      _currentCardId = card.id; // Set current card ID
      // _footerText = card.footerText ?? ""; // Deprecated, use controller
      if (card.imagePath != null) {
        _selectedImage = card.imagePath!;
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
                  const Text("글상자 스타일", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                              decoration: BoxDecoration(
                                color: _boxColor.withOpacity(_boxOpacity),
                                borderRadius: BorderRadius.circular(_boxRadius),
                                border: _hasBorder 
                                  ? Border.all(color: _borderColor.withOpacity(0.5), width: _borderWidth)
                                  : null,
                              ),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Preview Text\n스타일 미리보기",
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
                                        "보낸 사람",
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
                          // 1. 배경 색상
                          const Text("배경 색상", style: TextStyle(fontWeight: FontWeight.w600)),
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
                              const Text("투명도", style: TextStyle(fontWeight: FontWeight.w600)),
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
                              const Text("둥근 모서리", style: TextStyle(fontWeight: FontWeight.w600)),
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
                              const Text("테두리", style: TextStyle(fontWeight: FontWeight.w600)),
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

                          const Divider(height: 30),

                          // 5. 푸터 스타일 (Footer Style)
                          const Text("푸터 (보낸 사람) 배경 스타일", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          
                          // 안내 문구
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                SizedBox(width: 8),
                                Expanded(child: Text("글자 크기와 색상은 푸터를 선택 후 상단 툴바에서 변경하세요.", style: TextStyle(fontSize: 12, color: Colors.grey))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 푸터 배경 색상
                          const Text("배경 색상", style: TextStyle(fontWeight: FontWeight.w600)),
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
                              const Text("배경 투명도", style: TextStyle(fontWeight: FontWeight.w600)),
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
                              const Text("배경 둥근 모서리", style: TextStyle(fontWeight: FontWeight.w600)),
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
                              child: const Text("완료"),
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

  // 이미지 캡처 함수 - 배경이미지 + 글씨박스 + 글씨만 캡처
  Future<Uint8List?> _captureCardImage() async {
    try {
      RenderRepaintBoundary boundary = _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("캡처 오류: $e");
      return null;
    }
  }
  
  // 캡처한 이미지 저장
  Future<String?> _saveCardImage() async {
    if (!mounted) return null;

    // 캡쳐 전에 UI 요소 숨기기
    setState(() => _isCapturing = true);
    
    // UI 업데이트 및 리페인트를 위해 충분히 대기
    await Future.delayed(const Duration(milliseconds: 500));

    final imageBytes = await _captureCardImage();

    // 캡쳐 후 UI 복구
    if (mounted) {
      setState(() => _isCapturing = false);
    }

    if (imageBytes == null) return null;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'card_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);
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

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF9),
      body: Stack(
        children: [
          // Background/Content - 상단에 붙도록 padding 제거
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. Card Preview (캡쳐 가능 영역) - 상단에 붙음
                  _buildCardPreview(),
                  
                  // 2. Toolbar (이미지와 썸네일 사이)
                  _buildToolbar(),
                  
                  // 3. Template Selector (Background or Frame)
                  _buildTemplateSelector(),
                  
                  // 4. Footer Input (보낸 사람 입력) - Removed as per user request
                  const SizedBox(height: 40), // Extra spacing instead

                ],
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
                
                // 배경 버튼 (상단 고정)
                GestureDetector(
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
                      color: !_isFrameMode ? const Color(0xFFF29D86) : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image, color: !_isFrameMode ? Colors.white : const Color(0xFFF29D86), size: 18),
                        const SizedBox(width: 6),
                        Text("배경", style: TextStyle(color: !_isFrameMode ? Colors.white : const Color(0xFF555555), fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
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
                const SizedBox(width: 8),
                // 글상자 스타일 버튼 (상단 고정)
                GestureDetector(
                  onTap: _showBoxStylePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.style, color: Color(0xFFF29D86), size: 18),
                        SizedBox(width: 6),
                        Text("글상자", style: TextStyle(color: Color(0xFF555555), fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
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
          
          // 하단 고정 전송 버튼 및 수신자 목록
          Positioned(
            bottom: 20,
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
                    // 중앙 정렬을 위한 Spacer (왼쪽)
                    const SizedBox(width: 80), 

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
                    Container(
                      width: 80,
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("발송대상", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(
                            "$_sentCount / ${_recipients.length}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF29D86)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
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
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      _transformationController.value = Matrix4.identity()..scale(2.0);
    }
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
              onHorizontalDragEnd: _handleSwipeNavigation,
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
                              minScale: 1.0,
                              maxScale: 4.0,
                              panEnabled: true,
                              scaleEnabled: true,
                              child: _buildImage(_selectedImage, fit: BoxFit.cover),
                            ),
                          ),
                        ),

                        // 2. Draggable Text Area (위치 유지됨)
                        Positioned.fill(
                          child: Center(
                            child: Transform.translate(
                              offset: _dragOffset,
                              child: GestureDetector(
                                onPanUpdate: (details) {
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
                                onPanEnd: (details) {
                                  _saveDraft();
                                },
                                onTap: () {
                                  _editorFocusNode.requestFocus();
                                  setState(() {
                                    _isFooterActive = false;
                                  });
                                  _updateToolbarState();
                                  _saveDraft();
                                },
                                child: Container(
                                  key: _textBoxKey,
                                  width: MediaQuery.of(context).size.width * 0.78,
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.width * 0.90 * 0.85,
                                ),
                                padding: const EdgeInsets.fromLTRB(20, 20, 30, 20),
                                decoration: BoxDecoration(
                                  // 프레임 이미지가 있으면 이미지 배경, 없으면 사용자 정의 스타일
                                  color: _selectedFrame != null ? null : _boxColor.withOpacity(_boxOpacity),
                                  image: _selectedFrame != null ? DecorationImage(
                                    image: AssetImage(_selectedFrame!),
                                    fit: BoxFit.fill, // 프레임은 늘려서 채움
                                  ) : null,
                                  borderRadius: BorderRadius.circular(_selectedFrame != null ? 0 : _boxRadius),
                                  border: _selectedFrame == null && _hasBorder
                                      ? Border.all(
                                          color: !_isFooterActive ? const Color(0xFFF29D86) : _borderColor.withOpacity(0.5), 
                                          width: !_isFooterActive ? 2.0 : _borderWidth
                                        )
                                      : (!_isFooterActive && !_isCapturing) 
                                          ? Border.all(color: const Color(0xFFF29D86), width: 2.0) // Visual indicator when active
                                          : Border.all(color: Colors.transparent, width: 2.0),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // 1. 글자수 & AI 버튼 (상단 오른쪽 정렬) - 캡쳐 시 숨김
                                        if (!_isCapturing)
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding: const EdgeInsets.only(bottom: 8.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.7),
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
                                                        color: Colors.white.withOpacity(0.7),
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
                                          ),

                                        // 2. 편집 가능한 QuillEditor
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context).size.width * 0.5,
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
    
    // 수신자가 없으면 초기화 (테스트용)
    if (_recipients.isEmpty) {
       for (int i = 1; i <= 20; i++) {
        _recipients.add("수신자 $i (010-0000-${i.toString().padLeft(4, '0')})");
      }
    }

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
                      const Text("카드 이미지 확인", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "수신자들에게 발송될 최종 이미지입니다.\n이대로 발송하시겠습니까?", 
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14)
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F7FA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFB2EBF2)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, size: 14, color: Color(0xFF0097A7)),
                            SizedBox(width: 6),
                            Text(
                              "💡 더블 클릭: 확대/축소  |  드래그: 이동",
                              style: TextStyle(fontSize: 12, color: Color(0xFF006064), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[100],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: GestureDetector(
                              onDoubleTap: () {
                                if (transformationController.value.getMaxScaleOnAxis() > 1.0) {
                                  transformationController.value = Matrix4.identity();
                                } else {
                                  transformationController.value = Matrix4.identity()..scale(3.0);
                                }
                              },
                              child: InteractiveViewer(
                                transformationController: transformationController,
                                minScale: 1.0,
                                maxScale: 5.0,
                                child: Image.file(File(savedPath), fit: BoxFit.contain),
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
                        child: const Text("취소", style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                        child: const Text("확인 (다음 단계)"),
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
      builder: (context) => Container(
        height: 500,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Select Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        Text(cat.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                      ],
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
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImage = categoryImages[index];
                              _saveDraft();
                            });
                            Navigator.pop(context);
                            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(categoryImages[index], fit: BoxFit.cover),
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
}


class RecipientManagerDialog extends StatefulWidget {
  final List<String> recipients;
  final String savedPath;
  final AppDatabase database;
  final Function(List<String>) onRecipientsChanged;

  const RecipientManagerDialog({
    Key? key,
    required this.recipients,
    required this.savedPath,
    required this.database,
    required this.onRecipientsChanged,
  }) : super(key: key);

  @override
  State<RecipientManagerDialog> createState() => _RecipientManagerDialogState();
}

class _RecipientManagerDialogState extends State<RecipientManagerDialog> {
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
  }

  /// 마우스 트래커 재진입 에러 방지: addPostFrameCallback 사용
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(fn);
    });
  }

  void _showResultPopup() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("발송 완료"),
        content: Text("성공: $_successCount건\n실패: $_failureCount건"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 팝업 닫기
              if (mounted) Navigator.pop(context); // 발송 관리 화면 닫기
            },
            child: const Text("확인"),
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
    
    // 1. 즉시 상태 업데이트 (버튼 클릭 등 사용자 인터랙션에서는 setState 직접 호출이 반응성 좋음)
    setState(() {
      _isSending = true;
      if (_pendingRecipients.isEmpty) {
        _pendingRecipients = List.from(_localRecipients);
        _sentCount = 0;
        _successCount = 0;
        _failureCount = 0;
      }
    });
    
    // 2. 실제 발송 로직은 UI 렌더링 후 실행되도록 약간의 딜레이 부여
    // 이렇게 하면 "발송 중..." 상태가 화면에 그려질 시간을 확보함
    await Future.delayed(const Duration(milliseconds: 100));
    
    await _executeSendingLoop();
  }
  
  /// 실제 발송 루프 - UI 업데이트와 분리되어 실행됨
  Future<void> _executeSendingLoop() async {
    while (_pendingRecipients.isNotEmpty && _isSending) {
      if (!mounted) break;

      int batchSize = 5;
      if (_pendingRecipients.length < batchSize) batchSize = _pendingRecipients.length;
      final batch = _pendingRecipients.take(batchSize).toList();

      // Wait 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      
      if (!mounted || !_isSending) break;

      // Process batch (DB inserts)
      for (var item in batch) {
         try {
           final dashedPhone = _extractDashedPhone(item);
           if (dashedPhone != null) {
             // Try to find contact
             var contact = await (widget.database.select(widget.database.contacts)..where((t) => t.phone.equals(dashedPhone))).getSingleOrNull();
             
             if (contact != null) {
               await widget.database.insertHistory(HistoryCompanion(
                 contactId: Value(contact.id),
                 type: const Value('SENT'),
                 message: const Value('카드 발송'), 
                 imagePath: Value(widget.savedPath),
                 eventDate: Value(DateTime.now()),
               ));
               _successCount++;
             } else {
               // Create dummy contact for history test if it's one of our generated ones
                if (item.contains("수신자")) {
                  final phoneStartIndex = item.indexOf(dashedPhone);
                  final dummyName = phoneStartIndex > 0 ? item.substring(0, phoneStartIndex).trimRight() : item;
                  final newId = await widget.database.insertContact(ContactsCompanion(
                    name: Value(dummyName.trim()),
                    phone: Value(dashedPhone),
                    groupTag: const Value('Test'),
                  ));
                  await widget.database.insertHistory(HistoryCompanion(
                     contactId: Value(newId),
                     type: const Value('SENT'),
                     message: const Value('카드 발송'), 
                     imagePath: Value(widget.savedPath),
                     eventDate: Value(DateTime.now()),
                   ));
                   _successCount++;
               } else {
                 _failureCount++;
               }
             }
           } else {
             _failureCount++;
           }
         } catch (e) {
           _failureCount++;
           debugPrint("Send Error: $e");
         }
      }

      if (!mounted) break;

      // 배치 완료 후 상태 업데이트 - 다음 프레임에 예약
      for (var item in batch) {
        _pendingRecipients.remove(item);
      }
      _sentCount += batchSize;
      
      // UI 업데이트
      _safeSetState(() {});

      if (!_autoContinue && _pendingRecipients.isNotEmpty) {
        _isSending = false;
        _safeSetState(() {});
        break;
      }
    }
    
    if (mounted && _isSending && _pendingRecipients.isEmpty) {
      _isSending = false;
      _safeSetState(() {
        _showResultPopup();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: RepaintBoundary(
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF29D86),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.people_alt_rounded, color: Colors.white),
                      SizedBox(width: 10),
                      Text("발송 대상 관리", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (_isSending)
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                       decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                       child: const Row(
                         children: [
                           SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                           SizedBox(width: 8),
                           Text("발송 중...", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                         ],
                       ),
                     ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Top Info & Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("총 ${_localRecipients.length}명", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF5D4037))),
                        if (!_isSending)
                        TextButton.icon(
                          onPressed: () {
                             final textController = TextEditingController();
                             showDialog(
                               context: context,
                               builder: (c) => AlertDialog(
                                 title: const Text("수신자 추가"),
                                 content: TextField(
                                   controller: textController,
                                   decoration: const InputDecoration(hintText: "이름 010-0000-0000"),
                                   autofocus: true,
                                   inputFormatters: [RecipientInputFormatter()],
                                 ),
                                 actions: [
                                   TextButton(onPressed: () => Navigator.pop(c), child: const Text("취소")),
                                   TextButton(
                                     onPressed: () {
                                       final raw = textController.text.trim();
                                       if (raw.isEmpty) {
                                         Navigator.pop(c);
                                         return;
                                       }

                                       final parsed = _parseRecipient(raw);
                                       if (parsed == null) {
                                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("형식이 올바르지 않습니다. 예: 홍길동 010-1234-5678")));
                                         return;
                                       }

                                       final newDigits = parsed['digits']!;
                                       final isDuplicate = _localRecipients.any((r) => _extractPhoneDigits(r) == newDigits);
                                       if (isDuplicate) {
                                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("이미 존재하는 수신자입니다.")));
                                         return;
                                       }

                                       _addRecipient(parsed['display']!);
                                       Navigator.pop(c);
                                     },
                                     child: const Text("추가"),
                                   ),
                                 ],
                               ),
                             );
                          },
                          icon: const Icon(Icons.person_add, size: 18, color: Color(0xFFF29D86)),
                          label: const Text("대상 추가", style: TextStyle(color: Color(0xFFF29D86))),
                        ),
                      ],
                    ),
                    const Divider(height: 20, thickness: 1),
                    
                    // List - MouseTracker 에러 방지: 발송 중에는 IgnorePointer로 감싸기
                    Expanded(
                      child: IgnorePointer(
                        ignoring: _isSending, // 발송 중에만 마우스 이벤트 무시
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFFAFAFA),
                          ),
                          child: ListView.separated(
                            // 발송 중에는 스크롤 비활성화하여 마우스 이벤트 충돌 방지
                            physics: _isSending ? const NeverScrollableScrollPhysics() : null,
                            padding: const EdgeInsets.all(8),
                            itemCount: _localRecipients.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final recipient = _localRecipients[index];
                              // Logic: if sending, check if pending. 
                              // If sending started and not in pending, it's sent.
                              // If sending not started, nothing is sent.
                              
                              bool isSent = false;
                              if (_isSending || _sentCount > 0) {
                                  isSent = !_pendingRecipients.contains(recipient);
                              }

                              // MouseTracker 에러 방지: ListTile 대신 일반 Container 사용
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: isSent ? Colors.green.withOpacity(0.1) : const Color(0xFFF29D86).withOpacity(0.1),
                                      child: Icon(Icons.person, size: 20, color: isSent ? Colors.green : const Color(0xFFF29D86)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        recipient, 
                                        style: TextStyle(
                                          color: isSent ? Colors.grey : Colors.black87, 
                                          decoration: isSent ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                    ),
                                    if (!_isSending)
                                      GestureDetector(
                                        onTap: () => _removeRecipient(index),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(Icons.remove_circle_outline, size: 20, color: Colors.redAccent),
                                        ),
                                      )
                                    else if (isSent)
                                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    if (_isSending || _sentCount > 0) ...[
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("발송 진행률", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              Text("$_sentCount / ${_localRecipients.length}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF29D86))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _localRecipients.isEmpty ? 0 : (_sentCount / _localRecipients.length),
                              backgroundColor: Colors.grey[200],
                              color: const Color(0xFFF29D86),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "단시간 다량 발송은 스팸 정책에 의해 제한될 수 있습니다.\n안전을 위해 '자동 계속' 해제를 권장합니다.",
                              style: TextStyle(fontSize: 12, color: Color(0xFF8D6E63), height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // MouseTracker 에러 방지: Checkbox 대신 GestureDetector 사용
                          GestureDetector(
                            onTap: _isSending ? null : () {
                              _safeSetState(() => _autoContinue = !_autoContinue);
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(right: 8), // right margin only
                              decoration: BoxDecoration(
                                color: _autoContinue ? const Color(0xFFF29D86) : Colors.transparent,
                                border: Border.all(
                                  color: _autoContinue ? const Color(0xFFF29D86) : Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: _autoContinue 
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                            ),
                          ),
                          Flexible(
                            child: GestureDetector(
                              onTap: _isSending ? null : () {
                                _safeSetState(() => _autoContinue = !_autoContinue);
                              },
                              child: Text(
                                "5건 발송 후 자동 계속", 
                                style: TextStyle(fontSize: 14, color: _isSending ? Colors.grey : Colors.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: _isSending ? null : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                            minimumSize: Size.zero, // 최소 사이즈 제거
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 패딩 줄임
                          ),
                          child: const Text("닫기"),
                        ),
                        const SizedBox(width: 8),
                        // 발송 버튼: 발송 중일 때는 '발송 중...'으로 텍스트 변경하고 클릭 무시
                        GestureDetector(
                          onTap: () {
                            if (_isSending) return; // 중복 클릭 방지 및 발송 중 클릭 방지
                            _startSending();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // 패딩 약간 줄임
                            decoration: BoxDecoration(
                              color: _isSending ? Colors.grey : const Color(0xFFF29D86),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isSending)
                                  const SizedBox(
                                    width: 14, // 사이즈 줄임
                                    height: 14, 
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                  )
                                else
                                  Icon(
                                    _sentCount > 0 && _pendingRecipients.isNotEmpty ? Icons.play_arrow : Icons.send, 
                                    size: 16, // 사이즈 줄임
                                    color: Colors.white,
                                  ),
                                const SizedBox(width: 6),
                                Flexible( // 텍스트도 줄어들 수 있게
                                  child: Text(
                                    _isSending 
                                      ? "발송 중..." 
                                      : (_sentCount > 0 && _pendingRecipients.isNotEmpty ? "계속 발송" : "발송 시작"),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), // 폰트 사이즈 조정
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isSending) ...[
                           const SizedBox(width: 8),
                           GestureDetector(
                             onTap: () {
                               _safeSetState(() => _isSending = false);
                             },
                             child: Container(
                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                               decoration: BoxDecoration(
                                 border: Border.all(color: Colors.red),
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               child: const Text("중지", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13)), // 텍스트 "발송 중지" -> "중지"로 단축
                             ),
                           ),
                        ],
                      ],
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

