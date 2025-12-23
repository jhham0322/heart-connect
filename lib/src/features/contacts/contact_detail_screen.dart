import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../database/app_database.dart';
import '../database/database_provider.dart';

class ContactDetailScreen extends ConsumerWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(appDatabaseProvider);

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
                      Text(contact.phone, style: const TextStyle(fontSize: 16, color: Color(0xFF795548), fontWeight: FontWeight.w500)),
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

                final history = snapshot.data!;
                // Sort by date descending
                history.sort((a, b) => b.eventDate.compareTo(a.eventDate));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final isSent = item.type == 'SENT';
                    
                    return Align(
                      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSent ? const Color(0xFFFFAB91) : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isSent ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isSent ? Radius.zero : const Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, 2), blurRadius: 4),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.imagePath != null && item.imagePath!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(item.imagePath!), fit: BoxFit.cover),
                                ),
                              ),
                            if (item.message != null && item.message!.isNotEmpty)
                              Text(item.message!, style: TextStyle(color: isSent ? const Color(0xFF3E2723) : Colors.black87)),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('yyyy.MM.dd HH:mm').format(item.eventDate),
                              style: TextStyle(fontSize: 10, color: isSent ? Colors.white.withOpacity(0.8) : Colors.grey),
                            ),
                          ],
                        ),
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
