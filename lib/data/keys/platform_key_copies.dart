import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'local_keys.dart';
import 'synced_key_vault.dart';

/// The vault the app uses: the key on this phone, with a copy in iCloud
/// Keychain on iOS and in Block Store on Android (ADR 0012).
SyncedKeyVault appKeyVault({String name = SecureStorageKeyVault.defaultName}) =>
    SyncedKeyVault(
      SecureStorageKeyVault(name: name),
      Platform.isIOS
          ? KeychainKeyCopy(name: '$name.synced')
          : BlockStoreKeyCopy(name: name),
    );

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

/// Block Store, through the cairn/key_sync channel (KeySyncChannel.kt).
///
/// Unlike iCloud Keychain it is never shared between live phones, only
/// restored onto a new one, so each keep overwrites it with this phone's key.
class BlockStoreKeyCopy implements KeyCopy {
  const BlockStoreKeyCopy({required this.name});

  final String name;

  static const _channel = MethodChannel('cairn/key_sync');

  @override
  Future<Uint8List?> read() => _channel.invokeMethod<Uint8List>('read', name);

  @override
  Future<void> keep(Uint8List key) =>
      _channel.invokeMethod<bool>('keep', {'name': name, 'key': key});

  @override
  Future<void> delete() => _channel.invokeMethod<void>('delete', name);
}
