import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/database.dart';
import '../ids.dart';
import 'hlc.dart';

/// Hands out HLC stamps for this device. The last stamp is saved with each
/// change, so stamps keep increasing across restarts.
class JournalClock {
  JournalClock._(this._db, this.deviceId, this._last, this._now);

  static const _deviceIdKey = 'device_id';
  static const _hlcKey = 'hlc';

  /// Loads the clock, creating this device's id on first use.
  ///
  /// The device id belongs to this install, not to the journal: pass
  /// [newDevice] for a journal restored from a backup or transferred from
  /// another phone, which may still be writing with the old id.
  static Future<JournalClock> load(
    CairnDatabase db, {
    int Function()? now,
    bool newDevice = false,
  }) async {
    final rows = await db.select(db.meta).get();
    final meta = {for (final row in rows) row.key: row.value};
    var deviceId = meta[_deviceIdKey];
    if (deviceId == null || newDevice) {
      deviceId = newDeviceId();
      await db
          .into(db.meta)
          .insertOnConflictUpdate(
            MetaCompanion.insert(key: _deviceIdKey, value: deviceId),
          );
    }
    // Stamps keep counting up from the journal's last one, under this
    // device's id.
    final last = meta[_hlcKey];
    final previous = last == null ? null : Hlc.parse(last);
    return JournalClock._(
      db,
      deviceId,
      Hlc(previous?.wallMs ?? 0, previous?.counter ?? 0, deviceId),
      now ?? () => DateTime.now().millisecondsSinceEpoch,
    );
  }

  final CairnDatabase _db;
  final int Function() _now;
  final String deviceId;
  Hlc _last;

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

/// A save was refused because the record has been deleted, for example an
/// autosave from an editor still showing an item whose page was deleted.
class RecordDeleted implements Exception {
  const RecordDeleted(this.type, this.id);

  final RecordType type;
  final String id;

  @override
  String toString() => 'RecordDeleted: ${type.name} $id was deleted';
}

/// Saves and deletes synced records. Every write also adds an entry to the
/// change log in the same transaction, so sync can later send exactly what
/// changed (specs/sync-format.md).
class RecordWriter {
  RecordWriter(this.db, this.clock);

  final CairnDatabase db;
  final JournalClock clock;

  /// Inserts or replaces the record [build] returns for a fresh stamp.
  /// Throws [RecordDeleted] instead of overwriting a deleted record, so a
  /// stale copy can never undo a delete.
  Future<D> save<T extends Table, D extends DataClass>(
    RecordType type,
    TableInfo<T, D> table,
    D Function(String hlc) build,
  ) {
    return db.transaction(() async {
      final hlc = await clock.next();
      final row = build(hlc);
      final json = row.toJson();
      final id = json['id'] as String;
      final stored = await db
          .customSelect(
            'SELECT deleted FROM "${table.actualTableName}" WHERE id = ?',
            variables: [Variable.withString(id)],
            readsFrom: {table},
          )
          .getSingleOrNull();
      if (stored != null && stored.read<bool>('deleted')) {
        throw RecordDeleted(type, id);
      }
      // Write every column, nulls included. Passing the data class itself
      // leaves null fields out of the upsert, so clearing a field (a custom
      // colour, a trail name) would keep the old value while the change log
      // recorded the null.
      final columns = (row as Insertable<D>).toColumns(false);
      await db
          .into(table)
          .insertOnConflictUpdate(RawValuesInsertable<D>(columns));
      await db
          .into(db.changes)
          .insert(
            ChangesCompanion.insert(
              recordType: type,
              recordId: id,
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
