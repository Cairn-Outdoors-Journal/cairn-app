import 'dart:io';

import 'package:cairn/data/journal.dart';
import 'package:drift/drift.dart';
import 'package:cairn/data/keys/local_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sodium/sodium.dart';

/// A key vault that lives in memory, standing in for the Keychain/Keystore.
class MemoryKeyVault implements LocalKeyVault {
  Uint8List? key;

  @override
  Future<Uint8List?> read() async => key;

  @override
  Future<void> write(Uint8List key) async => this.key = key;

  @override
  Future<void> delete() async => key = null;
}

/// A clock the test moves by hand.
class FakeClock {
  int nowMs = DateTime.utc(2026, 6, 1, 7).millisecondsSinceEpoch;

  int call() => nowMs;
}

/// A journal in a fresh temp folder, closed and deleted after the test.
class TestJournal {
  TestJournal._(this.root, this.sodium, this.vault, this.clock);

  static Future<TestJournal> create() async {
    // Tests reopen the journal on purpose, as after an app restart.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final root = await Directory.systemTemp.createTemp('cairn_journal_');
    final harness = TestJournal._(
      root,
      await SodiumInit.init(),
      MemoryKeyVault(),
      FakeClock(),
    );
    await harness.open();
    addTearDown(() async {
      await harness.journal.close();
      await root.delete(recursive: true);
    });
    return harness;
  }

  final Directory root;
  final Sodium sodium;
  final MemoryKeyVault vault;
  final FakeClock clock;
  late Journal journal;

  File get databaseFile => File('${root.path}/journal.db');

  Future<Journal> open() async => journal = await Journal.open(
    root: root,
    sodium: sodium,
    vault: vault,
    now: clock.call,
  );

  /// Closes and opens the journal again, as after an app restart.
  Future<Journal> reopen() async {
    await journal.close();
    return open();
  }
}

/// A journal in memory for widget tests. Create it in `setUp` and close it
/// in `tearDown`; inside `testWidgets`, call it through `tester.runAsync`,
/// since database work doesn't advance under the test's fake clock.
Future<Journal> memoryJournal() async {
  final media = await Directory.systemTemp.createTemp('cairn_media_');
  addTearDown(() => media.delete(recursive: true));
  return Journal.inMemory(sodium: await SodiumInit.init(), mediaDir: media);
}
