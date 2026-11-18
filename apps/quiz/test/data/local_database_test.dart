import 'dart:io';

import 'package:diia_my/data/local_database.dart';
import 'package:diia_my/data/user_store.dart';
import 'package:diia_my/domain/user_data.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  late AppDatabase database;
  late DriftUserStore store;
  late bool storeClosed;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    store = DriftUserStore(database);
    storeClosed = false;
  });

  tearDown(() async {
    if (!storeClosed) await store.close();
  });

  test('settings survive a repository reopen', () async {
    const settings = AppSettings(
      explanations: false,
      sound: true,
      vibration: true,
      shuffle: true,
    );
    await store.saveSettings(settings);

    expect(await store.loadSettings(), settings);
  });

  test('completed attempt updates last and keeps the best score', () async {
    const perfect = SavedRoundProgress(
      contentVersion: 'v1',
      categoryId: 'children',
      roundNumber: 1,
      lastScore: 7,
      bestScore: 7,
      total: 7,
    );
    const retry = SavedRoundProgress(
      contentVersion: 'v1',
      categoryId: 'children',
      roundNumber: 1,
      lastScore: 4,
      bestScore: 4,
      total: 7,
    );

    await store.saveCompletedAttempt(perfect);
    await store.saveCompletedAttempt(retry);

    final progress = await store.loadProgress('v1');
    expect(progress, hasLength(1));
    expect(progress.single.lastScore, 4);
    expect(progress.single.bestScore, 7);
    expect(await database.attemptCount(), 2);
  });

  test(
    'content replacement is atomic and returns the active snapshot',
    () async {
      const old = CachedContent(
        version: 'v1',
        mode: 'draft',
        json: '{"version":"v1"}',
      );
      const fresh = CachedContent(
        version: 'v2',
        mode: 'approved',
        json: '{"version":"v2"}',
      );
      await store.saveContent(old);
      await store.saveContent(fresh);

      expect(await store.loadContent(), fresh);
      expect(await database.contentSnapshotCount(), 1);
    },
  );

  test('schema version 1 is migrated without losing settings', () async {
    await store.close();
    storeClosed = true;
    final directory = await Directory.systemTemp.createTemp(
      'diia-my-migration-',
    );
    final file = File('${directory.path}/legacy.sqlite');
    final legacy = sqlite.sqlite3.open(file.path);
    legacy.execute('''
      CREATE TABLE settings (
        id INTEGER NOT NULL PRIMARY KEY,
        explanations INTEGER NOT NULL DEFAULT 1,
        shuffle INTEGER NOT NULL DEFAULT 0
      )
    ''');
    legacy.execute('''
      CREATE TABLE round_progress_entries (
        content_version TEXT NOT NULL,
        category_id TEXT NOT NULL,
        round_number INTEGER NOT NULL,
        last_score INTEGER NOT NULL,
        best_score INTEGER NOT NULL,
        total INTEGER NOT NULL,
        completed_at INTEGER NOT NULL,
        PRIMARY KEY (content_version, category_id, round_number)
      )
    ''');
    legacy.execute(
      'INSERT INTO settings (id, explanations, shuffle) VALUES (1, 0, 1)',
    );
    legacy.execute('PRAGMA user_version = 1');
    legacy.close();

    final migrated = AppDatabase(NativeDatabase(file));
    final migratedStore = DriftUserStore(migrated);
    addTearDown(() async {
      await migratedStore.close();
      await file.delete();
      await directory.delete();
    });
    final settings = await migratedStore.loadSettings();

    expect(settings.explanations, isFalse);
    expect(settings.shuffle, isTrue);
    expect(settings.sound, isFalse);
    expect(settings.vibration, isFalse);
    expect(await migrated.attemptCount(), 0);
  });
}
