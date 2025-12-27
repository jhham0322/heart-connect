import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/database_provider.dart';

/// Custom wrapper for SMS Message to allow mocking and platform independence
class AppSmsMessage {
  final int? id;
  final String? address;
  final String? body;
  final DateTime? date;
  final bool? read;
  final String kind; 

  AppSmsMessage({
    this.id,
    this.address,
    this.body,
    this.date,
    this.read,
    this.kind = 'inbox',
  });
}

class SmsService {
  final Ref ref;

  SmsService(this.ref);

  Future<List<AppSmsMessage>> getFilteredMessages() async {
    final db = ref.read(appDatabaseProvider);
    final contacts = await db.getAllContacts();
    
    // Normalize contact numbers for comparison
    final contactNumbers = contacts.map((c) => _normalizeNumber(c.phone)).toSet();

    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // Return mock data for non-mobile platforms
      return _getMockMessages(contactNumbers);
    }

    // Mobile: Request permissions and fetch SMS
    final permission = await Permission.sms.status;
    if (!permission.isGranted) {
      final result = await Permission.sms.request();
      if (!result.isGranted) {
        throw Exception('SMS permission denied');
      }
    }

    final SmsQuery query = SmsQuery();
    final List<SmsMessage> messages = await query.querySms(
      kinds: [SmsQueryKind.inbox],
      sort: true, // Sorts by date desc by default
    );

    // Filter by contact numbers AND mobile phone only
    final filtered = messages.where((msg) {
      if (msg.address == null) return false;
      final normalizedSender = _normalizeNumber(msg.address!);
      
      // 1. 핸드폰 번호만 필터링 (010, 011 등)
      if (!_isMobilePhone(msg.address!)) return false;
      
      // 2. 내 연락처에 있는 사람만
      return contactNumbers.any((cNum) => _isMatch(normalizedSender, cNum));
    }).map((m) => AppSmsMessage(
      id: m.id,
      address: m.address,
      body: m.body,
      date: m.date,
      read: m.isRead,
      kind: m.kind == SmsMessageKind.sent ? 'sent' : 'inbox',
    )).toList();

    return filtered;
  }
  
  /// 특정 전화번호와 주고받은 SMS 메시지 가져오기
  Future<List<AppSmsMessage>> getMessagesForPhone(String phone) async {
    final normalizedPhone = _normalizeNumber(phone);
    
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // Mock data for desktop
      return _getMockMessagesForPhone(normalizedPhone);
    }
    
    // Mobile: Request permissions and fetch SMS
    final permission = await Permission.sms.status;
    if (!permission.isGranted) {
      final result = await Permission.sms.request();
      if (!result.isGranted) {
        return [];
      }
    }
    
    final SmsQuery query = SmsQuery();
    
    // 받은 메시지
    final List<SmsMessage> inboxMessages = await query.querySms(
      kinds: [SmsQueryKind.inbox],
      sort: true,
    );
    
    // 보낸 메시지
    final List<SmsMessage> sentMessages = await query.querySms(
      kinds: [SmsQueryKind.sent],
      sort: true,
    );
    
    // 모든 메시지 합치기
    final allMessages = <AppSmsMessage>[];
    
    // 받은 메시지 필터링
    for (final msg in inboxMessages) {
      if (msg.address == null) continue;
      final normalizedSender = _normalizeNumber(msg.address!);
      if (_isMatch(normalizedSender, normalizedPhone)) {
        allMessages.add(AppSmsMessage(
          id: msg.id,
          address: msg.address,
          body: msg.body,
          date: msg.date,
          read: msg.isRead,
          kind: 'received',
        ));
      }
    }
    
    // 보낸 메시지 필터링
    for (final msg in sentMessages) {
      if (msg.address == null) continue;
      final normalizedRecipient = _normalizeNumber(msg.address!);
      if (_isMatch(normalizedRecipient, normalizedPhone)) {
        allMessages.add(AppSmsMessage(
          id: msg.id,
          address: msg.address,
          body: msg.body,
          date: msg.date,
          read: true,
          kind: 'sent',
        ));
      }
    }
    
    // 날짜순 정렬 (최신순)
    allMessages.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
    
    return allMessages;
  }
  
  List<AppSmsMessage> _getMockMessagesForPhone(String phone) {
    final now = DateTime.now();
    return [
      AppSmsMessage(
        body: "테스트 메시지입니다.",
        date: now.subtract(const Duration(hours: 1)),
        address: phone,
        read: true,
        kind: 'received',
        id: 1,
      ),
      AppSmsMessage(
        body: "네, 알겠습니다!",
        date: now.subtract(const Duration(hours: 2)),
        address: phone,
        read: true,
        kind: 'sent',
        id: 2,
      ),
    ];
  }

  String _normalizeNumber(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }
  
  /// 핸드폰 번호인지 확인 (010, 011, 016, 017, 018, 019로 시작)
  bool _isMobilePhone(String phone) {
    final normalized = _normalizeNumber(phone);
    // 한국 핸드폰: 010, 011, 016, 017, 018, 019
    // 국가코드 포함: 8210, 82010 등
    if (normalized.startsWith('010') || 
        normalized.startsWith('011') ||
        normalized.startsWith('016') ||
        normalized.startsWith('017') ||
        normalized.startsWith('018') ||
        normalized.startsWith('019')) {
      return normalized.length >= 10 && normalized.length <= 11;
    }
    // 국가코드 포함 (+82)
    if (normalized.startsWith('8210') || normalized.startsWith('82010')) {
      return normalized.length >= 12 && normalized.length <= 13;
    }
    return false;
  }

  bool _isMatch(String sender, String contact) {
    // Check if one ends with the other (handling country codes)
    if (sender == contact) return true;
    if (sender.length > contact.length) return sender.endsWith(contact);
    if (contact.length > sender.length) return contact.endsWith(sender);
    return false;
  }

  List<AppSmsMessage> _getMockMessages(Set<String> contactNumbers) {
    final now = DateTime.now();
    
    return [
      AppSmsMessage(
        body: "이번 주 촬영 시간 확인 부탁해~",
        date: now.subtract(const Duration(minutes: 10)),
        address: "01012345678", // Yu Jae-seok
        read: false, 
        kind: 'inbox',
        id: 1, 
      ),
      AppSmsMessage(
        body: "운동 가자!",
        date: now.subtract(const Duration(hours: 2)),
        address: "01098765432", // Kim Jong-kook
        read: true, 
        kind: 'inbox',
        id: 2, 
      ),
      AppSmsMessage(
        body: "다음 주 스케줄 나왔어?",
        date: now.subtract(const Duration(days: 1)),
        address: "01012345678",
        read: true, 
        kind: 'inbox',
        id: 3, 
      ),
      AppSmsMessage(
        body: "광고 전화입니다.",
        date: now.subtract(const Duration(hours: 5)),
        address: "01000000000", // Unknown
        read: false, 
        kind: 'inbox',
        id: 4, 
      ),
    ].where((msg) {
      if (msg.address == null) return false;
      final normalizedSender = _normalizeNumber(msg.address!);
      return contactNumbers.any((cNum) => _isMatch(normalizedSender, cNum));
    }).toList();
  }
}

final smsServiceProvider = Provider<SmsService>((ref) {
  return SmsService(ref);
});

final smsMessagesProvider = FutureProvider<List<AppSmsMessage>>((ref) async {
  final service = ref.watch(smsServiceProvider);
  return service.getFilteredMessages();
});
