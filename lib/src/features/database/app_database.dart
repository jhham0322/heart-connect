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
  TextColumn get assetPath => text()();
  @override
  Set<Column> get primaryKey => {assetPath};
}

@DriftDatabase(tables: [Contacts, History, Templates, GalleryFavorites])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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

  // GALLERY FAVORITES methods
  Future<List<GalleryFavorite>> getAllGalleryFavorites() => select(galleryFavorites).get();
  Stream<List<GalleryFavorite>> watchAllGalleryFavorites() => select(galleryFavorites).watch();
  Future<int> addGalleryFavorite(String path) => into(galleryFavorites).insert(GalleryFavoritesCompanion.insert(assetPath: path), mode: InsertMode.insertOrReplace);
  Future<int> removeGalleryFavorite(String path) => (delete(galleryFavorites)..where((t) => t.assetPath.equals(path))).go();
  Future<bool> isGalleryFavorite(String path) async {
    final query = select(galleryFavorites)..where((t) => t.assetPath.equals(path));
    final result = await query.getSingleOrNull();
    return result != null;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
