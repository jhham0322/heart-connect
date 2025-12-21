import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _selectedIndex = 0; // 0: Gallery, 1: Quotes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSegmentBtn("Gallery", 0),
                    _buildSegmentBtn("Quotes", 1),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _selectedIndex == 0 ? _buildGalleryGrid() : _buildQuotesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFFCC80),
        child: const Icon(FontAwesomeIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildSegmentBtn(String text, int index) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF90CAF9) : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryGrid() {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildGridCard(color: const Color(0xFFEF9A9A), label: "Birthday", icon: FontAwesomeIcons.cakeCandles),
        _buildGridCard(color: const Color(0xFFFFF59D), label: "Thanks", icon: FontAwesomeIcons.heart),
        _buildGridCard(color: const Color(0xFFA5D6A7), icon: FontAwesomeIcons.envelope),
        _buildFolderCard(color: const Color(0xFF90CAF9), name: "My Photos"),
        _buildGridCard(color: const Color(0xFFCE93D8), label: "Snow", icon: FontAwesomeIcons.snowflake),
        _buildGridCard(color: const Color(0xFFEF9A9A), icon: FontAwesomeIcons.gift),
        _buildImageCard(),
        _buildGridCard(color: const Color(0xFFFFF59D), icon: FontAwesomeIcons.star),
        _buildGridCard(color: const Color(0xFFA5D6A7), label: "Travel", icon: FontAwesomeIcons.plane),
      ],
    );
  }

  Widget _buildQuotesList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      children: const [
        _QuoteCard(
          color: Color(0xFF90CAF9),
          text: "Love looks not with the eyes, but with the mind.",
          author: "William Shakespeare",
        ),
        SizedBox(height: 16),
        _QuoteCard(
          color: Color(0xFFEF9A9A),
          text: "The best thing to hold onto in life is each other.",
          author: "Audrey Hepburn",
        ),
        SizedBox(height: 16),
        _QuoteCard(
          color: Color(0xFFCE93D8),
          text: "Life is the flower for which love is the honey.",
          author: "Victor Hugo",
        ),
      ],
    );
  }

  Widget _buildGridCard({required Color color, String? label, IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 4))],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (label != null)
            Positioned(
              top: 8,
              child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black45)),
            ),
          if (icon != null)
             Icon(icon, color: Colors.white, size: 32),
        ],
      ),
    );
  }

  Widget _buildFolderCard({required Color color, required String name}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FontAwesomeIcons.folderOpen, size: 32, color: Colors.white),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            "https://placehold.co/100x100/png?text=IMG",
            fit: BoxFit.cover,
            errorBuilder: (_,__,___) => const Center(child: Icon(Icons.error)),
          ),
          Container(color: Colors.black12),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final Color color;
  final String text;
  final String author;

  const _QuoteCard({required this.color, required this.text, required this.author});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Text("- $author", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
