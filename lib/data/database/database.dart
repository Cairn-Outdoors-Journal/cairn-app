import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
// createInBackground reports errors from its isolate as DriftRemoteException;
// the library marks it experimental but has no other public type for them.
// ignore: experimental_member_use
import 'package:drift/remote.dart' show DriftRemoteException;

import '../../design/tokens.dart';
import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Notebooks,
    Pages,
    PageItems,
    PocketItems,
    LocationPoints,
    Media,
    Meta,
    Changes,
  ],
)
class CairnDatabase extends _$CairnDatabase {
  CairnDatabase(super.e);

  /// Bump with every schema change and add a step to [migration]; the
  /// schemas are kept in drift_schemas/journal/ for migration tests.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (m) => m.createAll());
}

/// Opens the journal database file, encrypted with SQLite3MultipleCiphers
/// (ADR 0010). [keyHex] is the 32-byte database key as hex.
QueryExecutor openEncryptedDatabase(File file, String keyHex) {
  return NativeDatabase.createInBackground(
    file,
    setup: (db) {
      // Upstream SQLite has no cipher pragma. Without it the hooks in
      // pubspec.yaml are wrong and the journal would be written in the clear.
      if (db.select('PRAGMA cipher;').isEmpty) {
        throw StateError('SQLite was built without encryption');
      }
      db.execute("PRAGMA hexkey = '$keyHex';");
      // Fails here, not on first use, when the key is wrong.
      db.select('SELECT count(*) FROM sqlite_master;');
    },
  );
}

/// Whether [error] is SQLite saying the key doesn't open the file. SQLite
/// can't tell a wrong key from a file that isn't a database at all; both are
/// "file is not a database" (SQLITE_NOTADB, 26). Other failures, such as a
/// corrupt page or a full disk, have their own codes.
bool isWrongDatabaseKey(Object error) {
  final cause = error is DriftRemoteException ? error.remoteCause : error;
  return cause is SqliteException && cause.resultCode == 26;
}
