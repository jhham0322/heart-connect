import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    // SMS 권한이 제거되었으므로 항상 mock 데이터 반환
    return _getMockMessages(contactNumbers);
  }
  
  /// 특정 전화번호와 주고받은 SMS 메시지 가져오기
  Future<List<AppSmsMessage>> getMessagesForPhone(String phone) async {
    final normalizedPhone = _normalizeNumber(phone);
    
    // SMS 권한이 제거되었으므로 항상 mock 데이터 반환
    return _getMockMessagesForPhone(normalizedPhone);
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
    // 둘 다 숫자만 있어야 함
    if (sender.isEmpty || contact.isEmpty) return false;
    
    // 완전 일치
    if (sender == contact) return true;
    
    // 최소 8자리 이상이어야 비교 가능 (010-XXXX-XXXX의 8자리)
    if (sender.length < 8 || contact.length < 8) return false;
    
    // 휴대폰 번호 형식 체크 (발신자가 휴대폰 번호가 아니면 무시)
    if (!_isMobilePhone(sender)) return false;
    
    // 마지막 8자리가 정확히 일치해야 함
    final senderLast8 = sender.substring(sender.length - 8);
    final contactLast8 = contact.substring(contact.length - 8);
    
    return senderLast8 == contactLast8;
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
