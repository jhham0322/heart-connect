import 'dart:convert';
import 'dart:io';
import '../ai/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for rootBundle
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
  TextStyle _currentStyle = GoogleFonts.greatVibes(fontSize: 32, color: const Color(0xFF1A1A1A), height: 1.0);
  TextAlign _textAlign = TextAlign.center;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  double _fontSize = 32.0;
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

  // Text Drag Offset
  Offset _dragOffset = Offset.zero;

  // Scroll Controller for Template Selector
  final ScrollController _scrollController = ScrollController();

  // Quill Editor Controller
  late QuillController _quillController;

  void _resetDragOffset() {
    setState(() {
      _dragOffset = Offset.zero;
    });
  }

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: _message);
    _footerController = TextEditingController(text: _footerText);
    _quillController = QuillController(
      document: Document()..insert(0, _message),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _quillController.addListener(_onQuillChanged);

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
    _quillController.removeListener(_onQuillChanged);
    _quillController.dispose();
    super.dispose();
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
      final double fontSize = double.tryParse(sizeMatch?.group(1) ?? '32.0') ?? 32.0;
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

  void _updateStyle() {
    setState(() {
      _currentStyle = GoogleFonts.getFont(
        _fontName,
        fontSize: _fontSize,
        color: _currentStyle.color,
        fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
        decoration: _isUnderline ? TextDecoration.underline : TextDecoration.none,
        height: 1.0, // Reduced line spacing
      );
    });
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
                        setState(() {
                          _fontName = font;
                          _updateStyle();
                        });
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 65, height: 65,
        child: FloatingActionButton(
          onPressed: _isSending ? null : _handleSend,
          backgroundColor: const Color(0xFFF29D86),
          shape: const CircleBorder(),
          elevation: 8,
          child: _isSending 
             ? const SizedBox(
                 width: 28, height: 28,
                 child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
               )
             : const Icon(FontAwesomeIcons.paperPlane, color: Colors.white, size: 26),
        ),
      ),
      body: Stack(
        children: [
          // Background/Content
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 2. Card Preview
                    _buildCardPreview(),
                    
                    // 3. Template Selector
                    _buildTemplateSelector(),

                    // 4. Spacer (Toolbar removed as it is now part of Editor)
                    const SizedBox(height: 8),

                    // 5. Editor Input
                    _buildEditorInput(),

                    // 6. Bottom Padding
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // 1. Floating Header (Transparent)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
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
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close, color: Colors.grey, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    padding: const EdgeInsets.all(4),
                  ),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Center(
        child: AspectRatio(
          aspectRatio: 4/4.5, // 이미지 크기에 맞게 늘림
          child: Container(
            width: MediaQuery.of(context).size.width * 0.90, // 너비 확대
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
                  // 1. Full Background Image
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _showCategoryPicker,
                      child: _buildImage(_selectedImage, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    ),
                  ),

                  // 2. Change BG Indicator (Top Right)
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
                            Text("Change BG", style: TextStyle(color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Draggable Text Area
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _dragOffset += details.delta;
                        });
                      },
                      onPanEnd: (_) => _resetDragOffset(),
                      onPanCancel: () => _resetDragOffset(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        transform: Matrix4.translationValues(_dragOffset.dx, _dragOffset.dy, 0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.78, // 텍스트 영역 너비 확대
                          // Limit max height to prevent overflow stripes
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.width * 0.90 * 0.85, // 높이도 확대
                          ),
                          padding: const EdgeInsets.all(28), // 패딩 증가
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3), // 30% Transparent White
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Render Quill content in preview
                                QuillEditor.basic(
                                  controller: _quillController,
                                  config: const QuillEditorConfig(
                                    autoFocus: false,
                                    expands: false,
                                    scrollable: false,
                                    padding: EdgeInsets.zero,
                                    showCursor: false,
                                  ), 
                                ),
                                const SizedBox(height: 24),
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
          ),
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
  
  Widget _buildToolbar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        // Use a container with minWidth to help with centering on wide screens
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // Font Toggle (Open Picker)
          _buildToolbarButton(
            icon: FontAwesomeIcons.font, 
            onTap: _showFontPicker,
          ),
          
          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: Colors.grey[300]),
          const SizedBox(width: 8),

          // Bold, Italic, Underline
          _buildToolbarButton(icon: FontAwesomeIcons.bold, isActive: _isBold, onTap: () {
            setState(() {
              _isBold = !_isBold;
              _updateStyle();
            });
          }),
          _buildToolbarButton(icon: FontAwesomeIcons.italic, isActive: _isItalic, onTap: () {
            setState(() {
              _isItalic = !_isItalic;
              _updateStyle();
            });
          }),
          _buildToolbarButton(icon: FontAwesomeIcons.underline, isActive: _isUnderline, onTap: () {
            setState(() {
              _isUnderline = !_isUnderline;
              _updateStyle();
            });
          }),

          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: Colors.grey[300]),
          const SizedBox(width: 8),

          // Font Size
          _buildToolbarButton(icon: FontAwesomeIcons.minus, onTap: () {
            setState(() {
              _fontSize = (_fontSize - 2).clamp(12.0, 100.0);
              _updateStyle();
            });
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text("${_fontSize.toInt()}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          _buildToolbarButton(icon: FontAwesomeIcons.plus, onTap: () {
            setState(() {
              _fontSize = (_fontSize + 2).clamp(12.0, 100.0);
              _updateStyle();
            });
          }),

          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: Colors.grey[300]),
          const SizedBox(width: 8),

          // Align
          _buildToolbarButton(icon: FontAwesomeIcons.alignLeft, isActive: _textAlign == TextAlign.left, onTap: () => setState(() => _textAlign = TextAlign.left)),
          _buildToolbarButton(icon: FontAwesomeIcons.alignCenter, isActive: _textAlign == TextAlign.center, onTap: () => setState(() => _textAlign = TextAlign.center)),
          _buildToolbarButton(icon: FontAwesomeIcons.alignRight, isActive: _textAlign == TextAlign.right, onTap: () => setState(() => _textAlign = TextAlign.right)),

          const SizedBox(width: 8),
           Container(width: 1, height: 24, color: Colors.grey[300]),
          const SizedBox(width: 8),
          
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
                      setState(() {
                        _currentStyle = _currentStyle.copyWith(color: color);
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: isSelected ? const Color(0xFFF29D86) : Colors.white.withOpacity(0.5), width: 3),
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
        width: 32, height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEEF2FF) : Colors.white,
          border: Border.all(color: isActive ? const Color(0xFFF29D86) : const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(child: Icon(icon, size: 14, color: isActive ? const Color(0xFFF29D86) : const Color(0xFF555555))),
      ),
    );
  }

  Widget _buildEditorInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2), // 줄간격 축소
      child: Column(
        children: [
           TextField(
             controller: _footerController,
             onChanged: (val) {
               setState(() => _footerText = val);
               _saveFooter(val); // Footer 저장
             },
             decoration: const InputDecoration(
               labelText: "Footer (보낸사람)",
               border: OutlineInputBorder(),
               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
             ),
             style: const TextStyle(fontSize: 13),
           ),
           const SizedBox(height: 4), // 간격 축소
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF5),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), offset: const Offset(0, -2), blurRadius: 4)],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // 패딩 축소
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // 1줄 툴바 with 글자 크기 콤보박스
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 글자 크기 콤보박스 (6~32)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFDDDDDD)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<double>(
                                    value: _fontSizeOptions.contains(_fontSize) ? _fontSize : 18,
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
                                        setState(() {
                                          _fontSize = value;
                                          _updateStyle();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Bold, Italic, Underline
                              _buildToolbarButton(icon: FontAwesomeIcons.bold, isActive: _isBold, onTap: () {
                                setState(() {
                                  _isBold = !_isBold;
                                  _updateStyle();
                                });
                              }),
                              _buildToolbarButton(icon: FontAwesomeIcons.italic, isActive: _isItalic, onTap: () {
                                setState(() {
                                  _isItalic = !_isItalic;
                                  _updateStyle();
                                });
                              }),
                              _buildToolbarButton(icon: FontAwesomeIcons.underline, isActive: _isUnderline, onTap: () {
                                setState(() {
                                  _isUnderline = !_isUnderline;
                                  _updateStyle();
                                });
                              }),
                              const SizedBox(width: 2),
                              // Color
                              _buildToolbarButton(icon: FontAwesomeIcons.palette, onTap: _showColorPicker),
                              const SizedBox(width: 2),
                              Container(width: 1, height: 20, color: Colors.grey[300]),
                              const SizedBox(width: 2),
                              // Align
                              _buildToolbarButton(icon: FontAwesomeIcons.alignLeft, isActive: _textAlign == TextAlign.left, onTap: () => setState(() => _textAlign = TextAlign.left)),
                              _buildToolbarButton(icon: FontAwesomeIcons.alignCenter, isActive: _textAlign == TextAlign.center, onTap: () => setState(() => _textAlign = TextAlign.center)),
                              _buildToolbarButton(icon: FontAwesomeIcons.alignRight, isActive: _textAlign == TextAlign.right, onTap: () => setState(() => _textAlign = TextAlign.right)),
                              const SizedBox(width: 2),
                              Container(width: 1, height: 20, color: Colors.grey[300]),
                              const SizedBox(width: 2),
                              // Font Picker
                              _buildToolbarButton(icon: FontAwesomeIcons.font, onTap: _showFontPicker),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 150, // Fixed height for editor
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: QuillEditor.basic(
                            controller: _quillController,
                            config: const QuillEditorConfig(
                              expands: true,
                              autoFocus: false,
                              padding: EdgeInsets.all(8),
                              scrollable: true,
                              placeholder: '메시지를 입력하세요 (한 줄 15자, 최대 5줄)',
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${_message.length} / 75",
                              style: TextStyle(fontSize: 10, color: _message.length >= 75 ? Colors.red : Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            // AI Button relocated here
                            GestureDetector(
                              onTap: _showAiToneSelector,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0EB),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFF29D86).withOpacity(0.5)),
                                ),
                                child: const Icon(FontAwesomeIcons.wandMagicSparkles, size: 14, color: Color(0xFFF29D86)),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  Future<void> _handleSend() async {
    if (_isSending) return;
    
    setState(() => _isSending = true);
    
    try {
      // Simulate sending delay
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("카드가 생성되었습니다! 수신자 선택으로 이동합니다...")),
        );
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
