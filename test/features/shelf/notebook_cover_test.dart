import 'package:cairn/data/database/database.dart';
import 'package:cairn/design/theme.dart';
import 'package:cairn/design/tokens.dart';
import 'package:cairn/features/shelf/notebook_cover.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/contrast.dart';
import 'fixtures.dart';

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

  test('a custom colour replaces the cloth', () {
    expect(coverColorOf(notebook()), CoverCloth.forest.color);
    expect(
      coverColorOf(notebook().copyWith(coverColor: const Value(0x8A3B6F))),
      const Color(0xFF8A3B6F),
    );
  });

  group('cover lettering', () {
    const ink = Color(0xFF1C1D1A);
    const paper = Color(0xFFF7F7F4);

    test('the cloths keep the lettering they were designed with', () {
      expect(coverLetterColor(CoverCloth.waxedCanvas.color), ink);
      expect(coverLetterColor(CoverCloth.ochre.color), ink);
      for (final cloth in [
        CoverCloth.forest,
        CoverCloth.rust,
        CoverCloth.slate,
        CoverCloth.lake,
      ]) {
        expect(coverLetterColor(cloth.color), paper, reason: cloth.name);
      }
    });

    test('any colour gets whichever lettering reads better', () {
      for (var hue = 0.0; hue < 360; hue += 15) {
        for (final saturation in [0.0, 0.4, 0.8, 1.0]) {
          for (final value in [0.2, 0.4, 0.6, 0.75, 0.9, 1.0]) {
            final cover = HSVColor.fromAHSV(
              1,
              hue,
              saturation,
              value,
            ).toColor();
            final chosen = coverLetterColor(cover);
            final other = chosen == ink ? paper : ink;
            expect(
              contrastRatio(chosen, cover),
              greaterThanOrEqualTo(contrastRatio(other, cover)),
              reason: '$cover',
            );
            // Black or white lettering always reaches at least 4.5:1 on one
            // side of the crossover; the better of ink and paper gets 3:1.
            expect(
              contrastRatio(chosen, cover),
              greaterThan(3),
              reason: '$cover',
            );
          }
        }
      }
    });

    test('the mid-tones from the review get dark lettering', () {
      for (final hex in [0xFFE07020, 0xFF3D8FC6, 0xFF4A9E5C]) {
        expect(coverLetterColor(Color(hex)), ink);
      }
    });
  });
}
