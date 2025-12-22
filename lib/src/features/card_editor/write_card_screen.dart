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

  final List<String> _fontList = [
    'Great Vibes', 'Caveat', 'Dancing Script', 'Pacifico', 'Indie Flower',
    'Roboto', 'Montserrat', 'Playfair Display',
    'Nanum Pen Script', 'Nanum Gothic', 'Gowun Batang', 'Song Myung'
  ];
  
  // Font size dropdown options (6~32)
  final List<double> _fontSizeOptions = [6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32];

  // Text Drag Offset - 이제 위치 유지됨
  Offset _dragOffset = Offset.zero;

  // Scroll Controller for Template Selector
  final ScrollController _scrollController = ScrollController();

  // Quill Editor Controller
  late QuillController _quillController;
  
  // Focus Node for Quill Editor
  final FocusNode _editorFocusNode = FocusNode();
  
  // GlobalKey for RepaintBoundary (이미지 캡처용)
  final GlobalKey _captureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: _message);
    _footerController = TextEditingController(text: _footerText);
    _quillController = QuillController(
      document: Document()..insert(0, _message),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _quillController.addListener(_onEditorChanged);

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
    _loadSavedFooter(); // Load saved footer
  }
  
  // Load footer from SharedPreferences
  Future<void> _loadSavedFooter() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFooter = prefs.getString('footer_text');
    if (savedFooter != null && savedFooter.isNotEmpty && mounted) {
      setState(() {
        _footerText = savedFooter;
        _footerController.text = savedFooter;
      });
    }
  }
  
  // Save footer to SharedPreferences
  Future<void> _saveFooter(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('footer_text', value);
  }

  void _onQuillChanged() {
    setState(() {
      _message = _quillController.document.toPlainText().trim();
    });
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
    _editorFocusNode.dispose();
    _quillController.removeListener(_onEditorChanged);
    _quillController.dispose();
    super.dispose();
  }

  void _onEditorChanged() {
    _onQuillChanged();
    _updateToolbarState();
  }

  // 커서 위치나 선택 영역 변경 시 툴바 상태 업데이트
  void _updateToolbarState() {
    final style = _quillController.getSelectionStyle();
    
    setState(() {
      _isBold = style.containsKey(Attribute.bold.key);
      _isItalic = style.containsKey(Attribute.italic.key);
      _isUnderline = style.containsKey(Attribute.underline.key);
      
      // 정렬 상태 확인
      if (style.containsKey(Attribute.leftAlignment.key)) _textAlign = TextAlign.left;
      else if (style.containsKey(Attribute.centerAlignment.key)) _textAlign = TextAlign.center;
      else if (style.containsKey(Attribute.rightAlignment.key)) _textAlign = TextAlign.right;
      else _textAlign = TextAlign.left; // Default

      // 폰트 사이즈 확인
      if (style.containsKey('size')) {
        final sizeStr = style.attributes['size']?.value;
        if (sizeStr != null) {
            // "14" or "14.0" or "small" etc.
             final parsed = double.tryParse(sizeStr.toString());
             if (parsed != null) _fontSize = parsed;
        }
      }
      
      // 폰트 패밀리 확인
      if (style.containsKey('font')) {
         _fontName = style.attributes['font']?.value ?? 'Great Vibes';
      }
      
      // 색상 확인
      if (style.containsKey('color')) {
        final colorHex = style.attributes['color']?.value;
        if (colorHex != null) {
           // #AABBCC
           try {
             if (colorHex.toString().startsWith('#')) {
                _currentStyle = _currentStyle.copyWith(color: Color(int.parse("FF${colorHex.toString().substring(1)}", radix: 16)));
             }
           } catch (_) {}
        }
      }
    });
  }

  void _scrollToSelected() {
    if (_templates.isEmpty || _selectedImage.isEmpty) return;
    
    final index = _templates.indexOf(_selectedImage);
    if (index != -1 && _scrollController.hasClients) {
      // Item width 80 + margin 12 = 92. Center it.
      final screenWidth = MediaQuery.of(context).size.width;
      final offset = (index * 92.0) - (screenWidth / 2) + 40; // 40 is half item width
      
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // ★ Assets 폴더의 이미지를 동적으로 읽어오는 함수
  Future<void> _loadTemplateAssets() async {
    List<String> allAssets = [];
    try {
      // Preferred method since Flutter 3.10
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      allAssets = manifest.listAssets();
    } catch (e) {
      print("AssetManifest load error: $e");
      try {
        final manifestContent = await rootBundle.loadString('AssetManifest.json');
        final Map<String, dynamic> manifestMap = json.decode(manifestContent);
        allAssets = manifestMap.keys.toList();
      } catch (e2) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    // Filter for card images
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
      // Scroll to initial selection after loading
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
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
    final colorHex = (_currentStyle.color ?? Colors.black).value.toRadixString(16).padLeft(8, '0').substring(2);
    final align = _textAlign.name;
    final fontFamily = _currentStyle.fontFamily ?? 'Caveat';
    final fontSize = _currentStyle.fontSize ?? 22.0;
    
    // Wrap the generated HTML in a div with overall styles
    return '<div style="font-family: \'$fontFamily\'; font-size: ${fontSize}px; color: #$colorHex; text-align: $align;">$html</div>';
  }

  void _loadFromHtml(String html) {
    // This is a simplified approach. A full HTML to Quill Delta converter would be complex.
    // For now, we'll extract text and basic styles.
    final fontMatch = RegExp(r"font-family:\s*'([^']+)'").firstMatch(html);
    final sizeMatch = RegExp(r"font-size:\s*([\d.]+)px").firstMatch(html);
    final colorMatch = RegExp(r"color:\s*#([0-9a-fA-F]+)").firstMatch(html);
    final alignMatch = RegExp(r"text-align:\s*(\w+)").firstMatch(html);
    
    // Extract plain text content from HTML using regex (simplified, since Document.fromHtml is not available)
    // Remove HTML tags to get plain text
    final plainText = html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();

    setState(() {
      final String fontFamily = fontMatch?.group(1) ?? 'Great Vibes';
      final double fontSize = double.tryParse(sizeMatch?.group(1) ?? '24.0') ?? 24.0;
      final Color textColor = Color(int.parse("FF${colorMatch?.group(1) ?? '1A1A1A'}", radix: 16));
      
      _fontName = fontFamily;
      _fontSize = fontSize;
      _currentStyle = GoogleFonts.getFont(fontFamily, fontSize: fontSize, color: textColor);

      if (alignMatch != null) {
        final alignStr = alignMatch.group(1);
        _textAlign = TextAlign.values.firstWhere((e) => e.name == alignStr, orElse: () => TextAlign.center);
      }
      
      _message = plainText;
      _quillController.document = Document()..insert(0, plainText);
    });
  }

  // 볼드 토글 (부분 적용)
  void _toggleBold() {
    final isBold = _quillController.getSelectionStyle().containsKey(Attribute.bold.key);
    _quillController.formatSelection(
      isBold ? Attribute.clone(Attribute.bold, null) : Attribute.bold
    );
  }
  
  // 이탤릭 토글 (부분 적용)
  void _toggleItalic() {
    final isItalic = _quillController.getSelectionStyle().containsKey(Attribute.italic.key);
    _quillController.formatSelection(
      isItalic ? Attribute.clone(Attribute.italic, null) : Attribute.italic
    );
  }
  
  // 밑줄 토글 (부분 적용)
  void _toggleUnderline() {
    final isUnder = _quillController.getSelectionStyle().containsKey(Attribute.underline.key);
    _quillController.formatSelection(
      isUnder ? Attribute.clone(Attribute.underline, null) : Attribute.underline
    );
  }
  
  // 텍스트 정렬 적용 (부분/문단 적용)
  void _applyAlignment(TextAlign align) {
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
    _quillController.formatSelection(alignAttr);
    // 상태 업데이트는 Listener에서 처리됨
  }

  // 폰트 변경 (부분 적용)
  void _applyFont(String fontName) {
    _quillController.formatSelection(Attribute.fromKeyValue('font', fontName));
  }
  
  // 폰트 사이즈 변경 (부분 적용)
  void _applyFontSize(double size) {
    // 픽셀 값으로 저장 (나중에 파싱할 때 주의)
    _quillController.formatSelection(Attribute.fromKeyValue('size', size.toString()));
  }
  
  // 색상 변경 (부분 적용)
  void _applyColor(Color color) {
    final hex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    _quillController.formatSelection(Attribute.fromKeyValue('color', hex));
  }

  Future<void> _saveCurrentCard() async {
    final nameController = TextEditingController(text: _message.length > 20 ? "${_message.substring(0, 20)}..." : _message);
    
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

    final db = ref.read(appDatabaseProvider);
    final html = _convertToHtml(_message);
    
    await db.insertSavedCard(SavedCardsCompanion.insert(
      name: Value(nameController.text),
      htmlContent: html,
      footerText: Value(_footerText),
      imagePath: Value(_selectedImage),
    ));
    
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
  }

  void _loadCard(SavedCard card) {
    _loadFromHtml(card.htmlContent);
    setState(() {
      _footerText = card.footerText ?? "";
      if (card.imagePath != null) {
        _selectedImage = card.imagePath!;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("메시지를 불러왔습니다.")));
  }

  void _showFontPicker() {
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
                    final isSelected = _fontName == font;
                    return ListTile(
                      title: Text(font, style: GoogleFonts.getFont(font, fontSize: 18)),
                      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFF29D86)) : null,
                      onTap: () {
                        _applyFont(font);
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
    final imageBytes = await _captureCardImage();
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
                  // 상단 여백 제거 (이미지 상단 밀착)
                  // SizedBox(height: MediaQuery.of(context).padding.top + 50),
                  
                  // 1. Card Preview (캡쳐 가능 영역) - 상단에 붙음
                  _buildCardPreview(),
                  
                  // 2. Toolbar (이미지와 썸네일 사이)
                  _buildToolbar(),
                  
                  // 3. Template Selector
                  _buildTemplateSelector(),
                  
                  // 4. Footer Input
                  _buildFooterInput(),

                  // 5. Bottom Padding for send button
                  const SizedBox(height: 120),
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
                  icon: Icons.file_download, 
                  onTap: _showSavedCardsDialog,
                ),
                const SizedBox(width: 8),
                _buildHeaderButton(
                  icon: Icons.save_alt, 
                  onTap: _saveCurrentCard,
                ),
                const Spacer(),
              ],
            ),
          ),
          
          // 하단 고정 전송 버튼
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Hero(
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
            ),
          ),
        ],
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
    
    // Debug info
    print("[WriteCardScreen] Loading image: $path");

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

    // Fallback: try asset one last time (maybe path doesn't start with assets/ but is in pubspec?)
    // Or just show error
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

  Widget _buildCardPreview() {
    return Container(
      padding: EdgeInsets.zero, // 패딩 제거
      child: Center(
        child: AspectRatio(
          aspectRatio: 4/4.5,
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
              child: Stack(
                children: [
                  // RepaintBoundary로 캡처 영역 감싸기 (버튼 제외)
                  RepaintBoundary(
                    key: _captureKey,
                    child: Stack(
                      children: [
                        // 1. Full Background Image
                        Positioned.fill(
                          child: _buildImage(_selectedImage, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                        ),

                        // 2. Draggable Text Area (위치 유지됨)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Transform.translate(
                              offset: _dragOffset,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    _dragOffset += details.delta;
                                  });
                                },
                                // 드래그 끝나도 위치 유지 (resetDragOffset 호출 안함)
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.78,
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.width * 0.90 * 0.85,
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 편집 가능한 QuillEditor
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
                                      const SizedBox(height: 16),
                                      // Footer
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD6B5A1),
                                          borderRadius: BorderRadius.circular(4),
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                                        ),
                                        child: Text(
                                          _footerText.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                      // 글자수 카운터 & AI 버튼 (박스 아래)
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.7),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              "${_message.length} / 75",
                                              style: TextStyle(fontSize: 10, color: _message.length >= 75 ? Colors.red : Colors.grey[700]),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
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
                  
                  // 3. Change BG Indicator (Top Right) - 캡처에서 제외
                  Positioned(
                    top: 12, right: 12,
                    child: GestureDetector(
                      onTap: _showCategoryPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text("배경", style: TextStyle(color: Colors.white, fontSize: 11)),
                          ],
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
    );
  }
  
  // 툴바 (이미지와 썸네일 사이)
  Widget _buildToolbar() {
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
                      _applyFontSize(value);
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
    // Show empty state if no templates
    if (_templates.isEmpty) {
        return const SizedBox(
            height: 100,
            child: Center(child: Text("No card images found in assets."))
        );
    }

    return SizedBox(
      height: 90,
      child: ListView.builder(
        controller: _scrollController, // Added controller
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _templates.length + 1,
        itemBuilder: (context, index) {
          if (index == _templates.length) {
            // Upload button placeholder
            return _buildThumbItem(null, isUpload: true);
          }
          final idx = index;
          return _buildThumbItem(_templates[idx], isActive: _selectedImage == _templates[idx], onTap: () {
            setState(() => _selectedImage = _templates[idx]);
            // Optional: Scroll to center when tapped manually? 
            // Better not to disturb user action unless requested.
          });
        },
      ),
    );
  }

  Widget _buildThumbItem(String? imgUrl, {bool isActive = false, bool isUpload = false, VoidCallback? onTap}) {
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
                  : imgUrl != null ? _buildImage(imgUrl, fit: BoxFit.cover) : Container(color: Colors.grey[200]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker() {
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
              const Text("글자색 선택", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: colors.map((color) {
                  final isSelected = _currentStyle.color?.value == color.value;
                  return GestureDetector(
                    onTap: () {
                      _applyColor(color);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: isSelected ? const Color(0xFFF29D86) : Colors.grey.withOpacity(0.3), width: isSelected ? 3 : 1),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
  
  // Footer 입력 영역
  Widget _buildFooterInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _footerController,
        onChanged: (val) {
          setState(() => _footerText = val);
          _saveFooter(val);
        },
        decoration: InputDecoration(
          labelText: "보낸 사람 (Footer)",
          labelStyle: const TextStyle(fontSize: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: Colors.white,
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Future<void> _handleSend() async {
    if (_isSending) return;
    
    setState(() => _isSending = true);
    
    try {
      // 이미지 캡처 및 저장
      final savedPath = await _saveCardImage();
      
      if (mounted) {
        if (savedPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("카드가 저장되었습니다: $savedPath")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("카드가 생성되었습니다! 수신자 선택으로 이동합니다...")),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
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
