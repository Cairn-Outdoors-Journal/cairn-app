import 'package:cairn/data/database/database.dart';
import 'package:cairn/design/theme.dart';
import 'package:cairn/design/tokens.dart';
import 'package:cairn/features/shelf/notebook_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens the sheet from a button and records what it returns.
class _Harness extends StatefulWidget {
  const _Harness({this.initial});

  final NotebookDraft? initial;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  NotebookDraft? result;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () async {
          result = await showNotebookSheet(
            context,
            initial: widget.initial,
            today: DateTime(2026, 6, 5),
          );
        },
        child: const Text('open'),
      ),
    ),
  );
}

Future<_HarnessState> _open(
  WidgetTester tester, {
  NotebookDraft? initial,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: cairnTheme(CairnColors.light, Brightness.light),
      home: _Harness(initial: initial),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return tester.state(find.byType(_Harness));
}

void main() {
  testWidgets('a new notebook defaults to this year\'s Day hikes', (
    tester,
  ) async {
    final harness = await _open(tester);
    expect(find.text('New notebook'), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
    await tester.tap(find.text('Create notebook'));
    await tester.pumpAndSettle();

    final draft = harness.result!;
    expect(draft.kind, NotebookKind.year);
    expect(draft.title, 'Day hikes');
    expect(draft.year, 2026);
    expect(draft.cover, CoverCloth.forest);
  });

  testWidgets('a trip takes its trail, trail name, first day and cloth', (
    tester,
  ) async {
    final harness = await _open(tester);
    await tester.tap(find.text('Trip'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('notebook-title')))
          .controller!
          .text,
      isEmpty,
    );
    await tester.enterText(find.byKey(const Key('notebook-title')), 'PCT 2026');
    await tester.enterText(
      find.byKey(const Key('notebook-trail')),
      'Pacific Crest Trail',
    );
    await tester.enterText(
      find.byKey(const Key('notebook-trail-name')),
      'Switchback',
    );
    await tester.tap(find.byKey(const Key('notebook-start-day')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cloth-rust')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create notebook'));
    await tester.tap(find.text('Create notebook'));
    await tester.pumpAndSettle();

    final draft = harness.result!;
    expect(draft.kind, NotebookKind.trip);
    expect(draft.title, 'PCT 2026');
    expect(draft.trail, 'Pacific Crest Trail');
    expect(draft.trailName, 'Switchback');
    expect(draft.startDay, '2026-06-05');
    expect(draft.year, 2026);
    expect(draft.cover, CoverCloth.rust);
  });

  testWidgets('a notebook needs a name', (tester) async {
    final harness = await _open(tester);
    await tester.enterText(find.byKey(const Key('notebook-title')), '   ');
    await tester.tap(find.text('Create notebook'));
    await tester.pumpAndSettle();
    expect(find.text('Give the notebook a name'), findsOneWidget);
    expect(harness.result, isNull);
  });

  testWidgets('editing starts from the notebook and keeps trip fields', (
    tester,
  ) async {
    final harness = await _open(
      tester,
      initial: const NotebookDraft(
        kind: NotebookKind.trip,
        title: 'JMT',
        year: 2025,
        cover: CoverCloth.slate,
        trail: 'John Muir Trail',
        startDay: '2025-07-01',
      ),
    );
    expect(find.text('Edit notebook'), findsOneWidget);
    expect(find.text('1 Jul 2025'), findsOneWidget);
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(harness.result!.trail, 'John Muir Trail');
    expect(harness.result!.year, 2025);
  });

  testWidgets('editing a trip with no first day keeps its year', (
    tester,
  ) async {
    // The harness opens the sheet with today in 2026.
    final harness = await _open(
      tester,
      initial: const NotebookDraft(
        kind: NotebookKind.trip,
        title: 'Wonderland',
        year: 2024,
        cover: CoverCloth.rust,
      ),
    );
    await tester.enterText(
      find.byKey(const Key('notebook-title')),
      'Wonderland Trail',
    );
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(harness.result!.year, 2024);
  });
}
