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

class $SavedCardsTable extends SavedCards
    with TableInfo<$SavedCardsTable, SavedCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('제목 없음'));
  static const VerificationMeta _htmlContentMeta =
      const VerificationMeta('htmlContent');
  @override
  late final GeneratedColumn<String> htmlContent = GeneratedColumn<String>(
      'html_content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _footerTextMeta =
      const VerificationMeta('footerText');
  @override
  late final GeneratedColumn<String> footerText = GeneratedColumn<String>(
      'footer_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _frameMeta = const VerificationMeta('frame');
  @override
  late final GeneratedColumn<String> frame = GeneratedColumn<String>(
      'frame', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _boxStyleMeta =
      const VerificationMeta('boxStyle');
  @override
  late final GeneratedColumn<String> boxStyle = GeneratedColumn<String>(
      'box_style', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _footerStyleMeta =
      const VerificationMeta('footerStyle');
  @override
  late final GeneratedColumn<String> footerStyle = GeneratedColumn<String>(
      'footer_style', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mainStyleMeta =
      const VerificationMeta('mainStyle');
  @override
  late final GeneratedColumn<String> mainStyle = GeneratedColumn<String>(
      'main_style', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isFooterActiveMeta =
      const VerificationMeta('isFooterActive');
  @override
  late final GeneratedColumn<bool> isFooterActive = GeneratedColumn<bool>(
      'is_footer_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_footer_active" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        htmlContent,
        footerText,
        imagePath,
        frame,
        boxStyle,
        footerStyle,
        mainStyle,
        isFooterActive,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_cards';
  @override
  VerificationContext validateIntegrity(Insertable<SavedCard> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('html_content')) {
      context.handle(
          _htmlContentMeta,
          htmlContent.isAcceptableOrUnknown(
              data['html_content']!, _htmlContentMeta));
    } else if (isInserting) {
      context.missing(_htmlContentMeta);
    }
    if (data.containsKey('footer_text')) {
      context.handle(
          _footerTextMeta,
          footerText.isAcceptableOrUnknown(
              data['footer_text']!, _footerTextMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('frame')) {
      context.handle(
          _frameMeta, frame.isAcceptableOrUnknown(data['frame']!, _frameMeta));
    }
    if (data.containsKey('box_style')) {
      context.handle(_boxStyleMeta,
          boxStyle.isAcceptableOrUnknown(data['box_style']!, _boxStyleMeta));
    }
    if (data.containsKey('footer_style')) {
      context.handle(
          _footerStyleMeta,
          footerStyle.isAcceptableOrUnknown(
              data['footer_style']!, _footerStyleMeta));
    }
    if (data.containsKey('main_style')) {
      context.handle(_mainStyleMeta,
          mainStyle.isAcceptableOrUnknown(data['main_style']!, _mainStyleMeta));
    }
    if (data.containsKey('is_footer_active')) {
      context.handle(
          _isFooterActiveMeta,
          isFooterActive.isAcceptableOrUnknown(
              data['is_footer_active']!, _isFooterActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedCard(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      htmlContent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}html_content'])!,
      footerText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}footer_text']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      frame: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}frame']),
      boxStyle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}box_style']),
      footerStyle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}footer_style']),
      mainStyle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}main_style']),
      isFooterActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_footer_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SavedCardsTable createAlias(String alias) {
    return $SavedCardsTable(attachedDatabase, alias);
  }
}

class SavedCard extends DataClass implements Insertable<SavedCard> {
  final int id;
  final String name;
  final String htmlContent;
  final String? footerText;
  final String? imagePath;
  final String? frame;
  final String? boxStyle;
  final String? footerStyle;
  final String? mainStyle;
  final bool isFooterActive;
  final DateTime createdAt;
  const SavedCard(
      {required this.id,
      required this.name,
      required this.htmlContent,
      this.footerText,
      this.imagePath,
      this.frame,
      this.boxStyle,
      this.footerStyle,
      this.mainStyle,
      required this.isFooterActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['html_content'] = Variable<String>(htmlContent);
    if (!nullToAbsent || footerText != null) {
      map['footer_text'] = Variable<String>(footerText);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || frame != null) {
      map['frame'] = Variable<String>(frame);
    }
    if (!nullToAbsent || boxStyle != null) {
      map['box_style'] = Variable<String>(boxStyle);
    }
    if (!nullToAbsent || footerStyle != null) {
      map['footer_style'] = Variable<String>(footerStyle);
    }
    if (!nullToAbsent || mainStyle != null) {
      map['main_style'] = Variable<String>(mainStyle);
    }
    map['is_footer_active'] = Variable<bool>(isFooterActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SavedCardsCompanion toCompanion(bool nullToAbsent) {
    return SavedCardsCompanion(
      id: Value(id),
      name: Value(name),
      htmlContent: Value(htmlContent),
      footerText: footerText == null && nullToAbsent
          ? const Value.absent()
          : Value(footerText),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      frame:
          frame == null && nullToAbsent ? const Value.absent() : Value(frame),
      boxStyle: boxStyle == null && nullToAbsent
          ? const Value.absent()
          : Value(boxStyle),
      footerStyle: footerStyle == null && nullToAbsent
          ? const Value.absent()
          : Value(footerStyle),
      mainStyle: mainStyle == null && nullToAbsent
          ? const Value.absent()
          : Value(mainStyle),
      isFooterActive: Value(isFooterActive),
      createdAt: Value(createdAt),
    );
  }

  factory SavedCard.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedCard(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      htmlContent: serializer.fromJson<String>(json['htmlContent']),
      footerText: serializer.fromJson<String?>(json['footerText']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      frame: serializer.fromJson<String?>(json['frame']),
      boxStyle: serializer.fromJson<String?>(json['boxStyle']),
      footerStyle: serializer.fromJson<String?>(json['footerStyle']),
      mainStyle: serializer.fromJson<String?>(json['mainStyle']),
      isFooterActive: serializer.fromJson<bool>(json['isFooterActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'htmlContent': serializer.toJson<String>(htmlContent),
      'footerText': serializer.toJson<String?>(footerText),
      'imagePath': serializer.toJson<String?>(imagePath),
      'frame': serializer.toJson<String?>(frame),
      'boxStyle': serializer.toJson<String?>(boxStyle),
      'footerStyle': serializer.toJson<String?>(footerStyle),
      'mainStyle': serializer.toJson<String?>(mainStyle),
      'isFooterActive': serializer.toJson<bool>(isFooterActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SavedCard copyWith(
          {int? id,
          String? name,
          String? htmlContent,
          Value<String?> footerText = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          Value<String?> frame = const Value.absent(),
          Value<String?> boxStyle = const Value.absent(),
          Value<String?> footerStyle = const Value.absent(),
          Value<String?> mainStyle = const Value.absent(),
          bool? isFooterActive,
          DateTime? createdAt}) =>
      SavedCard(
        id: id ?? this.id,
        name: name ?? this.name,
        htmlContent: htmlContent ?? this.htmlContent,
        footerText: footerText.present ? footerText.value : this.footerText,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        frame: frame.present ? frame.value : this.frame,
        boxStyle: boxStyle.present ? boxStyle.value : this.boxStyle,
        footerStyle: footerStyle.present ? footerStyle.value : this.footerStyle,
        mainStyle: mainStyle.present ? mainStyle.value : this.mainStyle,
        isFooterActive: isFooterActive ?? this.isFooterActive,
        createdAt: createdAt ?? this.createdAt,
      );
  SavedCard copyWithCompanion(SavedCardsCompanion data) {
    return SavedCard(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      htmlContent:
          data.htmlContent.present ? data.htmlContent.value : this.htmlContent,
      footerText:
          data.footerText.present ? data.footerText.value : this.footerText,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      frame: data.frame.present ? data.frame.value : this.frame,
      boxStyle: data.boxStyle.present ? data.boxStyle.value : this.boxStyle,
      footerStyle:
          data.footerStyle.present ? data.footerStyle.value : this.footerStyle,
      mainStyle: data.mainStyle.present ? data.mainStyle.value : this.mainStyle,
      isFooterActive: data.isFooterActive.present
          ? data.isFooterActive.value
          : this.isFooterActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedCard(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('htmlContent: $htmlContent, ')
          ..write('footerText: $footerText, ')
          ..write('imagePath: $imagePath, ')
          ..write('frame: $frame, ')
          ..write('boxStyle: $boxStyle, ')
          ..write('footerStyle: $footerStyle, ')
          ..write('mainStyle: $mainStyle, ')
          ..write('isFooterActive: $isFooterActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, htmlContent, footerText, imagePath,
      frame, boxStyle, footerStyle, mainStyle, isFooterActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedCard &&
          other.id == this.id &&
          other.name == this.name &&
          other.htmlContent == this.htmlContent &&
          other.footerText == this.footerText &&
          other.imagePath == this.imagePath &&
          other.frame == this.frame &&
          other.boxStyle == this.boxStyle &&
          other.footerStyle == this.footerStyle &&
          other.mainStyle == this.mainStyle &&
          other.isFooterActive == this.isFooterActive &&
          other.createdAt == this.createdAt);
}

class SavedCardsCompanion extends UpdateCompanion<SavedCard> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> htmlContent;
  final Value<String?> footerText;
  final Value<String?> imagePath;
  final Value<String?> frame;
  final Value<String?> boxStyle;
  final Value<String?> footerStyle;
  final Value<String?> mainStyle;
  final Value<bool> isFooterActive;
  final Value<DateTime> createdAt;
  const SavedCardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.htmlContent = const Value.absent(),
    this.footerText = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.frame = const Value.absent(),
    this.boxStyle = const Value.absent(),
    this.footerStyle = const Value.absent(),
    this.mainStyle = const Value.absent(),
    this.isFooterActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SavedCardsCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    required String htmlContent,
    this.footerText = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.frame = const Value.absent(),
    this.boxStyle = const Value.absent(),
    this.footerStyle = const Value.absent(),
    this.mainStyle = const Value.absent(),
    this.isFooterActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : htmlContent = Value(htmlContent);
  static Insertable<SavedCard> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? htmlContent,
    Expression<String>? footerText,
    Expression<String>? imagePath,
    Expression<String>? frame,
    Expression<String>? boxStyle,
    Expression<String>? footerStyle,
    Expression<String>? mainStyle,
    Expression<bool>? isFooterActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (htmlContent != null) 'html_content': htmlContent,
      if (footerText != null) 'footer_text': footerText,
      if (imagePath != null) 'image_path': imagePath,
      if (frame != null) 'frame': frame,
      if (boxStyle != null) 'box_style': boxStyle,
      if (footerStyle != null) 'footer_style': footerStyle,
      if (mainStyle != null) 'main_style': mainStyle,
      if (isFooterActive != null) 'is_footer_active': isFooterActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SavedCardsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? htmlContent,
      Value<String?>? footerText,
      Value<String?>? imagePath,
      Value<String?>? frame,
      Value<String?>? boxStyle,
      Value<String?>? footerStyle,
      Value<String?>? mainStyle,
      Value<bool>? isFooterActive,
      Value<DateTime>? createdAt}) {
    return SavedCardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      htmlContent: htmlContent ?? this.htmlContent,
      footerText: footerText ?? this.footerText,
      imagePath: imagePath ?? this.imagePath,
      frame: frame ?? this.frame,
      boxStyle: boxStyle ?? this.boxStyle,
      footerStyle: footerStyle ?? this.footerStyle,
      mainStyle: mainStyle ?? this.mainStyle,
      isFooterActive: isFooterActive ?? this.isFooterActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (htmlContent.present) {
      map['html_content'] = Variable<String>(htmlContent.value);
    }
    if (footerText.present) {
      map['footer_text'] = Variable<String>(footerText.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (frame.present) {
      map['frame'] = Variable<String>(frame.value);
    }
    if (boxStyle.present) {
      map['box_style'] = Variable<String>(boxStyle.value);
    }
    if (footerStyle.present) {
      map['footer_style'] = Variable<String>(footerStyle.value);
    }
    if (mainStyle.present) {
      map['main_style'] = Variable<String>(mainStyle.value);
    }
    if (isFooterActive.present) {
      map['is_footer_active'] = Variable<bool>(isFooterActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedCardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('htmlContent: $htmlContent, ')
          ..write('footerText: $footerText, ')
          ..write('imagePath: $imagePath, ')
          ..write('frame: $frame, ')
          ..write('boxStyle: $boxStyle, ')
          ..write('footerStyle: $footerStyle, ')
          ..write('mainStyle: $mainStyle, ')
          ..write('isFooterActive: $isFooterActive, ')
          ..write('createdAt: $createdAt')
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
  static const VerificationMeta _savedCardIdMeta =
      const VerificationMeta('savedCardId');
  @override
  late final GeneratedColumn<int> savedCardId = GeneratedColumn<int>(
      'saved_card_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES saved_cards (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, contactId, type, eventDate, message, imagePath, savedCardId];
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
    if (data.containsKey('saved_card_id')) {
      context.handle(
          _savedCardIdMeta,
          savedCardId.isAcceptableOrUnknown(
              data['saved_card_id']!, _savedCardIdMeta));
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
      savedCardId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}saved_card_id']),
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
  final int? savedCardId;
  const HistoryData(
      {required this.id,
      required this.contactId,
      required this.type,
      required this.eventDate,
      this.message,
      this.imagePath,
      this.savedCardId});
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
    if (!nullToAbsent || savedCardId != null) {
      map['saved_card_id'] = Variable<int>(savedCardId);
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
      savedCardId: savedCardId == null && nullToAbsent
          ? const Value.absent()
          : Value(savedCardId),
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
      savedCardId: serializer.fromJson<int?>(json['savedCardId']),
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
      'savedCardId': serializer.toJson<int?>(savedCardId),
    };
  }

  HistoryData copyWith(
          {int? id,
          int? contactId,
          String? type,
          DateTime? eventDate,
          Value<String?> message = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          Value<int?> savedCardId = const Value.absent()}) =>
      HistoryData(
        id: id ?? this.id,
        contactId: contactId ?? this.contactId,
        type: type ?? this.type,
        eventDate: eventDate ?? this.eventDate,
        message: message.present ? message.value : this.message,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        savedCardId: savedCardId.present ? savedCardId.value : this.savedCardId,
      );
  HistoryData copyWithCompanion(HistoryCompanion data) {
    return HistoryData(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      type: data.type.present ? data.type.value : this.type,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      message: data.message.present ? data.message.value : this.message,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      savedCardId:
          data.savedCardId.present ? data.savedCardId.value : this.savedCardId,
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
          ..write('imagePath: $imagePath, ')
          ..write('savedCardId: $savedCardId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, contactId, type, eventDate, message, imagePath, savedCardId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryData &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.type == this.type &&
          other.eventDate == this.eventDate &&
          other.message == this.message &&
          other.imagePath == this.imagePath &&
          other.savedCardId == this.savedCardId);
}

class HistoryCompanion extends UpdateCompanion<HistoryData> {
  final Value<int> id;
  final Value<int> contactId;
  final Value<String> type;
  final Value<DateTime> eventDate;
  final Value<String?> message;
  final Value<String?> imagePath;
  final Value<int?> savedCardId;
  const HistoryCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.type = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.message = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.savedCardId = const Value.absent(),
  });
  HistoryCompanion.insert({
    this.id = const Value.absent(),
    required int contactId,
    required String type,
    this.eventDate = const Value.absent(),
    this.message = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.savedCardId = const Value.absent(),
  })  : contactId = Value(contactId),
        type = Value(type);
  static Insertable<HistoryData> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<String>? type,
    Expression<DateTime>? eventDate,
    Expression<String>? message,
    Expression<String>? imagePath,
    Expression<int>? savedCardId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (type != null) 'type': type,
      if (eventDate != null) 'event_date': eventDate,
      if (message != null) 'message': message,
      if (imagePath != null) 'image_path': imagePath,
      if (savedCardId != null) 'saved_card_id': savedCardId,
    });
  }

  HistoryCompanion copyWith(
      {Value<int>? id,
      Value<int>? contactId,
      Value<String>? type,
      Value<DateTime>? eventDate,
      Value<String?>? message,
      Value<String?>? imagePath,
      Value<int?>? savedCardId}) {
    return HistoryCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      type: type ?? this.type,
      eventDate: eventDate ?? this.eventDate,
      message: message ?? this.message,
      imagePath: imagePath ?? this.imagePath,
      savedCardId: savedCardId ?? this.savedCardId,
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
    if (savedCardId.present) {
      map['saved_card_id'] = Variable<int>(savedCardId.value);
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
          ..write('imagePath: $imagePath, ')
          ..write('savedCardId: $savedCardId')
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

class $HolidaysTable extends Holidays with TableInfo<$HolidaysTable, Holiday> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HolidaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Holiday'));
  static const VerificationMeta _isLunarMeta =
      const VerificationMeta('isLunar');
  @override
  late final GeneratedColumn<bool> isLunar = GeneratedColumn<bool>(
      'is_lunar', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_lunar" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, name, date, type, isLunar];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holidays';
  @override
  VerificationContext validateIntegrity(Insertable<Holiday> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('is_lunar')) {
      context.handle(_isLunarMeta,
          isLunar.isAcceptableOrUnknown(data['is_lunar']!, _isLunarMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Holiday map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Holiday(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      isLunar: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_lunar'])!,
    );
  }

  @override
  $HolidaysTable createAlias(String alias) {
    return $HolidaysTable(attachedDatabase, alias);
  }
}

class Holiday extends DataClass implements Insertable<Holiday> {
  final int id;
  final String name;
  final DateTime date;
  final String type;
  final bool isLunar;
  const Holiday(
      {required this.id,
      required this.name,
      required this.date,
      required this.type,
      required this.isLunar});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['date'] = Variable<DateTime>(date);
    map['type'] = Variable<String>(type);
    map['is_lunar'] = Variable<bool>(isLunar);
    return map;
  }

  HolidaysCompanion toCompanion(bool nullToAbsent) {
    return HolidaysCompanion(
      id: Value(id),
      name: Value(name),
      date: Value(date),
      type: Value(type),
      isLunar: Value(isLunar),
    );
  }

  factory Holiday.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Holiday(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      isLunar: serializer.fromJson<bool>(json['isLunar']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(type),
      'isLunar': serializer.toJson<bool>(isLunar),
    };
  }

  Holiday copyWith(
          {int? id,
          String? name,
          DateTime? date,
          String? type,
          bool? isLunar}) =>
      Holiday(
        id: id ?? this.id,
        name: name ?? this.name,
        date: date ?? this.date,
        type: type ?? this.type,
        isLunar: isLunar ?? this.isLunar,
      );
  Holiday copyWithCompanion(HolidaysCompanion data) {
    return Holiday(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      isLunar: data.isLunar.present ? data.isLunar.value : this.isLunar,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Holiday(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('isLunar: $isLunar')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, date, type, isLunar);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Holiday &&
          other.id == this.id &&
          other.name == this.name &&
          other.date == this.date &&
          other.type == this.type &&
          other.isLunar == this.isLunar);
}

class HolidaysCompanion extends UpdateCompanion<Holiday> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> date;
  final Value<String> type;
  final Value<bool> isLunar;
  const HolidaysCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.isLunar = const Value.absent(),
  });
  HolidaysCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime date,
    this.type = const Value.absent(),
    this.isLunar = const Value.absent(),
  })  : name = Value(name),
        date = Value(date);
  static Insertable<Holiday> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<bool>? isLunar,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (isLunar != null) 'is_lunar': isLunar,
    });
  }

  HolidaysCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<DateTime>? date,
      Value<String>? type,
      Value<bool>? isLunar}) {
    return HolidaysCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      type: type ?? this.type,
      isLunar: isLunar ?? this.isLunar,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isLunar.present) {
      map['is_lunar'] = Variable<bool>(isLunar.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HolidaysCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('isLunar: $isLunar')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $SavedCardsTable savedCards = $SavedCardsTable(this);
  late final $HistoryTable history = $HistoryTable(this);
  late final $TemplatesTable templates = $TemplatesTable(this);
  late final $GalleryFavoritesTable galleryFavorites =
      $GalleryFavoritesTable(this);
  late final $HolidaysTable holidays = $HolidaysTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [contacts, savedCards, history, templates, galleryFavorites, holidays];
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

final class $$ContactsTableReferences
    extends BaseReferences<_$AppDatabase, $ContactsTable, Contact> {
  $$ContactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HistoryTable, List<HistoryData>>
      _historyRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.history,
              aliasName:
                  $_aliasNameGenerator(db.contacts.id, db.history.contactId));

  $$HistoryTableProcessedTableManager get historyRefs {
    final manager = $$HistoryTableTableManager($_db, $_db.history)
        .filter((f) => f.contactId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_historyRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthday => $composableBuilder(
      column: $table.birthday, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupTag => $composableBuilder(
      column: $table.groupTag, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSentDate => $composableBuilder(
      column: $table.lastSentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReceivedDate => $composableBuilder(
      column: $table.lastReceivedDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoData => $composableBuilder(
      column: $table.photoData, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  Expression<bool> historyRefs(
      Expression<bool> Function($$HistoryTableFilterComposer f) f) {
    final $$HistoryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.history,
        getReferencedColumn: (t) => t.contactId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HistoryTableFilterComposer(
              $db: $db,
              $table: $db.history,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthday => $composableBuilder(
      column: $table.birthday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupTag => $composableBuilder(
      column: $table.groupTag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSentDate => $composableBuilder(
      column: $table.lastSentDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReceivedDate => $composableBuilder(
      column: $table.lastReceivedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoData => $composableBuilder(
      column: $table.photoData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get birthday =>
      $composableBuilder(column: $table.birthday, builder: (column) => column);

  GeneratedColumn<String> get groupTag =>
      $composableBuilder(column: $table.groupTag, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSentDate => $composableBuilder(
      column: $table.lastSentDate, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReceivedDate => $composableBuilder(
      column: $table.lastReceivedDate, builder: (column) => column);

  GeneratedColumn<String> get photoData =>
      $composableBuilder(column: $table.photoData, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  Expression<T> historyRefs<T extends Object>(
      Expression<T> Function($$HistoryTableAnnotationComposer a) f) {
    final $$HistoryTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.history,
        getReferencedColumn: (t) => t.contactId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HistoryTableAnnotationComposer(
              $db: $db,
              $table: $db.history,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ContactsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContactsTable,
    Contact,
    $$ContactsTableFilterComposer,
    $$ContactsTableOrderingComposer,
    $$ContactsTableAnnotationComposer,
    $$ContactsTableCreateCompanionBuilder,
    $$ContactsTableUpdateCompanionBuilder,
    (Contact, $$ContactsTableReferences),
    Contact,
    PrefetchHooks Function({bool historyRefs})> {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
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
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ContactsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({historyRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (historyRefs) db.history],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (historyRefs)
                    await $_getPrefetchedData<Contact, $ContactsTable,
                            HistoryData>(
                        currentTable: table,
                        referencedTable:
                            $$ContactsTableReferences._historyRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ContactsTableReferences(db, table, p0)
                                .historyRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.contactId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ContactsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContactsTable,
    Contact,
    $$ContactsTableFilterComposer,
    $$ContactsTableOrderingComposer,
    $$ContactsTableAnnotationComposer,
    $$ContactsTableCreateCompanionBuilder,
    $$ContactsTableUpdateCompanionBuilder,
    (Contact, $$ContactsTableReferences),
    Contact,
    PrefetchHooks Function({bool historyRefs})>;
typedef $$SavedCardsTableCreateCompanionBuilder = SavedCardsCompanion Function({
  Value<int> id,
  Value<String> name,
  required String htmlContent,
  Value<String?> footerText,
  Value<String?> imagePath,
  Value<String?> frame,
  Value<String?> boxStyle,
  Value<String?> footerStyle,
  Value<String?> mainStyle,
  Value<bool> isFooterActive,
  Value<DateTime> createdAt,
});
typedef $$SavedCardsTableUpdateCompanionBuilder = SavedCardsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> htmlContent,
  Value<String?> footerText,
  Value<String?> imagePath,
  Value<String?> frame,
  Value<String?> boxStyle,
  Value<String?> footerStyle,
  Value<String?> mainStyle,
  Value<bool> isFooterActive,
  Value<DateTime> createdAt,
});

final class $$SavedCardsTableReferences
    extends BaseReferences<_$AppDatabase, $SavedCardsTable, SavedCard> {
  $$SavedCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HistoryTable, List<HistoryData>>
      _historyRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.history,
          aliasName:
              $_aliasNameGenerator(db.savedCards.id, db.history.savedCardId));

  $$HistoryTableProcessedTableManager get historyRefs {
    final manager = $$HistoryTableTableManager($_db, $_db.history)
        .filter((f) => f.savedCardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_historyRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SavedCardsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedCardsTable> {
  $$SavedCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get htmlContent => $composableBuilder(
      column: $table.htmlContent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get footerText => $composableBuilder(
      column: $table.footerText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frame => $composableBuilder(
      column: $table.frame, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boxStyle => $composableBuilder(
      column: $table.boxStyle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get footerStyle => $composableBuilder(
      column: $table.footerStyle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mainStyle => $composableBuilder(
      column: $table.mainStyle, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFooterActive => $composableBuilder(
      column: $table.isFooterActive,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> historyRefs(
      Expression<bool> Function($$HistoryTableFilterComposer f) f) {
    final $$HistoryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.history,
        getReferencedColumn: (t) => t.savedCardId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HistoryTableFilterComposer(
              $db: $db,
              $table: $db.history,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SavedCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedCardsTable> {
  $$SavedCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get htmlContent => $composableBuilder(
      column: $table.htmlContent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get footerText => $composableBuilder(
      column: $table.footerText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frame => $composableBuilder(
      column: $table.frame, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boxStyle => $composableBuilder(
      column: $table.boxStyle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get footerStyle => $composableBuilder(
      column: $table.footerStyle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mainStyle => $composableBuilder(
      column: $table.mainStyle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFooterActive => $composableBuilder(
      column: $table.isFooterActive,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SavedCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedCardsTable> {
  $$SavedCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get htmlContent => $composableBuilder(
      column: $table.htmlContent, builder: (column) => column);

  GeneratedColumn<String> get footerText => $composableBuilder(
      column: $table.footerText, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get frame =>
      $composableBuilder(column: $table.frame, builder: (column) => column);

  GeneratedColumn<String> get boxStyle =>
      $composableBuilder(column: $table.boxStyle, builder: (column) => column);

  GeneratedColumn<String> get footerStyle => $composableBuilder(
      column: $table.footerStyle, builder: (column) => column);

  GeneratedColumn<String> get mainStyle =>
      $composableBuilder(column: $table.mainStyle, builder: (column) => column);

  GeneratedColumn<bool> get isFooterActive => $composableBuilder(
      column: $table.isFooterActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> historyRefs<T extends Object>(
      Expression<T> Function($$HistoryTableAnnotationComposer a) f) {
    final $$HistoryTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.history,
        getReferencedColumn: (t) => t.savedCardId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HistoryTableAnnotationComposer(
              $db: $db,
              $table: $db.history,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SavedCardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SavedCardsTable,
    SavedCard,
    $$SavedCardsTableFilterComposer,
    $$SavedCardsTableOrderingComposer,
    $$SavedCardsTableAnnotationComposer,
    $$SavedCardsTableCreateCompanionBuilder,
    $$SavedCardsTableUpdateCompanionBuilder,
    (SavedCard, $$SavedCardsTableReferences),
    SavedCard,
    PrefetchHooks Function({bool historyRefs})> {
  $$SavedCardsTableTableManager(_$AppDatabase db, $SavedCardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> htmlContent = const Value.absent(),
            Value<String?> footerText = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> frame = const Value.absent(),
            Value<String?> boxStyle = const Value.absent(),
            Value<String?> footerStyle = const Value.absent(),
            Value<String?> mainStyle = const Value.absent(),
            Value<bool> isFooterActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SavedCardsCompanion(
            id: id,
            name: name,
            htmlContent: htmlContent,
            footerText: footerText,
            imagePath: imagePath,
            frame: frame,
            boxStyle: boxStyle,
            footerStyle: footerStyle,
            mainStyle: mainStyle,
            isFooterActive: isFooterActive,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            required String htmlContent,
            Value<String?> footerText = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> frame = const Value.absent(),
            Value<String?> boxStyle = const Value.absent(),
            Value<String?> footerStyle = const Value.absent(),
            Value<String?> mainStyle = const Value.absent(),
            Value<bool> isFooterActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SavedCardsCompanion.insert(
            id: id,
            name: name,
            htmlContent: htmlContent,
            footerText: footerText,
            imagePath: imagePath,
            frame: frame,
            boxStyle: boxStyle,
            footerStyle: footerStyle,
            mainStyle: mainStyle,
            isFooterActive: isFooterActive,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SavedCardsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({historyRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (historyRefs) db.history],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (historyRefs)
                    await $_getPrefetchedData<SavedCard, $SavedCardsTable,
                            HistoryData>(
                        currentTable: table,
                        referencedTable:
                            $$SavedCardsTableReferences._historyRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SavedCardsTableReferences(db, table, p0)
                                .historyRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.savedCardId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SavedCardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SavedCardsTable,
    SavedCard,
    $$SavedCardsTableFilterComposer,
    $$SavedCardsTableOrderingComposer,
    $$SavedCardsTableAnnotationComposer,
    $$SavedCardsTableCreateCompanionBuilder,
    $$SavedCardsTableUpdateCompanionBuilder,
    (SavedCard, $$SavedCardsTableReferences),
    SavedCard,
    PrefetchHooks Function({bool historyRefs})>;
typedef $$HistoryTableCreateCompanionBuilder = HistoryCompanion Function({
  Value<int> id,
  required int contactId,
  required String type,
  Value<DateTime> eventDate,
  Value<String?> message,
  Value<String?> imagePath,
  Value<int?> savedCardId,
});
typedef $$HistoryTableUpdateCompanionBuilder = HistoryCompanion Function({
  Value<int> id,
  Value<int> contactId,
  Value<String> type,
  Value<DateTime> eventDate,
  Value<String?> message,
  Value<String?> imagePath,
  Value<int?> savedCardId,
});

final class $$HistoryTableReferences
    extends BaseReferences<_$AppDatabase, $HistoryTable, HistoryData> {
  $$HistoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ContactsTable _contactIdTable(_$AppDatabase db) => db.contacts
      .createAlias($_aliasNameGenerator(db.history.contactId, db.contacts.id));

  $$ContactsTableProcessedTableManager get contactId {
    final $_column = $_itemColumn<int>('contact_id')!;

    final manager = $$ContactsTableTableManager($_db, $_db.contacts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SavedCardsTable _savedCardIdTable(_$AppDatabase db) =>
      db.savedCards.createAlias(
          $_aliasNameGenerator(db.history.savedCardId, db.savedCards.id));

  $$SavedCardsTableProcessedTableManager? get savedCardId {
    final $_column = $_itemColumn<int>('saved_card_id');
    if ($_column == null) return null;
    final manager = $$SavedCardsTableTableManager($_db, $_db.savedCards)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_savedCardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$HistoryTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryTable> {
  $$HistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableFilterComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SavedCardsTableFilterComposer get savedCardId {
    final $$SavedCardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.savedCardId,
        referencedTable: $db.savedCards,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavedCardsTableFilterComposer(
              $db: $db,
              $table: $db.savedCards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$HistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryTable> {
  $$HistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableOrderingComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SavedCardsTableOrderingComposer get savedCardId {
    final $$SavedCardsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.savedCardId,
        referencedTable: $db.savedCards,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavedCardsTableOrderingComposer(
              $db: $db,
              $table: $db.savedCards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$HistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryTable> {
  $$HistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  $$ContactsTableAnnotationComposer get contactId {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactsTableAnnotationComposer(
              $db: $db,
              $table: $db.contacts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SavedCardsTableAnnotationComposer get savedCardId {
    final $$SavedCardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.savedCardId,
        referencedTable: $db.savedCards,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavedCardsTableAnnotationComposer(
              $db: $db,
              $table: $db.savedCards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$HistoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HistoryTable,
    HistoryData,
    $$HistoryTableFilterComposer,
    $$HistoryTableOrderingComposer,
    $$HistoryTableAnnotationComposer,
    $$HistoryTableCreateCompanionBuilder,
    $$HistoryTableUpdateCompanionBuilder,
    (HistoryData, $$HistoryTableReferences),
    HistoryData,
    PrefetchHooks Function({bool contactId, bool savedCardId})> {
  $$HistoryTableTableManager(_$AppDatabase db, $HistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> contactId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<DateTime> eventDate = const Value.absent(),
            Value<String?> message = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<int?> savedCardId = const Value.absent(),
          }) =>
              HistoryCompanion(
            id: id,
            contactId: contactId,
            type: type,
            eventDate: eventDate,
            message: message,
            imagePath: imagePath,
            savedCardId: savedCardId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int contactId,
            required String type,
            Value<DateTime> eventDate = const Value.absent(),
            Value<String?> message = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<int?> savedCardId = const Value.absent(),
          }) =>
              HistoryCompanion.insert(
            id: id,
            contactId: contactId,
            type: type,
            eventDate: eventDate,
            message: message,
            imagePath: imagePath,
            savedCardId: savedCardId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$HistoryTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({contactId = false, savedCardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (contactId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.contactId,
                    referencedTable:
                        $$HistoryTableReferences._contactIdTable(db),
                    referencedColumn:
                        $$HistoryTableReferences._contactIdTable(db).id,
                  ) as T;
                }
                if (savedCardId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.savedCardId,
                    referencedTable:
                        $$HistoryTableReferences._savedCardIdTable(db),
                    referencedColumn:
                        $$HistoryTableReferences._savedCardIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$HistoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HistoryTable,
    HistoryData,
    $$HistoryTableFilterComposer,
    $$HistoryTableOrderingComposer,
    $$HistoryTableAnnotationComposer,
    $$HistoryTableCreateCompanionBuilder,
    $$HistoryTableUpdateCompanionBuilder,
    (HistoryData, $$HistoryTableReferences),
    HistoryData,
    PrefetchHooks Function({bool contactId, bool savedCardId})>;
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

class $$TemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));
}

class $$TemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));
}

class $$TemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);
}

class $$TemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TemplatesTable,
    Template,
    $$TemplatesTableFilterComposer,
    $$TemplatesTableOrderingComposer,
    $$TemplatesTableAnnotationComposer,
    $$TemplatesTableCreateCompanionBuilder,
    $$TemplatesTableUpdateCompanionBuilder,
    (Template, BaseReferences<_$AppDatabase, $TemplatesTable, Template>),
    Template,
    PrefetchHooks Function()> {
  $$TemplatesTableTableManager(_$AppDatabase db, $TemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplatesTableAnnotationComposer($db: db, $table: table),
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
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TemplatesTable,
    Template,
    $$TemplatesTableFilterComposer,
    $$TemplatesTableOrderingComposer,
    $$TemplatesTableAnnotationComposer,
    $$TemplatesTableCreateCompanionBuilder,
    $$TemplatesTableUpdateCompanionBuilder,
    (Template, BaseReferences<_$AppDatabase, $TemplatesTable, Template>),
    Template,
    PrefetchHooks Function()>;
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

class $$GalleryFavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $GalleryFavoritesTable> {
  $$GalleryFavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedDate => $composableBuilder(
      column: $table.addedDate, builder: (column) => ColumnFilters(column));
}

class $$GalleryFavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $GalleryFavoritesTable> {
  $$GalleryFavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedDate => $composableBuilder(
      column: $table.addedDate, builder: (column) => ColumnOrderings(column));
}

class $$GalleryFavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GalleryFavoritesTable> {
  $$GalleryFavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get addedDate =>
      $composableBuilder(column: $table.addedDate, builder: (column) => column);
}

class $$GalleryFavoritesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GalleryFavoritesTable,
    GalleryFavorite,
    $$GalleryFavoritesTableFilterComposer,
    $$GalleryFavoritesTableOrderingComposer,
    $$GalleryFavoritesTableAnnotationComposer,
    $$GalleryFavoritesTableCreateCompanionBuilder,
    $$GalleryFavoritesTableUpdateCompanionBuilder,
    (
      GalleryFavorite,
      BaseReferences<_$AppDatabase, $GalleryFavoritesTable, GalleryFavorite>
    ),
    GalleryFavorite,
    PrefetchHooks Function()> {
  $$GalleryFavoritesTableTableManager(
      _$AppDatabase db, $GalleryFavoritesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GalleryFavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GalleryFavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GalleryFavoritesTableAnnotationComposer($db: db, $table: table),
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
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GalleryFavoritesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GalleryFavoritesTable,
    GalleryFavorite,
    $$GalleryFavoritesTableFilterComposer,
    $$GalleryFavoritesTableOrderingComposer,
    $$GalleryFavoritesTableAnnotationComposer,
    $$GalleryFavoritesTableCreateCompanionBuilder,
    $$GalleryFavoritesTableUpdateCompanionBuilder,
    (
      GalleryFavorite,
      BaseReferences<_$AppDatabase, $GalleryFavoritesTable, GalleryFavorite>
    ),
    GalleryFavorite,
    PrefetchHooks Function()>;
typedef $$HolidaysTableCreateCompanionBuilder = HolidaysCompanion Function({
  Value<int> id,
  required String name,
  required DateTime date,
  Value<String> type,
  Value<bool> isLunar,
});
typedef $$HolidaysTableUpdateCompanionBuilder = HolidaysCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> date,
  Value<String> type,
  Value<bool> isLunar,
});

class $$HolidaysTableFilterComposer
    extends Composer<_$AppDatabase, $HolidaysTable> {
  $$HolidaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLunar => $composableBuilder(
      column: $table.isLunar, builder: (column) => ColumnFilters(column));
}

class $$HolidaysTableOrderingComposer
    extends Composer<_$AppDatabase, $HolidaysTable> {
  $$HolidaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLunar => $composableBuilder(
      column: $table.isLunar, builder: (column) => ColumnOrderings(column));
}

class $$HolidaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $HolidaysTable> {
  $$HolidaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isLunar =>
      $composableBuilder(column: $table.isLunar, builder: (column) => column);
}

class $$HolidaysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HolidaysTable,
    Holiday,
    $$HolidaysTableFilterComposer,
    $$HolidaysTableOrderingComposer,
    $$HolidaysTableAnnotationComposer,
    $$HolidaysTableCreateCompanionBuilder,
    $$HolidaysTableUpdateCompanionBuilder,
    (Holiday, BaseReferences<_$AppDatabase, $HolidaysTable, Holiday>),
    Holiday,
    PrefetchHooks Function()> {
  $$HolidaysTableTableManager(_$AppDatabase db, $HolidaysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HolidaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HolidaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HolidaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<bool> isLunar = const Value.absent(),
          }) =>
              HolidaysCompanion(
            id: id,
            name: name,
            date: date,
            type: type,
            isLunar: isLunar,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required DateTime date,
            Value<String> type = const Value.absent(),
            Value<bool> isLunar = const Value.absent(),
          }) =>
              HolidaysCompanion.insert(
            id: id,
            name: name,
            date: date,
            type: type,
            isLunar: isLunar,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HolidaysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HolidaysTable,
    Holiday,
    $$HolidaysTableFilterComposer,
    $$HolidaysTableOrderingComposer,
    $$HolidaysTableAnnotationComposer,
    $$HolidaysTableCreateCompanionBuilder,
    $$HolidaysTableUpdateCompanionBuilder,
    (Holiday, BaseReferences<_$AppDatabase, $HolidaysTable, Holiday>),
    Holiday,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$SavedCardsTableTableManager get savedCards =>
      $$SavedCardsTableTableManager(_db, _db.savedCards);
  $$HistoryTableTableManager get history =>
      $$HistoryTableTableManager(_db, _db.history);
  $$TemplatesTableTableManager get templates =>
      $$TemplatesTableTableManager(_db, _db.templates);
  $$GalleryFavoritesTableTableManager get galleryFavorites =>
      $$GalleryFavoritesTableTableManager(_db, _db.galleryFavorites);
  $$HolidaysTableTableManager get holidays =>
      $$HolidaysTableTableManager(_db, _db.holidays);
}
