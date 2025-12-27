import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../card_editor/write_card_screen.dart';
import '../message/sms_service.dart';
import '../../utils/phone_formatter.dart';
import 'current_contact_provider.dart';

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
    // 현재 보고 있는 연락처를 Provider에 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentContactProvider.notifier).state = widget.contact;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // 화면을 떠날 때 현재 연락처 초기화
    ref.read(currentContactProvider.notifier).state = null;
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
            icon: Image.asset(
              'assets/icons/heart_icon.png',
              width: 36,
              height: 36,
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
          print("[ContactDetailScreen] FAB pressed for contact: ${contact.name}");
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
                // 프로필 사진 표시 (photoData가 있으면 사진, 없으면 이모지)
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF59D),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF5D4037), width: 2),
                  ),
                  child: ClipOval(
                    child: contact.photoData != null && contact.photoData!.isNotEmpty
                        ? Image.file(
                            File(contact.photoData!),
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                            errorBuilder: (context, error, stackTrace) => 
                                const Center(child: Text("👤", style: TextStyle(fontSize: 40))),
                          )
                        : const Center(child: Text("👤", style: TextStyle(fontSize: 40))),
                  ),
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

          // SMS 메시지 목록 (문자 기준)
          Expanded(
            child: FutureBuilder<List<AppSmsMessage>>(
              future: ref.read(smsServiceProvider).getMessagesForPhone(contact.phone),
              builder: (context, smsSnapshot) {
                if (smsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final smsMessages = smsSnapshot.data ?? [];
                
                // 검색 필터
                var filteredMessages = smsMessages;
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  filteredMessages = smsMessages.where((msg) {
                    return (msg.body?.toLowerCase() ?? '').contains(query);
                  }).toList();
                }
                
                if (filteredMessages.isEmpty) {
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
                
                if (filteredMessages.isEmpty && _searchQuery.isNotEmpty) {
                  return const Center(
                    child: Text("검색 결과가 없습니다."),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredMessages.length,
                  itemBuilder: (context, index) {
                    final msg = filteredMessages[index];
                    final isSent = msg.kind == 'sent';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSent ? const Color(0xFFF29D86).withOpacity(0.2) : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isSent ? const Radius.circular(16) : const Radius.circular(4),
                                bottomRight: isSent ? const Radius.circular(4) : const Radius.circular(16),
                              ),
                              border: isSent 
                                  ? Border.all(color: const Color(0xFFF29D86), width: 1) 
                                  : Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  offset: const Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isSent ? const Color(0xFFF29D86) : const Color(0xFF8D6E63),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isSent ? "보냄" : "받음",
                                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      msg.date != null ? DateFormat('MM.dd HH:mm').format(msg.date!) : '',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF8D6E63)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  msg.body ?? '',
                                  style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723), height: 1.4),
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
