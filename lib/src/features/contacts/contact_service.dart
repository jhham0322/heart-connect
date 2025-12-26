import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';
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
      // 1. Request Contact Permission
      if (!await fc.FlutterContacts.requestPermission(readonly: true)) {
        throw Exception('Contact permission denied');
      }

      // 2. Fetch Device Contacts (with accounts to get starred info)
      final deviceContacts = await fc.FlutterContacts.getContacts(
        withProperties: true, 
        withPhoto: true,
        withAccounts: true, // starred 정보 포함
        sorted: true
      );

      // 3. 내 이름에서 성씨 추출 (첫 번째 연락처 또는 SIM 정보에서)
      String? myFamilyName;
      try {
        // 보통 "내 정보" 또는 첫 연락처에서 성씨를 추출
        // 또는 SharedPreferences에서 사용자가 설정한 이름을 사용
        // 여기서는 간단히 "함" 성씨를 기본값으로 사용 (나중에 설정에서 변경 가능)
        // TODO: 사용자 프로필에서 성씨 가져오기
        myFamilyName = null; // 일단 null로 두고 groupTag 기반으로 처리
      } catch (e) {
        debugPrint('Error getting my name: $e');
      }

      // 4. Sync contacts to DB
      for (var c in deviceContacts) {
        if (c.phones.isEmpty) continue;
        
        final normalizedPhone = c.phones.first.number.replaceAll(RegExp(r'\D'), ''); 
        
        // starred 연락처 확인
        final isStarred = c.isStarred;
        
        // 가족 태그 결정
        String? groupTag;
        if (c.groups.isNotEmpty) {
          groupTag = c.groups.first.name;
        }
        
        // 성씨가 같으면 가족으로 판단 (한국 이름 기준: 첫 글자가 성)
        if (myFamilyName != null && c.displayName.isNotEmpty) {
          final contactFamilyName = c.displayName[0];
          if (contactFamilyName == myFamilyName) {
            groupTag = '가족';
          }
        }
        
        // 사진 데이터를 Base64로 변환
        String? photoBase64;
        if (c.photo != null && c.photo!.isNotEmpty) {
          photoBase64 = base64Encode(c.photo!);
        }
        
        final companion = ContactsCompanion(
          phone: Value(normalizedPhone),
          name: Value(c.displayName),
          groupTag: Value(groupTag),
          isFavorite: Value(isStarred), // 스타 여부 저장
          photoData: Value(photoBase64), // 사진 데이터 저장
        );

        await db.upsertContact(companion);
      }
      
      // 5. 통화 기록 동기화 (최근 6개월)
      await _syncCallLog(db);
      
    } else {
      // Windows/Web/Mac: Seed Mock Data
      await _seedMockData(db);
    }
  }
  
  /// 통화 기록을 읽어서 연락처의 최근 연락 날짜 업데이트
  Future<void> _syncCallLog(AppDatabase db) async {
    try {
      // 통화 기록 권한 요청
      final status = await Permission.phone.request();
      if (!status.isGranted) {
        debugPrint('Call log permission denied');
        return;
      }
      
      // 6개월 전 날짜
      final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
      
      // 통화 기록 가져오기
      final Iterable<CallLogEntry> entries = await CallLog.query(
        dateFrom: sixMonthsAgo.millisecondsSinceEpoch,
        dateTo: DateTime.now().millisecondsSinceEpoch,
      );
      
      // 전화번호별 최근 통화 날짜 맵 생성
      final Map<String, DateTime> lastCallDates = {};
      final Map<String, String> lastCallTypes = {}; // 'outgoing' or 'incoming'
      
      for (var entry in entries) {
        if (entry.number == null) continue;
        
        final normalizedPhone = entry.number!.replaceAll(RegExp(r'\D'), '');
        final callDate = DateTime.fromMillisecondsSinceEpoch(entry.timestamp ?? 0);
        
        // 이미 기록된 날짜보다 최근이면 업데이트
        if (!lastCallDates.containsKey(normalizedPhone) || 
            callDate.isAfter(lastCallDates[normalizedPhone]!)) {
          lastCallDates[normalizedPhone] = callDate;
          
          // 발신/수신 구분
          if (entry.callType == CallType.outgoing) {
            lastCallTypes[normalizedPhone] = 'outgoing';
          } else {
            lastCallTypes[normalizedPhone] = 'incoming';
          }
        }
      }
      
      // DB의 연락처 업데이트
      final contacts = await db.getAllContacts();
      for (var contact in contacts) {
        final normalizedPhone = contact.phone.replaceAll(RegExp(r'\D'), '');
        
        if (lastCallDates.containsKey(normalizedPhone)) {
          final callDate = lastCallDates[normalizedPhone]!;
          final callType = lastCallTypes[normalizedPhone];
          
          // 발신이면 lastSentDate, 수신이면 lastReceivedDate 업데이트
          await db.updateContactCallDate(
            contact.id,
            callType == 'outgoing' ? callDate : null,
            callType == 'incoming' ? callDate : null,
          );
        }
      }
      
      debugPrint('Call log sync completed: ${lastCallDates.length} entries');
    } catch (e) {
      debugPrint('Error syncing call log: $e');
    }
  }

  Future<void> _seedMockData(AppDatabase db) async {
    // 1. Mock Contacts
    final now = DateTime.now();
    final mockContacts = [
      ContactsCompanion(
        name: Value('유재석'), 
        phone: Value('01012345678'), 
        groupTag: Value('Friend'),
        birthday: Value(now.add(const Duration(days: 1))), // Tomorrow
      ),
      ContactsCompanion(
        name: Value('김종국'), 
        phone: Value('01098765432'), 
        groupTag: Value('Gym'),
        birthday: Value(now.add(const Duration(days: 7))), // D-7
      ),
      ContactsCompanion(
        name: Value('송지효'), 
        phone: Value('01055554444'), 
        groupTag: Value('Family'),
        birthday: Value(now.add(const Duration(days: 30))), // Next Month
      ),
      ContactsCompanion( // No birthday
        name: Value('하동훈'), 
        phone: Value('01077778888'), 
        groupTag: Value('Work')
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
            type: Value('RECEIVED'),
            message: Value('이번 주 촬영 어때?'),
            eventDate: Value(DateTime.now().subtract(const Duration(days: 1))),
          ));
       }
       if (contact.name == '송지효') {
          await db.insertHistory(HistoryCompanion(
             contactId: Value(contact.id),
             type: Value('RECEIVED'),
             message: Value('오빠, 생일 축하해! 🎂'),
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
