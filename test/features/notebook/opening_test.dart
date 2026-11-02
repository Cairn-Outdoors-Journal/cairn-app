import 'package:cairn/app.dart';
import 'package:cairn/clock.dart';
import 'package:cairn/data/database/database.dart';
import 'package:cairn/data/journal.dart';
import 'package:cairn/data/providers.dart';
import 'package:cairn/design/tokens.dart';
import 'package:cairn/features/notebook/notebook_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../data/helpers.dart';
import '../../helpers/settle.dart';

void main() {
  late Journal journal;

  setUp(() async {
    journal = await memoryJournal();
    await journal.notebooks.create(
      kind: NotebookKind.trip,
      title: 'PCT 2026',
      year: 2026,
      cover: CoverCloth.forest,
      startDay: '2026-04-20',
    );
  });
  tearDown(() => journal.close());

  Future<void> showShelf(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalProvider.overrideWith((ref) async => journal),
          clockProvider.overrideWithValue(() => DateTime(2026, 6, 5, 7)),
        ],
        child: const CairnApp(),
      ),
    );
    await settle(tester);
  }

  /// Taps the notebook and stops partway through the opening.
  Future<void> startOpening(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('current-notebook')));
    for (
      var i = 0;
      i < 10 && find.byType(NotebookScreen).evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 200));
  }

  Finder cover() => find.byKey(const Key('opening-cover'));

  testWidgets('opens in full once a day, quickly after that', (tester) async {
    await showShelf(tester);
    await startOpening(tester);
    expect(cover(), findsOneWidget);
    await settle(tester);
    expect(cover(), findsNothing);
    expect(find.text('DAY 47'), findsOneWidget);

    await tester.tap(find.text('Shelf'));
    await settle(tester);
    await startOpening(tester);
    expect(cover(), findsNothing);
    await settle(tester);
    expect(find.text('DAY 47'), findsOneWidget);
  });

  testWidgets('with reduce motion on, the page just appears', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await showShelf(tester);
    await startOpening(tester);
    expect(cover(), findsNothing);
    await settle(tester);
    expect(find.text('DAY 47'), findsOneWidget);
  });
}
