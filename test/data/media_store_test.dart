import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cairn/data/database/database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  Uint8List randomBytes(int n) {
    final random = Random(n);
    return Uint8List.fromList(List.generate(n, (_) => random.nextInt(256)));
  }

  test('round-trips files of every chunk boundary', () async {
    final t = await TestJournal.create();
    const chunk = 64 * 1024;
    for (final size in [0, 1, chunk - 1, chunk, chunk + 1, 3 * chunk + 17]) {
      final bytes = randomBytes(size);
      final record = await t.journal.media.put(
        bytes,
        kind: MediaKind.photo,
        mimeType: 'image/jpeg',
      );
      expect(record.byteSize, size);
      expect(await t.journal.media.read(record.id), bytes, reason: '$size');
    }
  });

  test('the file on disk holds no plain content', () async {
    final t = await TestJournal.create();
    final plain = utf8.encode('Forester Pass, 13,200 ft. ' * 400);
    final record = await t.journal.media.put(
      Uint8List.fromList(plain),
      kind: MediaKind.sketch,
      mimeType: 'text/plain',
    );
    final onDisk = await t.journal.media
        .fileFor(record.id)
        .readAsString(encoding: latin1);
    expect(onDisk.startsWith('CRL1'), isTrue);
    expect(onDisk.contains('Forester'), isFalse);
  });

  test('a changed byte fails to decrypt', () async {
    final t = await TestJournal.create();
    final record = await t.journal.media.put(
      randomBytes(5000),
      kind: MediaKind.photo,
      mimeType: 'image/jpeg',
    );
    final file = t.journal.media.fileFor(record.id);
    final bytes = await file.readAsBytes();
    bytes[2000] ^= 0x01;
    await file.writeAsBytes(bytes);
    await expectLater(t.journal.media.read(record.id), throwsA(anything));
  });

  test('a file copied over another id fails to decrypt', () async {
    final t = await TestJournal.create();
    final media = t.journal.media;
    final a = await media.put(
      randomBytes(100),
      kind: MediaKind.photo,
      mimeType: 'image/jpeg',
    );
    final b = await media.put(
      randomBytes(100),
      kind: MediaKind.photo,
      mimeType: 'image/jpeg',
    );
    await media.fileFor(a.id).copy(media.fileFor(b.id).path);
    await expectLater(media.read(b.id), throwsA(anything));
  });

  test('deleting removes the file and leaves a tombstone', () async {
    final t = await TestJournal.create();
    final media = t.journal.media;
    final record = await media.put(
      randomBytes(10),
      kind: MediaKind.voice,
      mimeType: 'audio/m4a',
    );
    expect(media.isOnPhone(record.id), isTrue);
    await media.delete(record.id);
    expect(media.isOnPhone(record.id), isFalse);
    final db = t.journal.database;
    final row = await (db.select(
      db.media,
    )..where((m) => m.id.equals(record.id))).getSingle();
    expect(row.deleted, isTrue);
  });
}
