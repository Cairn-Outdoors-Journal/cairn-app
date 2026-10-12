import 'dart:convert';
import 'dart:typed_data';

import 'package:sodium/sodium.dart';

/// The account master key written out for people: the printable recovery
/// key (specs/sync-format.md, ADR 0010).
///
/// 32 key bytes plus a 3-byte checksum, in Crockford Base32: 56 characters
/// in 14 groups of four, such as `7K2Q-M9XG-...`. Crockford's alphabet has no
/// I, L, O or U, and reading accepts lower case, spaces, and O, I or L typed
/// for 0 and 1, so a key copied by hand in a tent still reads back. The
/// checksum catches a mistyped character.
abstract final class RecoveryKey {
  static const keyBytes = 32;
  static const _checksumBytes = 3;
  static const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  static const _groupLength = 4;

  static String encode(Sodium sodium, Uint8List key) {
    if (key.length != keyBytes) {
      throw ArgumentError.value(key.length, 'key', 'must be $keyBytes bytes');
    }
    final bytes = Uint8List.fromList([...key, ..._checksum(sodium, key)]);
    final chars = _toBase32(bytes);
    final groups = <String>[
      for (var i = 0; i < chars.length; i += _groupLength)
        chars.substring(i, i + _groupLength),
    ];
    return groups.join('-');
  }

  /// The key in [text]. Throws [FormatException] for a wrong length,
  /// character or checksum.
  static Uint8List decode(Sodium sodium, String text) {
    final normalized = text
        .toUpperCase()
        .replaceAll(RegExp(r'[\s-]'), '')
        .replaceAll('O', '0')
        .replaceAll(RegExp('[IL]'), '1');
    final expectedLength = ((keyBytes + _checksumBytes) * 8 / 5).ceil();
    if (normalized.length != expectedLength) {
      throw FormatException(
        'A recovery key has $expectedLength characters; '
        'this has ${normalized.length}',
      );
    }
    final bytes = _fromBase32(normalized);
    final key = Uint8List.sublistView(bytes, 0, keyBytes);
    final checksum = Uint8List.sublistView(bytes, keyBytes);
    final expected = _checksum(sodium, key);
    for (var i = 0; i < _checksumBytes; i++) {
      if (checksum[i] != expected[i]) {
        throw const FormatException(
          'This recovery key has a mistyped character',
        );
      }
    }
    return Uint8List.fromList(key);
  }

  static Uint8List _checksum(Sodium sodium, Uint8List key) {
    final hash = sodium.crypto.genericHash(
      message: Uint8List.fromList([
        ...utf8.encode('cairn-recovery-v1'),
        ...key,
      ]),
      outLen: 16,
    );
    return Uint8List.sublistView(hash, 0, _checksumBytes);
  }

  static String _toBase32(Uint8List bytes) {
    final out = StringBuffer();
    var buffer = 0;
    var bits = 0;
    for (final byte in bytes) {
      buffer = ((buffer << 8) | byte) & 0xffff;
      bits += 8;
      while (bits >= 5) {
        bits -= 5;
        out.write(_alphabet[(buffer >> bits) & 31]);
      }
    }
    if (bits > 0) out.write(_alphabet[(buffer << (5 - bits)) & 31]);
    return out.toString();
  }

  static Uint8List _fromBase32(String text) {
    final out = <int>[];
    var buffer = 0;
    var bits = 0;
    for (final char in text.split('')) {
      final value = _alphabet.indexOf(char);
      if (value < 0) {
        throw FormatException('"$char" is not used in recovery keys');
      }
      buffer = ((buffer << 5) | value) & 0xffff;
      bits += 5;
      if (bits >= 8) {
        bits -= 8;
        out.add((buffer >> bits) & 0xff);
      }
    }
    return Uint8List.fromList(out);
  }
}
