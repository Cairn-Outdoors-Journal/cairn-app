import 'dart:io';
import 'dart:typed_data';

import 'package:cairn/data/journal.dart';
import 'package:cairn/design/tokens.dart';
import 'package:cairn/data/keys/recovery_key.dart';
import 'package:cairn/data/keys/synced_key_vault.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sodium/sodium.dart';

import 'helpers.dart';

/// Stands in for iCloud Keychain or Block Store.
class FakeKeyCopy implements KeyCopy {
  Uint8List? key;
  bool failing = false;
  int keeps = 0;

  @override
  Future<Uint8List?> read() async {
    if (failing) throw Exception('copy unavailable');
    return key;
  }

  @override
  Future<void> keep(Uint8List key) async {
    if (failing) throw Exception('copy unavailable');
    keeps++;
    this.key = key;
  }

  @override
  Future<void> delete() async => key = null;
}

void main() {
  late MemoryKeyVault device;
  late FakeKeyCopy copy;
  late SyncedKeyVault vault;

  setUp(() {
    device = MemoryKeyVault();
    copy = FakeKeyCopy();
    vault = SyncedKeyVault(device, copy);
  });

  Uint8List key(int seed) => Uint8List.fromList(List.filled(32, seed));

  test('a new key goes to this phone and the copy', () async {
    await vault.write(key(1));
    expect(device.key, key(1));
    expect(copy.key, key(1));
  });

  test("this phone's key wins over the copy", () async {
    device.key = key(1);
    copy.key = key(2);
    expect(await vault.read(), key(1));
  });

  test('a key made before the copy existed gets one when read', () async {
    device.key = key(1);
    expect(await vault.read(), key(1));
    await vault.pendingKeep;
    expect(copy.key, key(1));
  });

  test('a new phone takes the copy and keeps it', () async {
    copy.key = key(2);
    expect(await vault.read(), key(2));
    expect(device.key, key(2));
    expect(copy.keeps, 0);
  });

  test('a failing copy never stops the key being read or written', () async {
    copy.failing = true;
    await vault.write(key(1));
    expect(device.key, key(1));
    expect(await vault.read(), key(1));
    await vault.pendingKeep;

    device.key = null;
    expect(await vault.read(), isNull);
  });

  test('delete removes both', () async {
    await vault.write(key(1));
    await vault.delete();
    expect(device.key, isNull);
    expect(copy.key, isNull);
  });

  group('with a journal', () {
    late Sodium sodium;
    late Directory root;

    setUp(() async {
      sodium = await SodiumInit.init();
      root = await Directory.systemTemp.createTemp('cairn_synced_key_');
      addTearDown(() => root.delete(recursive: true));
    });

    test('a new phone starts its journal with the copied key', () async {
      copy.key = key(3);
      final journal = await Journal.open(
        root: root,
        sodium: sodium,
        vault: vault,
      );
      addTearDown(journal.close);
      expect(journal.recoveryKey(), RecoveryKey.encode(sodium, key(3)));
    });

    test('a key lost on this phone comes back from the copy', () async {
      var journal = await Journal.open(
        root: root,
        sodium: sodium,
        vault: vault,
      );
      final notebook = await journal.notebooks.create(
        title: 'Arctic Trail',
        year: 2026,
        cover: CoverCloth.ochre,
      );
      await journal.close();

      device.key = null;
      journal = await Journal.open(root: root, sodium: sodium, vault: vault);
      addTearDown(journal.close);
      expect(
        (await journal.notebooks.find(notebook.id))?.title,
        'Arctic Trail',
      );
    });
  });
}
