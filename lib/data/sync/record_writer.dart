import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/database.dart';
import '../ids.dart';
import 'hlc.dart';

/// Hands out HLC stamps for this device. The last stamp is saved with each
/// change, so stamps keep increasing across restarts.
class JournalClock {
  JournalClock._(this._db, this._last, this._now);

  static const _deviceIdKey = 'device_id';
  static const _hlcKey = 'hlc';

  /// Loads the clock, creating this device's id on first use.
  static Future<JournalClock> load(
    CairnDatabase db, {
    int Function()? now,
  }) async {
    final rows = await db.select(db.meta).get();
    final meta = {for (final row in rows) row.key: row.value};
    var deviceId = meta[_deviceIdKey];
    if (deviceId == null) {
      deviceId = newDeviceId();
      await db
          .into(db.meta)
          .insert(MetaCompanion.insert(key: _deviceIdKey, value: deviceId));
    }
    final last = meta[_hlcKey];
    return JournalClock._(
      db,
      last == null ? Hlc.zero(deviceId) : Hlc.parse(last),
      now ?? () => DateTime.now().millisecondsSinceEpoch,
    );
  }

  final CairnDatabase _db;
  final int Function() _now;
  Hlc _last;

  String get deviceId => _last.deviceId;

  /// Wall-clock time for record timestamps such as `createdAtMs`.
  int nowMs() => _now();

  /// The stamp for the next change. Call inside the change's transaction.
  Future<String> next() async {
    _last = _last.tick(_now());
    final packed = _last.pack();
    await _db
        .into(_db.meta)
        .insertOnConflictUpdate(
          MetaCompanion.insert(key: _hlcKey, value: packed),
        );
    return packed;
  }
}

/// Saves and deletes synced records. Every write also adds an entry to the
/// change log in the same transaction, so sync can later send exactly what
/// changed (specs/sync-format.md).
class RecordWriter {
  RecordWriter(this.db, this.clock);

  final CairnDatabase db;
  final JournalClock clock;

  /// Inserts or replaces the record [build] returns for a fresh stamp.
  Future<D> save<T extends Table, D extends DataClass>(
    RecordType type,
    TableInfo<T, D> table,
    D Function(String hlc) build,
  ) {
    return db.transaction(() async {
      final hlc = await clock.next();
      final row = build(hlc);
      await db.into(table).insertOnConflictUpdate(row as Insertable<D>);
      final json = row.toJson();
      await db
          .into(db.changes)
          .insert(
            ChangesCompanion.insert(
              recordType: type,
              recordId: json['id'] as String,
              hlc: hlc,
              op: ChangeOp.upsert,
              payload: Value(jsonEncode(json)),
            ),
          );
      return row;
    });
  }

  /// Marks the record deleted, leaving a tombstone. Returns false when it
  /// was already deleted or never existed.
  Future<bool> delete(
    RecordType type,
    TableInfo<Table, Object?> table,
    String id,
  ) {
    return db.transaction(() async {
      final hlc = await clock.next();
      final updated = await db.customUpdate(
        'UPDATE "${table.actualTableName}" SET deleted = 1, hlc = ? '
        'WHERE id = ? AND deleted = 0',
        variables: [Variable.withString(hlc), Variable.withString(id)],
        updates: {table},
        updateKind: UpdateKind.update,
      );
      if (updated == 0) return false;
      await db
          .into(db.changes)
          .insert(
            ChangesCompanion.insert(
              recordType: type,
              recordId: id,
              hlc: hlc,
              op: ChangeOp.delete,
            ),
          );
      return true;
    });
  }
}
