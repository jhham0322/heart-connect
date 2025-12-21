import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../../theme/app_theme.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(appDatabaseProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5), // bg-base
      body: Stack(
        children: [
          // Dot pattern background
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: CustomPaint(painter: DotPatternPainter()),
            ),
          ),
          
          Column(
            children: [
               // Top Tab Bar
              _buildTopTabBar(context),

              // Search Section
              _buildSearchSection(context),

               // Contact List Area
              Expanded(
                child: StreamBuilder<List<Contact>>(
                  stream: database.watchAllContacts(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final contacts = snapshot.data!;
                    if (contacts.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        return _buildContactCard(context, contacts[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopTabBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16 + 24, left: 20, right: 20, bottom: 0), // +24 for status bar
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              text: "내 사람들",
              icon: FontAwesomeIcons.heart,
              isActive: true, // TODO: State logic
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TabPill(
              text: "추억 기록",
              isActive: false,
              onTap: () {}, // TODO: Navigate to memory log
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
           Container(
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(25),
               border: Border.all(color: const Color(0xFF5D4037)),
             ),
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
             child: const TextField(
               decoration: InputDecoration(
                 icon: Icon(FontAwesomeIcons.magnifyingGlass, color: Color(0xFF795548), size: 18),
                 border: InputBorder.none,
                 hintText: "이름, 태그 검색",
                 hintStyle: TextStyle(color: Color(0xFFBCAAA4)),
               ),
             ),
           ),
           const SizedBox(height: 12),
           SingleChildScrollView(
             scrollDirection: Axis.horizontal,
             child: Row(
               children: [
                 _FilterChip(label: "전체", isActive: true),
                 const SizedBox(width: 8),
                 _FilterChip(label: "즐겨찾기"),
                 const SizedBox(width: 8),
                 _FilterChip(label: "최근 연락"),
                 const SizedBox(width: 8),
                 _FilterChip(label: "가족"),
               ],
             ),
           )
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, Contact contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5D4037).withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), offset: const Offset(0, 4), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF59D),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF5D4037)),
            ),
            child: const Center(child: Text("👩🏻", style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF3E2723))),
                const SizedBox(height: 2),
                Text(contact.phone, style: const TextStyle(fontSize: 12, color: Color(0xFF795548), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              contact.isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              color: const Color(0xFFFF8A65),
            ),
            onPressed: () {}, // TODO: Toggle favorite
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FontAwesomeIcons.solidAddressBook, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("연락처를 동기화해주세요."),
          TextButton(
            onPressed: () {
              // trigger sync
              // ref.read(contactServiceProvider.notifier).syncContacts();
            }, 
            child: const Text("동기화 하기"),
          )
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String text;
  final bool isActive;
  final IconData? icon;
  final VoidCallback onTap;

  const _TabPill({required this.text, required this.isActive, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFAB91) : const Color(0xFFFFF9C4),
          borderRadius: BorderRadius.circular(50),
          border: isActive ? Border.all(color: const Color(0xFF5D4037), width: 2) : Border.all(color: const Color(0xFF5D4037).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 16, color: const Color(0xFF3E2723)), const SizedBox(width: 6)],
            Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3E2723))),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _FilterChip({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3E2723) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF5D4037)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF795548),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFFD7CCC8)
      ..style = PaintingStyle.fill;

    for (double y = 0; y < size.height; y += 20) {
      for (double x = 0; x < size.width; x += 20) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
