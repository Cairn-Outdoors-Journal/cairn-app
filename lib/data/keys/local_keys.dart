import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sodium/sodium.dart';

import 'recovery_key.dart';

/// Where the account master key is kept on this phone.
abstract interface class LocalKeyVault {
  Future<Uint8List?> read();
  Future<void> write(Uint8List key);
  Future<void> delete();
}

/// The Keychain on iOS and the Keystore on Android (ADR 0010).
///
/// iOS restores the key when a backup goes back onto the same iPhone, but
/// never copies it to another phone. Android never restores it. Anywhere
/// else, the journal opens with the recovery key.
class SecureStorageKeyVault implements LocalKeyVault {
  const SecureStorageKeyVault({this.name = 'cairn.account_master_key.v1'});

  /// The entry's name; tests use their own so they never touch the app's key.
  final String name;

  static const _storage = FlutterSecureStorage(
    // Readable after the first unlock, so captures work while the phone is
    // locked; never copied to another device.
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    // The default wipes all stored values on any read error. Fail instead,
    // and let the person unlock with the recovery key.
    aOptions: AndroidOptions(resetOnError: false),
  );

  @override
  Future<Uint8List?> read() async {
    try {
      final value = await _storage.read(key: name);
      return value == null ? null : base64Decode(value);
    } on PlatformException catch (error) {
      // For example, Android data restored without its Keystore key.
      debugPrint('Journal key unreadable: $error');
      return null;
    }
  }

  @override
  Future<void> write(Uint8List key) =>
      _storage.write(key: name, value: base64Encode(key));

  @override
  Future<void> delete() => _storage.delete(key: name);
}

/// The journal is on this phone but no key here opens it: after a reset and
/// restore on Android, on a new phone, or when a key left from an earlier
/// install belongs to another journal. It opens with the recovery key.
class JournalKeyMissing implements Exception {
  const JournalKeyMissing();

  @override
  String toString() =>
      'JournalKeyMissing: unlock the journal with its recovery key';
}

/// The recovery key is valid but belongs to a different journal.
class WrongRecoveryKey implements Exception {
  const WrongRecoveryKey();

  @override
  String toString() => 'WrongRecoveryKey: this key does not open the journal';
}

/// The keys protecting everything Cairn keeps on this phone.
///
/// The root is the account master key (specs/sync-format.md), which the
/// person holds as their recovery key. The keys for the database and media
/// are derived from it, so the recovery key alone opens a restored journal.
class LocalKeys {
  LocalKeys._(this._sodium, this._master);

  /// libsodium KDF context; exactly 8 bytes.
  static const _context = 'cairn_lc';
  static const _databaseSubkey = 1;
  static const _mediaSubkey = 2;

  /// Loads the master key, creating it for a new journal. Throws
  /// [JournalKeyMissing] when [journalExists] but the key is not here.
  static Future<LocalKeys> load(
    Sodium sodium,
    LocalKeyVault vault, {
    required bool journalExists,
  }) async {
    final stored = await vault.read();
    if (stored != null) {
      return LocalKeys._(sodium, SecureKey.fromList(sodium, stored));
    }
    if (journalExists) throw const JournalKeyMissing();
    final master = sodium.crypto.kdf.keygen();
    await vault.write(master.extractBytes());
    return LocalKeys._(sodium, master);
  }

  /// Keys from a typed recovery key. Throws [FormatException] for a typo.
  /// Not saved until [save]: check it opens the journal first.
  static LocalKeys fromRecoveryKey(Sodium sodium, String recoveryKey) =>
      LocalKeys._(
        sodium,
        SecureKey.fromList(sodium, RecoveryKey.decode(sodium, recoveryKey)),
      );

  /// A fresh key that is never stored, for in-memory test journals.
  @visibleForTesting
  static LocalKeys generate(Sodium sodium) =>
      LocalKeys._(sodium, sodium.crypto.kdf.keygen());

  final Sodium _sodium;
  final SecureKey _master;

  Future<void> save(LocalKeyVault vault) => vault.write(_master.extractBytes());

  /// The recovery key to show the person once and ask them to keep.
  String recoveryKey() => RecoveryKey.encode(_sodium, _master.extractBytes());

  /// The SQLite database key, as hex for `PRAGMA hexkey`.
  String databaseKeyHex() {
    final key = _derive(_databaseSubkey, 32);
    try {
      return key.runUnlockedSync(
        (bytes) => bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      );
    } finally {
      key.dispose();
    }
  }

  /// The key for media files (secretstream).
  SecureKey mediaKey() =>
      _derive(_mediaSubkey, _sodium.crypto.secretStream.keyBytes);

  SecureKey _derive(int id, int length) => _sodium.crypto.kdf.deriveFromKey(
    masterKey: _master,
    context: _context,
    subkeyId: BigInt.from(id),
    subkeyLen: length,
  );

  void dispose() => _master.dispose();
}
