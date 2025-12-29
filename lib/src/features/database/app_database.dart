import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// 1. Contacts Table
class Contacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get phone => text().unique()(); // Phone number is unique identifier
  TextColumn get name => text().withLength(min: 1, max: 50)();
  DateTimeColumn get birthday => dateTime().nullable()();
  TextColumn get groupTag => text().nullable()(); // 'Family', 'Friend', etc.
  DateTimeColumn get lastSentDate => dateTime().nullable()();
  DateTimeColumn get lastReceivedDate => dateTime().nullable()();
  TextColumn get photoData => text().nullable()(); // Base64 or path to avatar
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

// 2. History Table
class History extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contactId => integer().references(Contacts, #id)();
  TextColumn get type => text()(); // 'SENT', 'RECEIVED'
  DateTimeColumn get eventDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get message => text().nullable()();
  TextColumn get imagePath => text().nullable()(); // Path to sent/received image
  IntColumn get savedCardId => integer().nullable().references(SavedCards, #id)(); // Reference to SavedCard
}

// 3. Templates Table
class Templates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()(); // 'Birthday', 'Thanks', 'Love'
  TextColumn get content => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

// 4. Gallery Favorites Table
class GalleryFavorites extends Table {
  TextColumn get imagePath => text()();
  DateTimeColumn get addedDate => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {imagePath};
}

// 5. Saved Cards (Drafts)
class SavedCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withDefault(const Constant('제목 없음'))();
  TextColumn get htmlContent => text()(); // HTML format for rich text support
  TextColumn get footerText => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get frame => text().nullable()();
  TextColumn get boxStyle => text().nullable()();
  TextColumn get footerStyle => text().nullable()();
  TextColumn get mainStyle => text().nullable()();
  BoolColumn get isFooterActive => boolean().withDefault(const Constant(false))();
  TextColumn get topic => text().nullable()(); // 선택된 주제 (새해, 감사, 크리스마스 등)
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 6. Holidays Table
class Holidays extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  DateTimeColumn get date => dateTime()(); // YYYY-MM-DD
  TextColumn get type => text().withDefault(const Constant('Holiday'))(); // Holiday, Election, etc.
  BoolColumn get isLunar => boolean().withDefault(const Constant(false))();
}

// 7. Contact Groups Table
class ContactGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get icon => text().withDefault(const Constant('group'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 8. Contact-Group Memberships Table (Many-to-Many)
class ContactGroupMemberships extends Table {
  IntColumn get contactId => integer().references(Contacts, #id)();
  IntColumn get groupId => integer().references(ContactGroups, #id)();
  
  @override
  Set<Column> get primaryKey => {contactId, groupId};
}

// 9. Greeting Templates Table
class GreetingTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get topic => text()();      // 주제: 새해, 감사, 크리스마스 등
  TextColumn get sentiment => text()();  // 감성종류: polite, witty, friendly, poetic
  TextColumn get message => text()();    // 문구 내용
}

// 10. Greeting Topics Table (콤보박스 표시용)
class GreetingTopics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();       // 주제 이름: 새해, 생일, 감사 등
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();  // 정렬 순서
}

class DailyPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get content => text()();
  TextColumn get type => text().withDefault(const Constant('Normal'))(); // Normal, Birthday, Holiday
  IntColumn get goalCount => integer().withDefault(const Constant(5))();
  BoolColumn get isGenerated => boolean().withDefault(const Constant(true))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get recipients => text().nullable()(); // JSON list of recipients: [{"name":"Kim","phone":"010..."}]
}

@DriftDatabase(tables: [Contacts, History, Templates, GalleryFavorites, SavedCards, Holidays, DailyPlans, ContactGroups, ContactGroupMemberships, GreetingTemplates, GreetingTopics])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  // Constructor for testing
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 13; // Version 13: GreetingTopics table

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _insertDefaultHolidays(this);
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Create GalleryFavorites table for version 2
        await m.createTable(galleryFavorites);
      }
      if (from < 3) {
        // Create SavedCards table for version 3
        await m.createTable(savedCards);
      }
      if (from < 4) {
        await m.addColumn(savedCards, savedCards.frame);
        await m.addColumn(savedCards, savedCards.boxStyle);
        await m.addColumn(savedCards, savedCards.footerStyle);
        await m.addColumn(savedCards, savedCards.mainStyle);
        await m.addColumn(savedCards, savedCards.isFooterActive);
      }
      if (from < 5) {
        await m.addColumn(history, history.savedCardId);
      }
      if (from < 6) {
        await m.createTable(holidays);
        await _insertDefaultHolidays(this);
      }
      if (from < 7) {
        await m.createTable(dailyPlans);
      }
      if (from < 8) {
        await m.addColumn(dailyPlans, dailyPlans.isCompleted);
        await m.addColumn(dailyPlans, dailyPlans.sortOrder);
      }
      if (from < 9) {
        await m.addColumn(dailyPlans, dailyPlans.recipients);
      }
      if (from < 10) {
        // Version 10: Ensure recipients column exists (re-run of 9 if needed, but Drift handles versioning)
        // No new schema changes, just a bump to trigger migration logic if it was missed.
      }
      if (from < 11) {
        // Version 11: Contact Groups feature
        await m.createTable(contactGroups);
        await m.createTable(contactGroupMemberships);
      }
      if (from < 12) {
        // Version 12: Greeting Templates & SavedCards topic
        await m.createTable(greetingTemplates);
        await m.addColumn(savedCards, savedCards.topic);
      }
      if (from < 13) {
        // Version 13: Greeting Topics table for combo box
        await m.createTable(greetingTopics);
      }
    },
    beforeOpen: (details) async {
      final count = await select(holidays).get();
      if (count.isEmpty) {
        await _insertDefaultHolidays(this);
      }

      // FIX: Ensure 'recipients' column exists in daily_plans (Manual repair)
      try {
        final columns = await customSelect('PRAGMA table_info(daily_plans)').get();
        final hasRecipients = columns.any((row) => row.read<String>('name') == 'recipients');
        if (!hasRecipients) {
          print('[AppDatabase] Repairing DB: Adding missing recipients column to daily_plans');
          await customStatement('ALTER TABLE daily_plans ADD COLUMN recipients TEXT NULL');
        } else {
           print('[AppDatabase] recipients column exists.');
        }
      } catch (e) {
        print('[AppDatabase] Error checking/repairing schema: $e');
      }
    },
  );

  Future<void> _insertDefaultHolidays(AppDatabase db) async {
    final list = [
      HolidaysCompanion.insert(name: '신정', date: DateTime(2025, 1, 1), type: const Value('Holiday')),
      HolidaysCompanion.insert(name: '설날 연휴', date: DateTime(2025, 1, 28), type: const Value('Holiday')),
      HolidaysCompanion.insert(name: '설날', date: DateTime(2025, 1, 29), type: const Value('Holiday')),
      HolidaysCompanion.insert(name: '설날 연휴', date: DateTime(2025, 1, 30), type: const Value('Holiday')),
      HolidaysCompanion.insert(name: '삼일절', date: DateTime(2025, 3, 1), type: const Value('Holiday')),
      HolidaysCompanion.insert(name: '어린이날', date: DateTime(2025, 5, 5), type: const Value('Holiday')),
      HolidaysCompanion.insert(name: '부처님오신날', date: DateTime(2025, 5, 5), type: const Value('Holiday')),
      HolidaysCompanion.insert(name: '대체공휴일(어린이날)', date: DateTime(2025, 5, 6), type: const Value('Holiday')),
      HolidaysCompanion.insert(name: '현충일', date: DateTime(2025, 6, 6), type: const Value('Holiday')),
      HolidaysCompanion.insert(name: '광복절', date: DateTime(2025, 8, 15), type: const Value('Holiday')),
      HolidaysCompanion.insert(name: '추석 연휴', date: DateTime(2025, 10, 5), type: const Value('Holiday')),
      HolidaysCompanion.insert(name: '추석', date: DateTime(2025, 10, 6), type: const Value('Holiday')),
      HolidaysCompanion.insert(name: '추석 연휴', date: DateTime(2025, 10, 7), type: const Value('Holiday')),
      HolidaysCompanion.insert(name: '개천절', date: DateTime(2025, 10, 3), type: const Value('Holiday')),
      HolidaysCompanion.insert(name: '한글날', date: DateTime(2025, 10, 9), type: const Value('Holiday')),
      HolidaysCompanion.insert(name: '성탄절', date: DateTime(2025, 12, 25), type: const Value('Holiday')),
    ];
    
    await db.batch((batch) {
      batch.insertAll(holidays, list);
    });
  }

  // READ: Contacts
  Future<List<Contact>> getAllContacts() => select(contacts).get();
  Stream<List<Contact>> watchAllContacts() => select(contacts).watch();
  
  // CREATE/UPDATE: Contact
  Future<int> insertContact(ContactsCompanion entry) => into(contacts).insert(entry);
  Future<bool> updateContact(Contact entry) => update(contacts).replace(entry);
  Future<int> upsertContact(ContactsCompanion entry) async {
    // phone 컬럼이 UNIQUE이므로 phone 기준으로 upsert
    final existingContact = await (select(contacts)
      ..where((t) => t.phone.equals(entry.phone.value))
    ).getSingleOrNull();
    
    if (existingContact != null) {
      // Update existing
      await (update(contacts)..where((t) => t.id.equals(existingContact.id))).write(
        ContactsCompanion(
          name: entry.name,
          groupTag: entry.groupTag,
          birthday: entry.birthday,
          isFavorite: entry.isFavorite, // 즐겨찾기 정보도 업데이트
          photoData: entry.photoData, // 사진 데이터도 업데이트
        )
      );
      return existingContact.id;
    } else {
      // Insert new
      return into(contacts).insert(entry);
    }
  }
  
  // 통화 기록 기반 연락처 업데이트
  Future<void> updateContactCallDate(int contactId, DateTime? lastSent, DateTime? lastReceived) async {
    final companion = ContactsCompanion(
      lastSentDate: lastSent != null ? Value(lastSent) : const Value.absent(),
      lastReceivedDate: lastReceived != null ? Value(lastReceived) : const Value.absent(),
    );
    await (update(contacts)..where((t) => t.id.equals(contactId))).write(companion);
  }
  
  // 가족 태그 업데이트
  Future<void> updateContactFamily(int contactId, bool isFamily) async {
    final companion = ContactsCompanion(
      groupTag: Value(isFamily ? '가족' : null),
    );
    await (update(contacts)..where((t) => t.id.equals(contactId))).write(companion);
  }

  // 가족 연락처 조회
  Future<List<Contact>> getFamilyContacts() {
    return (select(contacts)..where((t) => t.groupTag.equals('가족'))).get();
  }

  // ========== groupTag 기반 그룹 관리 ==========
  
  // 모든 고유 그룹 태그 조회 (ContactGroups 테이블 + contacts.groupTag 합집합)
  Future<List<String>> getDistinctGroupTags() async {
    // 1. contacts 테이블에서 실제 사용 중인 groupTag
    final contactGroupTags = await customSelect(
      'SELECT DISTINCT group_tag FROM contacts WHERE group_tag IS NOT NULL AND group_tag != \'\' ORDER BY group_tag',
    ).get();
    final fromContacts = contactGroupTags.map((row) => row.read<String>('group_tag')).toSet();
    
    // 2. ContactGroups 테이블에서 등록된 그룹 이름
    final allGroups = await select(contactGroups).get();
    final fromGroups = allGroups.map((g) => g.name).toSet();
    
    // 3. 두 집합 합치기 (중복 제거)
    final combined = {...fromContacts, ...fromGroups}.toList();
    combined.sort();
    return combined;
  }

  // 특정 그룹 태그를 가진 연락처 조회
  Future<List<Contact>> getContactsByGroupTag(String groupTag) {
    return (select(contacts)..where((t) => t.groupTag.equals(groupTag))).get();
  }

  // 특정 그룹 태그를 가진 연락처 수
  Future<int> getContactCountByGroupTag(String groupTag) async {
    final count = await customSelect(
      'SELECT COUNT(*) as cnt FROM contacts WHERE group_tag = ?',
      variables: [Variable.withString(groupTag)],
    ).getSingle();
    return count.read<int>('cnt');
  }

  // 연락처의 그룹 태그 업데이트
  Future<void> updateContactGroupTag(int contactId, String? groupTag) async {
    final companion = ContactsCompanion(
      groupTag: Value(groupTag),
    );
    await (update(contacts)..where((t) => t.id.equals(contactId))).write(companion);
  }

  // 여러 연락처를 특정 그룹 태그에 추가
  Future<void> addContactsToGroupTag(List<int> contactIds, String groupTag) async {
    for (final id in contactIds) {
      await updateContactGroupTag(id, groupTag);
    }
  }

  // 연락처를 그룹에서 제거 (groupTag를 null로)
  Future<void> removeContactFromGroupTag(int contactId) async {
    await updateContactGroupTag(contactId, null);
  }

  // HISTORY methods
  Future<List<HistoryData>> getHistoryForContact(int contactId) {
    return (select(history)..where((t) => t.contactId.equals(contactId))).get();
  }
  
  // HOLIDAYS methods
  Future<List<Holiday>> getHolidays(DateTime start, DateTime end) {
    return (select(holidays)
      ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerOrEqualValue(end))
    ).get();
  }
  
  Future<int> insertHistory(HistoryCompanion entry) => into(history).insert(entry);

  // --- Daily Plans Methods ---
  Future<List<DailyPlan>> getPlansForRange(DateTime start, DateTime end) {
    return (select(dailyPlans)
      ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerOrEqualValue(end))
      ..orderBy([
        (t) => OrderingTerm(expression: t.date),
        (t) => OrderingTerm(expression: t.sortOrder),
      ])
    ).get();
  }
  
  // 모든 일정 가져오기 (백업용)
  Future<List<DailyPlan>> getAllDailyPlans() {
    return (select(dailyPlans)
      ..orderBy([(t) => OrderingTerm(expression: t.date)])
    ).get();
  }
  
  Future<List<DailyPlan>> getFuturePlans(DateTime start) {
     return (select(dailyPlans)
      ..where((t) => t.date.isBiggerOrEqualValue(start))
      ..orderBy([
        (t) => OrderingTerm(expression: t.date),
        (t) => OrderingTerm(expression: t.sortOrder),
      ])
    ).get();
  }

  Future<List<DailyPlan>> getTodayPlans(DateTime today) {
    return (select(dailyPlans)
      ..where((t) => t.date.equals(today) & t.isCompleted.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])
    ).get();
  }

  Future<DailyPlan> getPlan(int id) {
    return (select(dailyPlans)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<int> insertPlan(DailyPlansCompanion entry) => into(dailyPlans).insert(entry);
  
  // 간단한 일정 추가 (스플래시용)
  Future<int> insertPlanSimple({
    required DateTime date,
    required String content,
    String type = 'Schedule',
  }) {
    return into(dailyPlans).insert(DailyPlansCompanion.insert(
      date: date,
      content: content,
      type: Value(type),
      goalCount: const Value(5),
      isGenerated: const Value(false),
      sortOrder: const Value(0),
      isCompleted: const Value(false),
    ));
  }
  
  Future<bool> updatePlan(DailyPlan entry) => update(dailyPlans).replace(entry);
  
  Future<int> deletePlan(int id) => (delete(dailyPlans)..where((t) => t.id.equals(id))).go();

  Future<void> reschedulePlan(int id, DateTime newDate) {
    return (update(dailyPlans)..where((t) => t.id.equals(id))).write(
      DailyPlansCompanion(date: Value(newDate), sortOrder: const Value(0))
    );
  }

  Future<void> updatePlanType(int id, String newType) {
    return (update(dailyPlans)..where((t) => t.id.equals(id))).write(
      DailyPlansCompanion(type: Value(newType))
    );
  }



  Future<void> completePlan(int id) {
    return (update(dailyPlans)..where((t) => t.id.equals(id))).write(
      const DailyPlansCompanion(isCompleted: Value(true))
    );
  }

  Future<void> movePlanToEnd(int id, DateTime date) async {
    // Get max sortOrder for the date
    final maxOrder = await (select(dailyPlans)
      ..where((t) => t.date.equals(date))
      ..orderBy([(t) => OrderingTerm.desc(t.sortOrder)])
      ..limit(1)
    ).map((row) => row.sortOrder).getSingleOrNull() ?? 0;
    
    await (update(dailyPlans)..where((t) => t.id.equals(id))).write(
      DailyPlansCompanion(sortOrder: Value(maxOrder + 1))
    );
  }
  
  Future<void> updatePlanContent(int id, String newContent) {
    return (update(dailyPlans)..where((t) => t.id.equals(id))).write(
      DailyPlansCompanion(content: Value(newContent))
    );
  }

  Future<void> updatePlanDetails(int id, String title, DateTime date, String type) {
    return (update(dailyPlans)..where((t) => t.id.equals(id))).write(
      DailyPlansCompanion(
        content: Value(title),
        date: Value(date),
        type: Value(type),
      )
    );
  }

  Future<void> updatePlanDetailsWithRecipients(int id, String title, DateTime date, String type, String? recipients) {
    print('[AppDatabase] Executing UPDATE DailyPlans: id=$id, title=$title, recipients=$recipients');
    _logToDebugFile('[AppDatabase] Executing UPDATE DailyPlans: id=$id, title=$title, recipients=$recipients');
    return (update(dailyPlans)..where((t) => t.id.equals(id))).write(
      DailyPlansCompanion(
        content: Value(title),
        date: Value(date),
        type: Value(type),
        recipients: Value(recipients),
      )
    ).then((rows) {
      _logToDebugFile('[AppDatabase] Update Result: $rows rows affected for plan $id');
      print('[AppDatabase] Update Result: $rows rows affected for plan $id');
    });
  }

  Future<void> _logToDebugFile(String message) async {
    try {
      final file = File('Assets/Debug/debug.txt');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      await file.writeAsString('${DateTime.now()}: $message\n', mode: FileMode.append);
    } catch (e) {
      print('Failed to write to debug file: $e');
    }
  }

  Future<void> updatePlanRecipients(int id, String? recipients) {
    return (update(dailyPlans)..where((t) => t.id.equals(id))).write(
      DailyPlansCompanion(
        recipients: Value(recipients),
      )
    );
  }

  Future<void> deleteOldPlans(DateTime cutoff) {
    return (delete(dailyPlans)..where((t) => t.date.isSmallerThanValue(cutoff))).go();
  }

  // Mock 데이터 삭제 (이전에 저장된 테스트용 데이터 정리)
  Future<void> deleteMockPlans() async {
    final mockTitles = [
      '유재석의 생일',
      '박명수의 생일',
      '결혼기념일 10주년',
      'Christmas (성탄절)',
      '신정 (New Year)',
    ];
    
    for (var title in mockTitles) {
      await (delete(dailyPlans)..where((t) => t.content.equals(title))).go();
    }
    print('[AppDatabase] Deleted mock plans from database');
  }

  // --- Plan Generation Logic ---
  Future<void> generateWeeklyPlans() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Cleanup old plans (keep last 30 days for reference)
    await deleteOldPlans(today.subtract(const Duration(days: 30)));
    
    // Check next 7 days
    for (int i = 0; i <= 7; i++) {
       final targetDate = today.add(Duration(days: i));
       
       // Check if plan exists
       final existing = await (select(dailyPlans)..where((t) => t.date.equals(targetDate))).get();
       // Only skip if we have already GENERATED plans for this day. 
       // If only manual/calendar plans exist, we should still generate base plans.
       if (existing.any((e) => e.isGenerated)) continue; 
       
       // Generate Plan
       // 1. Check Holidays
       final holidayList = await (select(holidays)..where((t) => t.date.equals(targetDate))).get();
       
       // 2. Check Birthdays
       final contactList = await getAllContacts();
       final birthdayContacts = contactList.where((c) {
          if (c.birthday == null) return false;
          final bday = c.birthday!;
          // Simple check for same month/day (ignoring year for now or matching current year)
          // Since we are generating for specific targetDate (year included), we need to check if birthday falls on this day in THIS year.
          // Note: getAllContacts returns birthday with original year.
          final nextBday = DateTime(targetDate.year, bday.month, bday.day);
          return nextBday.month == targetDate.month && nextBday.day == targetDate.day;
       }).toList();
       
       // 3. Create Plan Items
       // If multiple events, we create multiple rows? Or one main row?
       // The user prompt implies "Plan Table" -> "Upcoming Events".
       // If we create multiple rows, we can display them all.
       
       bool hasEvent = false;
       
       // Holidays
       for (var h in holidayList) {
          await into(dailyPlans).insert(DailyPlansCompanion(
             date: Value(targetDate),
             content: Value(h.name),
             type: Value('Holiday'),
             goalCount: Value(10), // Higher goal for holidays?
             isGenerated: const Value(true),
          ));
          hasEvent = true;
       }
       
       // Birthdays
       for (var c in birthdayContacts) {
          await into(dailyPlans).insert(DailyPlansCompanion(
             date: Value(targetDate),
             content: Value('${c.name} Birthday'),
             type: Value('Birthday'),
             goalCount: Value(10),
             isGenerated: const Value(true),
          ));
          hasEvent = true;
       }
       
       // If no events, create default plan
       if (!hasEvent) {
          await into(dailyPlans).insert(DailyPlansCompanion(
             date: Value(targetDate),
             content: Value('Daily Warmth'),
             type: Value('Normal'),
             goalCount: Value(5),
             isGenerated: const Value(true),
          ));
       }
    }
  }

  Stream<List<RecentContactData>> watchRecentContacts() {
    return customSelect(
      'SELECT c.*, h.event_date as latest_date, h.message as latest_message, h.type as latest_type, h.image_path as card_thumbnail '
      'FROM contacts c '
      'JOIN history h ON h.contact_id = c.id '
      'WHERE h.event_date = ('
      '  SELECT MAX(h2.event_date) '
      '  FROM history h2 '
      '  WHERE h2.contact_id = c.id'
      ') '
      'ORDER BY latest_date DESC',
      readsFrom: {contacts, history},
    ).map((row) {
      final contact = Contact(
        id: row.read<int>('id'),
        phone: row.read<String>('phone'),
        name: row.read<String>('name'),
        birthday: row.readNullable<DateTime>('birthday'),
        groupTag: row.readNullable<String>('group_tag'),
        lastSentDate: row.readNullable<DateTime>('last_sent_date'),
        lastReceivedDate: row.readNullable<DateTime>('last_received_date'),
        photoData: row.readNullable<String>('photo_data'),
        isFavorite: row.read<bool>('is_favorite'),
      );
      return RecentContactData(
        contact: contact,
        lastDate: row.read<DateTime>('latest_date'),
        lastMessage: row.readNullable<String>('latest_message'),
        lastType: row.read<String>('latest_type'),
        cardThumbnail: row.readNullable<String>('card_thumbnail'),
      );
    }).watch();
  }

  // GALLERY FAVORITES
  Future<int> addGalleryFavorite(String path) {
    return into(galleryFavorites).insert(GalleryFavoritesCompanion.insert(imagePath: path), mode: InsertMode.insertOrIgnore);
  }

  Future<int> removeGalleryFavorite(String path) {
    return (delete(galleryFavorites)..where((t) => t.imagePath.equals(path))).go();
  }

  Future<List<String>> getAllGalleryFavorites() {
    return select(galleryFavorites).map((row) => row.imagePath).get();
  }

  // STATISTICS & EVENTS
  Future<int> getTodaySentCount() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final countExp = history.id.count();
    final query = selectOnly(history)
      ..addColumns([countExp])
      ..where(history.type.equals('SENT') & 
              history.eventDate.isBetweenValues(startOfDay, endOfDay));
    
    return await query.map((row) => row.read(countExp)).getSingle() ?? 0;
  }

  // SAVED CARDS (DRAFTS) methods
  Future<List<SavedCard>> getAllSavedCards() => (select(savedCards)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  Future<int> insertSavedCard(SavedCardsCompanion entry) => into(savedCards).insert(entry);
  Future<bool> updateSavedCard(SavedCard entry) => update(savedCards).replace(entry);
  Future<int> deleteSavedCard(int id) => (delete(savedCards)..where((t) => t.id.equals(id))).go();

  // --- Contact Groups Methods ---
  Future<List<ContactGroup>> getAllContactGroups() => 
    (select(contactGroups)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();
  
  Stream<List<ContactGroup>> watchAllContactGroups() => 
    (select(contactGroups)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).watch();
  
  Future<int> insertContactGroup(ContactGroupsCompanion entry) => 
    into(contactGroups).insert(entry);
  
  Future<bool> updateContactGroup(ContactGroup entry) => 
    update(contactGroups).replace(entry);
  
  Future<int> deleteContactGroup(int id) async {
    // First remove all memberships for this group
    await (delete(contactGroupMemberships)..where((t) => t.groupId.equals(id))).go();
    // Then delete the group
    return (delete(contactGroups)..where((t) => t.id.equals(id))).go();
  }

  // --- Contact Group Memberships Methods ---
  Future<int> addContactToGroup(int contactId, int groupId) => 
    into(contactGroupMemberships).insert(
      ContactGroupMembershipsCompanion.insert(contactId: contactId, groupId: groupId),
      mode: InsertMode.insertOrIgnore,
    );
  
  Future<int> removeContactFromGroup(int contactId, int groupId) => 
    (delete(contactGroupMemberships)..where((t) => 
      t.contactId.equals(contactId) & t.groupId.equals(groupId)
    )).go();
  
  Future<List<ContactGroup>> getGroupsForContact(int contactId) {
    final query = select(contactGroups).join([
      innerJoin(contactGroupMemberships, 
        contactGroupMemberships.groupId.equalsExp(contactGroups.id))
    ])..where(contactGroupMemberships.contactId.equals(contactId));
    
    return query.map((row) => row.readTable(contactGroups)).get();
  }
  
  Stream<List<ContactGroup>> watchGroupsForContact(int contactId) {
    final query = select(contactGroups).join([
      innerJoin(contactGroupMemberships, 
        contactGroupMemberships.groupId.equalsExp(contactGroups.id))
    ])..where(contactGroupMemberships.contactId.equals(contactId));
    
    return query.map((row) => row.readTable(contactGroups)).watch();
  }
  
  Future<List<Contact>> getContactsInGroup(int groupId) {
    final query = select(contacts).join([
      innerJoin(contactGroupMemberships, 
        contactGroupMemberships.contactId.equalsExp(contacts.id))
    ])..where(contactGroupMemberships.groupId.equals(groupId));
    
    return query.map((row) => row.readTable(contacts)).get();
  }
  
  Stream<List<Contact>> watchContactsInGroup(int groupId) {
    final query = select(contacts).join([
      innerJoin(contactGroupMemberships, 
        contactGroupMemberships.contactId.equalsExp(contacts.id))
    ])..where(contactGroupMemberships.groupId.equals(groupId));
    
    return query.map((row) => row.readTable(contacts)).watch();
  }
  
  Future<int> getContactCountInGroup(int groupId) async {
    final query = selectOnly(contactGroupMemberships)
      ..addColumns([contactGroupMemberships.contactId.count()])
      ..where(contactGroupMemberships.groupId.equals(groupId));
    
    return await query.map((row) => row.read(contactGroupMemberships.contactId.count())).getSingle() ?? 0;
  }
  
  Future<void> updateContactGroups(int contactId, List<int> groupIds) async {
    // Remove all existing memberships
    await (delete(contactGroupMemberships)..where((t) => t.contactId.equals(contactId))).go();
    // Add new memberships
    for (final groupId in groupIds) {
      await addContactToGroup(contactId, groupId);
    }
  }

  // --- Greeting Templates Methods ---
  
  /// 인사말 삽입
  Future<int> insertGreeting(GreetingTemplatesCompanion entry) => 
    into(greetingTemplates).insert(entry);
  
  /// 여러 인사말 일괄 삽입
  Future<void> insertGreetings(List<GreetingTemplatesCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(greetingTemplates, entries);
    });
  }
  
  /// 사용 가능한 주제 목록 조회
  Future<List<String>> getDistinctTopics() async {
    final result = await customSelect(
      'SELECT DISTINCT topic FROM greeting_templates ORDER BY topic',
    ).get();
    return result.map((row) => row.read<String>('topic')).toList();
  }
  
  /// 특정 주제+감성에서 랜덤 문구 조회
  Future<String?> getRandomGreeting(String topic, String sentiment) async {
    final result = await customSelect(
      'SELECT message FROM greeting_templates WHERE topic = ? AND sentiment = ? ORDER BY RANDOM() LIMIT 1',
      variables: [Variable.withString(topic), Variable.withString(sentiment)],
    ).getSingleOrNull();
    return result?.read<String>('message');
  }
  
  /// 특정 주제의 모든 문구 조회 (감성 무관)
  Future<List<GreetingTemplate>> getGreetingsByTopic(String topic) {
    return (select(greetingTemplates)..where((t) => t.topic.equals(topic))).get();
  }
  
  /// 모든 인사말 템플릿 조회
  Future<List<GreetingTemplate>> getAllGreetingTemplates() => select(greetingTemplates).get();
  
  /// 인사말 템플릿 삭제 (주제별)
  Future<int> deleteGreetingsByTopic(String topic) =>
    (delete(greetingTemplates)..where((t) => t.topic.equals(topic))).go();

  // --- Greeting Topics Methods ---
  
  /// 모든 주제 목록 조회 (정렬순)
  Future<List<GreetingTopic>> getAllGreetingTopics() =>
    (select(greetingTopics)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();
  
  /// 주제 이름 목록만 조회 (콤보박스용)
  Future<List<String>> getGreetingTopicNames() async {
    final topics = await getAllGreetingTopics();
    return topics.map((t) => t.name).toList();
  }
  
  /// 주제 삽입
  Future<int> insertGreetingTopic(GreetingTopicsCompanion entry) =>
    into(greetingTopics).insert(entry);
  
  /// 여러 주제 일괄 삽입
  Future<void> insertGreetingTopicsIfEmpty(List<String> topicNames) async {
    final existing = await getAllGreetingTopics();
    if (existing.isEmpty) {
      await batch((batch) {
        for (int i = 0; i < topicNames.length; i++) {
          batch.insert(greetingTopics, GreetingTopicsCompanion.insert(
            name: topicNames[i],
            sortOrder: Value(i),
          ));
        }
      });
    }
  }
  
  /// 주제 삭제
  Future<int> deleteGreetingTopic(int id) =>
    (delete(greetingTopics)..where((t) => t.id.equals(id))).go();
  
  /// 모든 주제와 인사말 데이터 초기화
  Future<void> resetAllGreetingData() async {
    await delete(greetingTemplates).go();
    await delete(greetingTopics).go();
  }

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}

class RecentContactData {
  final Contact contact;
  final DateTime lastDate;
  final String? lastMessage;
  final String? lastType; // 'SENT' or 'RECEIVED'
  final String? cardThumbnail;

  RecentContactData({
    required this.contact,
    required this.lastDate,
    this.lastMessage,
    this.lastType,
    this.cardThumbnail,
  });
}
