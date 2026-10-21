import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:cairn/data/database/database.dart';
import 'package:cairn/data/journal.dart';
import 'package:cairn/data/keys/local_keys.dart';
import 'package:cairn/data/repositories/location_points.dart';
import 'package:cairn/data/repositories/page_items.dart';
import 'package:cairn/data/sync/hlc.dart';
import 'package:cairn/data/sync/record_writer.dart';
import 'package:cairn/design/tokens.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('encryption at rest', () {
    test('the database file is unreadable without the key', () async {
      final t = await TestJournal.create();
      await t.journal.notebooks.create(
        title: 'Sierra High Route',
        year: 2026,
        cover: CoverCloth.forest,
      );
      await t.journal.database.customStatement('PRAGMA wal_checkpoint(FULL)');
      await t.reopen();

      final bytes = await t.databaseFile.readAsBytes();
      expect(latin1.decode(bytes.sublist(0, 15)), isNot('SQLite format 3'));
      expect(_contains(bytes, utf8.encode('Sierra High Route')), isFalse);
    });

    test('reopening with the same key reads everything back', () async {
      final t = await TestJournal.create();
      final created = await t.journal.notebooks.create(
        title: 'PCT',
        year: 2026,
        cover: CoverCloth.rust,
      );
      final journal = await t.reopen();
      expect((await journal.notebooks.find(created.id))?.title, 'PCT');
    });

    test('a key that does not open the journal asks for the recovery '
        'key', () async {
      final t = await TestJournal.create();
      await t.journal.close();
      t.vault.key = Uint8List.fromList(
        List.generate(32, (_) => Random.secure().nextInt(256)),
      );
      await expectLater(t.open(), throwsA(isA<JournalKeyMissing>()));
      // Leave a working journal for the tear-down to close.
      t.vault.key = null;
      await t.databaseFile.delete();
      await t.open();
    });

    test(
      'after a reset, the recovery key unlocks the restored journal',
      () async {
        final t = await TestJournal.create();
        final notebook = await t.journal.notebooks.create(
          title: 'Arizona Trail',
          year: 2026,
          cover: CoverCloth.ochre,
        );
        final recoveryKey = t.journal.recoveryKey();
        final oldDeviceId = t.journal.clock.deviceId;
        await t.journal.close();
        // A reset phone restored from backup: files back, key gone.
        t.vault.key = null;
        await expectLater(t.open(), throwsA(isA<JournalKeyMissing>()));

        t.journal = await Journal.restore(
          root: t.root,
          sodium: t.sodium,
          vault: t.vault,
          recoveryKey: recoveryKey.toLowerCase(),
          now: t.clock.call,
        );
        expect(
          (await t.journal.notebooks.find(notebook.id))?.title,
          'Arizona Trail',
        );
        // A restored journal writes as a new device, so it never collides
        // with the phone it came from.
        final newDeviceId = t.journal.clock.deviceId;
        expect(newDeviceId, isNot(oldDeviceId));
        final edited = await t.journal.notebooks.create(
          title: 'After restore',
          year: 2026,
          cover: CoverCloth.ochre,
        );
        expect(Hlc.parse(edited.hlc).deviceId, newDeviceId);
        // The key and the new id are kept, so the next launch opens without
        // asking, as the same device.
        await t.reopen();
        expect(t.journal.recoveryKey(), recoveryKey);
        expect(t.journal.clock.deviceId, newDeviceId);
      },
    );

    test(
      'a restore that fails for another reason is not a wrong key',
      () async {
        final t = await TestJournal.create();
        final recoveryKey = t.journal.recoveryKey();
        await t.journal.close();
        final key = t.vault.key;
        t.vault.key = null;
        // Something in the way of the media folder: not the key's fault.
        final mediaDir = Directory('${t.root.path}/media');
        await mediaDir.delete(recursive: true);
        final blocker = await File(mediaDir.path).create();

        await expectLater(
          Journal.restore(
            root: t.root,
            sodium: t.sodium,
            vault: t.vault,
            recoveryKey: recoveryKey,
          ),
          throwsA(isA<FileSystemException>()),
        );
        expect(t.vault.key, isNull);
        await blocker.delete();
        t.vault.key = key;
        await t.open();
      },
    );

    test("another journal's recovery key is refused and not kept", () async {
      final t = await TestJournal.create();
      final other = await TestJournal.create();
      final otherKey = other.journal.recoveryKey();
      await t.journal.close();
      final key = t.vault.key;
      t.vault.key = null;

      await expectLater(
        Journal.restore(
          root: t.root,
          sodium: t.sodium,
          vault: t.vault,
          recoveryKey: otherKey,
        ),
        throwsA(isA<WrongRecoveryKey>()),
      );
      expect(t.vault.key, isNull);
      t.vault.key = key;
      await t.open();
    });

    test(
      'an existing journal whose key is gone is reported, not replaced',
      () async {
        final t = await TestJournal.create();
        await t.journal.close();
        final key = t.vault.key;
        t.vault.key = null;
        await expectLater(t.open(), throwsA(isA<JournalKeyMissing>()));
        expect(t.databaseFile.existsSync(), isTrue);
        t.vault.key = key;
        await t.open();
      },
    );
  });

  group('change log', () {
    test('every write is logged with its full record, in order', () async {
      final t = await TestJournal.create();
      final notebooks = t.journal.notebooks;
      final notebook = await notebooks.create(
        title: 'Draft',
        year: 2026,
        cover: CoverCloth.slate,
      );
      await notebooks.update(notebook.copyWith(title: 'John Muir Trail'));
      await notebooks.delete(notebook.id);

      final changes = await t.journal.unsentChanges();
      expect(changes.map((c) => c.op), [
        ChangeOp.upsert,
        ChangeOp.upsert,
        ChangeOp.delete,
      ]);
      expect(changes.every((c) => c.recordId == notebook.id), isTrue);
      expect(changes.every((c) => c.recordType == RecordType.notebook), isTrue);
      final renamed = jsonDecode(changes[1].payload!) as Map<String, Object?>;
      expect(renamed['title'], 'John Muir Trail');
      expect(renamed['cover'], 'slate');
      expect(changes[2].payload, isNull);

      final stamps = changes.map((c) => Hlc.parse(c.hlc)).toList();
      expect(stamps[0].compareTo(stamps[1]), lessThan(0));
      expect(stamps[1].compareTo(stamps[2]), lessThan(0));
    });

    test('stamps keep increasing after a restart, even if the clock '
        'went back', () async {
      final t = await TestJournal.create();
      final first = await t.journal.notebooks.create(
        title: 'A',
        year: 2026,
        cover: CoverCloth.ochre,
      );
      final deviceId = t.journal.clock.deviceId;
      t.clock.nowMs -= const Duration(hours: 3).inMilliseconds;
      final journal = await t.reopen();
      final second = await journal.notebooks.create(
        title: 'B',
        year: 2026,
        cover: CoverCloth.ochre,
      );
      expect(journal.clock.deviceId, deviceId);
      expect(
        Hlc.parse(second.hlc).compareTo(Hlc.parse(first.hlc)),
        greaterThan(0),
      );
    });

    test('a failed write leaves no record and no change', () async {
      final t = await TestJournal.create();
      final j = t.journal;
      final notebook = await j.notebooks.create(
        title: 'N',
        year: 2026,
        cover: CoverCloth.forest,
      );
      final page = await j.pages.create(
        notebookId: notebook.id,
        day: '2026-06-01',
      );
      // A photo pocket item with no media can't be taped to a page.
      final broken = await j.pocket.add(
        notebookId: notebook.id,
        kind: PocketItemKind.photo,
      );
      final before = (await j.unsentChanges()).length;

      await expectLater(
        j.pocket.placeOnPage(
          broken,
          pageId: page.id,
          placement: const Placement(0, 0, 100, 100),
        ),
        throwsA(anything),
      );
      expect((await j.unsentChanges()).length, before);
      expect(await j.items.watchForPage(page.id).first, isEmpty);
    });
  });

  group('repositories', () {
    test(
      'deleting a notebook leaves tombstones for everything in it',
      () async {
        final t = await TestJournal.create();
        final j = t.journal;
        final notebook = await j.notebooks.create(
          title: 'Colorado Trail',
          year: 2026,
          cover: CoverCloth.waxedCanvas,
        );
        final page = await j.pages.create(
          notebookId: notebook.id,
          day: '2026-07-04',
        );
        await j.items.addText(pageId: page.id, body: 'Waterton Canyon, hot.');
        await j.pocket.add(
          notebookId: notebook.id,
          kind: PocketItemKind.text,
          body: 'Ask about the Segment 6 detour',
        );

        await j.notebooks.delete(notebook.id);

        expect(await j.notebooks.watchAll().first, isEmpty);
        expect(await j.pages.watchForNotebook(notebook.id).first, isEmpty);
        expect(await j.items.watchForPage(page.id).first, isEmpty);
        expect(await j.pocket.watchWaiting(notebook.id).first, isEmpty);

        final db = j.database;
        final rows = [
          ...await db
              .select(db.notebooks)
              .get()
              .then((r) => r.map((x) => x.deleted)),
          ...await db
              .select(db.pages)
              .get()
              .then((r) => r.map((x) => x.deleted)),
          ...await db
              .select(db.pageItems)
              .get()
              .then((r) => r.map((x) => x.deleted)),
          ...await db
              .select(db.pocketItems)
              .get()
              .then((r) => r.map((x) => x.deleted)),
        ];
        expect(rows, [true, true, true, true]);
        final deletes = (await j.unsentChanges()).where(
          (c) => c.op == ChangeOp.delete,
        );
        expect(deletes.map((c) => c.recordType).toSet(), {
          RecordType.notebook,
          RecordType.page,
          RecordType.pageItem,
          RecordType.pocketItem,
        });
      },
    );

    test('deleting a notebook removes its points and unused photos', () async {
      final t = await TestJournal.create();
      final j = t.journal;
      final notebook = await j.notebooks.create(
        title: 'N',
        year: 2026,
        cover: CoverCloth.forest,
      );
      final page = await j.pages.create(
        notebookId: notebook.id,
        day: '2026-06-01',
      );
      final photo = await j.media.put(
        Uint8List.fromList([1, 2, 3]),
        kind: MediaKind.photo,
        mimeType: 'image/jpeg',
      );
      await j.items.addPhoto(
        pageId: page.id,
        mediaId: photo.id,
        placement: const Placement(0, 0, 10, 10),
      );
      const fix = LocationFix(
        latitude: 37.7,
        longitude: -119.1,
        accuracyM: 5,
        recordedAtMs: 0,
      );
      await j.points.record(fix, trigger: PointTrigger.widget, pageId: page.id);
      final unpinned = await j.points.record(
        fix,
        trigger: PointTrigger.appOpen,
      );

      await j.notebooks.delete(notebook.id);

      expect(j.media.fileFor(photo.id).existsSync(), isFalse);
      final live = await j.points.watchBetween(-1, 1).first;
      expect(live.map((pt) => pt.id), [unpinned.id]);
    });

    test('a photo used twice survives deleting one use', () async {
      final t = await TestJournal.create();
      final j = t.journal;
      final notebook = await j.notebooks.create(
        title: 'N',
        year: 2026,
        cover: CoverCloth.forest,
      );
      final page = await j.pages.create(
        notebookId: notebook.id,
        day: '2026-06-01',
      );
      final photo = await j.media.put(
        Uint8List.fromList([9, 9]),
        kind: MediaKind.photo,
        mimeType: 'image/jpeg',
      );
      const at = Placement(0, 0, 10, 10);
      final first = await j.items.addPhoto(
        pageId: page.id,
        mediaId: photo.id,
        placement: at,
      );
      final second = await j.items.addPhoto(
        pageId: page.id,
        mediaId: photo.id,
        placement: at,
      );

      await j.items.delete(first.id);
      expect(await j.media.read(photo.id), [9, 9]);

      await j.items.delete(second.id);
      expect(j.media.fileFor(photo.id).existsSync(), isFalse);
    });

    test('a stale copy cannot bring a deleted item back', () async {
      final t = await TestJournal.create();
      final j = t.journal;
      final notebook = await j.notebooks.create(
        title: 'N',
        year: 2026,
        cover: CoverCloth.forest,
      );
      final page = await j.pages.create(
        notebookId: notebook.id,
        day: '2026-06-01',
      );
      // An editor holds the item, then its page is deleted under it.
      final held = await j.items.addText(pageId: page.id, body: 'Draft');
      await j.pages.delete(page.id);
      final before = (await j.unsentChanges()).length;

      await expectLater(
        j.items.update(held.copyWith(body: const Value('Autosaved'))),
        throwsA(isA<RecordDeleted>()),
      );
      expect((await j.unsentChanges()).length, before);
      final db = j.database;
      final row = await (db.select(
        db.pageItems,
      )..where((i) => i.id.equals(held.id))).getSingle();
      expect(row.deleted, isTrue);
      expect(row.body, 'Draft');
    });

    test('deleting twice logs one delete', () async {
      final t = await TestJournal.create();
      final j = t.journal;
      final notebook = await j.notebooks.create(
        title: 'N',
        year: 2026,
        cover: CoverCloth.forest,
      );
      final page = await j.pages.create(
        notebookId: notebook.id,
        day: '2026-06-01',
      );
      final item = await j.items.addText(pageId: page.id, body: 'x');
      await j.items.delete(item.id);
      await j.items.delete(item.id);
      final deletes = (await j.unsentChanges()).where(
        (c) => c.op == ChangeOp.delete,
      );
      expect(deletes, hasLength(1));
    });

    test('new taped items go on top', () async {
      final t = await TestJournal.create();
      final j = t.journal;
      final notebook = await j.notebooks.create(
        title: 'N',
        year: 2026,
        cover: CoverCloth.forest,
      );
      final page = await j.pages.create(
        notebookId: notebook.id,
        day: '2026-06-01',
      );
      final first = await j.items.addSketch(
        pageId: page.id,
        strokes: '[]',
        placement: const Placement(10, 10, 50, 50),
      );
      final second = await j.items.addText(
        pageId: page.id,
        body: 'Camp at 11,200 ft',
      );
      expect(second.z, first.z + 1);
      final items = await j.items.watchForPage(page.id).first;
      expect(items.map((i) => i.id), [first.id, second.id]);
    });

    test('laying out a pocket photo tapes it to the page', () async {
      final t = await TestJournal.create();
      final j = t.journal;
      final notebook = await j.notebooks.create(
        title: 'N',
        year: 2026,
        cover: CoverCloth.forest,
      );
      final page = await j.pages.create(
        notebookId: notebook.id,
        day: '2026-06-01',
      );
      final photo = await j.media.put(
        Uint8List.fromList([1, 2, 3]),
        kind: MediaKind.photo,
        mimeType: 'image/jpeg',
      );
      final pocketItem = await j.pocket.add(
        notebookId: notebook.id,
        kind: PocketItemKind.photo,
        mediaId: photo.id,
      );

      final placed = await j.pocket.placeOnPage(
        pocketItem,
        pageId: page.id,
        placement: const Placement(40, 60, 120, 90, rotation: -0.05),
      );

      expect(placed.kind, PageItemKind.photo);
      expect(placed.mediaId, photo.id);
      expect(placed.rotation, -0.05);
      expect(await j.pocket.watchWaiting(notebook.id).first, isEmpty);
      final db = j.database;
      final stored = await (db.select(
        db.pocketItems,
      )..where((i) => i.id.equals(pocketItem.id))).getSingle();
      expect(stored.placedItemId, placed.id);
    });

    test(
      "a pocket capture's point moves to the page it is laid out on",
      () async {
        final t = await TestJournal.create();
        final j = t.journal;
        final notebook = await j.notebooks.create(
          title: 'N',
          year: 2026,
          cover: CoverCloth.forest,
        );
        final page = await j.pages.create(
          notebookId: notebook.id,
          day: '2026-06-01',
        );
        final note = await j.pocket.add(
          notebookId: notebook.id,
          kind: PocketItemKind.text,
          body: 'Marmot stole a sock',
        );
        final point = await j.points.record(
          const LocationFix(
            latitude: 37.7,
            longitude: -119.1,
            accuracyM: 5,
            recordedAtMs: 0,
          ),
          trigger: PointTrigger.pocket,
          pocketItemId: note.id,
        );

        await j.pocket.placeOnPage(
          note,
          pageId: page.id,
          placement: const Placement(0, 0, 10, 10),
        );

        final db = j.database;
        final moved = await (db.select(
          db.locationPoints,
        )..where((pt) => pt.id.equals(point.id))).getSingle();
        expect(moved.pageId, page.id);
      },
    );

    test('app opens skip points that would repeat the last one', () async {
      final t = await TestJournal.create();
      final points = t.journal.points;
      LocationFix fix(double lat, int atMs) => LocationFix(
        latitude: lat,
        longitude: -119.173,
        accuracyM: 5,
        recordedAtMs: atMs,
      );
      final start = t.clock.nowMs;
      const minute = 60 * 1000;
      // 0.0002° of latitude is about 22 m; 0.001° about 111 m.
      expect(await points.recordAppOpen(fix(37.7225, start)), isNotNull);
      expect(
        await points.recordAppOpen(fix(37.7227, start + 5 * minute)),
        isNull,
      );
      expect(
        await points.recordAppOpen(fix(37.7235, start + 6 * minute)),
        isNotNull,
      );
      expect(
        await points.recordAppOpen(fix(37.7235, start + 17 * minute)),
        isNotNull,
      );

      final saved = await points.watchBetween(start, start + 60 * minute).first;
      expect(saved, hasLength(3));
      expect(saved.every((p) => p.trigger == PointTrigger.appOpen), isTrue);
    });

    test('distance between two points', () {
      // One degree of latitude is about 111.2 km.
      expect(distanceM(37, -119, 38, -119), closeTo(111195, 10));
      expect(distanceM(37, -119, 37, -119), 0);
    });
  });
}

bool _contains(List<int> haystack, List<int> needle) {
  outer:
  for (var i = 0; i <= haystack.length - needle.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}
