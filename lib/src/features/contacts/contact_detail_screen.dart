import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../card_editor/write_card_screen.dart';
import '../../utils/phone_formatter.dart';

class ContactDetailScreen extends ConsumerStatefulWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  ConsumerState<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends ConsumerState<ContactDetailScreen> {
  String _searchQuery = '';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(appDatabaseProvider);
    final contact = widget.contact;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5D4037)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(contact.name, style: const TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              contact.isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              color: const Color(0xFFFF8A65),
            ),
            onPressed: () {
              // Toggle favorite
              final updated = contact.copyWith(isFavorite: !contact.isFavorite);
              database.updateContact(updated);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WriteCardScreen(initialContact: contact)),
          );
        },
        backgroundColor: const Color(0xFFFF8A65),
        child: const Icon(FontAwesomeIcons.pen, color: Colors.white),
      ),
      body: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF59D),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF5D4037), width: 2),
                  ),
                  child: const Center(child: Text("👩🏻", style: TextStyle(fontSize: 40))),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formatPhone(contact.phone), style: const TextStyle(fontSize: 16, color: Color(0xFF795548), fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (contact.groupTag != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD7CCC8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(contact.groupTag!, style: const TextStyle(fontSize: 12, color: Color(0xFF3E2723))),
                            ),
                          const SizedBox(width: 8),
                          if (contact.birthday != null)
                            Text("🎂 ${DateFormat('MM.dd').format(contact.birthday!)}", style: const TextStyle(fontSize: 14, color: Color(0xFF5D4037))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 1, color: Color(0xFFD7CCC8)),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFF5D4037)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  icon: const Icon(FontAwesomeIcons.magnifyingGlass, color: Color(0xFF795548), size: 18),
                  border: InputBorder.none,
                  hintText: "내용 검색",
                  hintStyle: const TextStyle(color: Color(0xFFBCAAA4)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: Color(0xFFBCAAA4)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // History List
          Expanded(
            child: FutureBuilder<List<HistoryData>>(
              future: database.getHistoryForContact(contact.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.paperPlane, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("주고받은 내역이 없습니다."),
                      ],
                    ),
                  );
                }

                var history = snapshot.data!;
                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  history = history.where((item) {
                    final message = item.message?.toLowerCase() ?? '';
                    return message.contains(query);
                  }).toList();
                }

                if (history.isEmpty && _searchQuery.isNotEmpty) {
                   return const Center(
                    child: Text("검색 결과가 없습니다."),
                  );
                }

                // Sort by date descending
                history.sort((a, b) => b.eventDate.compareTo(a.eventDate));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), offset: const Offset(0, 4), blurRadius: 12),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Area
                          if (item.imagePath != null && item.imagePath!.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: Image.file(
                                File(item.imagePath!),
                                width: double.infinity,
                                height: 300, 
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                ),
                              ),
                            ),
                          
                          // Content Area
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFEBE9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        item.type == 'SENT' ? "보낸 카드" : "받은 카드",
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF5D4037), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      DateFormat('yyyy.MM.dd HH:mm').format(item.eventDate),
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF8D6E63)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (item.message != null && item.message!.isNotEmpty)
                                  Text(
                                    item.message!,
                                    style: const TextStyle(fontSize: 16, color: Color(0xFF3E2723), height: 1.5),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
