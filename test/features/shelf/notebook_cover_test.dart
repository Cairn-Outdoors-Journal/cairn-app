import 'package:cairn/data/database/database.dart';
import 'package:cairn/design/theme.dart';
import 'package:cairn/design/tokens.dart';
import 'package:cairn/features/shelf/notebook_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Notebook notebook({
  NotebookKind kind = NotebookKind.trip,
  String title = 'PCT 2026',
  String? trail = 'Pacific Crest Trail',
  String? trailName = 'Switchback',
  String? startDay = '2026-04-20',
}) => Notebook(
  id: 'n1',
  hlc: 'h',
  deleted: false,
  kind: kind,
  title: title,
  year: 2026,
  cover: CoverCloth.forest,
  trail: trail,
  trailName: trailName,
  startDay: startDay,
  createdAtMs: 0,
);

Widget host(Widget child) => MaterialApp(
  theme: cairnTheme(CairnColors.light, Brightness.light),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('the large cover shows the trip as on the moodboard', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        NotebookCover(
          notebook: notebook(),
          size: CoverSize.large,
          today: DateTime(2026, 6, 5),
        ),
      ),
    );
    expect(find.text('PACIFIC CREST TRAIL'), findsOneWidget);
    expect(find.text('PCT 2026'), findsOneWidget);
    expect(find.text('“Switchback”'), findsOneWidget);
    expect(find.text('DAY 47'), findsOneWidget);
  });

  testWidgets('a yearly cover shows its year, and no empty trail lines', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        NotebookCover(
          notebook: notebook(
            kind: NotebookKind.year,
            title: 'Day hikes',
            trail: null,
            trailName: null,
            startDay: null,
          ),
          size: CoverSize.large,
        ),
      ),
    );
    expect(find.text('Day hikes'), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('small covers carry no text (ADR 0005)', (tester) async {
    await tester.pumpWidget(
      host(NotebookCover(notebook: notebook(), size: CoverSize.small)),
    );
    expect(find.byType(Text), findsNothing);
    expect(tester.getSize(find.byType(NotebookCover)), NotebookCover.smallSize);
  });

  test('a trip that has not started shows its start date', () {
    expect(coverStamp(notebook(), DateTime(2026, 4, 1)), 'STARTS 20 APR');
  });
}
