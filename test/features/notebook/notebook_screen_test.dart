import 'package:cairn/app.dart';
import 'package:cairn/clock.dart';
import 'package:cairn/data/database/database.dart';
import 'package:cairn/data/journal.dart';
import 'package:cairn/data/providers.dart';
import 'package:cairn/design/tokens.dart';
import 'package:cairn/features/page/day_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';
import '../../helpers/settle.dart';

void main() {
  late Journal journal;
  late Notebook trip;

  setUp(() async {
    journal = await memoryJournal();
    trip = await journal.notebooks.create(
      kind: NotebookKind.trip,
      title: 'PCT 2026',
      year: 2026,
      cover: CoverCloth.forest,
      startDay: '2026-04-20',
    );
  });
  tearDown(() => journal.close());

  /// Opens the PCT notebook from the shelf on 5 June 2026, day 47.
  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalProvider.overrideWith((ref) async => journal),
          clockProvider.overrideWithValue(() => DateTime(2026, 6, 5, 19)),
        ],
        child: const CairnApp(),
      ),
    );
    await settle(tester);
    await tester.tap(find.byKey(const Key('current-notebook')));
    await settle(tester);
  }

  Finder field(String section) => find.descendant(
    of: find.byKey(Key('section-$section')),
    matching: find.byType(TextField),
  );

  testWidgets("opens at today's page, ready to write", (tester) async {
    await open(tester);
    expect(find.text('PCT 2026'), findsOneWidget);
    expect(find.text('DAY 47'), findsOneWidget);
    expect(find.bySemanticsLabel('Today'), findsOneWidget);
    expect(find.text('Three lines instead'), findsOneWidget);
    // Nothing is stored until something is written.
    expect(
      await tester.runAsync(() => journal.notebooks.pageCount(trip.id)),
      0,
    );

    await tester.enterText(field('the_day'), 'Muir Pass hut in the hail.');
    await tester.pump(DayPageState.saveDelay);
    await settle(tester);
    expect(
      await tester.runAsync(() => journal.notebooks.pageCount(trip.id)),
      1,
    );
    // Still the same page, still holding the writing.
    expect(find.text('Muir Pass hut in the hail.'), findsOneWidget);
  });

  testWidgets('swipes back to earlier days', (tester) async {
    await tester.runAsync(() async {
      final page = await journal.pages.create(
        notebookId: trip.id,
        day: '2026-06-03',
        template: 'day',
      );
      await journal.items.saveSectionText(
        pageId: page.id,
        section: 'the_day',
        body: 'Evolution Creek ford.',
      );
    });
    await open(tester);
    expect(find.text('DAY 47'), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(350, 0), 1500);
    await settle(tester);
    expect(find.text('DAY 45'), findsOneWidget);
    expect(find.text('Evolution Creek ford.'), findsOneWidget);
    expect(find.bySemanticsLabel('Today'), findsNothing);
    expect(find.text('Three lines instead'), findsNothing);
  });

  testWidgets('turns to the next page when writing fills this one', (
    tester,
  ) async {
    await open(tester);
    // The test font is much wider than Newsreader: this runs onto a third
    // page.
    final words = [for (var i = 0; i < 100; i++) 'word$i'].join(' ');
    await tester.enterText(field('the_day'), words);
    // Pump step by step: a focused field's cursor keeps drawing, so the
    // screen never settles.
    var pages = 0;
    for (var i = 0; i < 30 && pages < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
      pages = (await tester.runAsync(
        () => journal.notebooks.pageCount(trip.id),
      ))!;
    }
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(pages, 3);

    // Nothing lost, in order, across the three pages.
    final written = await tester.runAsync(() async {
      final day = await journal.pages.watchForDay(trip.id, '2026-06-05').first;
      final parts = <String>[];
      for (final page in day) {
        final items = await journal.items.watchForPage(page.id).first;
        parts.add(items.map((i) => i.body).join());
      }
      return parts;
    });
    expect(written!.join(' '), words);

    // The notebook turned to the last page, with the cursor in it.
    expect(find.textContaining('CONTINUED'), findsOneWidget);
    final free = tester.widget<TextField>(field('free'));
    expect(free.focusNode?.hasFocus, isTrue);
    expect(free.controller?.text, endsWith('word99'));
  });

  testWidgets('the Days tab lists the days and jumps to one', (tester) async {
    await tester.runAsync(() async {
      final page = await journal.pages.create(
        notebookId: trip.id,
        day: '2026-05-30',
        template: 'day',
      );
      await journal.items.saveSectionText(
        pageId: page.id,
        section: 'the_day',
        body: 'Kearsarge Pass to Onion Valley.\nHitched to Bishop.',
      );
    });
    await open(tester);
    expect(find.text('DAY 47'), findsOneWidget);

    await tester.tap(find.byKey(const Key('days-tab')));
    await settle(tester);
    expect(find.text('Days'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('Nothing written yet'), findsOneWidget);
    expect(find.text('Kearsarge Pass to Onion Valley.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('day-2026-05-30')));
    await settle(tester);
    expect(find.text('Days'), findsNothing);
    expect(find.text('DAY 41'), findsOneWidget);
    expect(find.text('DAY 47'), findsNothing);
  });

  testWidgets('back to the shelf', (tester) async {
    await open(tester);
    await tester.tap(find.text('Shelf'));
    await settle(tester);
    expect(find.text('1 NOTEBOOK'), findsOneWidget);
  });
}
