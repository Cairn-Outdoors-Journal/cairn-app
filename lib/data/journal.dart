import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sodium/sodium.dart';

import 'database/database.dart';
import 'keys/local_keys.dart';
import 'media/media_store.dart';
import 'repositories/location_points.dart';
import 'repositories/notebooks.dart';
import 'repositories/page_items.dart';
import 'repositories/pages.dart';
import 'repositories/pocket.dart';
import 'sync/record_writer.dart';

/// Everything Cairn keeps on this phone, opened and ready (ADR 0010):
///
/// - `journal.db`: the records, in SQLite encrypted with
///   SQLite3MultipleCiphers;
/// - `media/`: photos and other files, each encrypted with libsodium.
///
/// Screens read and write only through the repositories here.
class Journal {
  Journal._({
    required this.database,
    required this.clock,
    required this.notebooks,
    required this.pages,
    required this.items,
    required this.pocket,
    required this.points,
    required this.media,
    required this._keys,
  });

  /// Opens the journal in [root], creating it on first use. Throws
  /// [JournalKeyMissing] when the journal is here but the key on this phone
  /// is missing or doesn't open it; then ask for the recovery key and call
  /// [restore].
  static Future<Journal> open({
    required Directory root,
    required Sodium sodium,
    required LocalKeyVault vault,
    int Function()? now,
  }) async {
    final keys = await LocalKeys.load(
      sodium,
      vault,
      journalExists: _databaseFile(root).existsSync(),
    );
    try {
      return await _open(root, sodium, keys, now, newDevice: false);
    } catch (error) {
      keys.dispose();
      // For example, an iOS Keychain entry left from an earlier install,
      // next to a journal restored from a different backup.
      if (isWrongDatabaseKey(error)) throw const JournalKeyMissing();
      rethrow;
    }
  }

  /// Opens a journal restored from a backup with the person's recovery key,
  /// and keeps the key on this phone for next time. Throws
  /// [FormatException] for a typo and [WrongRecoveryKey] for another
  /// journal's key.
  static Future<Journal> restore({
    required Directory root,
    required Sodium sodium,
    required LocalKeyVault vault,
    required String recoveryKey,
    int Function()? now,
  }) async {
    final keys = LocalKeys.fromRecoveryKey(sodium, recoveryKey);
    final Journal journal;
    try {
      // Restoring means another phone, or a wiped one: give it its own
      // device id so it never writes as the phone the journal came from.
      journal = await _open(root, sodium, keys, now, newDevice: true);
    } catch (error) {
      keys.dispose();
      // Anything else (a damaged file, a full disk) is not about the key,
      // and asking the person to retype it would not help.
      if (isWrongDatabaseKey(error)) throw const WrongRecoveryKey();
      rethrow;
    }
    await keys.save(vault);
    return journal;
  }

  static File _databaseFile(Directory root) =>
      File(p.join(root.path, 'journal.db'));

  static Future<Journal> _open(
    Directory root,
    Sodium sodium,
    LocalKeys keys,
    int Function()? now, {
    required bool newDevice,
  }) async {
    final database = CairnDatabase(
      openEncryptedDatabase(_databaseFile(root), keys.databaseKeyHex()),
    );
    return _assemble(
      database,
      Directory(p.join(root.path, 'media')),
      sodium,
      keys,
      now,
      newDevice: newDevice,
    );
  }

  /// A journal held in memory, for widget tests: the same repositories, but
  /// no file and no background isolate, so it runs under the test clock.
  /// Media still goes to [mediaDir].
  @visibleForTesting
  static Future<Journal> inMemory({
    required Sodium sodium,
    required Directory mediaDir,
    int Function()? now,
  }) => _assemble(
    CairnDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    ),
    mediaDir,
    sodium,
    LocalKeys.generate(sodium),
    now,
    newDevice: false,
  );

  static Future<Journal> _assemble(
    CairnDatabase database,
    Directory mediaDir,
    Sodium sodium,
    LocalKeys keys,
    int Function()? now, {
    required bool newDevice,
  }) async {
    try {
      final clock = await JournalClock.load(
        database,
        now: now,
        newDevice: newDevice,
      );
      final writer = RecordWriter(database, clock);
      await mediaDir.create(recursive: true);
      final media = MediaStore(
        directory: mediaDir,
        sodium: sodium,
        key: keys.mediaKey(),
        writer: writer,
      );
      // Catches files left by a delete that was interrupted.
      await media.removeDeletedFiles();
      final removeFiles = media.removeDeletedFiles;
      final items = PageItemRepository(writer, removeFiles);
      return Journal._(
        database: database,
        clock: clock,
        notebooks: NotebookRepository(writer, removeFiles),
        pages: PageRepository(writer, removeFiles),
        items: items,
        pocket: PocketRepository(writer, items, removeFiles),
        points: LocationPointRepository(writer),
        media: media,
        keys: keys,
      );
    } catch (_) {
      await database.close();
      rethrow;
    }
  }

  final CairnDatabase database;
  final JournalClock clock;
  final NotebookRepository notebooks;
  final PageRepository pages;
  final PageItemRepository items;
  final PocketRepository pocket;
  final LocationPointRepository points;
  final MediaStore media;
  final LocalKeys _keys;

  /// The recovery key that opens this journal on any phone. Shown once at
  /// setup for the person to print or write down.
  String recoveryKey() => _keys.recoveryKey();

  /// Changes not yet sent by sync, oldest first.
  Future<List<Change>> unsentChanges() =>
      (database.select(database.changes)
            ..where((c) => c.packSeq.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.seq)]))
          .get();

  Future<void> close() async {
    await database.close();
    _keys.dispose();
  }
}
