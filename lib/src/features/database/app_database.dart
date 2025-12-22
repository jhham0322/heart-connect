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
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Contacts, History, Templates, GalleryFavorites, SavedCards])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3; // Incremented for new table

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
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
    },
  );

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
  
  Future<int> insertHistory(HistoryCompanion entry) => into(history).insert(entry);

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
