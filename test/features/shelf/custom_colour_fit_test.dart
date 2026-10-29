import 'package:cairn/design/theme.dart';
import 'package:cairn/design/tokens.dart';
import 'package:cairn/features/shelf/cover_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [320.0, 360.0, 412.0]) {
    testWidgets('the custom colour dialog fits a $width-wide phone', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width * 3, 800 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: cairnTheme(CairnColors.light, Brightness.light),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  showCustomColorDialog(context, CoverCloth.lake.color),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      // An overflow is reported as an exception during layout.
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('custom-wheel')), findsOneWidget);
    });
  }
}
