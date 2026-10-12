import 'dart:typed_data';

import 'package:cairn/data/keys/recovery_key.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sodium/sodium.dart';

void main() {
  late Sodium sodium;
  setUpAll(() async => sodium = await SodiumInit.init());

  Uint8List key(int seed) =>
      Uint8List.fromList(List.generate(32, (i) => (i * 37 + seed) % 256));

  test('reads back the key it wrote', () {
    for (final seed in [0, 1, 99, 255]) {
      final text = RecoveryKey.encode(sodium, key(seed));
      expect(RecoveryKey.decode(sodium, text), key(seed));
    }
  });

  test('is 14 groups of four characters from Crockford Base32', () {
    final text = RecoveryKey.encode(sodium, key(7));
    expect(
      text,
      matches(RegExp(r'^([0-9A-HJKMNP-TV-Z]{4}-){13}[0-9A-HJKMNP-TV-Z]{4}$')),
    );
  });

  test('forgives how it was copied by hand', () {
    final text = RecoveryKey.encode(sodium, key(3));
    final sloppy = text
        .toLowerCase()
        .replaceAll('-', ' ')
        .replaceAll('0', 'o')
        .replaceAll('1', 'l');
    expect(RecoveryKey.decode(sodium, sloppy), key(3));
  });

  test('catches a mistyped character', () {
    final text = RecoveryKey.encode(sodium, key(5));
    final first = text[0];
    final typo = (first == 'A' ? 'B' : 'A') + text.substring(1);
    expect(() => RecoveryKey.decode(sodium, typo), throwsFormatException);
  });

  test('rejects a missing group and letters it never uses', () {
    final text = RecoveryKey.encode(sodium, key(9));
    expect(
      () => RecoveryKey.decode(sodium, text.substring(5)),
      throwsFormatException,
    );
    expect(
      () => RecoveryKey.decode(sodium, 'U${text.substring(1)}'),
      throwsFormatException,
    );
  });
}
