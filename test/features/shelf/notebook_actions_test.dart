import 'package:cairn/design/theme.dart';
import 'package:cairn/design/tokens.dart';
import 'package:cairn/features/shelf/notebook_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

Future<T?> _run<T>(
  WidgetTester tester,
  Future<T?> Function(BuildContext) show,
) async {
  T? result;
  await tester.pumpWidget(
    MaterialApp(
      theme: cairnTheme(CairnColors.light, Brightness.light),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await show(context),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('the current notebook has no "Make current"', (tester) async {
    await _run(
      tester,
      (c) => showNotebookActions(c, notebook(), isCurrent: true),
    );
    expect(find.text('Change cover'), findsOneWidget);
    expect(find.text('Edit details'), findsOneWidget);
    expect(find.text('Make current'), findsNothing);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('choosing an action returns it', (tester) async {
    NotebookAction? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => picked = await showNotebookActions(
              context,
              notebook(),
              isCurrent: false,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Make current'));
    await tester.pumpAndSettle();
    expect(picked, NotebookAction.makeCurrent);
  });

  testWidgets('delete says how many pages go with the notebook', (
    tester,
  ) async {
    bool? confirmed;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => confirmed = await confirmDeleteNotebook(
              context,
              notebook(),
              pageCount: 12,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Delete “PCT 2026”?'), findsOneWidget);
    expect(find.textContaining('Its 12 pages'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(confirmed, isFalse);
  });
}
