import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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

      // 4. Sync contacts to DB (핸드폰 번호만)
      for (var c in deviceContacts) {
        if (c.phones.isEmpty) continue;
        
        // 핸드폰 번호 찾기 (010, 011 등으로 시작하는 번호)
        String? mobilePhone;
        for (var phone in c.phones) {
          final normalized = phone.number.replaceAll(RegExp(r'\D'), '');
          if (_isMobilePhone(normalized)) {
            mobilePhone = normalized;
            break;
          }
        }
        
        // 핸드폰 번호가 없으면 스킵
        if (mobilePhone == null) continue;
        
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
          phone: Value(mobilePhone),
          name: Value(c.displayName),
          groupTag: Value(groupTag),
          isFavorite: Value(isStarred), // 스타 여부 저장
          photoData: Value(photoBase64), // 사진 데이터 저장
        );

        await db.upsertContact(companion);
      }
      
      // 통화 기록 동기화 기능 제거됨 (권한 최소화)
      
    } else {
      // Windows/Web/Mac: Seed Mock Data
      await _seedMockData(db);
    }
  }
  
  /// 핸드폰 번호인지 확인 (010, 011, 016, 017, 018, 019로 시작)
  bool _isMobilePhone(String normalized) {
    // 한국 핸드폰: 010, 011, 016, 017, 018, 019
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
