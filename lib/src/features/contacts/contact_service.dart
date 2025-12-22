import 'dart:async';
import 'dart:io';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';

/// ContactService - 연락처 동기화 서비스
class ContactService extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initial state needed
    return null;
  }

  Future<void> syncContacts() async {
    final db = ref.read(appDatabaseProvider);
    
    // Check Platform
    if (Platform.isAndroid || Platform.isIOS) {
      // 1. Request Permission
      if (!await fc.FlutterContacts.requestPermission(readonly: true)) {
        throw Exception('Permission denied');
      }

      // 2. Fetch Device Contacts
      final deviceContacts = await fc.FlutterContacts.getContacts(
        withProperties: true, 
        withPhoto: true,
        sorted: true
      );

      // 3. Sync to DB
      for (var c in deviceContacts) {
        if (c.phones.isEmpty) continue;
        
        final normalizedPhone = c.phones.first.number.replaceAll(RegExp(r'\D'), ''); 
        
        final companion = ContactsCompanion(
          phone: Value(normalizedPhone),
          name: Value(c.displayName),
          groupTag: Value(c.groups.isNotEmpty ? c.groups.first.id : null),
        );

        await db.upsertContact(companion);
      }
    } else {
      // Windows/Web/Mac: Seed Mock Data
      await _seedMockData(db);
    }
  }

  Future<void> _seedMockData(AppDatabase db) async {
    // 1. Mock Contacts
    final now = DateTime.now();
    final mockContacts = [
      ContactsCompanion(
        name: const Value('유재석'), 
        phone: const Value('01012345678'), 
        groupTag: const Value('Friend'),
        birthday: Value(now.add(const Duration(days: 1))), // Tomorrow
      ),
      ContactsCompanion(
        name: const Value('김종국'), 
        phone: const Value('01098765432'), 
        groupTag: const Value('Gym'),
        birthday: Value(now.add(const Duration(days: 7))), // D-7
      ),
      ContactsCompanion(
        name: const Value('송지효'), 
        phone: const Value('01055554444'), 
        groupTag: const Value('Family'),
        birthday: Value(now.add(const Duration(days: 30))), // Next Month
      ),
      ContactsCompanion( // No birthday
        name: const Value('하동훈'), 
        phone: const Value('01077778888'), 
        groupTag: const Value('Work')
      ),
    ];

    for (var contact in mockContacts) {
      await db.upsertContact(contact);
    }

    // 2. Mock History (Messages)
    // First, retrieve inserted contacts to get their IDs
    final insertedContacts = await db.getAllContacts();
    
    // Avoid duplicate history by checking if empty (optional, but good for idempotent)
    // For simplicity, we just insert some if possible.
    
    for (var contact in insertedContacts) {
       // Add some dummy received messages
       if (contact.name == '유재석') {
          await db.insertHistory(HistoryCompanion(
            contactId: Value(contact.id),
            type: const Value('RECEIVED'),
            message: const Value('이번 주 촬영 어때?'),
            eventDate: Value(DateTime.now().subtract(const Duration(days: 1))),
          ));
       }
       if (contact.name == '송지효') {
          await db.insertHistory(HistoryCompanion(
             contactId: Value(contact.id),
             type: const Value('RECEIVED'),
             message: const Value('오빠, 생일 축하해! 🎂'),
             eventDate: Value(DateTime.now().subtract(const Duration(hours: 5))),
          ));
       }
    }
  }
}

/// ContactService Provider
final contactServiceProvider = AsyncNotifierProvider<ContactService, void>(() {
  return ContactService();
});
