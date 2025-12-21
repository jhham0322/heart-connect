import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WriteCardScreen extends ConsumerStatefulWidget {
  const WriteCardScreen({super.key});

  @override
  ConsumerState<WriteCardScreen> createState() => _WriteCardScreenState();
}

class _WriteCardScreenState extends ConsumerState<WriteCardScreen> {
  // State for Editing
  String _message = "Happy Birthday,\ndear Emma!\nWith love, Anna.";
  String _footerText = "Heart-Connect";
  String _selectedImage = "https://images.unsplash.com/photo-1490750967868-58cb75065ed2?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80"; // Demo
  
  // Style State
  TextStyle _currentStyle = GoogleFonts.greatVibes(fontSize: 32, color: const Color(0xFF1A1A1A));
  TextAlign _textAlign = TextAlign.center;
  
  // Templates
  final List<String> _templates = [
    "https://images.unsplash.com/photo-1490750967868-58cb75065ed2?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
    "https://images.unsplash.com/photo-1527638056260-2475e1491753?auto=format&fit=crop&w=600&q=80",
    "https://images.unsplash.com/photo-1516062423079-7ca13cdc7f5a?auto=format&fit=crop&w=600&q=80",
    // Add more demo urls
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF9),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header
            _buildHeader(),

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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildSendButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.arrowLeft, color: Color(0xFF222222)),
            onPressed: () => context.pop(),
          ),
          const Text("Greeting Card Editor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Row(
            children: [
              IconButton(icon: const Icon(FontAwesomeIcons.floppyDisk, size: 20), onPressed: () {}),
              IconButton(icon: const Icon(FontAwesomeIcons.folderOpen, size: 20), onPressed: () {}),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          aspectRatio: 4/5,
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
          child: Column(
            children: [
              // Image Part (55%)
              Expanded(
                flex: 55,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.network(_selectedImage, fit: BoxFit.cover, width: double.infinity),
                ),
              ),
              // Text Part (45%)
              Expanded(
                flex: 45,
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        child: Text(
                          _message,
                          style: _currentStyle,
                          textAlign: _textAlign,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6B5A1),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]
                          ),
                          child: Text(
                            _footerText.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateSelector() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _templates.length + 1,
        itemBuilder: (context, index) {
          if (index == _templates.length) {
            // Upload button
            return _buildThumbItem(null, isUpload: true);
          }
          final idx = index;
          return _buildThumbItem(_templates[idx], isActive: _selectedImage == _templates[idx], onTap: () {
            setState(() => _selectedImage = _templates[idx]);
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
                  child: Image.network(imgUrl!, fit: BoxFit.cover),
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
            // Cycle fonts demo
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
          
          // Color (Demo toggle)
          _buildToolbarButton(icon: FontAwesomeIcons.palette, onTap: () {
             setState(() {
               _currentStyle = _currentStyle.copyWith(
                 color: _currentStyle.color == const Color(0xFF1A1A1A) ? const Color(0xFFD81B60) : const Color(0xFF1A1A1A)
               );
             });
          }),
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
                 // Top rip effect simulation
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
    // 1. Generate Image
    // final file = await ImageGenerator().generateCard(
    //   templateUrl: _selectedImage,
    //   message: _message,
    //   footerText: _footerText,
    // );
    
    // 2. Demo feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Image Generated! Proceeding to recipient selection... (Demo)")),
    );
    
    // 3. Navigate to Selection (Not implemented in this view)
    // context.push('/select-contacts', extra: file.path);
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
}
