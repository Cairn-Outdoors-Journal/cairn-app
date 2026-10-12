import 'dart:io';

import 'package:drift/drift.dart';
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
  /// [JournalKeyMissing] when the journal is here but its key isn't; then
  /// ask for the recovery key and call [restore].
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
    return _open(root, sodium, keys, now);
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
      journal = await _open(root, sodium, keys, now);
    } on Exception {
      keys.dispose();
      throw const WrongRecoveryKey();
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
    int Function()? now,
  ) async {
    final database = CairnDatabase(
      openEncryptedDatabase(_databaseFile(root), keys.databaseKeyHex()),
    );
    final JournalClock clock;
    try {
      clock = await JournalClock.load(database, now: now);
    } catch (_) {
      await database.close();
      rethrow;
    }
    final writer = RecordWriter(database, clock);
    final mediaDir = Directory(p.join(root.path, 'media'));
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
