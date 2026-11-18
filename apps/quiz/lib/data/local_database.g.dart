// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _explanationsMeta = const VerificationMeta(
    'explanations',
  );
  @override
  late final GeneratedColumn<bool> explanations = GeneratedColumn<bool>(
    'explanations',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("explanations" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _soundMeta = const VerificationMeta('sound');
  @override
  late final GeneratedColumn<bool> sound = GeneratedColumn<bool>(
    'sound',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _vibrationMeta = const VerificationMeta(
    'vibration',
  );
  @override
  late final GeneratedColumn<bool> vibration = GeneratedColumn<bool>(
    'vibration',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibration" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _shuffleMeta = const VerificationMeta(
    'shuffle',
  );
  @override
  late final GeneratedColumn<bool> shuffle = GeneratedColumn<bool>(
    'shuffle',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffle" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    explanations,
    sound,
    vibration,
    shuffle,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('explanations')) {
      context.handle(
        _explanationsMeta,
        explanations.isAcceptableOrUnknown(
          data['explanations']!,
          _explanationsMeta,
        ),
      );
    }
    if (data.containsKey('sound')) {
      context.handle(
        _soundMeta,
        sound.isAcceptableOrUnknown(data['sound']!, _soundMeta),
      );
    }
    if (data.containsKey('vibration')) {
      context.handle(
        _vibrationMeta,
        vibration.isAcceptableOrUnknown(data['vibration']!, _vibrationMeta),
      );
    }
    if (data.containsKey('shuffle')) {
      context.handle(
        _shuffleMeta,
        shuffle.isAcceptableOrUnknown(data['shuffle']!, _shuffleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      explanations: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}explanations'],
      )!,
      sound: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound'],
      )!,
      vibration: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibration'],
      )!,
      shuffle: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffle'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final bool explanations;
  final bool sound;
  final bool vibration;
  final bool shuffle;
  const Setting({
    required this.id,
    required this.explanations,
    required this.sound,
    required this.vibration,
    required this.shuffle,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['explanations'] = Variable<bool>(explanations);
    map['sound'] = Variable<bool>(sound);
    map['vibration'] = Variable<bool>(vibration);
    map['shuffle'] = Variable<bool>(shuffle);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      explanations: Value(explanations),
      sound: Value(sound),
      vibration: Value(vibration),
      shuffle: Value(shuffle),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      explanations: serializer.fromJson<bool>(json['explanations']),
      sound: serializer.fromJson<bool>(json['sound']),
      vibration: serializer.fromJson<bool>(json['vibration']),
      shuffle: serializer.fromJson<bool>(json['shuffle']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'explanations': serializer.toJson<bool>(explanations),
      'sound': serializer.toJson<bool>(sound),
      'vibration': serializer.toJson<bool>(vibration),
      'shuffle': serializer.toJson<bool>(shuffle),
    };
  }

  Setting copyWith({
    int? id,
    bool? explanations,
    bool? sound,
    bool? vibration,
    bool? shuffle,
  }) => Setting(
    id: id ?? this.id,
    explanations: explanations ?? this.explanations,
    sound: sound ?? this.sound,
    vibration: vibration ?? this.vibration,
    shuffle: shuffle ?? this.shuffle,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      explanations: data.explanations.present
          ? data.explanations.value
          : this.explanations,
      sound: data.sound.present ? data.sound.value : this.sound,
      vibration: data.vibration.present ? data.vibration.value : this.vibration,
      shuffle: data.shuffle.present ? data.shuffle.value : this.shuffle,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('explanations: $explanations, ')
          ..write('sound: $sound, ')
          ..write('vibration: $vibration, ')
          ..write('shuffle: $shuffle')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, explanations, sound, vibration, shuffle);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.explanations == this.explanations &&
          other.sound == this.sound &&
          other.vibration == this.vibration &&
          other.shuffle == this.shuffle);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<bool> explanations;
  final Value<bool> sound;
  final Value<bool> vibration;
  final Value<bool> shuffle;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.explanations = const Value.absent(),
    this.sound = const Value.absent(),
    this.vibration = const Value.absent(),
    this.shuffle = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.explanations = const Value.absent(),
    this.sound = const Value.absent(),
    this.vibration = const Value.absent(),
    this.shuffle = const Value.absent(),
  });
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<bool>? explanations,
    Expression<bool>? sound,
    Expression<bool>? vibration,
    Expression<bool>? shuffle,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (explanations != null) 'explanations': explanations,
      if (sound != null) 'sound': sound,
      if (vibration != null) 'vibration': vibration,
      if (shuffle != null) 'shuffle': shuffle,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? explanations,
    Value<bool>? sound,
    Value<bool>? vibration,
    Value<bool>? shuffle,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      explanations: explanations ?? this.explanations,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
      shuffle: shuffle ?? this.shuffle,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (explanations.present) {
      map['explanations'] = Variable<bool>(explanations.value);
    }
    if (sound.present) {
      map['sound'] = Variable<bool>(sound.value);
    }
    if (vibration.present) {
      map['vibration'] = Variable<bool>(vibration.value);
    }
    if (shuffle.present) {
      map['shuffle'] = Variable<bool>(shuffle.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('explanations: $explanations, ')
          ..write('sound: $sound, ')
          ..write('vibration: $vibration, ')
          ..write('shuffle: $shuffle')
          ..write(')'))
        .toString();
  }
}

class $RoundProgressEntriesTable extends RoundProgressEntries
    with TableInfo<$RoundProgressEntriesTable, RoundProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoundProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  @override
  late final GeneratedColumn<String> contentVersion = GeneratedColumn<String>(
    'content_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundNumberMeta = const VerificationMeta(
    'roundNumber',
  );
  @override
  late final GeneratedColumn<int> roundNumber = GeneratedColumn<int>(
    'round_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastScoreMeta = const VerificationMeta(
    'lastScore',
  );
  @override
  late final GeneratedColumn<int> lastScore = GeneratedColumn<int>(
    'last_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestScoreMeta = const VerificationMeta(
    'bestScore',
  );
  @override
  late final GeneratedColumn<int> bestScore = GeneratedColumn<int>(
    'best_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    contentVersion,
    categoryId,
    roundNumber,
    lastScore,
    bestScore,
    total,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'round_progress_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoundProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentVersionMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('round_number')) {
      context.handle(
        _roundNumberMeta,
        roundNumber.isAcceptableOrUnknown(
          data['round_number']!,
          _roundNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_roundNumberMeta);
    }
    if (data.containsKey('last_score')) {
      context.handle(
        _lastScoreMeta,
        lastScore.isAcceptableOrUnknown(data['last_score']!, _lastScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_lastScoreMeta);
    }
    if (data.containsKey('best_score')) {
      context.handle(
        _bestScoreMeta,
        bestScore.isAcceptableOrUnknown(data['best_score']!, _bestScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_bestScoreMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    contentVersion,
    categoryId,
    roundNumber,
  };
  @override
  RoundProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoundProgressEntry(
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_version'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      roundNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round_number'],
      )!,
      lastScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_score'],
      )!,
      bestScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_score'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $RoundProgressEntriesTable createAlias(String alias) {
    return $RoundProgressEntriesTable(attachedDatabase, alias);
  }
}

class RoundProgressEntry extends DataClass
    implements Insertable<RoundProgressEntry> {
  final String contentVersion;
  final String categoryId;
  final int roundNumber;
  final int lastScore;
  final int bestScore;
  final int total;
  final DateTime completedAt;
  const RoundProgressEntry({
    required this.contentVersion,
    required this.categoryId,
    required this.roundNumber,
    required this.lastScore,
    required this.bestScore,
    required this.total,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['content_version'] = Variable<String>(contentVersion);
    map['category_id'] = Variable<String>(categoryId);
    map['round_number'] = Variable<int>(roundNumber);
    map['last_score'] = Variable<int>(lastScore);
    map['best_score'] = Variable<int>(bestScore);
    map['total'] = Variable<int>(total);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  RoundProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return RoundProgressEntriesCompanion(
      contentVersion: Value(contentVersion),
      categoryId: Value(categoryId),
      roundNumber: Value(roundNumber),
      lastScore: Value(lastScore),
      bestScore: Value(bestScore),
      total: Value(total),
      completedAt: Value(completedAt),
    );
  }

  factory RoundProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoundProgressEntry(
      contentVersion: serializer.fromJson<String>(json['contentVersion']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      roundNumber: serializer.fromJson<int>(json['roundNumber']),
      lastScore: serializer.fromJson<int>(json['lastScore']),
      bestScore: serializer.fromJson<int>(json['bestScore']),
      total: serializer.fromJson<int>(json['total']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'contentVersion': serializer.toJson<String>(contentVersion),
      'categoryId': serializer.toJson<String>(categoryId),
      'roundNumber': serializer.toJson<int>(roundNumber),
      'lastScore': serializer.toJson<int>(lastScore),
      'bestScore': serializer.toJson<int>(bestScore),
      'total': serializer.toJson<int>(total),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  RoundProgressEntry copyWith({
    String? contentVersion,
    String? categoryId,
    int? roundNumber,
    int? lastScore,
    int? bestScore,
    int? total,
    DateTime? completedAt,
  }) => RoundProgressEntry(
    contentVersion: contentVersion ?? this.contentVersion,
    categoryId: categoryId ?? this.categoryId,
    roundNumber: roundNumber ?? this.roundNumber,
    lastScore: lastScore ?? this.lastScore,
    bestScore: bestScore ?? this.bestScore,
    total: total ?? this.total,
    completedAt: completedAt ?? this.completedAt,
  );
  RoundProgressEntry copyWithCompanion(RoundProgressEntriesCompanion data) {
    return RoundProgressEntry(
      contentVersion: data.contentVersion.present
          ? data.contentVersion.value
          : this.contentVersion,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      roundNumber: data.roundNumber.present
          ? data.roundNumber.value
          : this.roundNumber,
      lastScore: data.lastScore.present ? data.lastScore.value : this.lastScore,
      bestScore: data.bestScore.present ? data.bestScore.value : this.bestScore,
      total: data.total.present ? data.total.value : this.total,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoundProgressEntry(')
          ..write('contentVersion: $contentVersion, ')
          ..write('categoryId: $categoryId, ')
          ..write('roundNumber: $roundNumber, ')
          ..write('lastScore: $lastScore, ')
          ..write('bestScore: $bestScore, ')
          ..write('total: $total, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    contentVersion,
    categoryId,
    roundNumber,
    lastScore,
    bestScore,
    total,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoundProgressEntry &&
          other.contentVersion == this.contentVersion &&
          other.categoryId == this.categoryId &&
          other.roundNumber == this.roundNumber &&
          other.lastScore == this.lastScore &&
          other.bestScore == this.bestScore &&
          other.total == this.total &&
          other.completedAt == this.completedAt);
}

class RoundProgressEntriesCompanion
    extends UpdateCompanion<RoundProgressEntry> {
  final Value<String> contentVersion;
  final Value<String> categoryId;
  final Value<int> roundNumber;
  final Value<int> lastScore;
  final Value<int> bestScore;
  final Value<int> total;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const RoundProgressEntriesCompanion({
    this.contentVersion = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.roundNumber = const Value.absent(),
    this.lastScore = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.total = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoundProgressEntriesCompanion.insert({
    required String contentVersion,
    required String categoryId,
    required int roundNumber,
    required int lastScore,
    required int bestScore,
    required int total,
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  }) : contentVersion = Value(contentVersion),
       categoryId = Value(categoryId),
       roundNumber = Value(roundNumber),
       lastScore = Value(lastScore),
       bestScore = Value(bestScore),
       total = Value(total),
       completedAt = Value(completedAt);
  static Insertable<RoundProgressEntry> custom({
    Expression<String>? contentVersion,
    Expression<String>? categoryId,
    Expression<int>? roundNumber,
    Expression<int>? lastScore,
    Expression<int>? bestScore,
    Expression<int>? total,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (contentVersion != null) 'content_version': contentVersion,
      if (categoryId != null) 'category_id': categoryId,
      if (roundNumber != null) 'round_number': roundNumber,
      if (lastScore != null) 'last_score': lastScore,
      if (bestScore != null) 'best_score': bestScore,
      if (total != null) 'total': total,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoundProgressEntriesCompanion copyWith({
    Value<String>? contentVersion,
    Value<String>? categoryId,
    Value<int>? roundNumber,
    Value<int>? lastScore,
    Value<int>? bestScore,
    Value<int>? total,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return RoundProgressEntriesCompanion(
      contentVersion: contentVersion ?? this.contentVersion,
      categoryId: categoryId ?? this.categoryId,
      roundNumber: roundNumber ?? this.roundNumber,
      lastScore: lastScore ?? this.lastScore,
      bestScore: bestScore ?? this.bestScore,
      total: total ?? this.total,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (contentVersion.present) {
      map['content_version'] = Variable<String>(contentVersion.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (roundNumber.present) {
      map['round_number'] = Variable<int>(roundNumber.value);
    }
    if (lastScore.present) {
      map['last_score'] = Variable<int>(lastScore.value);
    }
    if (bestScore.present) {
      map['best_score'] = Variable<int>(bestScore.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoundProgressEntriesCompanion(')
          ..write('contentVersion: $contentVersion, ')
          ..write('categoryId: $categoryId, ')
          ..write('roundNumber: $roundNumber, ')
          ..write('lastScore: $lastScore, ')
          ..write('bestScore: $bestScore, ')
          ..write('total: $total, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttemptsTable extends Attempts with TableInfo<$AttemptsTable, Attempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  @override
  late final GeneratedColumn<String> contentVersion = GeneratedColumn<String>(
    'content_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundNumberMeta = const VerificationMeta(
    'roundNumber',
  );
  @override
  late final GeneratedColumn<int> roundNumber = GeneratedColumn<int>(
    'round_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contentVersion,
    categoryId,
    roundNumber,
    score,
    total,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentVersionMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('round_number')) {
      context.handle(
        _roundNumberMeta,
        roundNumber.isAcceptableOrUnknown(
          data['round_number']!,
          _roundNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_roundNumberMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_version'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      roundNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round_number'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $AttemptsTable createAlias(String alias) {
    return $AttemptsTable(attachedDatabase, alias);
  }
}

class Attempt extends DataClass implements Insertable<Attempt> {
  final int id;
  final String contentVersion;
  final String categoryId;
  final int roundNumber;
  final int score;
  final int total;
  final DateTime completedAt;
  const Attempt({
    required this.id,
    required this.contentVersion,
    required this.categoryId,
    required this.roundNumber,
    required this.score,
    required this.total,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content_version'] = Variable<String>(contentVersion);
    map['category_id'] = Variable<String>(categoryId);
    map['round_number'] = Variable<int>(roundNumber);
    map['score'] = Variable<int>(score);
    map['total'] = Variable<int>(total);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  AttemptsCompanion toCompanion(bool nullToAbsent) {
    return AttemptsCompanion(
      id: Value(id),
      contentVersion: Value(contentVersion),
      categoryId: Value(categoryId),
      roundNumber: Value(roundNumber),
      score: Value(score),
      total: Value(total),
      completedAt: Value(completedAt),
    );
  }

  factory Attempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attempt(
      id: serializer.fromJson<int>(json['id']),
      contentVersion: serializer.fromJson<String>(json['contentVersion']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      roundNumber: serializer.fromJson<int>(json['roundNumber']),
      score: serializer.fromJson<int>(json['score']),
      total: serializer.fromJson<int>(json['total']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contentVersion': serializer.toJson<String>(contentVersion),
      'categoryId': serializer.toJson<String>(categoryId),
      'roundNumber': serializer.toJson<int>(roundNumber),
      'score': serializer.toJson<int>(score),
      'total': serializer.toJson<int>(total),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  Attempt copyWith({
    int? id,
    String? contentVersion,
    String? categoryId,
    int? roundNumber,
    int? score,
    int? total,
    DateTime? completedAt,
  }) => Attempt(
    id: id ?? this.id,
    contentVersion: contentVersion ?? this.contentVersion,
    categoryId: categoryId ?? this.categoryId,
    roundNumber: roundNumber ?? this.roundNumber,
    score: score ?? this.score,
    total: total ?? this.total,
    completedAt: completedAt ?? this.completedAt,
  );
  Attempt copyWithCompanion(AttemptsCompanion data) {
    return Attempt(
      id: data.id.present ? data.id.value : this.id,
      contentVersion: data.contentVersion.present
          ? data.contentVersion.value
          : this.contentVersion,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      roundNumber: data.roundNumber.present
          ? data.roundNumber.value
          : this.roundNumber,
      score: data.score.present ? data.score.value : this.score,
      total: data.total.present ? data.total.value : this.total,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attempt(')
          ..write('id: $id, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('categoryId: $categoryId, ')
          ..write('roundNumber: $roundNumber, ')
          ..write('score: $score, ')
          ..write('total: $total, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contentVersion,
    categoryId,
    roundNumber,
    score,
    total,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attempt &&
          other.id == this.id &&
          other.contentVersion == this.contentVersion &&
          other.categoryId == this.categoryId &&
          other.roundNumber == this.roundNumber &&
          other.score == this.score &&
          other.total == this.total &&
          other.completedAt == this.completedAt);
}

class AttemptsCompanion extends UpdateCompanion<Attempt> {
  final Value<int> id;
  final Value<String> contentVersion;
  final Value<String> categoryId;
  final Value<int> roundNumber;
  final Value<int> score;
  final Value<int> total;
  final Value<DateTime> completedAt;
  const AttemptsCompanion({
    this.id = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.roundNumber = const Value.absent(),
    this.score = const Value.absent(),
    this.total = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  AttemptsCompanion.insert({
    this.id = const Value.absent(),
    required String contentVersion,
    required String categoryId,
    required int roundNumber,
    required int score,
    required int total,
    required DateTime completedAt,
  }) : contentVersion = Value(contentVersion),
       categoryId = Value(categoryId),
       roundNumber = Value(roundNumber),
       score = Value(score),
       total = Value(total),
       completedAt = Value(completedAt);
  static Insertable<Attempt> custom({
    Expression<int>? id,
    Expression<String>? contentVersion,
    Expression<String>? categoryId,
    Expression<int>? roundNumber,
    Expression<int>? score,
    Expression<int>? total,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentVersion != null) 'content_version': contentVersion,
      if (categoryId != null) 'category_id': categoryId,
      if (roundNumber != null) 'round_number': roundNumber,
      if (score != null) 'score': score,
      if (total != null) 'total': total,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  AttemptsCompanion copyWith({
    Value<int>? id,
    Value<String>? contentVersion,
    Value<String>? categoryId,
    Value<int>? roundNumber,
    Value<int>? score,
    Value<int>? total,
    Value<DateTime>? completedAt,
  }) {
    return AttemptsCompanion(
      id: id ?? this.id,
      contentVersion: contentVersion ?? this.contentVersion,
      categoryId: categoryId ?? this.categoryId,
      roundNumber: roundNumber ?? this.roundNumber,
      score: score ?? this.score,
      total: total ?? this.total,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<String>(contentVersion.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (roundNumber.present) {
      map['round_number'] = Variable<int>(roundNumber.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptsCompanion(')
          ..write('id: $id, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('categoryId: $categoryId, ')
          ..write('roundNumber: $roundNumber, ')
          ..write('score: $score, ')
          ..write('total: $total, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $ContentSnapshotsTable extends ContentSnapshots
    with TableInfo<$ContentSnapshotsTable, ContentSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, version, mode, json, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContentSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ContentSnapshotsTable createAlias(String alias) {
    return $ContentSnapshotsTable(attachedDatabase, alias);
  }
}

class ContentSnapshot extends DataClass implements Insertable<ContentSnapshot> {
  final int id;
  final String version;
  final String mode;
  final String json;
  final DateTime updatedAt;
  const ContentSnapshot({
    required this.id,
    required this.version,
    required this.mode,
    required this.json,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['version'] = Variable<String>(version);
    map['mode'] = Variable<String>(mode);
    map['json'] = Variable<String>(json);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ContentSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return ContentSnapshotsCompanion(
      id: Value(id),
      version: Value(version),
      mode: Value(mode),
      json: Value(json),
      updatedAt: Value(updatedAt),
    );
  }

  factory ContentSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentSnapshot(
      id: serializer.fromJson<int>(json['id']),
      version: serializer.fromJson<String>(json['version']),
      mode: serializer.fromJson<String>(json['mode']),
      json: serializer.fromJson<String>(json['json']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'version': serializer.toJson<String>(version),
      'mode': serializer.toJson<String>(mode),
      'json': serializer.toJson<String>(json),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ContentSnapshot copyWith({
    int? id,
    String? version,
    String? mode,
    String? json,
    DateTime? updatedAt,
  }) => ContentSnapshot(
    id: id ?? this.id,
    version: version ?? this.version,
    mode: mode ?? this.mode,
    json: json ?? this.json,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ContentSnapshot copyWithCompanion(ContentSnapshotsCompanion data) {
    return ContentSnapshot(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      mode: data.mode.present ? data.mode.value : this.mode,
      json: data.json.present ? data.json.value : this.json,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentSnapshot(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('mode: $mode, ')
          ..write('json: $json, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, version, mode, json, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentSnapshot &&
          other.id == this.id &&
          other.version == this.version &&
          other.mode == this.mode &&
          other.json == this.json &&
          other.updatedAt == this.updatedAt);
}

class ContentSnapshotsCompanion extends UpdateCompanion<ContentSnapshot> {
  final Value<int> id;
  final Value<String> version;
  final Value<String> mode;
  final Value<String> json;
  final Value<DateTime> updatedAt;
  const ContentSnapshotsCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.mode = const Value.absent(),
    this.json = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ContentSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required String version,
    required String mode,
    required String json,
    required DateTime updatedAt,
  }) : version = Value(version),
       mode = Value(mode),
       json = Value(json),
       updatedAt = Value(updatedAt);
  static Insertable<ContentSnapshot> custom({
    Expression<int>? id,
    Expression<String>? version,
    Expression<String>? mode,
    Expression<String>? json,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (mode != null) 'mode': mode,
      if (json != null) 'json': json,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ContentSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<String>? version,
    Value<String>? mode,
    Value<String>? json,
    Value<DateTime>? updatedAt,
  }) {
    return ContentSnapshotsCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      mode: mode ?? this.mode,
      json: json ?? this.json,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('mode: $mode, ')
          ..write('json: $json, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $RoundProgressEntriesTable roundProgressEntries =
      $RoundProgressEntriesTable(this);
  late final $AttemptsTable attempts = $AttemptsTable(this);
  late final $ContentSnapshotsTable contentSnapshots = $ContentSnapshotsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    roundProgressEntries,
    attempts,
    contentSnapshots,
  ];
}

typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<bool> explanations,
  Value<bool> sound,
  Value<bool> vibration,
  Value<bool> shuffle,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<bool> explanations,
  Value<bool> sound,
  Value<bool> vibration,
  Value<bool> shuffle,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get explanations => $composableBuilder(
    column: $table.explanations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vibration => $composableBuilder(
    column: $table.vibration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shuffle => $composableBuilder(
    column: $table.shuffle,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get explanations => $composableBuilder(
    column: $table.explanations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vibration => $composableBuilder(
    column: $table.vibration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shuffle => $composableBuilder(
    column: $table.shuffle,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get explanations => $composableBuilder(
    column: $table.explanations,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sound =>
      $composableBuilder(column: $table.sound, builder: (column) => column);

  GeneratedColumn<bool> get vibration =>
      $composableBuilder(column: $table.vibration, builder: (column) => column);

  GeneratedColumn<bool> get shuffle =>
      $composableBuilder(column: $table.shuffle, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> explanations = const Value.absent(),
                Value<bool> sound = const Value.absent(),
                Value<bool> vibration = const Value.absent(),
                Value<bool> shuffle = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                explanations: explanations,
                sound: sound,
                vibration: vibration,
                shuffle: shuffle,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> explanations = const Value.absent(),
                Value<bool> sound = const Value.absent(),
                Value<bool> vibration = const Value.absent(),
                Value<bool> shuffle = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                explanations: explanations,
                sound: sound,
                vibration: vibration,
                shuffle: shuffle,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
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

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$RoundProgressEntriesTableCreateCompanionBuilder =
    RoundProgressEntriesCompanion Function({
      required String contentVersion,
      required String categoryId,
      required int roundNumber,
      required int lastScore,
      required int bestScore,
      required int total,
      required DateTime completedAt,
      Value<int> rowid,
    });
typedef $$RoundProgressEntriesTableUpdateCompanionBuilder =
    RoundProgressEntriesCompanion Function({
      Value<String> contentVersion,
      Value<String> categoryId,
      Value<int> roundNumber,
      Value<int> lastScore,
      Value<int> bestScore,
      Value<int> total,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });

class $$RoundProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $RoundProgressEntriesTable> {
  $$RoundProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastScore => $composableBuilder(
    column: $table.lastScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoundProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoundProgressEntriesTable> {
  $$RoundProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastScore => $composableBuilder(
    column: $table.lastScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoundProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoundProgressEntriesTable> {
  $$RoundProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastScore =>
      $composableBuilder(column: $table.lastScore, builder: (column) => column);

  GeneratedColumn<int> get bestScore =>
      $composableBuilder(column: $table.bestScore, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$RoundProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoundProgressEntriesTable,
          RoundProgressEntry,
          $$RoundProgressEntriesTableFilterComposer,
          $$RoundProgressEntriesTableOrderingComposer,
          $$RoundProgressEntriesTableAnnotationComposer,
          $$RoundProgressEntriesTableCreateCompanionBuilder,
          $$RoundProgressEntriesTableUpdateCompanionBuilder,
          (
            RoundProgressEntry,
            BaseReferences<
              _$AppDatabase,
              $RoundProgressEntriesTable,
              RoundProgressEntry
            >,
          ),
          RoundProgressEntry,
          PrefetchHooks Function()
        > {
  $$RoundProgressEntriesTableTableManager(
    _$AppDatabase db,
    $RoundProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoundProgressEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoundProgressEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RoundProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> contentVersion = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> roundNumber = const Value.absent(),
                Value<int> lastScore = const Value.absent(),
                Value<int> bestScore = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoundProgressEntriesCompanion(
                contentVersion: contentVersion,
                categoryId: categoryId,
                roundNumber: roundNumber,
                lastScore: lastScore,
                bestScore: bestScore,
                total: total,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String contentVersion,
                required String categoryId,
                required int roundNumber,
                required int lastScore,
                required int bestScore,
                required int total,
                required DateTime completedAt,
                Value<int> rowid = const Value.absent(),
              }) => RoundProgressEntriesCompanion.insert(
                contentVersion: contentVersion,
                categoryId: categoryId,
                roundNumber: roundNumber,
                lastScore: lastScore,
                bestScore: bestScore,
                total: total,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoundProgressEntriesTable, RoundProgressEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $RoundProgressEntriesTable,
                    RoundProgressEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoundProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoundProgressEntriesTable,
      RoundProgressEntry,
      $$RoundProgressEntriesTableFilterComposer,
      $$RoundProgressEntriesTableOrderingComposer,
      $$RoundProgressEntriesTableAnnotationComposer,
      $$RoundProgressEntriesTableCreateCompanionBuilder,
      $$RoundProgressEntriesTableUpdateCompanionBuilder,
      (
        RoundProgressEntry,
        BaseReferences<
          _$AppDatabase,
          $RoundProgressEntriesTable,
          RoundProgressEntry
        >,
      ),
      RoundProgressEntry,
      PrefetchHooks Function()
    >;
typedef $$AttemptsTableCreateCompanionBuilder = AttemptsCompanion Function({
  Value<int> id,
  required String contentVersion,
  required String categoryId,
  required int roundNumber,
  required int score,
  required int total,
  required DateTime completedAt,
});
typedef $$AttemptsTableUpdateCompanionBuilder = AttemptsCompanion Function({
  Value<int> id,
  Value<String> contentVersion,
  Value<String> categoryId,
  Value<int> roundNumber,
  Value<int> score,
  Value<int> total,
  Value<DateTime> completedAt,
});

class $$AttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$AttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttemptsTable,
          Attempt,
          $$AttemptsTableFilterComposer,
          $$AttemptsTableOrderingComposer,
          $$AttemptsTableAnnotationComposer,
          $$AttemptsTableCreateCompanionBuilder,
          $$AttemptsTableUpdateCompanionBuilder,
          (Attempt, BaseReferences<_$AppDatabase, $AttemptsTable, Attempt>),
          Attempt,
          PrefetchHooks Function()
        > {
  $$AttemptsTableTableManager(_$AppDatabase db, $AttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> contentVersion = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> roundNumber = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
              }) => AttemptsCompanion(
                id: id,
                contentVersion: contentVersion,
                categoryId: categoryId,
                roundNumber: roundNumber,
                score: score,
                total: total,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String contentVersion,
                required String categoryId,
                required int roundNumber,
                required int score,
                required int total,
                required DateTime completedAt,
              }) => AttemptsCompanion.insert(
                id: id,
                contentVersion: contentVersion,
                categoryId: categoryId,
                roundNumber: roundNumber,
                score: score,
                total: total,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttemptsTable, Attempt>(table),
                  BaseReferences<_$AppDatabase, $AttemptsTable, Attempt>(
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

typedef $$AttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttemptsTable,
      Attempt,
      $$AttemptsTableFilterComposer,
      $$AttemptsTableOrderingComposer,
      $$AttemptsTableAnnotationComposer,
      $$AttemptsTableCreateCompanionBuilder,
      $$AttemptsTableUpdateCompanionBuilder,
      (Attempt, BaseReferences<_$AppDatabase, $AttemptsTable, Attempt>),
      Attempt,
      PrefetchHooks Function()
    >;
typedef $$ContentSnapshotsTableCreateCompanionBuilder =
    ContentSnapshotsCompanion Function({
      Value<int> id,
      required String version,
      required String mode,
      required String json,
      required DateTime updatedAt,
    });
typedef $$ContentSnapshotsTableUpdateCompanionBuilder =
    ContentSnapshotsCompanion Function({
      Value<int> id,
      Value<String> version,
      Value<String> mode,
      Value<String> json,
      Value<DateTime> updatedAt,
    });

class $$ContentSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $ContentSnapshotsTable> {
  $$ContentSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentSnapshotsTable> {
  $$ContentSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentSnapshotsTable> {
  $$ContentSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ContentSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentSnapshotsTable,
          ContentSnapshot,
          $$ContentSnapshotsTableFilterComposer,
          $$ContentSnapshotsTableOrderingComposer,
          $$ContentSnapshotsTableAnnotationComposer,
          $$ContentSnapshotsTableCreateCompanionBuilder,
          $$ContentSnapshotsTableUpdateCompanionBuilder,
          (
            ContentSnapshot,
            BaseReferences<
              _$AppDatabase,
              $ContentSnapshotsTable,
              ContentSnapshot
            >,
          ),
          ContentSnapshot,
          PrefetchHooks Function()
        > {
  $$ContentSnapshotsTableTableManager(
    _$AppDatabase db,
    $ContentSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ContentSnapshotsCompanion(
                id: id,
                version: version,
                mode: mode,
                json: json,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String version,
                required String mode,
                required String json,
                required DateTime updatedAt,
              }) => ContentSnapshotsCompanion.insert(
                id: id,
                version: version,
                mode: mode,
                json: json,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContentSnapshotsTable, ContentSnapshot>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ContentSnapshotsTable,
                    ContentSnapshot
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentSnapshotsTable,
      ContentSnapshot,
      $$ContentSnapshotsTableFilterComposer,
      $$ContentSnapshotsTableOrderingComposer,
      $$ContentSnapshotsTableAnnotationComposer,
      $$ContentSnapshotsTableCreateCompanionBuilder,
      $$ContentSnapshotsTableUpdateCompanionBuilder,
      (
        ContentSnapshot,
        BaseReferences<_$AppDatabase, $ContentSnapshotsTable, ContentSnapshot>,
      ),
      ContentSnapshot,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$RoundProgressEntriesTableTableManager get roundProgressEntries =>
      $$RoundProgressEntriesTableTableManager(_db, _db.roundProgressEntries);
  $$AttemptsTableTableManager get attempts =>
      $$AttemptsTableTableManager(_db, _db.attempts);
  $$ContentSnapshotsTableTableManager get contentSnapshots =>
      $$ContentSnapshotsTableTableManager(_db, _db.contentSnapshots);
}
