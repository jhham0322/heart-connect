import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';

part 'contact_service.g.dart';

@riverpod
class ContactService extends _$ContactService {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  Future<void> syncContacts() async {
    final db = ref.read(appDatabaseProvider);
    
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
    // Optimization: In a real app, compare hashes or last modified to avoid overwriting everything.
    // For now, we use upsert on phone number.
    
    for (var c in deviceContacts) {
      if (c.phones.isEmpty) continue;
      
      final normalizedPhone = c.phones.first.number.replaceAll(RegExp(r'\D'), ''); // keeping just digits
      
      final companion = ContactsCompanion(
        phone: Value(normalizedPhone),
        name: Value(c.displayName),
        // Simplistic mapping
        groupTag: Value(c.groups.isNotEmpty ? c.groups.first.id : null),
        // photoData: Value(c.photo?.isNotEmpty == true ? base64Encode(c.photo!) : null), // Needs importing dart:convert
      );

      // Using the phone as key for upsert logic if DB supports it, 
      // or we check existence manually if `insertOnConflictUpdate` isn't enough for our custom logic.
      // Our DB table defined `phone` as unique, so `insertOnConflictUpdate` works.
      await db.upsertContact(companion);
    }
  }
}
