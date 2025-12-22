// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _birthdayMeta =
      const VerificationMeta('birthday');
  @override
  late final GeneratedColumn<DateTime> birthday = GeneratedColumn<DateTime>(
      'birthday', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _groupTagMeta =
      const VerificationMeta('groupTag');
  @override
  late final GeneratedColumn<String> groupTag = GeneratedColumn<String>(
      'group_tag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSentDateMeta =
      const VerificationMeta('lastSentDate');
  @override
  late final GeneratedColumn<DateTime> lastSentDate = GeneratedColumn<DateTime>(
      'last_sent_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastReceivedDateMeta =
      const VerificationMeta('lastReceivedDate');
  @override
  late final GeneratedColumn<DateTime> lastReceivedDate =
      GeneratedColumn<DateTime>('last_received_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _photoDataMeta =
      const VerificationMeta('photoData');
  @override
  late final GeneratedColumn<String> photoData = GeneratedColumn<String>(
      'photo_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        phone,
        name,
        birthday,
        groupTag,
        lastSentDate,
        lastReceivedDate,
        photoData,
        isFavorite
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(Insertable<Contact> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('birthday')) {
      context.handle(_birthdayMeta,
          birthday.isAcceptableOrUnknown(data['birthday']!, _birthdayMeta));
    }
    if (data.containsKey('group_tag')) {
      context.handle(_groupTagMeta,
          groupTag.isAcceptableOrUnknown(data['group_tag']!, _groupTagMeta));
    }
    if (data.containsKey('last_sent_date')) {
      context.handle(
          _lastSentDateMeta,
          lastSentDate.isAcceptableOrUnknown(
              data['last_sent_date']!, _lastSentDateMeta));
    }
    if (data.containsKey('last_received_date')) {
      context.handle(
          _lastReceivedDateMeta,
          lastReceivedDate.isAcceptableOrUnknown(
              data['last_received_date']!, _lastReceivedDateMeta));
    }
    if (data.containsKey('photo_data')) {
      context.handle(_photoDataMeta,
          photoData.isAcceptableOrUnknown(data['photo_data']!, _photoDataMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      birthday: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birthday']),
      groupTag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_tag']),
      lastSentDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_sent_date']),
      lastReceivedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_received_date']),
      photoData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_data']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  final int id;
  final String phone;
  final String name;
  final DateTime? birthday;
  final String? groupTag;
  final DateTime? lastSentDate;
  final DateTime? lastReceivedDate;
  final String? photoData;
  final bool isFavorite;
  const Contact(
      {required this.id,
      required this.phone,
      required this.name,
      this.birthday,
      this.groupTag,
      this.lastSentDate,
      this.lastReceivedDate,
      this.photoData,
      required this.isFavorite});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['phone'] = Variable<String>(phone);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || birthday != null) {
      map['birthday'] = Variable<DateTime>(birthday);
    }
    if (!nullToAbsent || groupTag != null) {
      map['group_tag'] = Variable<String>(groupTag);
    }
    if (!nullToAbsent || lastSentDate != null) {
      map['last_sent_date'] = Variable<DateTime>(lastSentDate);
    }
    if (!nullToAbsent || lastReceivedDate != null) {
      map['last_received_date'] = Variable<DateTime>(lastReceivedDate);
    }
    if (!nullToAbsent || photoData != null) {
      map['photo_data'] = Variable<String>(photoData);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      phone: Value(phone),
      name: Value(name),
      birthday: birthday == null && nullToAbsent
          ? const Value.absent()
          : Value(birthday),
      groupTag: groupTag == null && nullToAbsent
          ? const Value.absent()
          : Value(groupTag),
      lastSentDate: lastSentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSentDate),
      lastReceivedDate: lastReceivedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReceivedDate),
      photoData: photoData == null && nullToAbsent
          ? const Value.absent()
          : Value(photoData),
      isFavorite: Value(isFavorite),
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      id: serializer.fromJson<int>(json['id']),
      phone: serializer.fromJson<String>(json['phone']),
      name: serializer.fromJson<String>(json['name']),
      birthday: serializer.fromJson<DateTime?>(json['birthday']),
      groupTag: serializer.fromJson<String?>(json['groupTag']),
      lastSentDate: serializer.fromJson<DateTime?>(json['lastSentDate']),
      lastReceivedDate:
          serializer.fromJson<DateTime?>(json['lastReceivedDate']),
      photoData: serializer.fromJson<String?>(json['photoData']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'phone': serializer.toJson<String>(phone),
      'name': serializer.toJson<String>(name),
      'birthday': serializer.toJson<DateTime?>(birthday),
      'groupTag': serializer.toJson<String?>(groupTag),
      'lastSentDate': serializer.toJson<DateTime?>(lastSentDate),
      'lastReceivedDate': serializer.toJson<DateTime?>(lastReceivedDate),
      'photoData': serializer.toJson<String?>(photoData),
      'isFavorite': serializer.toJson<bool>(isFavorite),
    };
  }

  Contact copyWith(
          {int? id,
          String? phone,
          String? name,
          Value<DateTime?> birthday = const Value.absent(),
          Value<String?> groupTag = const Value.absent(),
          Value<DateTime?> lastSentDate = const Value.absent(),
          Value<DateTime?> lastReceivedDate = const Value.absent(),
          Value<String?> photoData = const Value.absent(),
          bool? isFavorite}) =>
      Contact(
        id: id ?? this.id,
        phone: phone ?? this.phone,
        name: name ?? this.name,
        birthday: birthday.present ? birthday.value : this.birthday,
        groupTag: groupTag.present ? groupTag.value : this.groupTag,
        lastSentDate:
            lastSentDate.present ? lastSentDate.value : this.lastSentDate,
        lastReceivedDate: lastReceivedDate.present
            ? lastReceivedDate.value
            : this.lastReceivedDate,
        photoData: photoData.present ? photoData.value : this.photoData,
        isFavorite: isFavorite ?? this.isFavorite,
      );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      id: data.id.present ? data.id.value : this.id,
      phone: data.phone.present ? data.phone.value : this.phone,
      name: data.name.present ? data.name.value : this.name,
      birthday: data.birthday.present ? data.birthday.value : this.birthday,
      groupTag: data.groupTag.present ? data.groupTag.value : this.groupTag,
      lastSentDate: data.lastSentDate.present
          ? data.lastSentDate.value
          : this.lastSentDate,
      lastReceivedDate: data.lastReceivedDate.present
          ? data.lastReceivedDate.value
          : this.lastReceivedDate,
      photoData: data.photoData.present ? data.photoData.value : this.photoData,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('id: $id, ')
          ..write('phone: $phone, ')
          ..write('name: $name, ')
          ..write('birthday: $birthday, ')
          ..write('groupTag: $groupTag, ')
          ..write('lastSentDate: $lastSentDate, ')
          ..write('lastReceivedDate: $lastReceivedDate, ')
          ..write('photoData: $photoData, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, phone, name, birthday, groupTag,
      lastSentDate, lastReceivedDate, photoData, isFavorite);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.id == this.id &&
          other.phone == this.phone &&
          other.name == this.name &&
          other.birthday == this.birthday &&
          other.groupTag == this.groupTag &&
          other.lastSentDate == this.lastSentDate &&
          other.lastReceivedDate == this.lastReceivedDate &&
          other.photoData == this.photoData &&
          other.isFavorite == this.isFavorite);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<int> id;
  final Value<String> phone;
  final Value<String> name;
  final Value<DateTime?> birthday;
  final Value<String?> groupTag;
  final Value<DateTime?> lastSentDate;
  final Value<DateTime?> lastReceivedDate;
  final Value<String?> photoData;
  final Value<bool> isFavorite;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.phone = const Value.absent(),
    this.name = const Value.absent(),
    this.birthday = const Value.absent(),
    this.groupTag = const Value.absent(),
    this.lastSentDate = const Value.absent(),
    this.lastReceivedDate = const Value.absent(),
    this.photoData = const Value.absent(),
    this.isFavorite = const Value.absent(),
  });
  ContactsCompanion.insert({
    this.id = const Value.absent(),
    required String phone,
    required String name,
    this.birthday = const Value.absent(),
    this.groupTag = const Value.absent(),
    this.lastSentDate = const Value.absent(),
    this.lastReceivedDate = const Value.absent(),
    this.photoData = const Value.absent(),
    this.isFavorite = const Value.absent(),
  })  : phone = Value(phone),
        name = Value(name);
  static Insertable<Contact> custom({
    Expression<int>? id,
    Expression<String>? phone,
    Expression<String>? name,
    Expression<DateTime>? birthday,
    Expression<String>? groupTag,
    Expression<DateTime>? lastSentDate,
    Expression<DateTime>? lastReceivedDate,
    Expression<String>? photoData,
    Expression<bool>? isFavorite,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (phone != null) 'phone': phone,
      if (name != null) 'name': name,
      if (birthday != null) 'birthday': birthday,
      if (groupTag != null) 'group_tag': groupTag,
      if (lastSentDate != null) 'last_sent_date': lastSentDate,
      if (lastReceivedDate != null) 'last_received_date': lastReceivedDate,
      if (photoData != null) 'photo_data': photoData,
      if (isFavorite != null) 'is_favorite': isFavorite,
    });
  }

  ContactsCompanion copyWith(
      {Value<int>? id,
      Value<String>? phone,
      Value<String>? name,
      Value<DateTime?>? birthday,
      Value<String?>? groupTag,
      Value<DateTime?>? lastSentDate,
      Value<DateTime?>? lastReceivedDate,
      Value<String?>? photoData,
      Value<bool>? isFavorite}) {
    return ContactsCompanion(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      groupTag: groupTag ?? this.groupTag,
      lastSentDate: lastSentDate ?? this.lastSentDate,
      lastReceivedDate: lastReceivedDate ?? this.lastReceivedDate,
      photoData: photoData ?? this.photoData,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (birthday.present) {
      map['birthday'] = Variable<DateTime>(birthday.value);
    }
    if (groupTag.present) {
      map['group_tag'] = Variable<String>(groupTag.value);
    }
    if (lastSentDate.present) {
      map['last_sent_date'] = Variable<DateTime>(lastSentDate.value);
    }
    if (lastReceivedDate.present) {
      map['last_received_date'] = Variable<DateTime>(lastReceivedDate.value);
    }
    if (photoData.present) {
      map['photo_data'] = Variable<String>(photoData.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('phone: $phone, ')
          ..write('name: $name, ')
          ..write('birthday: $birthday, ')
          ..write('groupTag: $groupTag, ')
          ..write('lastSentDate: $lastSentDate, ')
          ..write('lastReceivedDate: $lastReceivedDate, ')
          ..write('photoData: $photoData, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }
}

class $HistoryTable extends History with TableInfo<$HistoryTable, HistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
      'contact_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES contacts (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventDateMeta =
      const VerificationMeta('eventDate');
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
      'event_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, contactId, type, eventDate, message, imagePath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history';
  @override
  VerificationContext validateIntegrity(Insertable<HistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('event_date')) {
      context.handle(_eventDateMeta,
          eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta));
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}contact_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      eventDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}event_date'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
    );
  }

  @override
  $HistoryTable createAlias(String alias) {
    return $HistoryTable(attachedDatabase, alias);
  }
}

class HistoryData extends DataClass implements Insertable<HistoryData> {
  final int id;
  final int contactId;
  final String type;
  final DateTime eventDate;
  final String? message;
  final String? imagePath;
  const HistoryData(
      {required this.id,
      required this.contactId,
      required this.type,
      required this.eventDate,
      this.message,
      this.imagePath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_id'] = Variable<int>(contactId);
    map['type'] = Variable<String>(type);
    map['event_date'] = Variable<DateTime>(eventDate);
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    return map;
  }

  HistoryCompanion toCompanion(bool nullToAbsent) {
    return HistoryCompanion(
      id: Value(id),
      contactId: Value(contactId),
      type: Value(type),
      eventDate: Value(eventDate),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
    );
  }

  factory HistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryData(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<int>(json['contactId']),
      type: serializer.fromJson<String>(json['type']),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      message: serializer.fromJson<String?>(json['message']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<int>(contactId),
      'type': serializer.toJson<String>(type),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'message': serializer.toJson<String?>(message),
      'imagePath': serializer.toJson<String?>(imagePath),
    };
  }

  HistoryData copyWith(
          {int? id,
          int? contactId,
          String? type,
          DateTime? eventDate,
          Value<String?> message = const Value.absent(),
          Value<String?> imagePath = const Value.absent()}) =>
      HistoryData(
        id: id ?? this.id,
        contactId: contactId ?? this.contactId,
        type: type ?? this.type,
        eventDate: eventDate ?? this.eventDate,
        message: message.present ? message.value : this.message,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
      );
  HistoryData copyWithCompanion(HistoryCompanion data) {
    return HistoryData(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      type: data.type.present ? data.type.value : this.type,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      message: data.message.present ? data.message.value : this.message,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryData(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('type: $type, ')
          ..write('eventDate: $eventDate, ')
          ..write('message: $message, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, contactId, type, eventDate, message, imagePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryData &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.type == this.type &&
          other.eventDate == this.eventDate &&
          other.message == this.message &&
          other.imagePath == this.imagePath);
}

class HistoryCompanion extends UpdateCompanion<HistoryData> {
  final Value<int> id;
  final Value<int> contactId;
  final Value<String> type;
  final Value<DateTime> eventDate;
  final Value<String?> message;
  final Value<String?> imagePath;
  const HistoryCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.type = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.message = const Value.absent(),
    this.imagePath = const Value.absent(),
  });
  HistoryCompanion.insert({
    this.id = const Value.absent(),
    required int contactId,
    required String type,
    this.eventDate = const Value.absent(),
    this.message = const Value.absent(),
    this.imagePath = const Value.absent(),
  })  : contactId = Value(contactId),
        type = Value(type);
  static Insertable<HistoryData> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<String>? type,
    Expression<DateTime>? eventDate,
    Expression<String>? message,
    Expression<String>? imagePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (type != null) 'type': type,
      if (eventDate != null) 'event_date': eventDate,
      if (message != null) 'message': message,
      if (imagePath != null) 'image_path': imagePath,
    });
  }

  HistoryCompanion copyWith(
      {Value<int>? id,
      Value<int>? contactId,
      Value<String>? type,
      Value<DateTime>? eventDate,
      Value<String?>? message,
      Value<String?>? imagePath}) {
    return HistoryCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      type: type ?? this.type,
      eventDate: eventDate ?? this.eventDate,
      message: message ?? this.message,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('type: $type, ')
          ..write('eventDate: $eventDate, ')
          ..write('message: $message, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }
}

class $TemplatesTable extends Templates
    with TableInfo<$TemplatesTable, Template> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, category, content, isFavorite];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'templates';
  @override
  VerificationContext validateIntegrity(Insertable<Template> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Template map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Template(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
    );
  }

  @override
  $TemplatesTable createAlias(String alias) {
    return $TemplatesTable(attachedDatabase, alias);
  }
}

class Template extends DataClass implements Insertable<Template> {
  final int id;
  final String category;
  final String content;
  final bool isFavorite;
  const Template(
      {required this.id,
      required this.category,
      required this.content,
      required this.isFavorite});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category'] = Variable<String>(category);
    map['content'] = Variable<String>(content);
    map['is_favorite'] = Variable<bool>(isFavorite);
    return map;
  }

  TemplatesCompanion toCompanion(bool nullToAbsent) {
    return TemplatesCompanion(
      id: Value(id),
      category: Value(category),
      content: Value(content),
      isFavorite: Value(isFavorite),
    );
  }

  factory Template.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Template(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      content: serializer.fromJson<String>(json['content']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<String>(category),
      'content': serializer.toJson<String>(content),
      'isFavorite': serializer.toJson<bool>(isFavorite),
    };
  }

  Template copyWith(
          {int? id, String? category, String? content, bool? isFavorite}) =>
      Template(
        id: id ?? this.id,
        category: category ?? this.category,
        content: content ?? this.content,
        isFavorite: isFavorite ?? this.isFavorite,
      );
  Template copyWithCompanion(TemplatesCompanion data) {
    return Template(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      content: data.content.present ? data.content.value : this.content,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Template(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('content: $content, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, category, content, isFavorite);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Template &&
          other.id == this.id &&
          other.category == this.category &&
          other.content == this.content &&
          other.isFavorite == this.isFavorite);
}

class TemplatesCompanion extends UpdateCompanion<Template> {
  final Value<int> id;
  final Value<String> category;
  final Value<String> content;
  final Value<bool> isFavorite;
  const TemplatesCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.content = const Value.absent(),
    this.isFavorite = const Value.absent(),
  });
  TemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String category,
    required String content,
    this.isFavorite = const Value.absent(),
  })  : category = Value(category),
        content = Value(content);
  static Insertable<Template> custom({
    Expression<int>? id,
    Expression<String>? category,
    Expression<String>? content,
    Expression<bool>? isFavorite,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (content != null) 'content': content,
      if (isFavorite != null) 'is_favorite': isFavorite,
    });
  }

  TemplatesCompanion copyWith(
      {Value<int>? id,
      Value<String>? category,
      Value<String>? content,
      Value<bool>? isFavorite}) {
    return TemplatesCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      content: content ?? this.content,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplatesCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('content: $content, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }
}

class $GalleryFavoritesTable extends GalleryFavorites
    with TableInfo<$GalleryFavoritesTable, GalleryFavorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GalleryFavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addedDateMeta =
      const VerificationMeta('addedDate');
  @override
  late final GeneratedColumn<DateTime> addedDate = GeneratedColumn<DateTime>(
      'added_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [imagePath, addedDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gallery_favorites';
  @override
  VerificationContext validateIntegrity(Insertable<GalleryFavorite> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('added_date')) {
      context.handle(_addedDateMeta,
          addedDate.isAcceptableOrUnknown(data['added_date']!, _addedDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {imagePath};
  @override
  GalleryFavorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GalleryFavorite(
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path'])!,
      addedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_date'])!,
    );
  }

  @override
  $GalleryFavoritesTable createAlias(String alias) {
    return $GalleryFavoritesTable(attachedDatabase, alias);
  }
}

class GalleryFavorite extends DataClass implements Insertable<GalleryFavorite> {
  final String imagePath;
  final DateTime addedDate;
  const GalleryFavorite({required this.imagePath, required this.addedDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['image_path'] = Variable<String>(imagePath);
    map['added_date'] = Variable<DateTime>(addedDate);
    return map;
  }

  GalleryFavoritesCompanion toCompanion(bool nullToAbsent) {
    return GalleryFavoritesCompanion(
      imagePath: Value(imagePath),
      addedDate: Value(addedDate),
    );
  }

  factory GalleryFavorite.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GalleryFavorite(
      imagePath: serializer.fromJson<String>(json['imagePath']),
      addedDate: serializer.fromJson<DateTime>(json['addedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'imagePath': serializer.toJson<String>(imagePath),
      'addedDate': serializer.toJson<DateTime>(addedDate),
    };
  }

  GalleryFavorite copyWith({String? imagePath, DateTime? addedDate}) =>
      GalleryFavorite(
        imagePath: imagePath ?? this.imagePath,
        addedDate: addedDate ?? this.addedDate,
      );
  GalleryFavorite copyWithCompanion(GalleryFavoritesCompanion data) {
    return GalleryFavorite(
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      addedDate: data.addedDate.present ? data.addedDate.value : this.addedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GalleryFavorite(')
          ..write('imagePath: $imagePath, ')
          ..write('addedDate: $addedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(imagePath, addedDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GalleryFavorite &&
          other.imagePath == this.imagePath &&
          other.addedDate == this.addedDate);
}

class GalleryFavoritesCompanion extends UpdateCompanion<GalleryFavorite> {
  final Value<String> imagePath;
  final Value<DateTime> addedDate;
  final Value<int> rowid;
  const GalleryFavoritesCompanion({
    this.imagePath = const Value.absent(),
    this.addedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GalleryFavoritesCompanion.insert({
    required String imagePath,
    this.addedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : imagePath = Value(imagePath);
  static Insertable<GalleryFavorite> custom({
    Expression<String>? imagePath,
    Expression<DateTime>? addedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (imagePath != null) 'image_path': imagePath,
      if (addedDate != null) 'added_date': addedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GalleryFavoritesCompanion copyWith(
      {Value<String>? imagePath,
      Value<DateTime>? addedDate,
      Value<int>? rowid}) {
    return GalleryFavoritesCompanion(
      imagePath: imagePath ?? this.imagePath,
      addedDate: addedDate ?? this.addedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (addedDate.present) {
      map['added_date'] = Variable<DateTime>(addedDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GalleryFavoritesCompanion(')
          ..write('imagePath: $imagePath, ')
          ..write('addedDate: $addedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $HistoryTable history = $HistoryTable(this);
  late final $TemplatesTable templates = $TemplatesTable(this);
  late final $GalleryFavoritesTable galleryFavorites =
      $GalleryFavoritesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [contacts, history, templates, galleryFavorites];
}

typedef $$ContactsTableCreateCompanionBuilder = ContactsCompanion Function({
  Value<int> id,
  required String phone,
  required String name,
  Value<DateTime?> birthday,
  Value<String?> groupTag,
  Value<DateTime?> lastSentDate,
  Value<DateTime?> lastReceivedDate,
  Value<String?> photoData,
  Value<bool> isFavorite,
});
typedef $$ContactsTableUpdateCompanionBuilder = ContactsCompanion Function({
  Value<int> id,
  Value<String> phone,
  Value<String> name,
  Value<DateTime?> birthday,
  Value<String?> groupTag,
  Value<DateTime?> lastSentDate,
  Value<DateTime?> lastReceivedDate,
  Value<String?> photoData,
  Value<bool> isFavorite,
});

class $$ContactsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContactsTable,
    Contact,
    $$ContactsTableFilterComposer,
    $$ContactsTableOrderingComposer,
    $$ContactsTableCreateCompanionBuilder,
    $$ContactsTableUpdateCompanionBuilder> {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ContactsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ContactsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime?> birthday = const Value.absent(),
            Value<String?> groupTag = const Value.absent(),
            Value<DateTime?> lastSentDate = const Value.absent(),
            Value<DateTime?> lastReceivedDate = const Value.absent(),
            Value<String?> photoData = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
          }) =>
              ContactsCompanion(
            id: id,
            phone: phone,
            name: name,
            birthday: birthday,
            groupTag: groupTag,
            lastSentDate: lastSentDate,
            lastReceivedDate: lastReceivedDate,
            photoData: photoData,
            isFavorite: isFavorite,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String phone,
            required String name,
            Value<DateTime?> birthday = const Value.absent(),
            Value<String?> groupTag = const Value.absent(),
            Value<DateTime?> lastSentDate = const Value.absent(),
            Value<DateTime?> lastReceivedDate = const Value.absent(),
            Value<String?> photoData = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
          }) =>
              ContactsCompanion.insert(
            id: id,
            phone: phone,
            name: name,
            birthday: birthday,
            groupTag: groupTag,
            lastSentDate: lastSentDate,
            lastReceivedDate: lastReceivedDate,
            photoData: photoData,
            isFavorite: isFavorite,
          ),
        ));
}

class $$ContactsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get phone => $state.composableBuilder(
      column: $state.table.phone,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get birthday => $state.composableBuilder(
      column: $state.table.birthday,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get groupTag => $state.composableBuilder(
      column: $state.table.groupTag,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastSentDate => $state.composableBuilder(
      column: $state.table.lastSentDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastReceivedDate => $state.composableBuilder(
      column: $state.table.lastReceivedDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get photoData => $state.composableBuilder(
      column: $state.table.photoData,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter historyRefs(
      ComposableFilter Function($$HistoryTableFilterComposer f) f) {
    final $$HistoryTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.history,
        getReferencedColumn: (t) => t.contactId,
        builder: (joinBuilder, parentComposers) => $$HistoryTableFilterComposer(
            ComposerState(
                $state.db, $state.db.history, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ContactsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get phone => $state.composableBuilder(
      column: $state.table.phone,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get birthday => $state.composableBuilder(
      column: $state.table.birthday,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get groupTag => $state.composableBuilder(
      column: $state.table.groupTag,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastSentDate => $state.composableBuilder(
      column: $state.table.lastSentDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastReceivedDate => $state.composableBuilder(
      column: $state.table.lastReceivedDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get photoData => $state.composableBuilder(
      column: $state.table.photoData,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$HistoryTableCreateCompanionBuilder = HistoryCompanion Function({
  Value<int> id,
  required int contactId,
  required String type,
  Value<DateTime> eventDate,
  Value<String?> message,
  Value<String?> imagePath,
});
typedef $$HistoryTableUpdateCompanionBuilder = HistoryCompanion Function({
  Value<int> id,
  Value<int> contactId,
  Value<String> type,
  Value<DateTime> eventDate,
  Value<String?> message,
  Value<String?> imagePath,
});

class $$HistoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HistoryTable,
    HistoryData,
    $$HistoryTableFilterComposer,
    $$HistoryTableOrderingComposer,
    $$HistoryTableCreateCompanionBuilder,
    $$HistoryTableUpdateCompanionBuilder> {
  $$HistoryTableTableManager(_$AppDatabase db, $HistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$HistoryTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$HistoryTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> contactId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<DateTime> eventDate = const Value.absent(),
            Value<String?> message = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
          }) =>
              HistoryCompanion(
            id: id,
            contactId: contactId,
            type: type,
            eventDate: eventDate,
            message: message,
            imagePath: imagePath,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int contactId,
            required String type,
            Value<DateTime> eventDate = const Value.absent(),
            Value<String?> message = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
          }) =>
              HistoryCompanion.insert(
            id: id,
            contactId: contactId,
            type: type,
            eventDate: eventDate,
            message: message,
            imagePath: imagePath,
          ),
        ));
}

class $$HistoryTableFilterComposer
    extends FilterComposer<_$AppDatabase, $HistoryTable> {
  $$HistoryTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get eventDate => $state.composableBuilder(
      column: $state.table.eventDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get message => $state.composableBuilder(
      column: $state.table.message,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $state.db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ContactsTableFilterComposer(ComposerState(
                $state.db, $state.db.contacts, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$HistoryTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $HistoryTable> {
  $$HistoryTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get eventDate => $state.composableBuilder(
      column: $state.table.eventDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get message => $state.composableBuilder(
      column: $state.table.message,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $state.db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ContactsTableOrderingComposer(ComposerState(
                $state.db, $state.db.contacts, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$TemplatesTableCreateCompanionBuilder = TemplatesCompanion Function({
  Value<int> id,
  required String category,
  required String content,
  Value<bool> isFavorite,
});
typedef $$TemplatesTableUpdateCompanionBuilder = TemplatesCompanion Function({
  Value<int> id,
  Value<String> category,
  Value<String> content,
  Value<bool> isFavorite,
});

class $$TemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TemplatesTable,
    Template,
    $$TemplatesTableFilterComposer,
    $$TemplatesTableOrderingComposer,
    $$TemplatesTableCreateCompanionBuilder,
    $$TemplatesTableUpdateCompanionBuilder> {
  $$TemplatesTableTableManager(_$AppDatabase db, $TemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TemplatesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TemplatesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
          }) =>
              TemplatesCompanion(
            id: id,
            category: category,
            content: content,
            isFavorite: isFavorite,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String category,
            required String content,
            Value<bool> isFavorite = const Value.absent(),
          }) =>
              TemplatesCompanion.insert(
            id: id,
            category: category,
            content: content,
            isFavorite: isFavorite,
          ),
        ));
}

class $$TemplatesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$TemplatesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isFavorite => $state.composableBuilder(
      column: $state.table.isFavorite,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$GalleryFavoritesTableCreateCompanionBuilder
    = GalleryFavoritesCompanion Function({
  required String imagePath,
  Value<DateTime> addedDate,
  Value<int> rowid,
});
typedef $$GalleryFavoritesTableUpdateCompanionBuilder
    = GalleryFavoritesCompanion Function({
  Value<String> imagePath,
  Value<DateTime> addedDate,
  Value<int> rowid,
});

class $$GalleryFavoritesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GalleryFavoritesTable,
    GalleryFavorite,
    $$GalleryFavoritesTableFilterComposer,
    $$GalleryFavoritesTableOrderingComposer,
    $$GalleryFavoritesTableCreateCompanionBuilder,
    $$GalleryFavoritesTableUpdateCompanionBuilder> {
  $$GalleryFavoritesTableTableManager(
      _$AppDatabase db, $GalleryFavoritesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$GalleryFavoritesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$GalleryFavoritesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> imagePath = const Value.absent(),
            Value<DateTime> addedDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GalleryFavoritesCompanion(
            imagePath: imagePath,
            addedDate: addedDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String imagePath,
            Value<DateTime> addedDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GalleryFavoritesCompanion.insert(
            imagePath: imagePath,
            addedDate: addedDate,
            rowid: rowid,
          ),
        ));
}

class $$GalleryFavoritesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $GalleryFavoritesTable> {
  $$GalleryFavoritesTableFilterComposer(super.$state);
  ColumnFilters<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get addedDate => $state.composableBuilder(
      column: $state.table.addedDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$GalleryFavoritesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $GalleryFavoritesTable> {
  $$GalleryFavoritesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get addedDate => $state.composableBuilder(
      column: $state.table.addedDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$HistoryTableTableManager get history =>
      $$HistoryTableTableManager(_db, _db.history);
  $$TemplatesTableTableManager get templates =>
      $$TemplatesTableTableManager(_db, _db.templates);
  $$GalleryFavoritesTableTableManager get galleryFavorites =>
      $$GalleryFavoritesTableTableManager(_db, _db.galleryFavorites);
}
