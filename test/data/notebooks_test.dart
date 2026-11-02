import 'package:cairn/data/database/database.dart';
import 'package:cairn/data/days.dart';
import 'package:cairn/design/tokens.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('a trip notebook keeps its trail, trail name and start day', () async {
    final t = await TestJournal.create();
    final trip = await t.journal.notebooks.create(
      kind: NotebookKind.trip,
      title: 'PCT 2026',
      year: 2026,
      cover: CoverCloth.forest,
      trail: 'Pacific Crest Trail',
      trailName: 'Switchback',
      startDay: '2026-04-20',
    );
    final journal = await t.reopen();
    final stored = await journal.notebooks.find(trip.id);
    expect(stored?.kind, NotebookKind.trip);
    expect(stored?.trail, 'Pacific Crest Trail');
    expect(stored?.trailName, 'Switchback');
    expect(stored?.startDay, '2026-04-20');
  });

  test(
    'the current notebook is the one opened last, else the newest',
    () async {
      final t = await TestJournal.create();
      final notebooks = t.journal.notebooks;
      expect(await notebooks.watchCurrent().first, isNull);

      final older = await notebooks.create(
        title: 'Day hikes',
        year: 2025,
        cover: CoverCloth.ochre,
      );
      t.clock.nowMs += 1000;
      final newer = await notebooks.create(
        title: 'Day hikes',
        year: 2026,
        cover: CoverCloth.slate,
      );
      expect((await notebooks.watchCurrent().first)?.id, newer.id);

      await notebooks.markOpened(older.id);
      expect((await notebooks.watchCurrent().first)?.id, older.id);

      // Survives a restart, and falls back once that notebook is deleted.
      final journal = await t.reopen();
      expect((await journal.notebooks.watchCurrent().first)?.id, older.id);
      await journal.notebooks.delete(older.id);
      expect((await journal.notebooks.watchCurrent().first)?.id, newer.id);
    },
  );

  test('opening a notebook is not a journal change', () async {
    final t = await TestJournal.create();
    final notebook = await t.journal.notebooks.create(
      title: 'N',
      year: 2026,
      cover: CoverCloth.rust,
    );
    final before = (await t.journal.unsentChanges()).length;
    await t.journal.notebooks.markOpened(notebook.id);
    expect((await t.journal.unsentChanges()).length, before);
  });

  test('page count leaves out deleted pages', () async {
    final t = await TestJournal.create();
    final j = t.journal;
    final notebook = await j.notebooks.create(
      title: 'N',
      year: 2026,
      cover: CoverCloth.rust,
    );
    final first = await j.pages.create(
      notebookId: notebook.id,
      day: '2026-06-01',
    );
    await j.pages.create(notebookId: notebook.id, day: '2026-06-02');
    expect(await j.notebooks.pageCount(notebook.id), 2);
    await j.pages.delete(first.id);
    expect(await j.notebooks.pageCount(notebook.id), 1);
  });

  test('the full opening plays once a day', () async {
    final t = await TestJournal.create();
    final notebooks = t.journal.notebooks;
    expect(await notebooks.firstOpenOn('2026-06-05'), isTrue);
    expect(await notebooks.firstOpenOn('2026-06-05'), isFalse);
    // It's kept on the phone, across restarts.
    expect(
      await (await t.reopen()).notebooks.firstOpenOn('2026-06-05'),
      isFalse,
    );
    expect(await t.journal.notebooks.firstOpenOn('2026-06-06'), isTrue);
  });

  group('days', () {
    test('day keys round-trip', () {
      expect(dayKey(DateTime(2026, 3, 9, 23, 59)), '2026-03-09');
      expect(parseDayKey('2026-03-09'), DateTime.utc(2026, 3, 9));
    });

    test('the start day is day 1, across a daylight-saving change', () {
      expect(dayOfTrip('2026-03-07', DateTime(2026, 3, 7, 6)), 1);
      // US clocks change on 8 March 2026.
      expect(dayOfTrip('2026-03-07', DateTime(2026, 3, 9, 0, 30)), 3);
      expect(dayOfTrip('2026-04-20', DateTime(2026, 6, 5)), 47);
      expect(dayOfTrip('2026-04-20', DateTime(2026, 4, 19)), 0);
    });

    test('the header date names the weekday', () {
      expect(formatDayWithWeekday('2026-08-12'), 'Wed 12 Aug 2026');
      expect(formatDayWithWeekday('2026-11-01'), 'Sun 1 Nov 2026');
    });
  });
}
