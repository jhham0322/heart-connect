import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import 'sms_service.dart';

class MessageItem {
  final AppSmsMessage message;
  final String contactName;
  final String displayDate;
  final Contact? contact;

  MessageItem({
    required this.message,
    required this.contactName,
    required this.displayDate,
    this.contact,
  });
}

final messageListProvider = FutureProvider<List<MessageItem>>((ref) async {
  final smsService = ref.watch(smsServiceProvider);
  final db = ref.read(appDatabaseProvider);
  
  // 1. Get filtered messages
  final messages = await smsService.getFilteredMessages();
  
  // 2. Get contacts for name mapping
  final contacts = await db.getAllContacts();
  final Map<String, Contact> phoneToContact = {};
  
  for (var c in contacts) {
    // Normalize DB phone
    final norm = c.phone.replaceAll(RegExp(r'\D'), '');
    phoneToContact[norm] = c;
  }

  // 3. Map to MessageItem
  return messages.map((msg) {
    final address = msg.address ?? '';
    final normAddr = address.replaceAll(RegExp(r'\D'), '');
    
    // Find name
    String name = address;
    Contact? matchedContact;
    
    // Try to find match
    for (var key in phoneToContact.keys) {
      if (normAddr.endsWith(key) || key.endsWith(normAddr)) {
        matchedContact = phoneToContact[key];
        name = matchedContact!.name;
        break;
      }
    }

    return MessageItem(
      message: msg,
      contactName: name,
      displayDate: _formatDate(msg.date),
      contact: matchedContact,
    );
  }).toList();
});

String _formatDate(DateTime? date) {
  if (date == null) return '';
  final now = DateTime.now();
  final diff = now.difference(date);
  
  if (diff.inDays == 0) {
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  } else if (diff.inDays < 7) {
    const weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return weekDays[date.weekday - 1];
  } else {
    return "${date.month}/${date.day}";
  }
}

final messageActionsProvider = Provider((ref) => MessageActions(ref));

class MessageActions {
  final Ref ref;
  MessageActions(this.ref);

  Future<void> saveMessageToHistory(AppSmsMessage msg, Contact contact) async {
    final db = ref.read(appDatabaseProvider);
    
    if (msg.date == null) return;

    // Check if already exists
    final existing = await (db.select(db.history)
      ..where((t) => t.contactId.equals(contact.id))
      ..where((t) => t.type.equals('RECEIVED'))
      ..where((t) => t.eventDate.equals(msg.date!))
      ).get();
      
    bool exists = existing.any((h) => h.message == msg.body);
    
    if (!exists) {
      await db.into(db.history).insert(HistoryCompanion(
        contactId: Value(contact.id),
        type: Value('RECEIVED'),
        eventDate: Value(msg.date!),
        message: Value(msg.body),
      ));
    }
  }
}
