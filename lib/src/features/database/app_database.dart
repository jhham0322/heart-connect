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

@DriftDatabase(tables: [Contacts, History, Templates, GalleryFavorites, SavedCards, Holidays])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6; // Incremented for Holidays table

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
    },
    beforeOpen: (details) async {
      final count = await select(holidays).get();
      if (count.isEmpty) {
        await _insertDefaultHolidays(this);
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
    return into(contacts).insertOnConflictUpdate(entry);
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
  Future<int> deleteSavedCard(int id) => (delete(savedCards)..where((t) => t.id.equals(id))).go();
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
