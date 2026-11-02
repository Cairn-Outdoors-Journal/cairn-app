import 'dart:async';

import 'package:cairn/app.dart';
import 'package:cairn/clock.dart';
import 'package:cairn/data/database/database.dart';
import 'package:cairn/data/journal.dart';
import 'package:cairn/data/keys/local_keys.dart';
import 'package:cairn/data/providers.dart';
import 'package:cairn/design/tokens.dart';
import 'package:cairn/features/shelf/shelf_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';
import '../../helpers/settle.dart';

void main() {
  late Journal journal;
  setUp(() async => journal = await memoryJournal());
  tearDown(() => journal.close());

  Future<void> showShelf(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalProvider.overrideWith((ref) async => journal),
          clockProvider.overrideWithValue(() => DateTime(2026, 6, 5)),
        ],
        child: const CairnApp(),
      ),
    );
    await settle(tester);
  }

  testWidgets('an empty shelf starts the first notebook', (tester) async {
    await showShelf(tester);
    // An outline of the shelf to fill: the large place and a row of four.
    expect(find.byKey(const Key('start-first-notebook')), findsOneWidget);
    expect(find.byKey(const Key('empty-place-3')), findsOneWidget);
    expect(find.text('New'), findsNothing);

    await tester.tap(find.text('Start your first notebook'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create notebook'));
    await settle(tester);

    expect(find.text('Day hikes'), findsOneWidget);
    expect(find.text('1 NOTEBOOK'), findsOneWidget);
    expect(find.text('New'), findsOneWidget);
    expect(find.text('ON THE TRAIL'), findsOneWidget);
    expect(find.byKey(const Key('start-first-notebook')), findsNothing);
    // The rest of the shelf is still waiting to be filled.
    expect(find.byKey(const Key('empty-place-3')), findsOneWidget);
  });

  testWidgets('the last-opened notebook is large; the rest are below', (
    tester,
  ) async {
    late Notebook pct;
    await tester.runAsync(() async {
      await journal.notebooks.create(
        title: 'Day hikes',
        year: 2025,
        cover: CoverCloth.ochre,
      );
      pct = await journal.notebooks.create(
        kind: NotebookKind.trip,
        title: 'PCT 2026',
        year: 2026,
        cover: CoverCloth.forest,
        trail: 'Pacific Crest Trail',
        trailName: 'Switchback',
        startDay: '2026-04-20',
      );
    });
    await showShelf(tester);

    expect(find.text('2 NOTEBOOKS'), findsOneWidget);
    expect(find.text('DAY 47'), findsOneWidget);
    expect(find.text('ON THE SHELF'), findsOneWidget);
    expect(find.text('Day hikes'), findsOneWidget);
    expect(find.text('2025'), findsOneWidget);
    // One notebook on the shelf leaves three empty places in the row.
    expect(find.byKey(const Key('empty-place-2')), findsOneWidget);
    expect(find.byKey(const Key('empty-place-3')), findsNothing);

    // Opening the yearly notebook opens it and makes it current.
    await tester.tap(find.text('Day hikes'));
    await settle(tester);
    expect(find.text('THE DAY'), findsOneWidget);
    await tester.tap(find.text('Shelf'));
    await settle(tester);
    expect(find.text('DAY 47'), findsNothing);
    expect(find.text('PCT 2026'), findsOneWidget);
    expect(find.byKey(Key('notebook-${pct.id}')), findsOneWidget);
  });

  testWidgets('long-press changes the cover and deletes after asking', (
    tester,
  ) async {
    late Notebook notebook;
    await tester.runAsync(() async {
      notebook = await journal.notebooks.create(
        title: 'Day hikes',
        year: 2026,
        cover: CoverCloth.forest,
      );
      await journal.pages.create(notebookId: notebook.id, day: '2026-06-01');
    });
    await showShelf(tester);

    await tester.longPress(find.byKey(const Key('current-notebook')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change cover'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cloth-rust')));
    await settle(tester);
    final stored = await tester.runAsync(
      () => journal.notebooks.find(notebook.id),
    );
    expect(stored?.cover, CoverCloth.rust);

    await tester.longPress(find.byKey(const Key('current-notebook')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await settle(tester);
    expect(find.textContaining('Its 1 page'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await settle(tester);
    expect(find.byKey(const Key('start-first-notebook')), findsOneWidget);
  });

  testWidgets('a locked journal shows the unlock screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalProvider.overrideWith(
            (ref) async => throw const JournalKeyMissing(),
          ),
        ],
        child: const CairnApp(),
      ),
    );
    await settle(tester);
    expect(find.text('Unlock your journal'), findsOneWidget);
    expect(find.byKey(const Key('recovery-key')), findsOneWidget);
  });

  testWidgets('the shelf waits for both the list and the current notebook', (
    tester,
  ) async {
    late Notebook notebook;
    await tester.runAsync(() async {
      notebook = await journal.notebooks.create(
        title: 'Day hikes',
        year: 2026,
        cover: CoverCloth.forest,
      );
    });
    final never = StreamController<Notebook?>();
    addTearDown(never.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalProvider.overrideWith((ref) async => journal),
          notebooksProvider.overrideWith((ref) => Stream.value([notebook])),
          currentNotebookProvider.overrideWith((ref) => never.stream),
        ],
        child: const CairnApp(),
      ),
    );
    // The spinner never settles; pump a few frames instead.
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('start-first-notebook')), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('an error loading the shelf is shown, not hidden', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalProvider.overrideWith((ref) async => journal),
          notebooksProvider.overrideWith(
            (ref) => Stream.error(StateError('disk full')),
          ),
        ],
        child: const CairnApp(),
      ),
    );
    await settle(tester);
    expect(find.textContaining('disk full'), findsOneWidget);
  });
}
