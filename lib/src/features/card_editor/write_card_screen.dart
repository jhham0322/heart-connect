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

class WriteCardScreen extends ConsumerStatefulWidget {
  final String? initialImage;
  const WriteCardScreen({super.key, this.initialImage});

  @override
  ConsumerState<WriteCardScreen> createState() => _WriteCardScreenState();
}

class _WriteCardScreenState extends ConsumerState<WriteCardScreen> {
  // State for Editing
  String _message = "Happy Birthday,\ndear Emma!\nWith love, Anna.";
  String _footerText = "Heart-Connect";
  
  // Default placeholder until loaded
  String _selectedImage = ""; 
  
  // Style State
  TextStyle _currentStyle = GoogleFonts.greatVibes(fontSize: 32, color: const Color(0xFF1A1A1A));
  TextAlign _textAlign = TextAlign.center;
  
  // Templates (Loaded Dynamically)
  List<String> _templates = [];
  bool _isLoading = true;
  
  // AI Service
  final _aiService = AiService();
  bool _isAiLoading = false;

  // Text Drag Offset
  Offset _dragOffset = Offset.zero;

  // Scroll Controller for Template Selector
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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

  /// AI를 사용해 메시지를 더 감성적으로 다듬는 기능
  Future<void> _refineMessageWithAi() async {
    if (_message.trim().isEmpty || _isAiLoading) return;
    
    setState(() => _isAiLoading = true);
    
    try {
      final refined = await _aiService.refineMessage(_message);
      if (refined != null && mounted) {
        setState(() {
          _message = refined;
        });
      }
    } catch (e) {
      debugPrint('AI Refinement failed: $e');
      // Optionally show a snackbar here
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
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 2. Card Preview
                    _buildCardPreview(),
                    
                    // 3. Template Selector
                    _buildTemplateSelector(),

                    // 4. Toolbar
                    _buildToolbar(),

                    // 5. Editor Input
                    _buildEditorInput(),

                    // 6. Send Button (Moved into body to avoid overlap)
                    _buildSendButton(),
                    
                    // 7. Bottom Padding for Navigation Bar
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: AspectRatio(
          aspectRatio: 4/5,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
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
                    child: Transform.translate(
                      offset: _dragOffset,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _dragOffset += details.delta;
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3), // 30% Transparent White
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _message,
                                style: _currentStyle,
                                textAlign: _textAlign,
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
      height: 110,
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
              width: 70, height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isActive ? Border.all(color: const Color(0xFFF29D86), width: 2) : Border.all(color: Colors.transparent, width: 2),
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: isUpload 
                ? const Center(child: Icon(FontAwesomeIcons.camera, color: Color(0xFFAAAAAA)))
                : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildImage(imgUrl!),
                ),
            ),
            const SizedBox(height: 6),
            Text(isUpload ? "직접 선택" : "Template", style: TextStyle(fontSize: 11, color: isActive ? const Color(0xFFF29D86) : const Color(0xFF888888), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildToolbar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Font Family
          _buildToolbarButton(icon: FontAwesomeIcons.font, onTap: () {
            setState(() {
              if (_currentStyle.fontFamily?.contains('Great Vibes') ?? false) {
                 _currentStyle = GoogleFonts.caveat(fontSize: _currentStyle.fontSize, color: _currentStyle.color);
              } else if (_currentStyle.fontFamily?.contains('Caveat') ?? false) {
                 _currentStyle = GoogleFonts.roboto(fontSize: _currentStyle.fontSize, color: _currentStyle.color);
              } else {
                 _currentStyle = GoogleFonts.greatVibes(fontSize: _currentStyle.fontSize, color: _currentStyle.color);
              }
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
          
          // Color
          _buildToolbarButton(icon: FontAwesomeIcons.palette, onTap: () {
             setState(() {
               _currentStyle = _currentStyle.copyWith(
                 color: _currentStyle.color == const Color(0xFF1A1A1A) ? const Color(0xFFD81B60) : const Color(0xFF1A1A1A)
               );
             });
          }),

          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: Colors.grey[300]),
          const SizedBox(width: 8),

          // AI Magic Button
          _isAiLoading
            ? const SizedBox(width: 36, height: 36, child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF29D86))))
            : _buildToolbarButton(
                icon: FontAwesomeIcons.wandMagicSparkles,
                onTap: _refineMessageWithAi,
              ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({required IconData icon, bool isActive = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEEF2FF) : Colors.white,
          border: Border.all(color: isActive ? const Color(0xFFF29D86) : const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(child: Icon(icon, size: 16, color: isActive ? const Color(0xFFF29D86) : const Color(0xFF555555))),
      ),
    );
  }

  Widget _buildEditorInput() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
           TextField(
             onChanged: (val) => setState(() => _footerText = val),
             decoration: const InputDecoration(
               labelText: "Footer (보낸사람)",
               border: OutlineInputBorder(),
               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
             ),
             style: const TextStyle(fontSize: 13),
           ),
           const SizedBox(height: 12),
           Container(
             decoration: BoxDecoration(
               color: const Color(0xFFFFFDF5),
               borderRadius: BorderRadius.circular(2),
               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), offset: const Offset(0, -4), blurRadius: 10)],
             ),
             child: Column(
               children: [
                 Container(height: 10, decoration: const BoxDecoration(color: Color(0xFFFFFDF5))), 
                 Padding(
                   padding: const EdgeInsets.all(16),
                   child: TextField(
                     maxLines: 5,
                     onChanged: (val) => setState(() => _message = val),
                     style: GoogleFonts.caveat(fontSize: 22, color: const Color(0xFF555555)),
                     decoration: const InputDecoration(
                       border: InputBorder.none,
                       hintText: "메시지를 입력하세요...",
                     ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Image Generated! Proceeding to recipient selection... (Demo)")),
    );
  }

  Widget _buildSendButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCF9),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0,-5))]
      ),
      child: ElevatedButton(
        onPressed: _handleSend,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF29D86),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          elevation: 8,
          shadowColor: const Color(0xFFF29D86).withOpacity(0.4),
        ),
        child: Text("Send", style: GoogleFonts.greatVibes(fontSize: 28, fontWeight: FontWeight.w500)),
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
