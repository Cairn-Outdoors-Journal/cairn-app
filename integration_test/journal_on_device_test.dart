// Runs the data layer on a real phone, simulator or emulator, with the real
// Keychain / Keystore and the encrypted SQLite build:
//   flutter test integration_test -d <device>
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cairn/data/database/database.dart';
import 'package:cairn/data/journal.dart';
import 'package:cairn/data/keys/local_keys.dart';
import 'package:cairn/design/tokens.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sodium/sodium.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the journal is encrypted, survives a restart and a reset', (
    _,
  ) async {
    final support = await getApplicationSupportDirectory();
    final root = Directory(p.join(support.path, 'journal_device_test'));
    if (root.existsSync()) await root.delete(recursive: true);
    await root.create(recursive: true);
    final sodium = await SodiumInit.init();
    const vault = SecureStorageKeyVault(name: 'cairn.device_test_key');
    await vault.delete();

    var journal = await Journal.open(root: root, sodium: sodium, vault: vault);
    final notebook = await journal.notebooks.create(
      title: 'Device check notebook',
      year: 2026,
      cover: CoverCloth.ochre,
    );
    final photoBytes = Uint8List.fromList(
      List.generate(300000, (i) => i % 251),
    );
    final photo = await journal.media.put(
      photoBytes,
      kind: MediaKind.photo,
      mimeType: 'image/jpeg',
    );
    await journal.close();

    final dbBytes = await File(p.join(root.path, 'journal.db')).readAsBytes();
    expect(latin1.decode(dbBytes.sublist(0, 15)), isNot('SQLite format 3'));
    expect(latin1.decode(dbBytes).contains('Device check notebook'), isFalse);

    journal = await Journal.open(root: root, sodium: sodium, vault: vault);
    expect(
      (await journal.notebooks.find(notebook.id))?.title,
      'Device check notebook',
    );
    expect(await journal.media.read(photo.id), photoBytes);
    final recoveryKey = journal.recoveryKey();
    await journal.close();

    // A reset phone restored from backup: the files are back, the key isn't.
    await vault.delete();
    await expectLater(
      Journal.open(root: root, sodium: sodium, vault: vault),
      throwsA(isA<JournalKeyMissing>()),
    );
    journal = await Journal.restore(
      root: root,
      sodium: sodium,
      vault: vault,
      recoveryKey: recoveryKey,
    );
    expect(await journal.media.read(photo.id), photoBytes);
    await journal.close();
    journal = await Journal.open(root: root, sodium: sodium, vault: vault);
    await journal.close();

    await vault.delete();
    await root.delete(recursive: true);
  });
}
