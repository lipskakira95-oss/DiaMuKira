import 'dart:math';

import 'package:drift/drift.dart';

import '../domain/user_data.dart';
import 'local_database.dart';

class DriftUserStore implements UserStore {
  DriftUserStore(this.database);

  final AppDatabase database;

  @override
  Future<AppSettings> loadSettings() async {
    final row = await (database.select(
      database.settings,
    )..where((table) => table.id.equals(1))).getSingleOrNull();
    if (row == null) return const AppSettings.defaults();
    return AppSettings(
      explanations: row.explanations,
      sound: row.sound,
      vibration: row.vibration,
      shuffle: row.shuffle,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) => database
      .into(database.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(
          id: const Value(1),
          explanations: Value(settings.explanations),
          sound: Value(settings.sound),
          vibration: Value(settings.vibration),
          shuffle: Value(settings.shuffle),
        ),
      );

  @override
  Future<List<SavedRoundProgress>> loadProgress(String contentVersion) async {
    final rows = await (database.select(
      database.roundProgressEntries,
    )..where((table) => table.contentVersion.equals(contentVersion))).get();
    return rows
        .map(
          (row) => SavedRoundProgress(
            contentVersion: row.contentVersion,
            categoryId: row.categoryId,
            roundNumber: row.roundNumber,
            lastScore: row.lastScore,
            bestScore: row.bestScore,
            total: row.total,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveCompletedAttempt(SavedRoundProgress progress) =>
      database.transaction(() async {
        final old =
            await (database.select(database.roundProgressEntries)..where(
                  (table) =>
                      table.contentVersion.equals(progress.contentVersion) &
                      table.categoryId.equals(progress.categoryId) &
                      table.roundNumber.equals(progress.roundNumber),
                ))
                .getSingleOrNull();
        final now = DateTime.now().toUtc();
        await database
            .into(database.attempts)
            .insert(
              AttemptsCompanion.insert(
                contentVersion: progress.contentVersion,
                categoryId: progress.categoryId,
                roundNumber: progress.roundNumber,
                score: progress.lastScore,
                total: progress.total,
                completedAt: now,
              ),
            );
        await database
            .into(database.roundProgressEntries)
            .insertOnConflictUpdate(
              RoundProgressEntriesCompanion.insert(
                contentVersion: progress.contentVersion,
                categoryId: progress.categoryId,
                roundNumber: progress.roundNumber,
                lastScore: progress.lastScore,
                bestScore: max(old?.bestScore ?? 0, progress.bestScore),
                total: progress.total,
                completedAt: now,
              ),
            );
      });

  @override
  Future<CachedContent?> loadContent() async {
    final row = await (database.select(
      database.contentSnapshots,
    )..where((table) => table.id.equals(1))).getSingleOrNull();
    if (row == null) return null;
    return CachedContent(version: row.version, mode: row.mode, json: row.json);
  }

  @override
  Future<void> saveContent(CachedContent content) =>
      database.transaction(() async {
        await database.delete(database.contentSnapshots).go();
        await database
            .into(database.contentSnapshots)
            .insert(
              ContentSnapshotsCompanion.insert(
                id: const Value(1),
                version: content.version,
                mode: content.mode,
                json: content.json,
                updatedAt: DateTime.now().toUtc(),
              ),
            );
      });

  @override
  Future<void> close() => database.close();
}
