import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'local_database.g.dart';

class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  BoolColumn get explanations => boolean().withDefault(const Constant(true))();
  BoolColumn get sound => boolean().withDefault(const Constant(false))();
  BoolColumn get vibration => boolean().withDefault(const Constant(false))();
  BoolColumn get shuffle => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class RoundProgressEntries extends Table {
  TextColumn get contentVersion => text()();
  TextColumn get categoryId => text()();
  IntColumn get roundNumber => integer()();
  IntColumn get lastScore => integer()();
  IntColumn get bestScore => integer()();
  IntColumn get total => integer()();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {
    contentVersion,
    categoryId,
    roundNumber,
  };
}

class Attempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contentVersion => text()();
  TextColumn get categoryId => text()();
  IntColumn get roundNumber => integer()();
  IntColumn get score => integer()();
  IntColumn get total => integer()();
  DateTimeColumn get completedAt => dateTime()();
}

class ContentSnapshots extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get version => text()();
  TextColumn get mode => text()();
  TextColumn get json => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [Settings, RoundProgressEntries, Attempts, ContentSnapshots],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults()
    : super(
        driftDatabase(
          name: 'diia_my',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(settings, settings.sound);
        await migrator.addColumn(settings, settings.vibration);
        await migrator.createTable(attempts);
        await migrator.createTable(contentSnapshots);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<int> attemptCount() async {
    final count = attempts.id.count();
    final query = selectOnly(attempts)..addColumns([count]);
    return (await query.getSingle()).read(count) ?? 0;
  }

  Future<int> contentSnapshotCount() async {
    final count = contentSnapshots.id.count();
    final query = selectOnly(contentSnapshots)..addColumns([count]);
    return (await query.getSingle()).read(count) ?? 0;
  }
}
