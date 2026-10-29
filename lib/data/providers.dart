import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sodium/sodium.dart';

import 'journal.dart';
import 'keys/local_keys.dart';

/// The journal, opened once for the app's lifetime. Fails with
/// [JournalKeyMissing] after a restore that didn't bring the key back; then
/// call [unlockRestoredJournal] and invalidate this provider.
final journalProvider = FutureProvider<Journal>((ref) async {
  final journal = await Journal.open(
    root: await _journalRoot(),
    sodium: await SodiumInit.init(),
    vault: const SecureStorageKeyVault(),
  );
  ref.onDispose(journal.close);
  return journal;
}, retry: noRetry);

/// Riverpod retries failed providers by default. Opening the journal fails
/// for reasons a retry can't fix, such as a missing key, and the screen
/// must show that at once; providers built on the journal use this too.
Duration? noRetry(int retryCount, Object error) => null;

/// Unlocks a journal restored from a backup with the person's recovery key
/// and keeps the key on this phone. Throws [FormatException] for a typo and
/// [WrongRecoveryKey] for another journal's key.
Future<void> unlockRestoredJournal(String recoveryKey) async {
  final journal = await Journal.restore(
    root: await _journalRoot(),
    sodium: await SodiumInit.init(),
    vault: const SecureStorageKeyVault(),
    recoveryKey: recoveryKey,
  );
  await journal.close();
}

/// The journal lives in Application Support (iOS) or the files folder
/// (Android), kept out of phone backups (ADR 0011). On Android the backup
/// rules in the manifest do that.
Future<Directory> _journalRoot() async {
  final support = await getApplicationSupportDirectory();
  final root = Directory(p.join(support.path, 'journal'));
  await root.create(recursive: true);
  if (Platform.isIOS) {
    await const MethodChannel('cairn/storage')
        .invokeMethod<void>('excludeFromBackup', root.path);
  }
  return root;
}
