// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $NotebooksTable extends Notebooks
    with TableInfo<$NotebooksTable, Notebook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotebooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<NotebookKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('year'),
      ).withConverter<NotebookKind>($NotebooksTable.$converterkind);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CoverCloth, String> cover =
      GeneratedColumn<String>(
        'cover',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CoverCloth>($NotebooksTable.$convertercover);
  static const VerificationMeta _coverColorMeta = const VerificationMeta(
    'coverColor',
  );
  @override
  late final GeneratedColumn<int> coverColor = GeneratedColumn<int>(
    'cover_color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trailMeta = const VerificationMeta('trail');
  @override
  late final GeneratedColumn<String> trail = GeneratedColumn<String>(
    'trail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trailNameMeta = const VerificationMeta(
    'trailName',
  );
  @override
  late final GeneratedColumn<String> trailName = GeneratedColumn<String>(
    'trail_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDayMeta = const VerificationMeta(
    'startDay',
  );
  @override
  late final GeneratedColumn<String> startDay = GeneratedColumn<String>(
    'start_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hlc,
    deleted,
    kind,
    title,
    year,
    cover,
    coverColor,
    trail,
    trailName,
    startDay,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notebooks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Notebook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('cover_color')) {
      context.handle(
        _coverColorMeta,
        coverColor.isAcceptableOrUnknown(data['cover_color']!, _coverColorMeta),
      );
    }
    if (data.containsKey('trail')) {
      context.handle(
        _trailMeta,
        trail.isAcceptableOrUnknown(data['trail']!, _trailMeta),
      );
    }
    if (data.containsKey('trail_name')) {
      context.handle(
        _trailNameMeta,
        trailName.isAcceptableOrUnknown(data['trail_name']!, _trailNameMeta),
      );
    }
    if (data.containsKey('start_day')) {
      context.handle(
        _startDayMeta,
        startDay.isAcceptableOrUnknown(data['start_day']!, _startDayMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notebook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notebook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      kind: $NotebooksTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      cover: $NotebooksTable.$convertercover.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cover'],
        )!,
      ),
      coverColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cover_color'],
      ),
      trail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trail'],
      ),
      trailName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trail_name'],
      ),
      startDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_day'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $NotebooksTable createAlias(String alias) {
    return $NotebooksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<NotebookKind, String, String> $converterkind =
      const EnumNameConverter<NotebookKind>(NotebookKind.values);
  static JsonTypeConverter2<CoverCloth, String, String> $convertercover =
      const EnumNameConverter<CoverCloth>(CoverCloth.values);
}

class Notebook extends DataClass implements Insertable<Notebook> {
  /// UUIDv7, generated on the phone.
  final String id;

  /// Hybrid logical clock stamp of the record's last change.
  final String hlc;

  /// Deleted records stay as tombstones so the deletion can sync.
  final bool deleted;

  /// Added in schema 2; notebooks from schema 1 become yearly notebooks.
  final NotebookKind kind;
  final String title;

  /// The year on the spine. One notebook per year is the default.
  final int year;
  final CoverCloth cover;

  /// A colour the person picked instead of a cloth, as 0xRRGGBB (schema 3).
  /// Null shows [cover].
  final int? coverColor;

  /// Trips only: the trail or route ("Pacific Crest Trail"), the hiker's
  /// trail name ("Switchback"), and the first day (YYYY-MM-DD), which
  /// numbers the days.
  final String? trail;
  final String? trailName;
  final String? startDay;
  final int createdAtMs;
  const Notebook({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.kind,
    required this.title,
    required this.year,
    required this.cover,
    this.coverColor,
    this.trail,
    this.trailName,
    this.startDay,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    {
      map['kind'] = Variable<String>(
        $NotebooksTable.$converterkind.toSql(kind),
      );
    }
    map['title'] = Variable<String>(title);
    map['year'] = Variable<int>(year);
    {
      map['cover'] = Variable<String>(
        $NotebooksTable.$convertercover.toSql(cover),
      );
    }
    if (!nullToAbsent || coverColor != null) {
      map['cover_color'] = Variable<int>(coverColor);
    }
    if (!nullToAbsent || trail != null) {
      map['trail'] = Variable<String>(trail);
    }
    if (!nullToAbsent || trailName != null) {
      map['trail_name'] = Variable<String>(trailName);
    }
    if (!nullToAbsent || startDay != null) {
      map['start_day'] = Variable<String>(startDay);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  NotebooksCompanion toCompanion(bool nullToAbsent) {
    return NotebooksCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      kind: Value(kind),
      title: Value(title),
      year: Value(year),
      cover: Value(cover),
      coverColor: coverColor == null && nullToAbsent
          ? const Value.absent()
          : Value(coverColor),
      trail: trail == null && nullToAbsent
          ? const Value.absent()
          : Value(trail),
      trailName: trailName == null && nullToAbsent
          ? const Value.absent()
          : Value(trailName),
      startDay: startDay == null && nullToAbsent
          ? const Value.absent()
          : Value(startDay),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory Notebook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notebook(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      kind: $NotebooksTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      title: serializer.fromJson<String>(json['title']),
      year: serializer.fromJson<int>(json['year']),
      cover: $NotebooksTable.$convertercover.fromJson(
        serializer.fromJson<String>(json['cover']),
      ),
      coverColor: serializer.fromJson<int?>(json['coverColor']),
      trail: serializer.fromJson<String?>(json['trail']),
      trailName: serializer.fromJson<String?>(json['trailName']),
      startDay: serializer.fromJson<String?>(json['startDay']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'kind': serializer.toJson<String>(
        $NotebooksTable.$converterkind.toJson(kind),
      ),
      'title': serializer.toJson<String>(title),
      'year': serializer.toJson<int>(year),
      'cover': serializer.toJson<String>(
        $NotebooksTable.$convertercover.toJson(cover),
      ),
      'coverColor': serializer.toJson<int?>(coverColor),
      'trail': serializer.toJson<String?>(trail),
      'trailName': serializer.toJson<String?>(trailName),
      'startDay': serializer.toJson<String?>(startDay),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  Notebook copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    NotebookKind? kind,
    String? title,
    int? year,
    CoverCloth? cover,
    Value<int?> coverColor = const Value.absent(),
    Value<String?> trail = const Value.absent(),
    Value<String?> trailName = const Value.absent(),
    Value<String?> startDay = const Value.absent(),
    int? createdAtMs,
  }) => Notebook(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    year: year ?? this.year,
    cover: cover ?? this.cover,
    coverColor: coverColor.present ? coverColor.value : this.coverColor,
    trail: trail.present ? trail.value : this.trail,
    trailName: trailName.present ? trailName.value : this.trailName,
    startDay: startDay.present ? startDay.value : this.startDay,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  Notebook copyWithCompanion(NotebooksCompanion data) {
    return Notebook(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      year: data.year.present ? data.year.value : this.year,
      cover: data.cover.present ? data.cover.value : this.cover,
      coverColor: data.coverColor.present
          ? data.coverColor.value
          : this.coverColor,
      trail: data.trail.present ? data.trail.value : this.trail,
      trailName: data.trailName.present ? data.trailName.value : this.trailName,
      startDay: data.startDay.present ? data.startDay.value : this.startDay,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notebook(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('year: $year, ')
          ..write('cover: $cover, ')
          ..write('coverColor: $coverColor, ')
          ..write('trail: $trail, ')
          ..write('trailName: $trailName, ')
          ..write('startDay: $startDay, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlc,
    deleted,
    kind,
    title,
    year,
    cover,
    coverColor,
    trail,
    trailName,
    startDay,
    createdAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notebook &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.year == this.year &&
          other.cover == this.cover &&
          other.coverColor == this.coverColor &&
          other.trail == this.trail &&
          other.trailName == this.trailName &&
          other.startDay == this.startDay &&
          other.createdAtMs == this.createdAtMs);
}

class NotebooksCompanion extends UpdateCompanion<Notebook> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<NotebookKind> kind;
  final Value<String> title;
  final Value<int> year;
  final Value<CoverCloth> cover;
  final Value<int?> coverColor;
  final Value<String?> trail;
  final Value<String?> trailName;
  final Value<String?> startDay;
  final Value<int> createdAtMs;
  final Value<int> rowid;
  const NotebooksCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.year = const Value.absent(),
    this.cover = const Value.absent(),
    this.coverColor = const Value.absent(),
    this.trail = const Value.absent(),
    this.trailName = const Value.absent(),
    this.startDay = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotebooksCompanion.insert({
    required String id,
    required String hlc,
    this.deleted = const Value.absent(),
    this.kind = const Value.absent(),
    required String title,
    required int year,
    required CoverCloth cover,
    this.coverColor = const Value.absent(),
    this.trail = const Value.absent(),
    this.trailName = const Value.absent(),
    this.startDay = const Value.absent(),
    required int createdAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlc = Value(hlc),
       title = Value(title),
       year = Value(year),
       cover = Value(cover),
       createdAtMs = Value(createdAtMs);
  static Insertable<Notebook> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<int>? year,
    Expression<String>? cover,
    Expression<int>? coverColor,
    Expression<String>? trail,
    Expression<String>? trailName,
    Expression<String>? startDay,
    Expression<int>? createdAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (year != null) 'year': year,
      if (cover != null) 'cover': cover,
      if (coverColor != null) 'cover_color': coverColor,
      if (trail != null) 'trail': trail,
      if (trailName != null) 'trail_name': trailName,
      if (startDay != null) 'start_day': startDay,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotebooksCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<NotebookKind>? kind,
    Value<String>? title,
    Value<int>? year,
    Value<CoverCloth>? cover,
    Value<int?>? coverColor,
    Value<String?>? trail,
    Value<String?>? trailName,
    Value<String?>? startDay,
    Value<int>? createdAtMs,
    Value<int>? rowid,
  }) {
    return NotebooksCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      year: year ?? this.year,
      cover: cover ?? this.cover,
      coverColor: coverColor ?? this.coverColor,
      trail: trail ?? this.trail,
      trailName: trailName ?? this.trailName,
      startDay: startDay ?? this.startDay,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $NotebooksTable.$converterkind.toSql(kind.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(
        $NotebooksTable.$convertercover.toSql(cover.value),
      );
    }
    if (coverColor.present) {
      map['cover_color'] = Variable<int>(coverColor.value);
    }
    if (trail.present) {
      map['trail'] = Variable<String>(trail.value);
    }
    if (trailName.present) {
      map['trail_name'] = Variable<String>(trailName.value);
    }
    if (startDay.present) {
      map['start_day'] = Variable<String>(startDay.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotebooksCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('year: $year, ')
          ..write('cover: $cover, ')
          ..write('coverColor: $coverColor, ')
          ..write('trail: $trail, ')
          ..write('trailName: $trailName, ')
          ..write('startDay: $startDay, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PagesTable extends Pages with TableInfo<$PagesTable, JournalPage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notebookIdMeta = const VerificationMeta(
    'notebookId',
  );
  @override
  late final GeneratedColumn<String> notebookId = GeneratedColumn<String>(
    'notebook_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateMeta = const VerificationMeta(
    'template',
  );
  @override
  late final GeneratedColumn<String> template = GeneratedColumn<String>(
    'template',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _placeMeta = const VerificationMeta('place');
  @override
  late final GeneratedColumn<String> place = GeneratedColumn<String>(
    'place',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elevationMMeta = const VerificationMeta(
    'elevationM',
  );
  @override
  late final GeneratedColumn<double> elevationM = GeneratedColumn<double>(
    'elevation_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherMeta = const VerificationMeta(
    'weather',
  );
  @override
  late final GeneratedColumn<String> weather = GeneratedColumn<String>(
    'weather',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hlc,
    deleted,
    notebookId,
    day,
    template,
    place,
    elevationM,
    weather,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pages';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalPage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('notebook_id')) {
      context.handle(
        _notebookIdMeta,
        notebookId.isAcceptableOrUnknown(data['notebook_id']!, _notebookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_notebookIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('template')) {
      context.handle(
        _templateMeta,
        template.isAcceptableOrUnknown(data['template']!, _templateMeta),
      );
    }
    if (data.containsKey('place')) {
      context.handle(
        _placeMeta,
        place.isAcceptableOrUnknown(data['place']!, _placeMeta),
      );
    }
    if (data.containsKey('elevation_m')) {
      context.handle(
        _elevationMMeta,
        elevationM.isAcceptableOrUnknown(data['elevation_m']!, _elevationMMeta),
      );
    }
    if (data.containsKey('weather')) {
      context.handle(
        _weatherMeta,
        weather.isAcceptableOrUnknown(data['weather']!, _weatherMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalPage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalPage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      notebookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notebook_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      template: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template'],
      ),
      place: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place'],
      ),
      elevationM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_m'],
      ),
      weather: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $PagesTable createAlias(String alias) {
    return $PagesTable(attachedDatabase, alias);
  }
}

class JournalPage extends DataClass implements Insertable<JournalPage> {
  /// UUIDv7, generated on the phone.
  final String id;

  /// Hybrid logical clock stamp of the record's last change.
  final String hlc;

  /// Deleted records stay as tombstones so the deletion can sync.
  final bool deleted;
  final String notebookId;

  /// The calendar day, as YYYY-MM-DD in the hiker's local time.
  final String day;

  /// The template the page was started from; null for a blank page.
  final String? template;

  /// Stamped header fields. Sun and moon times are computed, not stored.
  final String? place;
  final double? elevationM;

  /// Weather as JSON, filled in when there is signal.
  final String? weather;
  final int createdAtMs;
  const JournalPage({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.notebookId,
    required this.day,
    this.template,
    this.place,
    this.elevationM,
    this.weather,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['notebook_id'] = Variable<String>(notebookId);
    map['day'] = Variable<String>(day);
    if (!nullToAbsent || template != null) {
      map['template'] = Variable<String>(template);
    }
    if (!nullToAbsent || place != null) {
      map['place'] = Variable<String>(place);
    }
    if (!nullToAbsent || elevationM != null) {
      map['elevation_m'] = Variable<double>(elevationM);
    }
    if (!nullToAbsent || weather != null) {
      map['weather'] = Variable<String>(weather);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  PagesCompanion toCompanion(bool nullToAbsent) {
    return PagesCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      notebookId: Value(notebookId),
      day: Value(day),
      template: template == null && nullToAbsent
          ? const Value.absent()
          : Value(template),
      place: place == null && nullToAbsent
          ? const Value.absent()
          : Value(place),
      elevationM: elevationM == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationM),
      weather: weather == null && nullToAbsent
          ? const Value.absent()
          : Value(weather),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory JournalPage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalPage(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      notebookId: serializer.fromJson<String>(json['notebookId']),
      day: serializer.fromJson<String>(json['day']),
      template: serializer.fromJson<String?>(json['template']),
      place: serializer.fromJson<String?>(json['place']),
      elevationM: serializer.fromJson<double?>(json['elevationM']),
      weather: serializer.fromJson<String?>(json['weather']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'notebookId': serializer.toJson<String>(notebookId),
      'day': serializer.toJson<String>(day),
      'template': serializer.toJson<String?>(template),
      'place': serializer.toJson<String?>(place),
      'elevationM': serializer.toJson<double?>(elevationM),
      'weather': serializer.toJson<String?>(weather),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  JournalPage copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    String? notebookId,
    String? day,
    Value<String?> template = const Value.absent(),
    Value<String?> place = const Value.absent(),
    Value<double?> elevationM = const Value.absent(),
    Value<String?> weather = const Value.absent(),
    int? createdAtMs,
  }) => JournalPage(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    notebookId: notebookId ?? this.notebookId,
    day: day ?? this.day,
    template: template.present ? template.value : this.template,
    place: place.present ? place.value : this.place,
    elevationM: elevationM.present ? elevationM.value : this.elevationM,
    weather: weather.present ? weather.value : this.weather,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  JournalPage copyWithCompanion(PagesCompanion data) {
    return JournalPage(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      notebookId: data.notebookId.present
          ? data.notebookId.value
          : this.notebookId,
      day: data.day.present ? data.day.value : this.day,
      template: data.template.present ? data.template.value : this.template,
      place: data.place.present ? data.place.value : this.place,
      elevationM: data.elevationM.present
          ? data.elevationM.value
          : this.elevationM,
      weather: data.weather.present ? data.weather.value : this.weather,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalPage(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('notebookId: $notebookId, ')
          ..write('day: $day, ')
          ..write('template: $template, ')
          ..write('place: $place, ')
          ..write('elevationM: $elevationM, ')
          ..write('weather: $weather, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlc,
    deleted,
    notebookId,
    day,
    template,
    place,
    elevationM,
    weather,
    createdAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalPage &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.notebookId == this.notebookId &&
          other.day == this.day &&
          other.template == this.template &&
          other.place == this.place &&
          other.elevationM == this.elevationM &&
          other.weather == this.weather &&
          other.createdAtMs == this.createdAtMs);
}

class PagesCompanion extends UpdateCompanion<JournalPage> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> notebookId;
  final Value<String> day;
  final Value<String?> template;
  final Value<String?> place;
  final Value<double?> elevationM;
  final Value<String?> weather;
  final Value<int> createdAtMs;
  final Value<int> rowid;
  const PagesCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.notebookId = const Value.absent(),
    this.day = const Value.absent(),
    this.template = const Value.absent(),
    this.place = const Value.absent(),
    this.elevationM = const Value.absent(),
    this.weather = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PagesCompanion.insert({
    required String id,
    required String hlc,
    this.deleted = const Value.absent(),
    required String notebookId,
    required String day,
    this.template = const Value.absent(),
    this.place = const Value.absent(),
    this.elevationM = const Value.absent(),
    this.weather = const Value.absent(),
    required int createdAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlc = Value(hlc),
       notebookId = Value(notebookId),
       day = Value(day),
       createdAtMs = Value(createdAtMs);
  static Insertable<JournalPage> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? notebookId,
    Expression<String>? day,
    Expression<String>? template,
    Expression<String>? place,
    Expression<double>? elevationM,
    Expression<String>? weather,
    Expression<int>? createdAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (notebookId != null) 'notebook_id': notebookId,
      if (day != null) 'day': day,
      if (template != null) 'template': template,
      if (place != null) 'place': place,
      if (elevationM != null) 'elevation_m': elevationM,
      if (weather != null) 'weather': weather,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PagesCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? notebookId,
    Value<String>? day,
    Value<String?>? template,
    Value<String?>? place,
    Value<double?>? elevationM,
    Value<String?>? weather,
    Value<int>? createdAtMs,
    Value<int>? rowid,
  }) {
    return PagesCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      notebookId: notebookId ?? this.notebookId,
      day: day ?? this.day,
      template: template ?? this.template,
      place: place ?? this.place,
      elevationM: elevationM ?? this.elevationM,
      weather: weather ?? this.weather,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (notebookId.present) {
      map['notebook_id'] = Variable<String>(notebookId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (template.present) {
      map['template'] = Variable<String>(template.value);
    }
    if (place.present) {
      map['place'] = Variable<String>(place.value);
    }
    if (elevationM.present) {
      map['elevation_m'] = Variable<double>(elevationM.value);
    }
    if (weather.present) {
      map['weather'] = Variable<String>(weather.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagesCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('notebookId: $notebookId, ')
          ..write('day: $day, ')
          ..write('template: $template, ')
          ..write('place: $place, ')
          ..write('elevationM: $elevationM, ')
          ..write('weather: $weather, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PageItemsTable extends PageItems
    with TableInfo<$PageItemsTable, PageItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PageItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<String> pageId = GeneratedColumn<String>(
    'page_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PageItemKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PageItemKind>($PageItemsTable.$converterkind);
  static const VerificationMeta _sectionMeta = const VerificationMeta(
    'section',
  );
  @override
  late final GeneratedColumn<String> section = GeneratedColumn<String>(
    'section',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
    'media_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rotationMeta = const VerificationMeta(
    'rotation',
  );
  @override
  late final GeneratedColumn<double> rotation = GeneratedColumn<double>(
    'rotation',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _styleMeta = const VerificationMeta('style');
  @override
  late final GeneratedColumn<String> style = GeneratedColumn<String>(
    'style',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _zMeta = const VerificationMeta('z');
  @override
  late final GeneratedColumn<int> z = GeneratedColumn<int>(
    'z',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hlc,
    deleted,
    pageId,
    kind,
    section,
    body,
    mediaId,
    x,
    y,
    width,
    height,
    rotation,
    style,
    z,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'page_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PageItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('section')) {
      context.handle(
        _sectionMeta,
        section.isAcceptableOrUnknown(data['section']!, _sectionMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('rotation')) {
      context.handle(
        _rotationMeta,
        rotation.isAcceptableOrUnknown(data['rotation']!, _rotationMeta),
      );
    }
    if (data.containsKey('style')) {
      context.handle(
        _styleMeta,
        style.isAcceptableOrUnknown(data['style']!, _styleMeta),
      );
    }
    if (data.containsKey('z')) {
      context.handle(_zMeta, z.isAcceptableOrUnknown(data['z']!, _zMeta));
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PageItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PageItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_id'],
      )!,
      kind: $PageItemsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      section: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      ),
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x'],
      ),
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      ),
      rotation: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rotation'],
      ),
      style: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style'],
      ),
      z: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}z'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $PageItemsTable createAlias(String alias) {
    return $PageItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PageItemKind, String, String> $converterkind =
      const EnumNameConverter<PageItemKind>(PageItemKind.values);
}

class PageItem extends DataClass implements Insertable<PageItem> {
  /// UUIDv7, generated on the phone.
  final String id;

  /// Hybrid logical clock stamp of the record's last change.
  final String hlc;

  /// Deleted records stay as tombstones so the deletion can sync.
  final bool deleted;
  final String pageId;
  final PageItemKind kind;

  /// The template section text belongs to; null for free writing.
  final String? section;

  /// The writing for text; stroke data as JSON for sketches.
  final String? body;
  final String? mediaId;

  /// Placement in page points for taped items; rotation in radians.
  final double? x;
  final double? y;
  final double? width;
  final double? height;
  final double? rotation;

  /// Print and tape style for photos.
  final String? style;

  /// Stacking order; higher is on top.
  final int z;
  final int createdAtMs;
  const PageItem({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.pageId,
    required this.kind,
    this.section,
    this.body,
    this.mediaId,
    this.x,
    this.y,
    this.width,
    this.height,
    this.rotation,
    this.style,
    required this.z,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['page_id'] = Variable<String>(pageId);
    {
      map['kind'] = Variable<String>(
        $PageItemsTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || section != null) {
      map['section'] = Variable<String>(section);
    }
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    if (!nullToAbsent || mediaId != null) {
      map['media_id'] = Variable<String>(mediaId);
    }
    if (!nullToAbsent || x != null) {
      map['x'] = Variable<double>(x);
    }
    if (!nullToAbsent || y != null) {
      map['y'] = Variable<double>(y);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<double>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<double>(height);
    }
    if (!nullToAbsent || rotation != null) {
      map['rotation'] = Variable<double>(rotation);
    }
    if (!nullToAbsent || style != null) {
      map['style'] = Variable<String>(style);
    }
    map['z'] = Variable<int>(z);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  PageItemsCompanion toCompanion(bool nullToAbsent) {
    return PageItemsCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      pageId: Value(pageId),
      kind: Value(kind),
      section: section == null && nullToAbsent
          ? const Value.absent()
          : Value(section),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      mediaId: mediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaId),
      x: x == null && nullToAbsent ? const Value.absent() : Value(x),
      y: y == null && nullToAbsent ? const Value.absent() : Value(y),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      rotation: rotation == null && nullToAbsent
          ? const Value.absent()
          : Value(rotation),
      style: style == null && nullToAbsent
          ? const Value.absent()
          : Value(style),
      z: Value(z),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory PageItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PageItem(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      pageId: serializer.fromJson<String>(json['pageId']),
      kind: $PageItemsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      section: serializer.fromJson<String?>(json['section']),
      body: serializer.fromJson<String?>(json['body']),
      mediaId: serializer.fromJson<String?>(json['mediaId']),
      x: serializer.fromJson<double?>(json['x']),
      y: serializer.fromJson<double?>(json['y']),
      width: serializer.fromJson<double?>(json['width']),
      height: serializer.fromJson<double?>(json['height']),
      rotation: serializer.fromJson<double?>(json['rotation']),
      style: serializer.fromJson<String?>(json['style']),
      z: serializer.fromJson<int>(json['z']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'pageId': serializer.toJson<String>(pageId),
      'kind': serializer.toJson<String>(
        $PageItemsTable.$converterkind.toJson(kind),
      ),
      'section': serializer.toJson<String?>(section),
      'body': serializer.toJson<String?>(body),
      'mediaId': serializer.toJson<String?>(mediaId),
      'x': serializer.toJson<double?>(x),
      'y': serializer.toJson<double?>(y),
      'width': serializer.toJson<double?>(width),
      'height': serializer.toJson<double?>(height),
      'rotation': serializer.toJson<double?>(rotation),
      'style': serializer.toJson<String?>(style),
      'z': serializer.toJson<int>(z),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  PageItem copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    String? pageId,
    PageItemKind? kind,
    Value<String?> section = const Value.absent(),
    Value<String?> body = const Value.absent(),
    Value<String?> mediaId = const Value.absent(),
    Value<double?> x = const Value.absent(),
    Value<double?> y = const Value.absent(),
    Value<double?> width = const Value.absent(),
    Value<double?> height = const Value.absent(),
    Value<double?> rotation = const Value.absent(),
    Value<String?> style = const Value.absent(),
    int? z,
    int? createdAtMs,
  }) => PageItem(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    pageId: pageId ?? this.pageId,
    kind: kind ?? this.kind,
    section: section.present ? section.value : this.section,
    body: body.present ? body.value : this.body,
    mediaId: mediaId.present ? mediaId.value : this.mediaId,
    x: x.present ? x.value : this.x,
    y: y.present ? y.value : this.y,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    rotation: rotation.present ? rotation.value : this.rotation,
    style: style.present ? style.value : this.style,
    z: z ?? this.z,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  PageItem copyWithCompanion(PageItemsCompanion data) {
    return PageItem(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      kind: data.kind.present ? data.kind.value : this.kind,
      section: data.section.present ? data.section.value : this.section,
      body: data.body.present ? data.body.value : this.body,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      rotation: data.rotation.present ? data.rotation.value : this.rotation,
      style: data.style.present ? data.style.value : this.style,
      z: data.z.present ? data.z.value : this.z,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PageItem(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('pageId: $pageId, ')
          ..write('kind: $kind, ')
          ..write('section: $section, ')
          ..write('body: $body, ')
          ..write('mediaId: $mediaId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('rotation: $rotation, ')
          ..write('style: $style, ')
          ..write('z: $z, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlc,
    deleted,
    pageId,
    kind,
    section,
    body,
    mediaId,
    x,
    y,
    width,
    height,
    rotation,
    style,
    z,
    createdAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PageItem &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.pageId == this.pageId &&
          other.kind == this.kind &&
          other.section == this.section &&
          other.body == this.body &&
          other.mediaId == this.mediaId &&
          other.x == this.x &&
          other.y == this.y &&
          other.width == this.width &&
          other.height == this.height &&
          other.rotation == this.rotation &&
          other.style == this.style &&
          other.z == this.z &&
          other.createdAtMs == this.createdAtMs);
}

class PageItemsCompanion extends UpdateCompanion<PageItem> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> pageId;
  final Value<PageItemKind> kind;
  final Value<String?> section;
  final Value<String?> body;
  final Value<String?> mediaId;
  final Value<double?> x;
  final Value<double?> y;
  final Value<double?> width;
  final Value<double?> height;
  final Value<double?> rotation;
  final Value<String?> style;
  final Value<int> z;
  final Value<int> createdAtMs;
  final Value<int> rowid;
  const PageItemsCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.pageId = const Value.absent(),
    this.kind = const Value.absent(),
    this.section = const Value.absent(),
    this.body = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.rotation = const Value.absent(),
    this.style = const Value.absent(),
    this.z = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PageItemsCompanion.insert({
    required String id,
    required String hlc,
    this.deleted = const Value.absent(),
    required String pageId,
    required PageItemKind kind,
    this.section = const Value.absent(),
    this.body = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.rotation = const Value.absent(),
    this.style = const Value.absent(),
    this.z = const Value.absent(),
    required int createdAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlc = Value(hlc),
       pageId = Value(pageId),
       kind = Value(kind),
       createdAtMs = Value(createdAtMs);
  static Insertable<PageItem> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? pageId,
    Expression<String>? kind,
    Expression<String>? section,
    Expression<String>? body,
    Expression<String>? mediaId,
    Expression<double>? x,
    Expression<double>? y,
    Expression<double>? width,
    Expression<double>? height,
    Expression<double>? rotation,
    Expression<String>? style,
    Expression<int>? z,
    Expression<int>? createdAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (pageId != null) 'page_id': pageId,
      if (kind != null) 'kind': kind,
      if (section != null) 'section': section,
      if (body != null) 'body': body,
      if (mediaId != null) 'media_id': mediaId,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (rotation != null) 'rotation': rotation,
      if (style != null) 'style': style,
      if (z != null) 'z': z,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PageItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? pageId,
    Value<PageItemKind>? kind,
    Value<String?>? section,
    Value<String?>? body,
    Value<String?>? mediaId,
    Value<double?>? x,
    Value<double?>? y,
    Value<double?>? width,
    Value<double?>? height,
    Value<double?>? rotation,
    Value<String?>? style,
    Value<int>? z,
    Value<int>? createdAtMs,
    Value<int>? rowid,
  }) {
    return PageItemsCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      pageId: pageId ?? this.pageId,
      kind: kind ?? this.kind,
      section: section ?? this.section,
      body: body ?? this.body,
      mediaId: mediaId ?? this.mediaId,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      style: style ?? this.style,
      z: z ?? this.z,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<String>(pageId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $PageItemsTable.$converterkind.toSql(kind.value),
      );
    }
    if (section.present) {
      map['section'] = Variable<String>(section.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (rotation.present) {
      map['rotation'] = Variable<double>(rotation.value);
    }
    if (style.present) {
      map['style'] = Variable<String>(style.value);
    }
    if (z.present) {
      map['z'] = Variable<int>(z.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PageItemsCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('pageId: $pageId, ')
          ..write('kind: $kind, ')
          ..write('section: $section, ')
          ..write('body: $body, ')
          ..write('mediaId: $mediaId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('rotation: $rotation, ')
          ..write('style: $style, ')
          ..write('z: $z, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PocketItemsTable extends PocketItems
    with TableInfo<$PocketItemsTable, PocketItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PocketItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notebookIdMeta = const VerificationMeta(
    'notebookId',
  );
  @override
  late final GeneratedColumn<String> notebookId = GeneratedColumn<String>(
    'notebook_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PocketItemKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PocketItemKind>($PocketItemsTable.$converterkind);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
    'media_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedAtMsMeta = const VerificationMeta(
    'capturedAtMs',
  );
  @override
  late final GeneratedColumn<int> capturedAtMs = GeneratedColumn<int>(
    'captured_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placedItemIdMeta = const VerificationMeta(
    'placedItemId',
  );
  @override
  late final GeneratedColumn<String> placedItemId = GeneratedColumn<String>(
    'placed_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hlc,
    deleted,
    notebookId,
    kind,
    body,
    mediaId,
    capturedAtMs,
    placedItemId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pocket_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PocketItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('notebook_id')) {
      context.handle(
        _notebookIdMeta,
        notebookId.isAcceptableOrUnknown(data['notebook_id']!, _notebookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_notebookIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    }
    if (data.containsKey('captured_at_ms')) {
      context.handle(
        _capturedAtMsMeta,
        capturedAtMs.isAcceptableOrUnknown(
          data['captured_at_ms']!,
          _capturedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMsMeta);
    }
    if (data.containsKey('placed_item_id')) {
      context.handle(
        _placedItemIdMeta,
        placedItemId.isAcceptableOrUnknown(
          data['placed_item_id']!,
          _placedItemIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PocketItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PocketItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      notebookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notebook_id'],
      )!,
      kind: $PocketItemsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      ),
      capturedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}captured_at_ms'],
      )!,
      placedItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}placed_item_id'],
      ),
    );
  }

  @override
  $PocketItemsTable createAlias(String alias) {
    return $PocketItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PocketItemKind, String, String> $converterkind =
      const EnumNameConverter<PocketItemKind>(PocketItemKind.values);
}

class PocketItem extends DataClass implements Insertable<PocketItem> {
  /// UUIDv7, generated on the phone.
  final String id;

  /// Hybrid logical clock stamp of the record's last change.
  final String hlc;

  /// Deleted records stay as tombstones so the deletion can sync.
  final bool deleted;
  final String notebookId;
  final PocketItemKind kind;

  /// The text, or a voice note's transcript.
  final String? body;
  final String? mediaId;
  final int capturedAtMs;

  /// The page item it became when laid out; null while in the pocket.
  final String? placedItemId;
  const PocketItem({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.notebookId,
    required this.kind,
    this.body,
    this.mediaId,
    required this.capturedAtMs,
    this.placedItemId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['notebook_id'] = Variable<String>(notebookId);
    {
      map['kind'] = Variable<String>(
        $PocketItemsTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    if (!nullToAbsent || mediaId != null) {
      map['media_id'] = Variable<String>(mediaId);
    }
    map['captured_at_ms'] = Variable<int>(capturedAtMs);
    if (!nullToAbsent || placedItemId != null) {
      map['placed_item_id'] = Variable<String>(placedItemId);
    }
    return map;
  }

  PocketItemsCompanion toCompanion(bool nullToAbsent) {
    return PocketItemsCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      notebookId: Value(notebookId),
      kind: Value(kind),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      mediaId: mediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaId),
      capturedAtMs: Value(capturedAtMs),
      placedItemId: placedItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(placedItemId),
    );
  }

  factory PocketItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PocketItem(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      notebookId: serializer.fromJson<String>(json['notebookId']),
      kind: $PocketItemsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      body: serializer.fromJson<String?>(json['body']),
      mediaId: serializer.fromJson<String?>(json['mediaId']),
      capturedAtMs: serializer.fromJson<int>(json['capturedAtMs']),
      placedItemId: serializer.fromJson<String?>(json['placedItemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'notebookId': serializer.toJson<String>(notebookId),
      'kind': serializer.toJson<String>(
        $PocketItemsTable.$converterkind.toJson(kind),
      ),
      'body': serializer.toJson<String?>(body),
      'mediaId': serializer.toJson<String?>(mediaId),
      'capturedAtMs': serializer.toJson<int>(capturedAtMs),
      'placedItemId': serializer.toJson<String?>(placedItemId),
    };
  }

  PocketItem copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    String? notebookId,
    PocketItemKind? kind,
    Value<String?> body = const Value.absent(),
    Value<String?> mediaId = const Value.absent(),
    int? capturedAtMs,
    Value<String?> placedItemId = const Value.absent(),
  }) => PocketItem(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    notebookId: notebookId ?? this.notebookId,
    kind: kind ?? this.kind,
    body: body.present ? body.value : this.body,
    mediaId: mediaId.present ? mediaId.value : this.mediaId,
    capturedAtMs: capturedAtMs ?? this.capturedAtMs,
    placedItemId: placedItemId.present ? placedItemId.value : this.placedItemId,
  );
  PocketItem copyWithCompanion(PocketItemsCompanion data) {
    return PocketItem(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      notebookId: data.notebookId.present
          ? data.notebookId.value
          : this.notebookId,
      kind: data.kind.present ? data.kind.value : this.kind,
      body: data.body.present ? data.body.value : this.body,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      capturedAtMs: data.capturedAtMs.present
          ? data.capturedAtMs.value
          : this.capturedAtMs,
      placedItemId: data.placedItemId.present
          ? data.placedItemId.value
          : this.placedItemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PocketItem(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('notebookId: $notebookId, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('mediaId: $mediaId, ')
          ..write('capturedAtMs: $capturedAtMs, ')
          ..write('placedItemId: $placedItemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlc,
    deleted,
    notebookId,
    kind,
    body,
    mediaId,
    capturedAtMs,
    placedItemId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PocketItem &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.notebookId == this.notebookId &&
          other.kind == this.kind &&
          other.body == this.body &&
          other.mediaId == this.mediaId &&
          other.capturedAtMs == this.capturedAtMs &&
          other.placedItemId == this.placedItemId);
}

class PocketItemsCompanion extends UpdateCompanion<PocketItem> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> notebookId;
  final Value<PocketItemKind> kind;
  final Value<String?> body;
  final Value<String?> mediaId;
  final Value<int> capturedAtMs;
  final Value<String?> placedItemId;
  final Value<int> rowid;
  const PocketItemsCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.notebookId = const Value.absent(),
    this.kind = const Value.absent(),
    this.body = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.capturedAtMs = const Value.absent(),
    this.placedItemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PocketItemsCompanion.insert({
    required String id,
    required String hlc,
    this.deleted = const Value.absent(),
    required String notebookId,
    required PocketItemKind kind,
    this.body = const Value.absent(),
    this.mediaId = const Value.absent(),
    required int capturedAtMs,
    this.placedItemId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlc = Value(hlc),
       notebookId = Value(notebookId),
       kind = Value(kind),
       capturedAtMs = Value(capturedAtMs);
  static Insertable<PocketItem> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? notebookId,
    Expression<String>? kind,
    Expression<String>? body,
    Expression<String>? mediaId,
    Expression<int>? capturedAtMs,
    Expression<String>? placedItemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (notebookId != null) 'notebook_id': notebookId,
      if (kind != null) 'kind': kind,
      if (body != null) 'body': body,
      if (mediaId != null) 'media_id': mediaId,
      if (capturedAtMs != null) 'captured_at_ms': capturedAtMs,
      if (placedItemId != null) 'placed_item_id': placedItemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PocketItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? notebookId,
    Value<PocketItemKind>? kind,
    Value<String?>? body,
    Value<String?>? mediaId,
    Value<int>? capturedAtMs,
    Value<String?>? placedItemId,
    Value<int>? rowid,
  }) {
    return PocketItemsCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      notebookId: notebookId ?? this.notebookId,
      kind: kind ?? this.kind,
      body: body ?? this.body,
      mediaId: mediaId ?? this.mediaId,
      capturedAtMs: capturedAtMs ?? this.capturedAtMs,
      placedItemId: placedItemId ?? this.placedItemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (notebookId.present) {
      map['notebook_id'] = Variable<String>(notebookId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $PocketItemsTable.$converterkind.toSql(kind.value),
      );
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (capturedAtMs.present) {
      map['captured_at_ms'] = Variable<int>(capturedAtMs.value);
    }
    if (placedItemId.present) {
      map['placed_item_id'] = Variable<String>(placedItemId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PocketItemsCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('notebookId: $notebookId, ')
          ..write('kind: $kind, ')
          ..write('body: $body, ')
          ..write('mediaId: $mediaId, ')
          ..write('capturedAtMs: $capturedAtMs, ')
          ..write('placedItemId: $placedItemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationPointsTable extends LocationPoints
    with TableInfo<$LocationPointsTable, LocationPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recordedAtMsMeta = const VerificationMeta(
    'recordedAtMs',
  );
  @override
  late final GeneratedColumn<int> recordedAtMs = GeneratedColumn<int>(
    'recorded_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta(
    'accuracyM',
  );
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
    'accuracy_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMMeta = const VerificationMeta(
    'altitudeM',
  );
  @override
  late final GeneratedColumn<double> altitudeM = GeneratedColumn<double>(
    'altitude_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pressureHpaMeta = const VerificationMeta(
    'pressureHpa',
  );
  @override
  late final GeneratedColumn<double> pressureHpa = GeneratedColumn<double>(
    'pressure_hpa',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PointTrigger, String> trigger =
      GeneratedColumn<String>(
        'trigger',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PointTrigger>($LocationPointsTable.$convertertrigger);
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<String> pageId = GeneratedColumn<String>(
    'page_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pocketItemIdMeta = const VerificationMeta(
    'pocketItemId',
  );
  @override
  late final GeneratedColumn<String> pocketItemId = GeneratedColumn<String>(
    'pocket_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hlc,
    deleted,
    recordedAtMs,
    latitude,
    longitude,
    accuracyM,
    altitudeM,
    pressureHpa,
    trigger,
    pageId,
    pocketItemId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('recorded_at_ms')) {
      context.handle(
        _recordedAtMsMeta,
        recordedAtMs.isAcceptableOrUnknown(
          data['recorded_at_ms']!,
          _recordedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMsMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(
        _accuracyMMeta,
        accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyMMeta);
    }
    if (data.containsKey('altitude_m')) {
      context.handle(
        _altitudeMMeta,
        altitudeM.isAcceptableOrUnknown(data['altitude_m']!, _altitudeMMeta),
      );
    }
    if (data.containsKey('pressure_hpa')) {
      context.handle(
        _pressureHpaMeta,
        pressureHpa.isAcceptableOrUnknown(
          data['pressure_hpa']!,
          _pressureHpaMeta,
        ),
      );
    }
    if (data.containsKey('page_id')) {
      context.handle(
        _pageIdMeta,
        pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta),
      );
    }
    if (data.containsKey('pocket_item_id')) {
      context.handle(
        _pocketItemIdMeta,
        pocketItemId.isAcceptableOrUnknown(
          data['pocket_item_id']!,
          _pocketItemIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      recordedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_at_ms'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      accuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_m'],
      )!,
      altitudeM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude_m'],
      ),
      pressureHpa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pressure_hpa'],
      ),
      trigger: $LocationPointsTable.$convertertrigger.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}trigger'],
        )!,
      ),
      pageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_id'],
      ),
      pocketItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pocket_item_id'],
      ),
    );
  }

  @override
  $LocationPointsTable createAlias(String alias) {
    return $LocationPointsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PointTrigger, String, String> $convertertrigger =
      const EnumNameConverter<PointTrigger>(PointTrigger.values);
}

class LocationPoint extends DataClass implements Insertable<LocationPoint> {
  /// UUIDv7, generated on the phone.
  final String id;

  /// Hybrid logical clock stamp of the record's last change.
  final String hlc;

  /// Deleted records stay as tombstones so the deletion can sync.
  final bool deleted;
  final int recordedAtMs;
  final double latitude;
  final double longitude;
  final double accuracyM;
  final double? altitudeM;
  final double? pressureHpa;
  final PointTrigger trigger;
  final String? pageId;
  final String? pocketItemId;
  const LocationPoint({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.recordedAtMs,
    required this.latitude,
    required this.longitude,
    required this.accuracyM,
    this.altitudeM,
    this.pressureHpa,
    required this.trigger,
    this.pageId,
    this.pocketItemId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['recorded_at_ms'] = Variable<int>(recordedAtMs);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['accuracy_m'] = Variable<double>(accuracyM);
    if (!nullToAbsent || altitudeM != null) {
      map['altitude_m'] = Variable<double>(altitudeM);
    }
    if (!nullToAbsent || pressureHpa != null) {
      map['pressure_hpa'] = Variable<double>(pressureHpa);
    }
    {
      map['trigger'] = Variable<String>(
        $LocationPointsTable.$convertertrigger.toSql(trigger),
      );
    }
    if (!nullToAbsent || pageId != null) {
      map['page_id'] = Variable<String>(pageId);
    }
    if (!nullToAbsent || pocketItemId != null) {
      map['pocket_item_id'] = Variable<String>(pocketItemId);
    }
    return map;
  }

  LocationPointsCompanion toCompanion(bool nullToAbsent) {
    return LocationPointsCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      recordedAtMs: Value(recordedAtMs),
      latitude: Value(latitude),
      longitude: Value(longitude),
      accuracyM: Value(accuracyM),
      altitudeM: altitudeM == null && nullToAbsent
          ? const Value.absent()
          : Value(altitudeM),
      pressureHpa: pressureHpa == null && nullToAbsent
          ? const Value.absent()
          : Value(pressureHpa),
      trigger: Value(trigger),
      pageId: pageId == null && nullToAbsent
          ? const Value.absent()
          : Value(pageId),
      pocketItemId: pocketItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(pocketItemId),
    );
  }

  factory LocationPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationPoint(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      recordedAtMs: serializer.fromJson<int>(json['recordedAtMs']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      accuracyM: serializer.fromJson<double>(json['accuracyM']),
      altitudeM: serializer.fromJson<double?>(json['altitudeM']),
      pressureHpa: serializer.fromJson<double?>(json['pressureHpa']),
      trigger: $LocationPointsTable.$convertertrigger.fromJson(
        serializer.fromJson<String>(json['trigger']),
      ),
      pageId: serializer.fromJson<String?>(json['pageId']),
      pocketItemId: serializer.fromJson<String?>(json['pocketItemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'recordedAtMs': serializer.toJson<int>(recordedAtMs),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'accuracyM': serializer.toJson<double>(accuracyM),
      'altitudeM': serializer.toJson<double?>(altitudeM),
      'pressureHpa': serializer.toJson<double?>(pressureHpa),
      'trigger': serializer.toJson<String>(
        $LocationPointsTable.$convertertrigger.toJson(trigger),
      ),
      'pageId': serializer.toJson<String?>(pageId),
      'pocketItemId': serializer.toJson<String?>(pocketItemId),
    };
  }

  LocationPoint copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    int? recordedAtMs,
    double? latitude,
    double? longitude,
    double? accuracyM,
    Value<double?> altitudeM = const Value.absent(),
    Value<double?> pressureHpa = const Value.absent(),
    PointTrigger? trigger,
    Value<String?> pageId = const Value.absent(),
    Value<String?> pocketItemId = const Value.absent(),
  }) => LocationPoint(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    recordedAtMs: recordedAtMs ?? this.recordedAtMs,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    accuracyM: accuracyM ?? this.accuracyM,
    altitudeM: altitudeM.present ? altitudeM.value : this.altitudeM,
    pressureHpa: pressureHpa.present ? pressureHpa.value : this.pressureHpa,
    trigger: trigger ?? this.trigger,
    pageId: pageId.present ? pageId.value : this.pageId,
    pocketItemId: pocketItemId.present ? pocketItemId.value : this.pocketItemId,
  );
  LocationPoint copyWithCompanion(LocationPointsCompanion data) {
    return LocationPoint(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      recordedAtMs: data.recordedAtMs.present
          ? data.recordedAtMs.value
          : this.recordedAtMs,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      altitudeM: data.altitudeM.present ? data.altitudeM.value : this.altitudeM,
      pressureHpa: data.pressureHpa.present
          ? data.pressureHpa.value
          : this.pressureHpa,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      pocketItemId: data.pocketItemId.present
          ? data.pocketItemId.value
          : this.pocketItemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationPoint(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('recordedAtMs: $recordedAtMs, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('altitudeM: $altitudeM, ')
          ..write('pressureHpa: $pressureHpa, ')
          ..write('trigger: $trigger, ')
          ..write('pageId: $pageId, ')
          ..write('pocketItemId: $pocketItemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlc,
    deleted,
    recordedAtMs,
    latitude,
    longitude,
    accuracyM,
    altitudeM,
    pressureHpa,
    trigger,
    pageId,
    pocketItemId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationPoint &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.recordedAtMs == this.recordedAtMs &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.accuracyM == this.accuracyM &&
          other.altitudeM == this.altitudeM &&
          other.pressureHpa == this.pressureHpa &&
          other.trigger == this.trigger &&
          other.pageId == this.pageId &&
          other.pocketItemId == this.pocketItemId);
}

class LocationPointsCompanion extends UpdateCompanion<LocationPoint> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<int> recordedAtMs;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> accuracyM;
  final Value<double?> altitudeM;
  final Value<double?> pressureHpa;
  final Value<PointTrigger> trigger;
  final Value<String?> pageId;
  final Value<String?> pocketItemId;
  final Value<int> rowid;
  const LocationPointsCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.recordedAtMs = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.altitudeM = const Value.absent(),
    this.pressureHpa = const Value.absent(),
    this.trigger = const Value.absent(),
    this.pageId = const Value.absent(),
    this.pocketItemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationPointsCompanion.insert({
    required String id,
    required String hlc,
    this.deleted = const Value.absent(),
    required int recordedAtMs,
    required double latitude,
    required double longitude,
    required double accuracyM,
    this.altitudeM = const Value.absent(),
    this.pressureHpa = const Value.absent(),
    required PointTrigger trigger,
    this.pageId = const Value.absent(),
    this.pocketItemId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlc = Value(hlc),
       recordedAtMs = Value(recordedAtMs),
       latitude = Value(latitude),
       longitude = Value(longitude),
       accuracyM = Value(accuracyM),
       trigger = Value(trigger);
  static Insertable<LocationPoint> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<int>? recordedAtMs,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? accuracyM,
    Expression<double>? altitudeM,
    Expression<double>? pressureHpa,
    Expression<String>? trigger,
    Expression<String>? pageId,
    Expression<String>? pocketItemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (recordedAtMs != null) 'recorded_at_ms': recordedAtMs,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (altitudeM != null) 'altitude_m': altitudeM,
      if (pressureHpa != null) 'pressure_hpa': pressureHpa,
      if (trigger != null) 'trigger': trigger,
      if (pageId != null) 'page_id': pageId,
      if (pocketItemId != null) 'pocket_item_id': pocketItemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationPointsCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<int>? recordedAtMs,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? accuracyM,
    Value<double?>? altitudeM,
    Value<double?>? pressureHpa,
    Value<PointTrigger>? trigger,
    Value<String?>? pageId,
    Value<String?>? pocketItemId,
    Value<int>? rowid,
  }) {
    return LocationPointsCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      recordedAtMs: recordedAtMs ?? this.recordedAtMs,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyM: accuracyM ?? this.accuracyM,
      altitudeM: altitudeM ?? this.altitudeM,
      pressureHpa: pressureHpa ?? this.pressureHpa,
      trigger: trigger ?? this.trigger,
      pageId: pageId ?? this.pageId,
      pocketItemId: pocketItemId ?? this.pocketItemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (recordedAtMs.present) {
      map['recorded_at_ms'] = Variable<int>(recordedAtMs.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (altitudeM.present) {
      map['altitude_m'] = Variable<double>(altitudeM.value);
    }
    if (pressureHpa.present) {
      map['pressure_hpa'] = Variable<double>(pressureHpa.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(
        $LocationPointsTable.$convertertrigger.toSql(trigger.value),
      );
    }
    if (pageId.present) {
      map['page_id'] = Variable<String>(pageId.value);
    }
    if (pocketItemId.present) {
      map['pocket_item_id'] = Variable<String>(pocketItemId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationPointsCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('recordedAtMs: $recordedAtMs, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('altitudeM: $altitudeM, ')
          ..write('pressureHpa: $pressureHpa, ')
          ..write('trigger: $trigger, ')
          ..write('pageId: $pageId, ')
          ..write('pocketItemId: $pocketItemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaTable extends Media with TableInfo<$MediaTable, MediaRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MediaKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MediaKind>($MediaTable.$converterkind);
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hlc,
    deleted,
    kind,
    mimeType,
    byteSize,
    width,
    height,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_byteSizeMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      kind: $MediaTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $MediaTable createAlias(String alias) {
    return $MediaTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MediaKind, String, String> $converterkind =
      const EnumNameConverter<MediaKind>(MediaKind.values);
}

class MediaRecord extends DataClass implements Insertable<MediaRecord> {
  /// UUIDv7, generated on the phone.
  final String id;

  /// Hybrid logical clock stamp of the record's last change.
  final String hlc;

  /// Deleted records stay as tombstones so the deletion can sync.
  final bool deleted;
  final MediaKind kind;
  final String mimeType;

  /// Size of the original file, before encryption.
  final int byteSize;
  final int? width;
  final int? height;
  final int createdAtMs;
  const MediaRecord({
    required this.id,
    required this.hlc,
    required this.deleted,
    required this.kind,
    required this.mimeType,
    required this.byteSize,
    this.width,
    this.height,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    {
      map['kind'] = Variable<String>($MediaTable.$converterkind.toSql(kind));
    }
    map['mime_type'] = Variable<String>(mimeType);
    map['byte_size'] = Variable<int>(byteSize);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  MediaCompanion toCompanion(bool nullToAbsent) {
    return MediaCompanion(
      id: Value(id),
      hlc: Value(hlc),
      deleted: Value(deleted),
      kind: Value(kind),
      mimeType: Value(mimeType),
      byteSize: Value(byteSize),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory MediaRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaRecord(
      id: serializer.fromJson<String>(json['id']),
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      kind: $MediaTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      byteSize: serializer.fromJson<int>(json['byteSize']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'kind': serializer.toJson<String>(
        $MediaTable.$converterkind.toJson(kind),
      ),
      'mimeType': serializer.toJson<String>(mimeType),
      'byteSize': serializer.toJson<int>(byteSize),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  MediaRecord copyWith({
    String? id,
    String? hlc,
    bool? deleted,
    MediaKind? kind,
    String? mimeType,
    int? byteSize,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    int? createdAtMs,
  }) => MediaRecord(
    id: id ?? this.id,
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    kind: kind ?? this.kind,
    mimeType: mimeType ?? this.mimeType,
    byteSize: byteSize ?? this.byteSize,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  MediaRecord copyWithCompanion(MediaCompanion data) {
    return MediaRecord(
      id: data.id.present ? data.id.value : this.id,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      kind: data.kind.present ? data.kind.value : this.kind,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaRecord(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('kind: $kind, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlc,
    deleted,
    kind,
    mimeType,
    byteSize,
    width,
    height,
    createdAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaRecord &&
          other.id == this.id &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.kind == this.kind &&
          other.mimeType == this.mimeType &&
          other.byteSize == this.byteSize &&
          other.width == this.width &&
          other.height == this.height &&
          other.createdAtMs == this.createdAtMs);
}

class MediaCompanion extends UpdateCompanion<MediaRecord> {
  final Value<String> id;
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<MediaKind> kind;
  final Value<String> mimeType;
  final Value<int> byteSize;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int> createdAtMs;
  final Value<int> rowid;
  const MediaCompanion({
    this.id = const Value.absent(),
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.kind = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaCompanion.insert({
    required String id,
    required String hlc,
    this.deleted = const Value.absent(),
    required MediaKind kind,
    required String mimeType,
    required int byteSize,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required int createdAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlc = Value(hlc),
       kind = Value(kind),
       mimeType = Value(mimeType),
       byteSize = Value(byteSize),
       createdAtMs = Value(createdAtMs);
  static Insertable<MediaRecord> custom({
    Expression<String>? id,
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? kind,
    Expression<String>? mimeType,
    Expression<int>? byteSize,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? createdAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (kind != null) 'kind': kind,
      if (mimeType != null) 'mime_type': mimeType,
      if (byteSize != null) 'byte_size': byteSize,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaCompanion copyWith({
    Value<String>? id,
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<MediaKind>? kind,
    Value<String>? mimeType,
    Value<int>? byteSize,
    Value<int?>? width,
    Value<int?>? height,
    Value<int>? createdAtMs,
    Value<int>? rowid,
  }) {
    return MediaCompanion(
      id: id ?? this.id,
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      kind: kind ?? this.kind,
      mimeType: mimeType ?? this.mimeType,
      byteSize: byteSize ?? this.byteSize,
      width: width ?? this.width,
      height: height ?? this.height,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $MediaTable.$converterkind.toSql(kind.value),
      );
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaCompanion(')
          ..write('id: $id, ')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('kind: $kind, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaTable extends Meta with TableInfo<$MetaTable, MetaEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $MetaTable createAlias(String alias) {
    return $MetaTable(attachedDatabase, alias);
  }
}

class MetaEntry extends DataClass implements Insertable<MetaEntry> {
  final String key;
  final String value;
  const MetaEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaCompanion toCompanion(bool nullToAbsent) {
    return MetaCompanion(key: Value(key), value: Value(value));
  }

  factory MetaEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  MetaEntry copyWith({String? key, String? value}) =>
      MetaEntry(key: key ?? this.key, value: value ?? this.value);
  MetaEntry copyWithCompanion(MetaCompanion data) {
    return MetaEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class MetaCompanion extends UpdateCompanion<MetaEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<MetaEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChangesTable extends Changes with TableInfo<$ChangesTable, Change> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<RecordType, String> recordType =
      GeneratedColumn<String>(
        'record_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecordType>($ChangesTable.$converterrecordType);
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ChangeOp, String> op =
      GeneratedColumn<String>(
        'op',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ChangeOp>($ChangesTable.$converterop);
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _packSeqMeta = const VerificationMeta(
    'packSeq',
  );
  @override
  late final GeneratedColumn<int> packSeq = GeneratedColumn<int>(
    'pack_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    recordType,
    recordId,
    hlc,
    op,
    payload,
    packSeq,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Change> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('pack_seq')) {
      context.handle(
        _packSeqMeta,
        packSeq.isAcceptableOrUnknown(data['pack_seq']!, _packSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  Change map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Change(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      recordType: $ChangesTable.$converterrecordType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}record_type'],
        )!,
      ),
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      op: $ChangesTable.$converterop.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}op'],
        )!,
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
      packSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pack_seq'],
      ),
    );
  }

  @override
  $ChangesTable createAlias(String alias) {
    return $ChangesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RecordType, String, String> $converterrecordType =
      const EnumNameConverter<RecordType>(RecordType.values);
  static JsonTypeConverter2<ChangeOp, String, String> $converterop =
      const EnumNameConverter<ChangeOp>(ChangeOp.values);
}

class Change extends DataClass implements Insertable<Change> {
  final int seq;
  final RecordType recordType;
  final String recordId;
  final String hlc;
  final ChangeOp op;

  /// The whole record as JSON for an upsert; null for a delete.
  final String? payload;

  /// The pack this change was sent in; null until it syncs.
  final int? packSeq;
  const Change({
    required this.seq,
    required this.recordType,
    required this.recordId,
    required this.hlc,
    required this.op,
    this.payload,
    this.packSeq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    {
      map['record_type'] = Variable<String>(
        $ChangesTable.$converterrecordType.toSql(recordType),
      );
    }
    map['record_id'] = Variable<String>(recordId);
    map['hlc'] = Variable<String>(hlc);
    {
      map['op'] = Variable<String>($ChangesTable.$converterop.toSql(op));
    }
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    if (!nullToAbsent || packSeq != null) {
      map['pack_seq'] = Variable<int>(packSeq);
    }
    return map;
  }

  ChangesCompanion toCompanion(bool nullToAbsent) {
    return ChangesCompanion(
      seq: Value(seq),
      recordType: Value(recordType),
      recordId: Value(recordId),
      hlc: Value(hlc),
      op: Value(op),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      packSeq: packSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(packSeq),
    );
  }

  factory Change.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Change(
      seq: serializer.fromJson<int>(json['seq']),
      recordType: $ChangesTable.$converterrecordType.fromJson(
        serializer.fromJson<String>(json['recordType']),
      ),
      recordId: serializer.fromJson<String>(json['recordId']),
      hlc: serializer.fromJson<String>(json['hlc']),
      op: $ChangesTable.$converterop.fromJson(
        serializer.fromJson<String>(json['op']),
      ),
      payload: serializer.fromJson<String?>(json['payload']),
      packSeq: serializer.fromJson<int?>(json['packSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'recordType': serializer.toJson<String>(
        $ChangesTable.$converterrecordType.toJson(recordType),
      ),
      'recordId': serializer.toJson<String>(recordId),
      'hlc': serializer.toJson<String>(hlc),
      'op': serializer.toJson<String>($ChangesTable.$converterop.toJson(op)),
      'payload': serializer.toJson<String?>(payload),
      'packSeq': serializer.toJson<int?>(packSeq),
    };
  }

  Change copyWith({
    int? seq,
    RecordType? recordType,
    String? recordId,
    String? hlc,
    ChangeOp? op,
    Value<String?> payload = const Value.absent(),
    Value<int?> packSeq = const Value.absent(),
  }) => Change(
    seq: seq ?? this.seq,
    recordType: recordType ?? this.recordType,
    recordId: recordId ?? this.recordId,
    hlc: hlc ?? this.hlc,
    op: op ?? this.op,
    payload: payload.present ? payload.value : this.payload,
    packSeq: packSeq.present ? packSeq.value : this.packSeq,
  );
  Change copyWithCompanion(ChangesCompanion data) {
    return Change(
      seq: data.seq.present ? data.seq.value : this.seq,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      op: data.op.present ? data.op.value : this.op,
      payload: data.payload.present ? data.payload.value : this.payload,
      packSeq: data.packSeq.present ? data.packSeq.value : this.packSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Change(')
          ..write('seq: $seq, ')
          ..write('recordType: $recordType, ')
          ..write('recordId: $recordId, ')
          ..write('hlc: $hlc, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('packSeq: $packSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(seq, recordType, recordId, hlc, op, payload, packSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Change &&
          other.seq == this.seq &&
          other.recordType == this.recordType &&
          other.recordId == this.recordId &&
          other.hlc == this.hlc &&
          other.op == this.op &&
          other.payload == this.payload &&
          other.packSeq == this.packSeq);
}

class ChangesCompanion extends UpdateCompanion<Change> {
  final Value<int> seq;
  final Value<RecordType> recordType;
  final Value<String> recordId;
  final Value<String> hlc;
  final Value<ChangeOp> op;
  final Value<String?> payload;
  final Value<int?> packSeq;
  const ChangesCompanion({
    this.seq = const Value.absent(),
    this.recordType = const Value.absent(),
    this.recordId = const Value.absent(),
    this.hlc = const Value.absent(),
    this.op = const Value.absent(),
    this.payload = const Value.absent(),
    this.packSeq = const Value.absent(),
  });
  ChangesCompanion.insert({
    this.seq = const Value.absent(),
    required RecordType recordType,
    required String recordId,
    required String hlc,
    required ChangeOp op,
    this.payload = const Value.absent(),
    this.packSeq = const Value.absent(),
  }) : recordType = Value(recordType),
       recordId = Value(recordId),
       hlc = Value(hlc),
       op = Value(op);
  static Insertable<Change> custom({
    Expression<int>? seq,
    Expression<String>? recordType,
    Expression<String>? recordId,
    Expression<String>? hlc,
    Expression<String>? op,
    Expression<String>? payload,
    Expression<int>? packSeq,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (recordType != null) 'record_type': recordType,
      if (recordId != null) 'record_id': recordId,
      if (hlc != null) 'hlc': hlc,
      if (op != null) 'op': op,
      if (payload != null) 'payload': payload,
      if (packSeq != null) 'pack_seq': packSeq,
    });
  }

  ChangesCompanion copyWith({
    Value<int>? seq,
    Value<RecordType>? recordType,
    Value<String>? recordId,
    Value<String>? hlc,
    Value<ChangeOp>? op,
    Value<String?>? payload,
    Value<int?>? packSeq,
  }) {
    return ChangesCompanion(
      seq: seq ?? this.seq,
      recordType: recordType ?? this.recordType,
      recordId: recordId ?? this.recordId,
      hlc: hlc ?? this.hlc,
      op: op ?? this.op,
      payload: payload ?? this.payload,
      packSeq: packSeq ?? this.packSeq,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(
        $ChangesTable.$converterrecordType.toSql(recordType.value),
      );
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (op.present) {
      map['op'] = Variable<String>($ChangesTable.$converterop.toSql(op.value));
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (packSeq.present) {
      map['pack_seq'] = Variable<int>(packSeq.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChangesCompanion(')
          ..write('seq: $seq, ')
          ..write('recordType: $recordType, ')
          ..write('recordId: $recordId, ')
          ..write('hlc: $hlc, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('packSeq: $packSeq')
          ..write(')'))
        .toString();
  }
}

abstract class _$CairnDatabase extends GeneratedDatabase {
  _$CairnDatabase(QueryExecutor e) : super(e);
  $CairnDatabaseManager get managers => $CairnDatabaseManager(this);
  late final $NotebooksTable notebooks = $NotebooksTable(this);
  late final $PagesTable pages = $PagesTable(this);
  late final $PageItemsTable pageItems = $PageItemsTable(this);
  late final $PocketItemsTable pocketItems = $PocketItemsTable(this);
  late final $LocationPointsTable locationPoints = $LocationPointsTable(this);
  late final $MediaTable media = $MediaTable(this);
  late final $MetaTable meta = $MetaTable(this);
  late final $ChangesTable changes = $ChangesTable(this);
  late final Index pagesByNotebook = Index(
    'pages_by_notebook',
    'CREATE INDEX pages_by_notebook ON pages (notebook_id, day)',
  );
  late final Index pageItemsByPage = Index(
    'page_items_by_page',
    'CREATE INDEX page_items_by_page ON page_items (page_id)',
  );
  late final Index pocketItemsByNotebook = Index(
    'pocket_items_by_notebook',
    'CREATE INDEX pocket_items_by_notebook ON pocket_items (notebook_id)',
  );
  late final Index locationPointsByTime = Index(
    'location_points_by_time',
    'CREATE INDEX location_points_by_time ON location_points (recorded_at_ms)',
  );
  late final Index changesByPack = Index(
    'changes_by_pack',
    'CREATE INDEX changes_by_pack ON changes (pack_seq)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    notebooks,
    pages,
    pageItems,
    pocketItems,
    locationPoints,
    media,
    meta,
    changes,
    pagesByNotebook,
    pageItemsByPage,
    pocketItemsByNotebook,
    locationPointsByTime,
    changesByPack,
  ];
}

typedef $$NotebooksTableCreateCompanionBuilder = NotebooksCompanion Function({
  required String id,
  required String hlc,
  Value<bool> deleted,
  Value<NotebookKind> kind,
  required String title,
  required int year,
  required CoverCloth cover,
  Value<int?> coverColor,
  Value<String?> trail,
  Value<String?> trailName,
  Value<String?> startDay,
  required int createdAtMs,
  Value<int> rowid,
});
typedef $$NotebooksTableUpdateCompanionBuilder = NotebooksCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<NotebookKind> kind,
  Value<String> title,
  Value<int> year,
  Value<CoverCloth> cover,
  Value<int?> coverColor,
  Value<String?> trail,
  Value<String?> trailName,
  Value<String?> startDay,
  Value<int> createdAtMs,
  Value<int> rowid,
});

class $$NotebooksTableFilterComposer
    extends Composer<_$CairnDatabase, $NotebooksTable> {
  $$NotebooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<NotebookKind, NotebookKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CoverCloth, CoverCloth, String> get cover =>
      $composableBuilder(
        column: $table.cover,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get coverColor => $composableBuilder(
    column: $table.coverColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trail => $composableBuilder(
    column: $table.trail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trailName => $composableBuilder(
    column: $table.trailName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDay => $composableBuilder(
    column: $table.startDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotebooksTableOrderingComposer
    extends Composer<_$CairnDatabase, $NotebooksTable> {
  $$NotebooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coverColor => $composableBuilder(
    column: $table.coverColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trail => $composableBuilder(
    column: $table.trail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trailName => $composableBuilder(
    column: $table.trailName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDay => $composableBuilder(
    column: $table.startDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotebooksTableAnnotationComposer
    extends Composer<_$CairnDatabase, $NotebooksTable> {
  $$NotebooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NotebookKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CoverCloth, String> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<int> get coverColor => $composableBuilder(
    column: $table.coverColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trail =>
      $composableBuilder(column: $table.trail, builder: (column) => column);

  GeneratedColumn<String> get trailName =>
      $composableBuilder(column: $table.trailName, builder: (column) => column);

  GeneratedColumn<String> get startDay =>
      $composableBuilder(column: $table.startDay, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$NotebooksTableTableManager
    extends
        RootTableManager<
          _$CairnDatabase,
          $NotebooksTable,
          Notebook,
          $$NotebooksTableFilterComposer,
          $$NotebooksTableOrderingComposer,
          $$NotebooksTableAnnotationComposer,
          $$NotebooksTableCreateCompanionBuilder,
          $$NotebooksTableUpdateCompanionBuilder,
          (
            Notebook,
            BaseReferences<_$CairnDatabase, $NotebooksTable, Notebook>,
          ),
          Notebook,
          PrefetchHooks Function()
        > {
  $$NotebooksTableTableManager(_$CairnDatabase db, $NotebooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotebooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotebooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotebooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<NotebookKind> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<CoverCloth> cover = const Value.absent(),
                Value<int?> coverColor = const Value.absent(),
                Value<String?> trail = const Value.absent(),
                Value<String?> trailName = const Value.absent(),
                Value<String?> startDay = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotebooksCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                kind: kind,
                title: title,
                year: year,
                cover: cover,
                coverColor: coverColor,
                trail: trail,
                trailName: trailName,
                startDay: startDay,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String hlc,
                Value<bool> deleted = const Value.absent(),
                Value<NotebookKind> kind = const Value.absent(),
                required String title,
                required int year,
                required CoverCloth cover,
                Value<int?> coverColor = const Value.absent(),
                Value<String?> trail = const Value.absent(),
                Value<String?> trailName = const Value.absent(),
                Value<String?> startDay = const Value.absent(),
                required int createdAtMs,
                Value<int> rowid = const Value.absent(),
              }) => NotebooksCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                kind: kind,
                title: title,
                year: year,
                cover: cover,
                coverColor: coverColor,
                trail: trail,
                trailName: trailName,
                startDay: startDay,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotebooksTable, Notebook>(table),
                  BaseReferences<_$CairnDatabase, $NotebooksTable, Notebook>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotebooksTableProcessedTableManager =
    ProcessedTableManager<
      _$CairnDatabase,
      $NotebooksTable,
      Notebook,
      $$NotebooksTableFilterComposer,
      $$NotebooksTableOrderingComposer,
      $$NotebooksTableAnnotationComposer,
      $$NotebooksTableCreateCompanionBuilder,
      $$NotebooksTableUpdateCompanionBuilder,
      (Notebook, BaseReferences<_$CairnDatabase, $NotebooksTable, Notebook>),
      Notebook,
      PrefetchHooks Function()
    >;
typedef $$PagesTableCreateCompanionBuilder = PagesCompanion Function({
  required String id,
  required String hlc,
  Value<bool> deleted,
  required String notebookId,
  required String day,
  Value<String?> template,
  Value<String?> place,
  Value<double?> elevationM,
  Value<String?> weather,
  required int createdAtMs,
  Value<int> rowid,
});
typedef $$PagesTableUpdateCompanionBuilder = PagesCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> notebookId,
  Value<String> day,
  Value<String?> template,
  Value<String?> place,
  Value<double?> elevationM,
  Value<String?> weather,
  Value<int> createdAtMs,
  Value<int> rowid,
});

class $$PagesTableFilterComposer
    extends Composer<_$CairnDatabase, $PagesTable> {
  $$PagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notebookId => $composableBuilder(
    column: $table.notebookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get template => $composableBuilder(
    column: $table.template,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationM => $composableBuilder(
    column: $table.elevationM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PagesTableOrderingComposer
    extends Composer<_$CairnDatabase, $PagesTable> {
  $$PagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notebookId => $composableBuilder(
    column: $table.notebookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get template => $composableBuilder(
    column: $table.template,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationM => $composableBuilder(
    column: $table.elevationM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PagesTableAnnotationComposer
    extends Composer<_$CairnDatabase, $PagesTable> {
  $$PagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get notebookId => $composableBuilder(
    column: $table.notebookId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get template =>
      $composableBuilder(column: $table.template, builder: (column) => column);

  GeneratedColumn<String> get place =>
      $composableBuilder(column: $table.place, builder: (column) => column);

  GeneratedColumn<double> get elevationM => $composableBuilder(
    column: $table.elevationM,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weather =>
      $composableBuilder(column: $table.weather, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$PagesTableTableManager
    extends
        RootTableManager<
          _$CairnDatabase,
          $PagesTable,
          JournalPage,
          $$PagesTableFilterComposer,
          $$PagesTableOrderingComposer,
          $$PagesTableAnnotationComposer,
          $$PagesTableCreateCompanionBuilder,
          $$PagesTableUpdateCompanionBuilder,
          (
            JournalPage,
            BaseReferences<_$CairnDatabase, $PagesTable, JournalPage>,
          ),
          JournalPage,
          PrefetchHooks Function()
        > {
  $$PagesTableTableManager(_$CairnDatabase db, $PagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> notebookId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String?> template = const Value.absent(),
                Value<String?> place = const Value.absent(),
                Value<double?> elevationM = const Value.absent(),
                Value<String?> weather = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PagesCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                notebookId: notebookId,
                day: day,
                template: template,
                place: place,
                elevationM: elevationM,
                weather: weather,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String hlc,
                Value<bool> deleted = const Value.absent(),
                required String notebookId,
                required String day,
                Value<String?> template = const Value.absent(),
                Value<String?> place = const Value.absent(),
                Value<double?> elevationM = const Value.absent(),
                Value<String?> weather = const Value.absent(),
                required int createdAtMs,
                Value<int> rowid = const Value.absent(),
              }) => PagesCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                notebookId: notebookId,
                day: day,
                template: template,
                place: place,
                elevationM: elevationM,
                weather: weather,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PagesTable, JournalPage>(table),
                  BaseReferences<_$CairnDatabase, $PagesTable, JournalPage>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PagesTableProcessedTableManager =
    ProcessedTableManager<
      _$CairnDatabase,
      $PagesTable,
      JournalPage,
      $$PagesTableFilterComposer,
      $$PagesTableOrderingComposer,
      $$PagesTableAnnotationComposer,
      $$PagesTableCreateCompanionBuilder,
      $$PagesTableUpdateCompanionBuilder,
      (JournalPage, BaseReferences<_$CairnDatabase, $PagesTable, JournalPage>),
      JournalPage,
      PrefetchHooks Function()
    >;
typedef $$PageItemsTableCreateCompanionBuilder = PageItemsCompanion Function({
  required String id,
  required String hlc,
  Value<bool> deleted,
  required String pageId,
  required PageItemKind kind,
  Value<String?> section,
  Value<String?> body,
  Value<String?> mediaId,
  Value<double?> x,
  Value<double?> y,
  Value<double?> width,
  Value<double?> height,
  Value<double?> rotation,
  Value<String?> style,
  Value<int> z,
  required int createdAtMs,
  Value<int> rowid,
});
typedef $$PageItemsTableUpdateCompanionBuilder = PageItemsCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> pageId,
  Value<PageItemKind> kind,
  Value<String?> section,
  Value<String?> body,
  Value<String?> mediaId,
  Value<double?> x,
  Value<double?> y,
  Value<double?> width,
  Value<double?> height,
  Value<double?> rotation,
  Value<String?> style,
  Value<int> z,
  Value<int> createdAtMs,
  Value<int> rowid,
});

class $$PageItemsTableFilterComposer
    extends Composer<_$CairnDatabase, $PageItemsTable> {
  $$PageItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PageItemKind, PageItemKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rotation => $composableBuilder(
    column: $table.rotation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get z => $composableBuilder(
    column: $table.z,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PageItemsTableOrderingComposer
    extends Composer<_$CairnDatabase, $PageItemsTable> {
  $$PageItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rotation => $composableBuilder(
    column: $table.rotation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get z => $composableBuilder(
    column: $table.z,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PageItemsTableAnnotationComposer
    extends Composer<_$CairnDatabase, $PageItemsTable> {
  $$PageItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get pageId =>
      $composableBuilder(column: $table.pageId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PageItemKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get section =>
      $composableBuilder(column: $table.section, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<double> get rotation =>
      $composableBuilder(column: $table.rotation, builder: (column) => column);

  GeneratedColumn<String> get style =>
      $composableBuilder(column: $table.style, builder: (column) => column);

  GeneratedColumn<int> get z =>
      $composableBuilder(column: $table.z, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$PageItemsTableTableManager
    extends
        RootTableManager<
          _$CairnDatabase,
          $PageItemsTable,
          PageItem,
          $$PageItemsTableFilterComposer,
          $$PageItemsTableOrderingComposer,
          $$PageItemsTableAnnotationComposer,
          $$PageItemsTableCreateCompanionBuilder,
          $$PageItemsTableUpdateCompanionBuilder,
          (
            PageItem,
            BaseReferences<_$CairnDatabase, $PageItemsTable, PageItem>,
          ),
          PageItem,
          PrefetchHooks Function()
        > {
  $$PageItemsTableTableManager(_$CairnDatabase db, $PageItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PageItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PageItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PageItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> pageId = const Value.absent(),
                Value<PageItemKind> kind = const Value.absent(),
                Value<String?> section = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> mediaId = const Value.absent(),
                Value<double?> x = const Value.absent(),
                Value<double?> y = const Value.absent(),
                Value<double?> width = const Value.absent(),
                Value<double?> height = const Value.absent(),
                Value<double?> rotation = const Value.absent(),
                Value<String?> style = const Value.absent(),
                Value<int> z = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PageItemsCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                pageId: pageId,
                kind: kind,
                section: section,
                body: body,
                mediaId: mediaId,
                x: x,
                y: y,
                width: width,
                height: height,
                rotation: rotation,
                style: style,
                z: z,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String hlc,
                Value<bool> deleted = const Value.absent(),
                required String pageId,
                required PageItemKind kind,
                Value<String?> section = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> mediaId = const Value.absent(),
                Value<double?> x = const Value.absent(),
                Value<double?> y = const Value.absent(),
                Value<double?> width = const Value.absent(),
                Value<double?> height = const Value.absent(),
                Value<double?> rotation = const Value.absent(),
                Value<String?> style = const Value.absent(),
                Value<int> z = const Value.absent(),
                required int createdAtMs,
                Value<int> rowid = const Value.absent(),
              }) => PageItemsCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                pageId: pageId,
                kind: kind,
                section: section,
                body: body,
                mediaId: mediaId,
                x: x,
                y: y,
                width: width,
                height: height,
                rotation: rotation,
                style: style,
                z: z,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PageItemsTable, PageItem>(table),
                  BaseReferences<_$CairnDatabase, $PageItemsTable, PageItem>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PageItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$CairnDatabase,
      $PageItemsTable,
      PageItem,
      $$PageItemsTableFilterComposer,
      $$PageItemsTableOrderingComposer,
      $$PageItemsTableAnnotationComposer,
      $$PageItemsTableCreateCompanionBuilder,
      $$PageItemsTableUpdateCompanionBuilder,
      (PageItem, BaseReferences<_$CairnDatabase, $PageItemsTable, PageItem>),
      PageItem,
      PrefetchHooks Function()
    >;
typedef $$PocketItemsTableCreateCompanionBuilder =
    PocketItemsCompanion Function({
      required String id,
      required String hlc,
      Value<bool> deleted,
      required String notebookId,
      required PocketItemKind kind,
      Value<String?> body,
      Value<String?> mediaId,
      required int capturedAtMs,
      Value<String?> placedItemId,
      Value<int> rowid,
    });
typedef $$PocketItemsTableUpdateCompanionBuilder =
    PocketItemsCompanion Function({
      Value<String> id,
      Value<String> hlc,
      Value<bool> deleted,
      Value<String> notebookId,
      Value<PocketItemKind> kind,
      Value<String?> body,
      Value<String?> mediaId,
      Value<int> capturedAtMs,
      Value<String?> placedItemId,
      Value<int> rowid,
    });

class $$PocketItemsTableFilterComposer
    extends Composer<_$CairnDatabase, $PocketItemsTable> {
  $$PocketItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notebookId => $composableBuilder(
    column: $table.notebookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PocketItemKind, PocketItemKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capturedAtMs => $composableBuilder(
    column: $table.capturedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placedItemId => $composableBuilder(
    column: $table.placedItemId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PocketItemsTableOrderingComposer
    extends Composer<_$CairnDatabase, $PocketItemsTable> {
  $$PocketItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notebookId => $composableBuilder(
    column: $table.notebookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capturedAtMs => $composableBuilder(
    column: $table.capturedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placedItemId => $composableBuilder(
    column: $table.placedItemId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PocketItemsTableAnnotationComposer
    extends Composer<_$CairnDatabase, $PocketItemsTable> {
  $$PocketItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get notebookId => $composableBuilder(
    column: $table.notebookId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PocketItemKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<int> get capturedAtMs => $composableBuilder(
    column: $table.capturedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get placedItemId => $composableBuilder(
    column: $table.placedItemId,
    builder: (column) => column,
  );
}

class $$PocketItemsTableTableManager
    extends
        RootTableManager<
          _$CairnDatabase,
          $PocketItemsTable,
          PocketItem,
          $$PocketItemsTableFilterComposer,
          $$PocketItemsTableOrderingComposer,
          $$PocketItemsTableAnnotationComposer,
          $$PocketItemsTableCreateCompanionBuilder,
          $$PocketItemsTableUpdateCompanionBuilder,
          (
            PocketItem,
            BaseReferences<_$CairnDatabase, $PocketItemsTable, PocketItem>,
          ),
          PocketItem,
          PrefetchHooks Function()
        > {
  $$PocketItemsTableTableManager(_$CairnDatabase db, $PocketItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PocketItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PocketItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PocketItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> notebookId = const Value.absent(),
                Value<PocketItemKind> kind = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> mediaId = const Value.absent(),
                Value<int> capturedAtMs = const Value.absent(),
                Value<String?> placedItemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PocketItemsCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                notebookId: notebookId,
                kind: kind,
                body: body,
                mediaId: mediaId,
                capturedAtMs: capturedAtMs,
                placedItemId: placedItemId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String hlc,
                Value<bool> deleted = const Value.absent(),
                required String notebookId,
                required PocketItemKind kind,
                Value<String?> body = const Value.absent(),
                Value<String?> mediaId = const Value.absent(),
                required int capturedAtMs,
                Value<String?> placedItemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PocketItemsCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                notebookId: notebookId,
                kind: kind,
                body: body,
                mediaId: mediaId,
                capturedAtMs: capturedAtMs,
                placedItemId: placedItemId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PocketItemsTable, PocketItem>(table),
                  BaseReferences<
                    _$CairnDatabase,
                    $PocketItemsTable,
                    PocketItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PocketItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$CairnDatabase,
      $PocketItemsTable,
      PocketItem,
      $$PocketItemsTableFilterComposer,
      $$PocketItemsTableOrderingComposer,
      $$PocketItemsTableAnnotationComposer,
      $$PocketItemsTableCreateCompanionBuilder,
      $$PocketItemsTableUpdateCompanionBuilder,
      (
        PocketItem,
        BaseReferences<_$CairnDatabase, $PocketItemsTable, PocketItem>,
      ),
      PocketItem,
      PrefetchHooks Function()
    >;
typedef $$LocationPointsTableCreateCompanionBuilder =
    LocationPointsCompanion Function({
      required String id,
      required String hlc,
      Value<bool> deleted,
      required int recordedAtMs,
      required double latitude,
      required double longitude,
      required double accuracyM,
      Value<double?> altitudeM,
      Value<double?> pressureHpa,
      required PointTrigger trigger,
      Value<String?> pageId,
      Value<String?> pocketItemId,
      Value<int> rowid,
    });
typedef $$LocationPointsTableUpdateCompanionBuilder =
    LocationPointsCompanion Function({
      Value<String> id,
      Value<String> hlc,
      Value<bool> deleted,
      Value<int> recordedAtMs,
      Value<double> latitude,
      Value<double> longitude,
      Value<double> accuracyM,
      Value<double?> altitudeM,
      Value<double?> pressureHpa,
      Value<PointTrigger> trigger,
      Value<String?> pageId,
      Value<String?> pocketItemId,
      Value<int> rowid,
    });

class $$LocationPointsTableFilterComposer
    extends Composer<_$CairnDatabase, $LocationPointsTable> {
  $$LocationPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordedAtMs => $composableBuilder(
    column: $table.recordedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitudeM => $composableBuilder(
    column: $table.altitudeM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pressureHpa => $composableBuilder(
    column: $table.pressureHpa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PointTrigger, PointTrigger, String>
  get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pocketItemId => $composableBuilder(
    column: $table.pocketItemId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationPointsTableOrderingComposer
    extends Composer<_$CairnDatabase, $LocationPointsTable> {
  $$LocationPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedAtMs => $composableBuilder(
    column: $table.recordedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitudeM => $composableBuilder(
    column: $table.altitudeM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pressureHpa => $composableBuilder(
    column: $table.pressureHpa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageId => $composableBuilder(
    column: $table.pageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pocketItemId => $composableBuilder(
    column: $table.pocketItemId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationPointsTableAnnotationComposer
    extends Composer<_$CairnDatabase, $LocationPointsTable> {
  $$LocationPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<int> get recordedAtMs => $composableBuilder(
    column: $table.recordedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<double> get altitudeM =>
      $composableBuilder(column: $table.altitudeM, builder: (column) => column);

  GeneratedColumn<double> get pressureHpa => $composableBuilder(
    column: $table.pressureHpa,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PointTrigger, String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  GeneratedColumn<String> get pageId =>
      $composableBuilder(column: $table.pageId, builder: (column) => column);

  GeneratedColumn<String> get pocketItemId => $composableBuilder(
    column: $table.pocketItemId,
    builder: (column) => column,
  );
}

class $$LocationPointsTableTableManager
    extends
        RootTableManager<
          _$CairnDatabase,
          $LocationPointsTable,
          LocationPoint,
          $$LocationPointsTableFilterComposer,
          $$LocationPointsTableOrderingComposer,
          $$LocationPointsTableAnnotationComposer,
          $$LocationPointsTableCreateCompanionBuilder,
          $$LocationPointsTableUpdateCompanionBuilder,
          (
            LocationPoint,
            BaseReferences<
              _$CairnDatabase,
              $LocationPointsTable,
              LocationPoint
            >,
          ),
          LocationPoint,
          PrefetchHooks Function()
        > {
  $$LocationPointsTableTableManager(
    _$CairnDatabase db,
    $LocationPointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> recordedAtMs = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> accuracyM = const Value.absent(),
                Value<double?> altitudeM = const Value.absent(),
                Value<double?> pressureHpa = const Value.absent(),
                Value<PointTrigger> trigger = const Value.absent(),
                Value<String?> pageId = const Value.absent(),
                Value<String?> pocketItemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationPointsCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                recordedAtMs: recordedAtMs,
                latitude: latitude,
                longitude: longitude,
                accuracyM: accuracyM,
                altitudeM: altitudeM,
                pressureHpa: pressureHpa,
                trigger: trigger,
                pageId: pageId,
                pocketItemId: pocketItemId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String hlc,
                Value<bool> deleted = const Value.absent(),
                required int recordedAtMs,
                required double latitude,
                required double longitude,
                required double accuracyM,
                Value<double?> altitudeM = const Value.absent(),
                Value<double?> pressureHpa = const Value.absent(),
                required PointTrigger trigger,
                Value<String?> pageId = const Value.absent(),
                Value<String?> pocketItemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationPointsCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                recordedAtMs: recordedAtMs,
                latitude: latitude,
                longitude: longitude,
                accuracyM: accuracyM,
                altitudeM: altitudeM,
                pressureHpa: pressureHpa,
                trigger: trigger,
                pageId: pageId,
                pocketItemId: pocketItemId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocationPointsTable, LocationPoint>(table),
                  BaseReferences<
                    _$CairnDatabase,
                    $LocationPointsTable,
                    LocationPoint
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$CairnDatabase,
      $LocationPointsTable,
      LocationPoint,
      $$LocationPointsTableFilterComposer,
      $$LocationPointsTableOrderingComposer,
      $$LocationPointsTableAnnotationComposer,
      $$LocationPointsTableCreateCompanionBuilder,
      $$LocationPointsTableUpdateCompanionBuilder,
      (
        LocationPoint,
        BaseReferences<_$CairnDatabase, $LocationPointsTable, LocationPoint>,
      ),
      LocationPoint,
      PrefetchHooks Function()
    >;
typedef $$MediaTableCreateCompanionBuilder = MediaCompanion Function({
  required String id,
  required String hlc,
  Value<bool> deleted,
  required MediaKind kind,
  required String mimeType,
  required int byteSize,
  Value<int?> width,
  Value<int?> height,
  required int createdAtMs,
  Value<int> rowid,
});
typedef $$MediaTableUpdateCompanionBuilder = MediaCompanion Function({
  Value<String> id,
  Value<String> hlc,
  Value<bool> deleted,
  Value<MediaKind> kind,
  Value<String> mimeType,
  Value<int> byteSize,
  Value<int?> width,
  Value<int?> height,
  Value<int> createdAtMs,
  Value<int> rowid,
});

class $$MediaTableFilterComposer
    extends Composer<_$CairnDatabase, $MediaTable> {
  $$MediaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MediaKind, MediaKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaTableOrderingComposer
    extends Composer<_$CairnDatabase, $MediaTable> {
  $$MediaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaTableAnnotationComposer
    extends Composer<_$CairnDatabase, $MediaTable> {
  $$MediaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MediaKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$MediaTableTableManager
    extends
        RootTableManager<
          _$CairnDatabase,
          $MediaTable,
          MediaRecord,
          $$MediaTableFilterComposer,
          $$MediaTableOrderingComposer,
          $$MediaTableAnnotationComposer,
          $$MediaTableCreateCompanionBuilder,
          $$MediaTableUpdateCompanionBuilder,
          (
            MediaRecord,
            BaseReferences<_$CairnDatabase, $MediaTable, MediaRecord>,
          ),
          MediaRecord,
          PrefetchHooks Function()
        > {
  $$MediaTableTableManager(_$CairnDatabase db, $MediaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<MediaKind> kind = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaCompanion(
                id: id,
                hlc: hlc,
                deleted: deleted,
                kind: kind,
                mimeType: mimeType,
                byteSize: byteSize,
                width: width,
                height: height,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String hlc,
                Value<bool> deleted = const Value.absent(),
                required MediaKind kind,
                required String mimeType,
                required int byteSize,
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                required int createdAtMs,
                Value<int> rowid = const Value.absent(),
              }) => MediaCompanion.insert(
                id: id,
                hlc: hlc,
                deleted: deleted,
                kind: kind,
                mimeType: mimeType,
                byteSize: byteSize,
                width: width,
                height: height,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaTable, MediaRecord>(table),
                  BaseReferences<_$CairnDatabase, $MediaTable, MediaRecord>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaTableProcessedTableManager =
    ProcessedTableManager<
      _$CairnDatabase,
      $MediaTable,
      MediaRecord,
      $$MediaTableFilterComposer,
      $$MediaTableOrderingComposer,
      $$MediaTableAnnotationComposer,
      $$MediaTableCreateCompanionBuilder,
      $$MediaTableUpdateCompanionBuilder,
      (MediaRecord, BaseReferences<_$CairnDatabase, $MediaTable, MediaRecord>),
      MediaRecord,
      PrefetchHooks Function()
    >;
typedef $$MetaTableCreateCompanionBuilder = MetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$MetaTableUpdateCompanionBuilder = MetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$MetaTableFilterComposer extends Composer<_$CairnDatabase, $MetaTable> {
  $$MetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaTableOrderingComposer
    extends Composer<_$CairnDatabase, $MetaTable> {
  $$MetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaTableAnnotationComposer
    extends Composer<_$CairnDatabase, $MetaTable> {
  $$MetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaTableTableManager
    extends
        RootTableManager<
          _$CairnDatabase,
          $MetaTable,
          MetaEntry,
          $$MetaTableFilterComposer,
          $$MetaTableOrderingComposer,
          $$MetaTableAnnotationComposer,
          $$MetaTableCreateCompanionBuilder,
          $$MetaTableUpdateCompanionBuilder,
          (MetaEntry, BaseReferences<_$CairnDatabase, $MetaTable, MetaEntry>),
          MetaEntry,
          PrefetchHooks Function()
        > {
  $$MetaTableTableManager(_$CairnDatabase db, $MetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => MetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetaTable, MetaEntry>(table),
                  BaseReferences<_$CairnDatabase, $MetaTable, MetaEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaTableProcessedTableManager =
    ProcessedTableManager<
      _$CairnDatabase,
      $MetaTable,
      MetaEntry,
      $$MetaTableFilterComposer,
      $$MetaTableOrderingComposer,
      $$MetaTableAnnotationComposer,
      $$MetaTableCreateCompanionBuilder,
      $$MetaTableUpdateCompanionBuilder,
      (MetaEntry, BaseReferences<_$CairnDatabase, $MetaTable, MetaEntry>),
      MetaEntry,
      PrefetchHooks Function()
    >;
typedef $$ChangesTableCreateCompanionBuilder = ChangesCompanion Function({
  Value<int> seq,
  required RecordType recordType,
  required String recordId,
  required String hlc,
  required ChangeOp op,
  Value<String?> payload,
  Value<int?> packSeq,
});
typedef $$ChangesTableUpdateCompanionBuilder = ChangesCompanion Function({
  Value<int> seq,
  Value<RecordType> recordType,
  Value<String> recordId,
  Value<String> hlc,
  Value<ChangeOp> op,
  Value<String?> payload,
  Value<int?> packSeq,
});

class $$ChangesTableFilterComposer
    extends Composer<_$CairnDatabase, $ChangesTable> {
  $$ChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RecordType, RecordType, String>
  get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ChangeOp, ChangeOp, String> get op =>
      $composableBuilder(
        column: $table.op,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get packSeq => $composableBuilder(
    column: $table.packSeq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChangesTableOrderingComposer
    extends Composer<_$CairnDatabase, $ChangesTable> {
  $$ChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get packSeq => $composableBuilder(
    column: $table.packSeq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChangesTableAnnotationComposer
    extends Composer<_$CairnDatabase, $ChangesTable> {
  $$ChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecordType, String> get recordType =>
      $composableBuilder(
        column: $table.recordType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ChangeOp, String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get packSeq =>
      $composableBuilder(column: $table.packSeq, builder: (column) => column);
}

class $$ChangesTableTableManager
    extends
        RootTableManager<
          _$CairnDatabase,
          $ChangesTable,
          Change,
          $$ChangesTableFilterComposer,
          $$ChangesTableOrderingComposer,
          $$ChangesTableAnnotationComposer,
          $$ChangesTableCreateCompanionBuilder,
          $$ChangesTableUpdateCompanionBuilder,
          (Change, BaseReferences<_$CairnDatabase, $ChangesTable, Change>),
          Change,
          PrefetchHooks Function()
        > {
  $$ChangesTableTableManager(_$CairnDatabase db, $ChangesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<RecordType> recordType = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<ChangeOp> op = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<int?> packSeq = const Value.absent(),
              }) => ChangesCompanion(
                seq: seq,
                recordType: recordType,
                recordId: recordId,
                hlc: hlc,
                op: op,
                payload: payload,
                packSeq: packSeq,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required RecordType recordType,
                required String recordId,
                required String hlc,
                required ChangeOp op,
                Value<String?> payload = const Value.absent(),
                Value<int?> packSeq = const Value.absent(),
              }) => ChangesCompanion.insert(
                seq: seq,
                recordType: recordType,
                recordId: recordId,
                hlc: hlc,
                op: op,
                payload: payload,
                packSeq: packSeq,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChangesTable, Change>(table),
                  BaseReferences<_$CairnDatabase, $ChangesTable, Change>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$CairnDatabase,
      $ChangesTable,
      Change,
      $$ChangesTableFilterComposer,
      $$ChangesTableOrderingComposer,
      $$ChangesTableAnnotationComposer,
      $$ChangesTableCreateCompanionBuilder,
      $$ChangesTableUpdateCompanionBuilder,
      (Change, BaseReferences<_$CairnDatabase, $ChangesTable, Change>),
      Change,
      PrefetchHooks Function()
    >;

class $CairnDatabaseManager {
  final _$CairnDatabase _db;
  $CairnDatabaseManager(this._db);
  $$NotebooksTableTableManager get notebooks =>
      $$NotebooksTableTableManager(_db, _db.notebooks);
  $$PagesTableTableManager get pages =>
      $$PagesTableTableManager(_db, _db.pages);
  $$PageItemsTableTableManager get pageItems =>
      $$PageItemsTableTableManager(_db, _db.pageItems);
  $$PocketItemsTableTableManager get pocketItems =>
      $$PocketItemsTableTableManager(_db, _db.pocketItems);
  $$LocationPointsTableTableManager get locationPoints =>
      $$LocationPointsTableTableManager(_db, _db.locationPoints);
  $$MediaTableTableManager get media =>
      $$MediaTableTableManager(_db, _db.media);
  $$MetaTableTableManager get meta => $$MetaTableTableManager(_db, _db.meta);
  $$ChangesTableTableManager get changes =>
      $$ChangesTableTableManager(_db, _db.changes);
}
