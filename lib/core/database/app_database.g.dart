// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VideosTable extends Videos with TableInfo<$VideosTable, Video> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('imported'),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPositionMsMeta = const VerificationMeta(
    'lastPositionMs',
  );
  @override
  late final GeneratedColumn<int> lastPositionMs = GeneratedColumn<int>(
    'last_position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isExternalMeta = const VerificationMeta(
    'isExternal',
  );
  @override
  late final GeneratedColumn<bool> isExternal = GeneratedColumn<bool>(
    'is_external',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_external" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    path,
    durationMs,
    status,
    origin,
    createdAt,
    lastPositionMs,
    isFavorite,
    isExternal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'videos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Video> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_position_ms')) {
      context.handle(
        _lastPositionMsMeta,
        lastPositionMs.isAcceptableOrUnknown(
          data['last_position_ms']!,
          _lastPositionMsMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_external')) {
      context.handle(
        _isExternalMeta,
        isExternal.isAcceptableOrUnknown(data['is_external']!, _isExternalMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Video map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Video(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastPositionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_position_ms'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isExternal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_external'],
      )!,
    );
  }

  @override
  $VideosTable createAlias(String alias) {
    return $VideosTable(attachedDatabase, alias);
  }
}

class Video extends DataClass implements Insertable<Video> {
  final String id;
  final String title;
  final String path;
  final int? durationMs;
  final String status;
  final String origin;
  final DateTime createdAt;
  final int lastPositionMs;
  final bool isFavorite;

  /// True when [path] points at a file we don't own (device gallery).
  final bool isExternal;
  const Video({
    required this.id,
    required this.title,
    required this.path,
    this.durationMs,
    required this.status,
    required this.origin,
    required this.createdAt,
    required this.lastPositionMs,
    required this.isFavorite,
    required this.isExternal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['status'] = Variable<String>(status);
    map['origin'] = Variable<String>(origin);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_position_ms'] = Variable<int>(lastPositionMs);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_external'] = Variable<bool>(isExternal);
    return map;
  }

  VideosCompanion toCompanion(bool nullToAbsent) {
    return VideosCompanion(
      id: Value(id),
      title: Value(title),
      path: Value(path),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      status: Value(status),
      origin: Value(origin),
      createdAt: Value(createdAt),
      lastPositionMs: Value(lastPositionMs),
      isFavorite: Value(isFavorite),
      isExternal: Value(isExternal),
    );
  }

  factory Video.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Video(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      path: serializer.fromJson<String>(json['path']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      status: serializer.fromJson<String>(json['status']),
      origin: serializer.fromJson<String>(json['origin']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastPositionMs: serializer.fromJson<int>(json['lastPositionMs']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isExternal: serializer.fromJson<bool>(json['isExternal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'path': serializer.toJson<String>(path),
      'durationMs': serializer.toJson<int?>(durationMs),
      'status': serializer.toJson<String>(status),
      'origin': serializer.toJson<String>(origin),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastPositionMs': serializer.toJson<int>(lastPositionMs),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isExternal': serializer.toJson<bool>(isExternal),
    };
  }

  Video copyWith({
    String? id,
    String? title,
    String? path,
    Value<int?> durationMs = const Value.absent(),
    String? status,
    String? origin,
    DateTime? createdAt,
    int? lastPositionMs,
    bool? isFavorite,
    bool? isExternal,
  }) => Video(
    id: id ?? this.id,
    title: title ?? this.title,
    path: path ?? this.path,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    status: status ?? this.status,
    origin: origin ?? this.origin,
    createdAt: createdAt ?? this.createdAt,
    lastPositionMs: lastPositionMs ?? this.lastPositionMs,
    isFavorite: isFavorite ?? this.isFavorite,
    isExternal: isExternal ?? this.isExternal,
  );
  Video copyWithCompanion(VideosCompanion data) {
    return Video(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      path: data.path.present ? data.path.value : this.path,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      status: data.status.present ? data.status.value : this.status,
      origin: data.origin.present ? data.origin.value : this.origin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastPositionMs: data.lastPositionMs.present
          ? data.lastPositionMs.value
          : this.lastPositionMs,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isExternal: data.isExternal.present
          ? data.isExternal.value
          : this.isExternal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Video(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('path: $path, ')
          ..write('durationMs: $durationMs, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastPositionMs: $lastPositionMs, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isExternal: $isExternal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    path,
    durationMs,
    status,
    origin,
    createdAt,
    lastPositionMs,
    isFavorite,
    isExternal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Video &&
          other.id == this.id &&
          other.title == this.title &&
          other.path == this.path &&
          other.durationMs == this.durationMs &&
          other.status == this.status &&
          other.origin == this.origin &&
          other.createdAt == this.createdAt &&
          other.lastPositionMs == this.lastPositionMs &&
          other.isFavorite == this.isFavorite &&
          other.isExternal == this.isExternal);
}

class VideosCompanion extends UpdateCompanion<Video> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> path;
  final Value<int?> durationMs;
  final Value<String> status;
  final Value<String> origin;
  final Value<DateTime> createdAt;
  final Value<int> lastPositionMs;
  final Value<bool> isFavorite;
  final Value<bool> isExternal;
  final Value<int> rowid;
  const VideosCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.path = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.status = const Value.absent(),
    this.origin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastPositionMs = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isExternal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VideosCompanion.insert({
    required String id,
    required String title,
    required String path,
    this.durationMs = const Value.absent(),
    this.status = const Value.absent(),
    this.origin = const Value.absent(),
    required DateTime createdAt,
    this.lastPositionMs = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isExternal = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       path = Value(path),
       createdAt = Value(createdAt);
  static Insertable<Video> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? path,
    Expression<int>? durationMs,
    Expression<String>? status,
    Expression<String>? origin,
    Expression<DateTime>? createdAt,
    Expression<int>? lastPositionMs,
    Expression<bool>? isFavorite,
    Expression<bool>? isExternal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (path != null) 'path': path,
      if (durationMs != null) 'duration_ms': durationMs,
      if (status != null) 'status': status,
      if (origin != null) 'origin': origin,
      if (createdAt != null) 'created_at': createdAt,
      if (lastPositionMs != null) 'last_position_ms': lastPositionMs,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isExternal != null) 'is_external': isExternal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VideosCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? path,
    Value<int?>? durationMs,
    Value<String>? status,
    Value<String>? origin,
    Value<DateTime>? createdAt,
    Value<int>? lastPositionMs,
    Value<bool>? isFavorite,
    Value<bool>? isExternal,
    Value<int>? rowid,
  }) {
    return VideosCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      path: path ?? this.path,
      durationMs: durationMs ?? this.durationMs,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      createdAt: createdAt ?? this.createdAt,
      lastPositionMs: lastPositionMs ?? this.lastPositionMs,
      isFavorite: isFavorite ?? this.isFavorite,
      isExternal: isExternal ?? this.isExternal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastPositionMs.present) {
      map['last_position_ms'] = Variable<int>(lastPositionMs.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isExternal.present) {
      map['is_external'] = Variable<bool>(isExternal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideosCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('path: $path, ')
          ..write('durationMs: $durationMs, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastPositionMs: $lastPositionMs, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isExternal: $isExternal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CuesTable extends Cues with TableInfo<$CuesTable, Cue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<int> rowId = GeneratedColumn<int>(
    'row_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _videoIdMeta = const VerificationMeta(
    'videoId',
  );
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
    'video_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES videos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
    'end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalMeta = const VerificationMeta(
    'original',
  );
  @override
  late final GeneratedColumn<String> original = GeneratedColumn<String>(
    'original',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('committed'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    rowId,
    videoId,
    startMs,
    endMs,
    body,
    original,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cues';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    }
    if (data.containsKey('video_id')) {
      context.handle(
        _videoIdMeta,
        videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('end_ms')) {
      context.handle(
        _endMsMeta,
        endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endMsMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('original')) {
      context.handle(
        _originalMeta,
        original.isAcceptableOrUnknown(data['original']!, _originalMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rowId};
  @override
  Cue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cue(
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_id'],
      )!,
      videoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_id'],
      )!,
      startMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ms'],
      )!,
      endMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ms'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      original: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $CuesTable createAlias(String alias) {
    return $CuesTable(attachedDatabase, alias);
  }
}

class Cue extends DataClass implements Insertable<Cue> {
  final int rowId;
  final String videoId;
  final int startMs;
  final int endMs;
  final String body;
  final String? original;
  final String status;
  const Cue({
    required this.rowId,
    required this.videoId,
    required this.startMs,
    required this.endMs,
    required this.body,
    this.original,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_id'] = Variable<int>(rowId);
    map['video_id'] = Variable<String>(videoId);
    map['start_ms'] = Variable<int>(startMs);
    map['end_ms'] = Variable<int>(endMs);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || original != null) {
      map['original'] = Variable<String>(original);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  CuesCompanion toCompanion(bool nullToAbsent) {
    return CuesCompanion(
      rowId: Value(rowId),
      videoId: Value(videoId),
      startMs: Value(startMs),
      endMs: Value(endMs),
      body: Value(body),
      original: original == null && nullToAbsent
          ? const Value.absent()
          : Value(original),
      status: Value(status),
    );
  }

  factory Cue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cue(
      rowId: serializer.fromJson<int>(json['rowId']),
      videoId: serializer.fromJson<String>(json['videoId']),
      startMs: serializer.fromJson<int>(json['startMs']),
      endMs: serializer.fromJson<int>(json['endMs']),
      body: serializer.fromJson<String>(json['body']),
      original: serializer.fromJson<String?>(json['original']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowId': serializer.toJson<int>(rowId),
      'videoId': serializer.toJson<String>(videoId),
      'startMs': serializer.toJson<int>(startMs),
      'endMs': serializer.toJson<int>(endMs),
      'body': serializer.toJson<String>(body),
      'original': serializer.toJson<String?>(original),
      'status': serializer.toJson<String>(status),
    };
  }

  Cue copyWith({
    int? rowId,
    String? videoId,
    int? startMs,
    int? endMs,
    String? body,
    Value<String?> original = const Value.absent(),
    String? status,
  }) => Cue(
    rowId: rowId ?? this.rowId,
    videoId: videoId ?? this.videoId,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
    body: body ?? this.body,
    original: original.present ? original.value : this.original,
    status: status ?? this.status,
  );
  Cue copyWithCompanion(CuesCompanion data) {
    return Cue(
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
      body: data.body.present ? data.body.value : this.body,
      original: data.original.present ? data.original.value : this.original,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cue(')
          ..write('rowId: $rowId, ')
          ..write('videoId: $videoId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('body: $body, ')
          ..write('original: $original, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(rowId, videoId, startMs, endMs, body, original, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cue &&
          other.rowId == this.rowId &&
          other.videoId == this.videoId &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs &&
          other.body == this.body &&
          other.original == this.original &&
          other.status == this.status);
}

class CuesCompanion extends UpdateCompanion<Cue> {
  final Value<int> rowId;
  final Value<String> videoId;
  final Value<int> startMs;
  final Value<int> endMs;
  final Value<String> body;
  final Value<String?> original;
  final Value<String> status;
  const CuesCompanion({
    this.rowId = const Value.absent(),
    this.videoId = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.body = const Value.absent(),
    this.original = const Value.absent(),
    this.status = const Value.absent(),
  });
  CuesCompanion.insert({
    this.rowId = const Value.absent(),
    required String videoId,
    required int startMs,
    required int endMs,
    required String body,
    this.original = const Value.absent(),
    this.status = const Value.absent(),
  }) : videoId = Value(videoId),
       startMs = Value(startMs),
       endMs = Value(endMs),
       body = Value(body);
  static Insertable<Cue> custom({
    Expression<int>? rowId,
    Expression<String>? videoId,
    Expression<int>? startMs,
    Expression<int>? endMs,
    Expression<String>? body,
    Expression<String>? original,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (rowId != null) 'row_id': rowId,
      if (videoId != null) 'video_id': videoId,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
      if (body != null) 'body': body,
      if (original != null) 'original': original,
      if (status != null) 'status': status,
    });
  }

  CuesCompanion copyWith({
    Value<int>? rowId,
    Value<String>? videoId,
    Value<int>? startMs,
    Value<int>? endMs,
    Value<String>? body,
    Value<String?>? original,
    Value<String>? status,
  }) {
    return CuesCompanion(
      rowId: rowId ?? this.rowId,
      videoId: videoId ?? this.videoId,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      body: body ?? this.body,
      original: original ?? this.original,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (original.present) {
      map['original'] = Variable<String>(original.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CuesCompanion(')
          ..write('rowId: $rowId, ')
          ..write('videoId: $videoId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('body: $body, ')
          ..write('original: $original, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VideosTable videos = $VideosTable(this);
  late final $CuesTable cues = $CuesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [videos, cues];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'videos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cues', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$VideosTableCreateCompanionBuilder =
    VideosCompanion Function({
      required String id,
      required String title,
      required String path,
      Value<int?> durationMs,
      Value<String> status,
      Value<String> origin,
      required DateTime createdAt,
      Value<int> lastPositionMs,
      Value<bool> isFavorite,
      Value<bool> isExternal,
      Value<int> rowid,
    });
typedef $$VideosTableUpdateCompanionBuilder =
    VideosCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> path,
      Value<int?> durationMs,
      Value<String> status,
      Value<String> origin,
      Value<DateTime> createdAt,
      Value<int> lastPositionMs,
      Value<bool> isFavorite,
      Value<bool> isExternal,
      Value<int> rowid,
    });

final class $$VideosTableReferences
    extends BaseReferences<_$AppDatabase, $VideosTable, Video> {
  $$VideosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CuesTable, List<Cue>> _cuesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cues,
    aliasName: $_aliasNameGenerator(db.videos.id, db.cues.videoId),
  );

  $$CuesTableProcessedTableManager get cuesRefs {
    final manager = $$CuesTableTableManager(
      $_db,
      $_db.cues,
    ).filter((f) => f.videoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cuesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VideosTableFilterComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExternal => $composableBuilder(
    column: $table.isExternal,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cuesRefs(
    Expression<bool> Function($$CuesTableFilterComposer f) f,
  ) {
    final $$CuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cues,
      getReferencedColumn: (t) => t.videoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuesTableFilterComposer(
            $db: $db,
            $table: $db.cues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VideosTableOrderingComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExternal => $composableBuilder(
    column: $table.isExternal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VideosTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastPositionMs => $composableBuilder(
    column: $table.lastPositionMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isExternal => $composableBuilder(
    column: $table.isExternal,
    builder: (column) => column,
  );

  Expression<T> cuesRefs<T extends Object>(
    Expression<T> Function($$CuesTableAnnotationComposer a) f,
  ) {
    final $$CuesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cues,
      getReferencedColumn: (t) => t.videoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CuesTableAnnotationComposer(
            $db: $db,
            $table: $db.cues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VideosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VideosTable,
          Video,
          $$VideosTableFilterComposer,
          $$VideosTableOrderingComposer,
          $$VideosTableAnnotationComposer,
          $$VideosTableCreateCompanionBuilder,
          $$VideosTableUpdateCompanionBuilder,
          (Video, $$VideosTableReferences),
          Video,
          PrefetchHooks Function({bool cuesRefs})
        > {
  $$VideosTableTableManager(_$AppDatabase db, $VideosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> lastPositionMs = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isExternal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VideosCompanion(
                id: id,
                title: title,
                path: path,
                durationMs: durationMs,
                status: status,
                origin: origin,
                createdAt: createdAt,
                lastPositionMs: lastPositionMs,
                isFavorite: isFavorite,
                isExternal: isExternal,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String path,
                Value<int?> durationMs = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> origin = const Value.absent(),
                required DateTime createdAt,
                Value<int> lastPositionMs = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isExternal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VideosCompanion.insert(
                id: id,
                title: title,
                path: path,
                durationMs: durationMs,
                status: status,
                origin: origin,
                createdAt: createdAt,
                lastPositionMs: lastPositionMs,
                isFavorite: isFavorite,
                isExternal: isExternal,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$VideosTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({cuesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cuesRefs) db.cues],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cuesRefs)
                    await $_getPrefetchedData<Video, $VideosTable, Cue>(
                      currentTable: table,
                      referencedTable: $$VideosTableReferences._cuesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$VideosTableReferences(db, table, p0).cuesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.videoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VideosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VideosTable,
      Video,
      $$VideosTableFilterComposer,
      $$VideosTableOrderingComposer,
      $$VideosTableAnnotationComposer,
      $$VideosTableCreateCompanionBuilder,
      $$VideosTableUpdateCompanionBuilder,
      (Video, $$VideosTableReferences),
      Video,
      PrefetchHooks Function({bool cuesRefs})
    >;
typedef $$CuesTableCreateCompanionBuilder =
    CuesCompanion Function({
      Value<int> rowId,
      required String videoId,
      required int startMs,
      required int endMs,
      required String body,
      Value<String?> original,
      Value<String> status,
    });
typedef $$CuesTableUpdateCompanionBuilder =
    CuesCompanion Function({
      Value<int> rowId,
      Value<String> videoId,
      Value<int> startMs,
      Value<int> endMs,
      Value<String> body,
      Value<String?> original,
      Value<String> status,
    });

final class $$CuesTableReferences
    extends BaseReferences<_$AppDatabase, $CuesTable, Cue> {
  $$CuesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VideosTable _videoIdTable(_$AppDatabase db) => db.videos.createAlias(
    $_aliasNameGenerator(db.cues.videoId, db.videos.id),
  );

  $$VideosTableProcessedTableManager get videoId {
    final $_column = $_itemColumn<String>('video_id')!;

    final manager = $$VideosTableTableManager(
      $_db,
      $_db.videos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_videoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CuesTableFilterComposer extends Composer<_$AppDatabase, $CuesTable> {
  $$CuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get original => $composableBuilder(
    column: $table.original,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$VideosTableFilterComposer get videoId {
    final $$VideosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.videoId,
      referencedTable: $db.videos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VideosTableFilterComposer(
            $db: $db,
            $table: $db.videos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CuesTableOrderingComposer extends Composer<_$AppDatabase, $CuesTable> {
  $$CuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get original => $composableBuilder(
    column: $table.original,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$VideosTableOrderingComposer get videoId {
    final $$VideosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.videoId,
      referencedTable: $db.videos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VideosTableOrderingComposer(
            $db: $db,
            $table: $db.videos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CuesTable> {
  $$CuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get original =>
      $composableBuilder(column: $table.original, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$VideosTableAnnotationComposer get videoId {
    final $$VideosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.videoId,
      referencedTable: $db.videos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VideosTableAnnotationComposer(
            $db: $db,
            $table: $db.videos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CuesTable,
          Cue,
          $$CuesTableFilterComposer,
          $$CuesTableOrderingComposer,
          $$CuesTableAnnotationComposer,
          $$CuesTableCreateCompanionBuilder,
          $$CuesTableUpdateCompanionBuilder,
          (Cue, $$CuesTableReferences),
          Cue,
          PrefetchHooks Function({bool videoId})
        > {
  $$CuesTableTableManager(_$AppDatabase db, $CuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                Value<String> videoId = const Value.absent(),
                Value<int> startMs = const Value.absent(),
                Value<int> endMs = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> original = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => CuesCompanion(
                rowId: rowId,
                videoId: videoId,
                startMs: startMs,
                endMs: endMs,
                body: body,
                original: original,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                required String videoId,
                required int startMs,
                required int endMs,
                required String body,
                Value<String?> original = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => CuesCompanion.insert(
                rowId: rowId,
                videoId: videoId,
                startMs: startMs,
                endMs: endMs,
                body: body,
                original: original,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$CuesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({videoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (videoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.videoId,
                                referencedTable: $$CuesTableReferences
                                    ._videoIdTable(db),
                                referencedColumn: $$CuesTableReferences
                                    ._videoIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CuesTable,
      Cue,
      $$CuesTableFilterComposer,
      $$CuesTableOrderingComposer,
      $$CuesTableAnnotationComposer,
      $$CuesTableCreateCompanionBuilder,
      $$CuesTableUpdateCompanionBuilder,
      (Cue, $$CuesTableReferences),
      Cue,
      PrefetchHooks Function({bool videoId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VideosTableTableManager get videos =>
      $$VideosTableTableManager(_db, _db.videos);
  $$CuesTableTableManager get cues => $$CuesTableTableManager(_db, _db.cues);
}
