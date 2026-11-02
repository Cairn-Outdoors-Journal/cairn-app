import 'package:cairn/data/database/database.dart';
import 'package:cairn/data/journal.dart';
import 'package:cairn/design/tokens.dart';
import 'package:cairn/features/page/day_page.dart';
import 'package:cairn/features/page/page_frame.dart';
import 'package:flutter/material.dart';
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

  final continued = <(String, int)>[];
  setUp(continued.clear);

  Future<void> show(
    WidgetTester tester, {
    JournalPage? page,
    PageFocus? focus,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageFrame(
            child: DayPage(
              key: ValueKey(page?.id),
              journal: journal,
              notebook: trip,
              day: '2026-06-05',
              page: page,
              ribbon: true,
              focus: focus,
              onContinued: (id, offset) => continued.add((id, offset)),
            ),
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Finder field(String section) => find.descendant(
    of: find.byKey(Key('section-$section')),
    matching: find.byType(TextField),
  );

  Future<Map<String?, String?>> stored() async {
    final page = await journal.pages.forDay(trip.id, '2026-06-05');
    if (page == null) return {};
    final items = await journal.items.watchForPage(page.id).first;
    return {for (final i in items) i.section: i.body};
  }

  testWidgets('shows the header and the day template', (tester) async {
    await show(tester);
    expect(find.text('DAY 47'), findsOneWidget);
    for (final label in [
      'THE DAY',
      'HIGH / LOW',
      'PEOPLE',
      'TRAIL NOTES',
      'TOMORROW',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('HIGH'), findsOneWidget);
    expect(find.text('LOW'), findsOneWidget);
  });

  testWidgets('an untouched page stores nothing', (tester) async {
    await show(tester);
    await tester.enterText(field('the_day'), 'x');
    await tester.enterText(field('the_day'), '');
    await tester.pump(DayPageState.saveDelay);
    await settle(tester);
    expect(
      await tester.runAsync(() => journal.pages.forDay(trip.id, '2026-06-05')),
      isNull,
    );
  });

  testWidgets('writing stores the page and each section', (tester) async {
    await show(tester);
    await tester.enterText(field('the_day'), 'Forester Pass at dawn.');
    await tester.enterText(field('high'), 'The view south');
    await tester.pump(DayPageState.saveDelay);
    await settle(tester);
    expect(await tester.runAsync(stored), {
      'the_day': 'Forester Pass at dawn.',
      'high': 'The view south',
    });
    final page = await tester.runAsync(
      () => journal.pages.forDay(trip.id, '2026-06-05'),
    );
    expect(page?.template, 'day');
  });

  testWidgets('leaving the page saves what is waiting', (tester) async {
    await show(tester);
    await tester.enterText(field('tomorrow'), 'Resupply in Bishop');
    // Gone before the save delay runs out.
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    expect(await tester.runAsync(stored), {'tomorrow': 'Resupply in Bishop'});
  });

  testWidgets('a stored page shows its writing again', (tester) async {
    late JournalPage page;
    await tester.runAsync(() async {
      page = await journal.pages.create(
        notebookId: trip.id,
        day: '2026-06-05',
        template: 'day',
      );
      await journal.items.saveSectionText(
        pageId: page.id,
        section: 'people',
        body: 'Met Lemonhead at the lake.',
      );
    });
    await show(tester, page: page);
    expect(find.text('Met Lemonhead at the lake.'), findsOneWidget);
  });

  group('a full page', () {
    final words = [for (var i = 0; i < 400; i++) 'word$i'].join(' ');

    Future<List<JournalPage>> pages() =>
        journal.pages.watchForDay(trip.id, '2026-06-05').first;

    Future<String?> freeWriting(JournalPage page) async {
      final items = await journal.items.watchForPage(page.id).first;
      return items.where((i) => i.section == null).firstOrNull?.body;
    }

    testWidgets('continues on a new page for the same day', (tester) async {
      await show(tester);
      await tester.enterText(field('the_day'), words);
      await settle(tester);

      final kept = tester.widget<TextField>(field('the_day')).controller!.text;
      expect(kept.length, lessThan(words.length));
      expect(kept, isNot(endsWith(' ')));

      final day = (await tester.runAsync(pages))!;
      expect(day, hasLength(2));
      expect(day[1].template, 'continued');
      final rest = (await tester.runAsync(() => freeWriting(day[1])))!;
      // Nothing lost, and the break falls between words.
      expect('$kept $rest', words);
      expect(await tester.runAsync(stored), {'the_day': kept});
      expect(continued.single, (day[1].id, rest.length));
    });

    testWidgets('a continued page that is full continues again', (
      tester,
    ) async {
      final long = [for (var i = 0; i < 900; i++) 'w$i'].join(' ');
      late JournalPage next;
      await tester.runAsync(() async {
        final first = await journal.pages.create(
          notebookId: trip.id,
          day: '2026-06-05',
          template: 'day',
        );
        next = await journal.pages.create(
          notebookId: trip.id,
          day: '2026-06-05',
          template: 'continued',
        );
        await journal.items.saveSectionText(
          pageId: first.id,
          section: 'the_day',
          body: 'Start.',
        );
        await journal.items.saveSectionText(
          pageId: next.id,
          section: null,
          body: long,
        );
      });
      await show(tester, page: next, focus: const PageFocus(null, 3));
      await settle(tester);

      final day = (await tester.runAsync(pages))!;
      expect(day, hasLength(3));
      final second = (await tester.runAsync(() => freeWriting(day[1])))!;
      final third = (await tester.runAsync(() => freeWriting(day[2])))!;
      expect('$second $third', long);
    });
  });
}
