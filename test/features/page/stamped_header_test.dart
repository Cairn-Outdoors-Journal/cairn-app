import 'package:cairn/data/database/database.dart';
import 'package:cairn/features/page/stamped_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../shelf/fixtures.dart';

void main() {
  Future<void> show(
    WidgetTester tester,
    Notebook notebook,
    String day, {
    bool continued = false,
  }) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StampedHeader(notebook: notebook, day: day, continued: continued),
      ),
    ),
  );

  testWidgets('a trip stamps its day number and the date', (tester) async {
    await show(tester, notebook(), '2026-06-05');
    expect(find.text('DAY 47'), findsOneWidget);
    expect(find.text('FRI 5 JUN 2026'), findsOneWidget);
  });

  testWidgets('a yearly notebook stamps the date alone', (tester) async {
    await show(
      tester,
      notebook(kind: NotebookKind.year, startDay: null),
      '2026-06-05',
    );
    expect(find.text('FRI 5 JUN 2026'), findsOneWidget);
    expect(find.textContaining('DAY'), findsNothing);
  });

  testWidgets('a day before the trip starts has no number', (tester) async {
    await show(tester, notebook(), '2026-04-19');
    expect(find.text('SUN 19 APR 2026'), findsOneWidget);
    expect(find.textContaining('DAY'), findsNothing);
  });

  testWidgets('a second page for the day says it continues', (tester) async {
    await show(tester, notebook(), '2026-06-05', continued: true);
    expect(find.text('FRI 5 JUN 2026 · CONTINUED'), findsOneWidget);
  });
}
