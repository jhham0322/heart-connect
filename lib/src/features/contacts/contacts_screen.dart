import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../card_editor/write_card_screen.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../../theme/app_theme.dart';
import 'contact_detail_screen.dart';
import '../../utils/phone_formatter.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  int _selectedTabIndex = 0; // 0: My People, 1: Memory Record
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
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
              _buildTopTabBar(),

              // Search Section (Only show for My People tab for now, or both?)
              // The mockup shows search in My People. Let's keep it for both but maybe filter differently.
              _buildSearchSection(),

               // Contact List Area
              Expanded(
                child: _selectedTabIndex == 0 
                  ? _buildMyPeopleList(database)
                  : _buildMemoryList(database),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopTabBar() {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 0),
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              text: "내 사람들",
              iconWidget: Image.asset('assets/icons/heart_icon.png', width: 16, height: 16),
              isActive: _selectedTabIndex == 0,
              onTap: () => setState(() => _selectedTabIndex = 0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TabPill(
              text: "추억 기록",
              icon: FontAwesomeIcons.star,
              isActive: _selectedTabIndex == 1,
              onTap: () => setState(() => _selectedTabIndex = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
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
             child: TextField(
               onChanged: (value) => setState(() => _searchQuery = value),
               decoration: const InputDecoration(
                 icon: Icon(FontAwesomeIcons.magnifyingGlass, color: Color(0xFF795548), size: 18),
                 border: InputBorder.none,
                 hintText: "이름, 태그 검색",
                 hintStyle: TextStyle(color: Color(0xFFBCAAA4)),
               ),
             ),
           ),
           const SizedBox(height: 12),
           // Filter chips can be dynamic based on tab
           SingleChildScrollView(
             scrollDirection: Axis.horizontal,
             child: Row(
               children: [
                 const _FilterChip(label: "전체", isActive: true),
                 const SizedBox(width: 8),
                 const _FilterChip(label: "즐겨찾기"),
                 const SizedBox(width: 8),
                 const _FilterChip(label: "최근 연락"),
                 const SizedBox(width: 8),
                 const _FilterChip(label: "가족"),
               ],
             ),
           )
        ],
      ),
    );
  }

  Widget _buildMyPeopleList(AppDatabase database) {
    return StreamBuilder<List<Contact>>(
      stream: database.watchAllContacts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final contacts = snapshot.data!;
        if (contacts.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _buildContactCard(contacts[index]);
          },
        );
      },
    );
  }

  Widget _buildMemoryList(AppDatabase database) {
    return StreamBuilder<List<RecentContactData>>(
      stream: database.watchRecentContacts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
           return Center(child: Text("Error: ${snapshot.error}"));
        }
        
        var recents = snapshot.data ?? [];
        if (_searchQuery.isNotEmpty) {
           final query = _searchQuery.toLowerCase();
           recents = recents.where((d) => 
             d.contact.name.toLowerCase().contains(query) || 
             (d.lastMessage?.toLowerCase().contains(query) ?? false)
           ).toList();
        }

        if (recents.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.clockRotateLeft, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text("아직 추억 기록이 없습니다."),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          itemCount: recents.length,
          itemBuilder: (context, index) {
            return _buildMemoryCard(recents[index]);
          },
        );
      },
    );
  }

  Widget _buildContactCard(Contact contact) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ContactDetailScreen(contact: contact)),
        );
      },
      child: Container(
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
                  Text(formatPhone(contact.phone), style: const TextStyle(fontSize: 12, color: Color(0xFF795548), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            IconButton(
              icon: Image.asset(
                'assets/icons/heart_icon.png',
                width: 24,
                height: 24,
                color: contact.isFavorite ? const Color(0xFFFF8A65) : const Color(0xFFFF8A65).withOpacity(0.4),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WriteCardScreen(initialContact: contact)),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryCard(RecentContactData data) {
    final bool isReceived = data.lastType == 'RECEIVED';
    final Color cardColor = isReceived ? const Color(0xFFC8E6C9) : const Color(0xFFFFF9C4); // Mint vs Yellow
    
    // Distinct icons and colors
    final IconData icon = isReceived ? FontAwesomeIcons.envelopeOpenText : FontAwesomeIcons.paperPlane;
    final Color iconColor = isReceived ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00); // Green vs Orange
    
    // Process message for preview (first line only)
    String messagePreview = data.lastMessage ?? (isReceived ? "새 메시지" : "카드 발송");
    if (messagePreview.contains('\n')) {
      messagePreview = messagePreview.split('\n').first;
    }
    // Remove manual length truncation, let Text widget handle it
    
    return GestureDetector(
      onTap: () {
         // Navigate to detail screen just like contact card
         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ContactDetailScreen(contact: data.contact)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, 2), blurRadius: 8)
          ],
          border: Border.all(color: Colors.black.withOpacity(0.02)),
        ),
        child: IntrinsicHeight( // For vertical divider
          child: Row(
            children: [
              // Left Section: Date & Icon
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20, color: iconColor),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(data.lastDate),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5D4037)),
                    ),
                  ],
                ),
              ),
              
              // Divider
              const VerticalDivider(
                width: 1, 
                thickness: 1, 
                color: Colors.transparent, 
              ),
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: CustomPaint(painter: DashedLinePainter()),
              ),

              // Right Section: Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Thumbnail
                      if (data.cardThumbnail != null && File(data.cardThumbnail!).existsSync())
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(data.cardThumbnail!), 
                            width: 48, 
                            height: 48, 
                            fit: BoxFit.cover
                          ),
                        )
                      else
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(child: Text("💐", style: TextStyle(fontSize: 24))),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data.contact.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF3E2723)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              messagePreview,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF5D4037), height: 1.4),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Reply Button for Received messages
                            if (isReceived) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 32,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                     Navigator.push(
                                       context,
                                       MaterialPageRoute(
                                         builder: (context) => WriteCardScreen(initialContact: data.contact)
                                       ),
                                     );
                                  },
                                  icon: const Icon(FontAwesomeIcons.pen, size: 12),
                                  label: const Text("카드 쓰기", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF5D4037),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(color: const Color(0xFF5D4037).withOpacity(0.2)),
                                    ),
                                  ),
                                ),
                              )
                            ]
                          ],
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
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "오늘";
    }
    
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return "어제";
    }
    
    if (diff.inDays < 7) {
      return "${diff.inDays}일 전";
    }
    
    return DateFormat('MM.dd').format(date);
  }

  Widget _buildEmptyState() {
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
  final Widget? iconWidget;
  final VoidCallback onTap;

  const _TabPill({required this.text, required this.isActive, this.icon, this.iconWidget, required this.onTap});

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
            if (iconWidget != null) ...[iconWidget!, const SizedBox(width: 6)]
            else if (icon != null) ...[Icon(icon, size: 16, color: const Color(0xFF3E2723)), const SizedBox(width: 6)],
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
  final VoidCallback? onTap;

  const _FilterChip({required this.label, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFF5D4037).withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashHeight = 5, dashSpace = 3, startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
