import 'package:cairn/data/database/database.dart';
import 'package:cairn/design/tokens.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late TestJournal t;
  late Notebook notebook;

  setUp(() async {
    t = await TestJournal.create();
    notebook = await t.journal.notebooks.create(
      title: 'PCT 2026',
      year: 2026,
      cover: CoverCloth.forest,
    );
  });

  group('a day page', () {
    test('is made once, however many saves race for it', () async {
      final pages = t.journal.pages;
      final made = await Future.wait([
        for (var i = 0; i < 3; i++)
          pages.findOrCreate(
            notebookId: notebook.id,
            day: '2026-06-05',
            template: 'day',
          ),
      ]);
      expect(made.map((p) => p.id).toSet(), hasLength(1));
      expect(made.first.template, 'day');
      expect(await pages.watchForNotebook(notebook.id).first, hasLength(1));
    });

    test('finds the first page of a day that runs onto a second', () async {
      final pages = t.journal.pages;
      final first = await pages.findOrCreate(
        notebookId: notebook.id,
        day: '2026-06-05',
        template: 'day',
      );
      t.clock.nowMs += 1000;
      final next = await pages.create(
        notebookId: notebook.id,
        day: '2026-06-05',
        template: 'continued',
      );
      final again = await pages.findOrCreate(
        notebookId: notebook.id,
        day: '2026-06-05',
        template: 'day',
      );
      expect(again.id, first.id);
      expect(
        (await pages.watchForDay(notebook.id, '2026-06-05').first).map(
          (p) => p.id,
        ),
        [first.id, next.id],
      );
    });
  });

  group('section writing', () {
    late JournalPage page;

    setUp(() async {
      page = await t.journal.pages.create(
        notebookId: notebook.id,
        day: '2026-06-05',
        template: 'day',
      );
    });

    test('each section keeps one item, updated in place', () async {
      final items = t.journal.items;
      final first = await items.saveSectionText(
        pageId: page.id,
        section: 'the_day',
        body: 'Up early.',
      );
      final second = await items.saveSectionText(
        pageId: page.id,
        section: 'the_day',
        body: 'Up early. Snow on Forester.',
      );
      await items.saveSectionText(
        pageId: page.id,
        section: 'tomorrow',
        body: 'Resupply.',
      );
      expect(second.id, first.id);
      final stored = await items.watchForPage(page.id).first;
      expect(
        {for (final i in stored) i.section: i.body},
        {'the_day': 'Up early. Snow on Forester.', 'tomorrow': 'Resupply.'},
      );
    });

    test('free writing is the item with no section', () async {
      final items = t.journal.items;
      await items.saveSectionText(
        pageId: page.id,
        section: 'the_day',
        body: 'A',
      );
      final free = await items.saveSectionText(
        pageId: page.id,
        section: null,
        body: 'B',
      );
      final again = await items.saveSectionText(
        pageId: page.id,
        section: null,
        body: 'C',
      );
      expect(again.id, free.id);
      expect(again.section, isNull);
      expect(again.body, 'C');
    });

    test('saving the same text writes nothing new', () async {
      final items = t.journal.items;
      final saved = await items.saveSectionText(
        pageId: page.id,
        section: 'the_day',
        body: 'Same',
      );
      final again = await items.saveSectionText(
        pageId: page.id,
        section: 'the_day',
        body: 'Same',
      );
      expect(again.hlc, saved.hlc);
    });
  });
}
