import 'package:flutter/foundation.dart';

import 'local_keys.dart';

/// A copy of the account master key that the person's next phone can get
/// back without the recovery key (ADR 0012).
abstract interface class KeyCopy {
  Future<Uint8List?> read();

  /// Keeps [key] as the copy. Called each time the journal opens, so a key
  /// made before the copy existed gets one.
  Future<void> keep(Uint8List key);

  Future<void> delete();
}

/// The key on this phone, plus a copy that travels to the person's next
/// phone (ADR 0012).
///
/// This phone always reads its own key first. The copy is only read when
/// there is none here, on a new phone or after a reinstall, and is then kept
/// on this phone too. A copy that fails never stops the journal opening.
class SyncedKeyVault implements LocalKeyVault {
  SyncedKeyVault(this.device, this.copy);

  final LocalKeyVault device;
  final KeyCopy copy;

  /// The last [KeyCopy.keep] started by [read], which doesn't wait for it.
  @visibleForTesting
  Future<void>? pendingKeep;

  @override
  Future<Uint8List?> read() async {
    final key = await device.read();
    if (key != null) {
      // Opening the journal shouldn't wait on the copy.
      pendingKeep = _keep(key);
      return key;
    }
    final copied = await _guard('read', copy.read);
    if (copied != null) await device.write(copied);
    return copied;
  }

  @override
  Future<void> write(Uint8List key) async {
    await device.write(key);
    await _keep(key);
  }

  /// Deletes both. On iOS the copy is gone from every phone signed in to the
  /// same iCloud account, so only tests call this.
  @override
  Future<void> delete() async {
    await device.delete();
    await copy.delete();
  }

  Future<void> _keep(Uint8List key) => _guard('keep', () => copy.keep(key));

  static Future<T?> _guard<T>(String action, Future<T> Function() run) async {
    try {
      return await run();
    } catch (error) {
      debugPrint('Key copy $action failed: $error');
      return null;
    }
  }
}
