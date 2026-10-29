import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'local_keys.dart';
import 'synced_key_vault.dart';

/// The vault the app uses: the key on this phone, with a copy in iCloud
/// Keychain on iOS (ADR 0012).
LocalKeyVault appKeyVault({String name = SecureStorageKeyVault.defaultName}) {
  final device = SecureStorageKeyVault(name: name);
  if (Platform.isIOS) {
    return SyncedKeyVault(device, KeychainKeyCopy(name: '$name.synced'));
  }
  return device;
}

/// A synchronizable Keychain item, which iCloud Keychain copies end to end
/// encrypted to the person's other Apple devices.
///
/// It is shared live between phones, so it is only written when missing: a
/// second iPhone that started its own journal before the copy arrived must
/// not replace the key of the first.
class KeychainKeyCopy implements KeyCopy {
  const KeychainKeyCopy({required this.name});

  final String name;

  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      synchronizable: true,
    ),
  );

  @override
  Future<Uint8List?> read() async {
    final value = await _storage.read(key: name);
    return value == null ? null : base64Decode(value);
  }

  @override
  Future<void> keep(Uint8List key) async {
    if (await read() != null) return;
    await _storage.write(key: name, value: base64Encode(key));
  }

  @override
  Future<void> delete() => _storage.delete(key: name);
}
