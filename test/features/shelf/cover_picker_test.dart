import 'package:cairn/design/theme.dart';
import 'package:cairn/design/tokens.dart';
import 'package:cairn/features/shelf/cover_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A picker whose choice the test can read back.
class _Host extends StatefulWidget {
  const _Host(this.initial);

  final CoverChoice initial;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late CoverChoice choice = widget.initial;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: CoverPicker(
        selected: choice,
        onSelected: (c) => setState(() => choice = c),
      ),
    ),
  );
}

Future<_HostState> _pump(WidgetTester tester, CoverChoice initial) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: cairnTheme(CairnColors.light, Brightness.light),
      home: _Host(initial),
    ),
  );
  return tester.state(find.byType(_Host));
}

void main() {
  test('hex reads with or without # and in short form', () {
    expect(parseHexColor('#2F4A3A'), 0x2F4A3A);
    expect(parseHexColor('2f4a3a'), 0x2F4A3A);
    expect(parseHexColor('#abc'), 0xAABBCC);
    expect(parseHexColor('#2F4A3'), isNull);
    expect(parseHexColor('zzzzzz'), isNull);
    expect(hexOf(0x0a0b0c), '#0A0B0C');
  });

  testWidgets('a typed hex colour becomes the cover colour', (tester) async {
    final host = await _pump(tester, const CoverChoice(CoverCloth.forest));
    await tester.tap(find.byKey(const Key('cloth-custom')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('custom-hex')), '8A3B6F');
    await tester.pump();
    final preview = tester.widget<Container>(
      find.byKey(const Key('custom-preview')),
    );
    expect(
      (preview.decoration! as BoxDecoration).color,
      const Color(0xFF8A3B6F),
    );
    await tester.tap(find.text('Use colour'));
    await tester.pumpAndSettle();
    expect(host.choice, const CoverChoice(CoverCloth.forest, 0x8A3B6F));
  });

  testWidgets('tapping the wheel picks hue and saturation', (tester) async {
    await _pump(tester, const CoverChoice(CoverCloth.forest, 0xFFFFFF));
    await tester.tap(find.byKey(const Key('cloth-custom')));
    await tester.pumpAndSettle();
    // The right-hand edge of the wheel is fully saturated red.
    final wheel = find.byKey(const Key('custom-wheel'));
    final centre = tester.getCenter(wheel);
    final radius = tester.getSize(wheel).width / 2;
    await tester.tapAt(centre + Offset(radius - 1, 0));
    await tester.pump();
    final hex = tester.widget<TextField>(find.byKey(const Key('custom-hex')));
    expect(hex.controller!.text, matches(RegExp(r'^FF0[0-9A-F]0[0-9A-F]$')));
  });

  testWidgets('the brightness bar darkens the colour', (tester) async {
    await _pump(tester, const CoverChoice(CoverCloth.forest, 0xFF0000));
    await tester.tap(find.byKey(const Key('cloth-custom')));
    await tester.pumpAndSettle();
    final bar = find.byKey(const Key('custom-brightness'));
    await tester.tapAt(
      tester.getTopLeft(bar) + Offset(1, tester.getSize(bar).height / 2),
    );
    await tester.pump();
    final hex = tester.widget<TextField>(find.byKey(const Key('custom-hex')));
    expect(hex.controller!.text, '000000');
  });

  testWidgets('a bad hex colour cannot be used', (tester) async {
    await _pump(tester, const CoverChoice(CoverCloth.forest));
    await tester.tap(find.byKey(const Key('cloth-custom')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('custom-hex')), '#12345G');
    await tester.pump();
    // The G is filtered out, leaving 5 digits: not yet a colour.
    await tester.enterText(find.byKey(const Key('custom-hex')), '1234567');
    await tester.pump();
    expect(find.text('Use 6 hex digits'), findsOneWidget);
    final use = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Use colour'),
    );
    expect(use.onPressed, isNull);
  });

  testWidgets('picking a cloth drops the custom colour', (tester) async {
    final host = await _pump(
      tester,
      const CoverChoice(CoverCloth.forest, 0x8A3B6F),
    );
    await tester.tap(find.byKey(const Key('cloth-rust')));
    await tester.pump();
    expect(host.choice, const CoverChoice(CoverCloth.rust));
  });

  testWidgets('six cloths and the custom swatch share one row', (tester) async {
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await _pump(tester, const CoverChoice(CoverCloth.lake));
    final first = tester.getTopLeft(find.byKey(const Key('cloth-waxedCanvas')));
    final custom = tester.getTopLeft(find.byKey(const Key('cloth-custom')));
    expect(custom.dy, first.dy);
    expect(find.bySemanticsLabel('Lake'), findsOneWidget);
  });

  testWidgets('a code typed one character at a time is only used once '
      'complete', (tester) async {
    final host = await _pump(tester, const CoverChoice(CoverCloth.forest));
    await tester.tap(find.byKey(const Key('cloth-custom')));
    await tester.pumpAndSettle();
    Color preview() =>
        (tester
                    .widget<Container>(find.byKey(const Key('custom-preview')))
                    .decoration!
                as BoxDecoration)
            .color!;
    TextButton use() => tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Use colour'),
    );
    final before = preview();

    final field = find.byKey(const Key('custom-hex'));
    await tester.enterText(field, '2E5');
    await tester.pump();
    expect(preview(), before, reason: 'no jump to #22EE55');
    await tester.enterText(field, '2E5A7');
    await tester.pump();
    expect(use().onPressed, isNull);
    await tester.enterText(field, '2E5A73');
    await tester.pump();
    expect(preview(), const Color(0xFF2E5A73));
    await tester.tap(find.text('Use colour'));
    await tester.pumpAndSettle();
    expect(host.choice, const CoverChoice(CoverCloth.forest, 0x2E5A73));
  });

  testWidgets('the short form counts when submitted', (tester) async {
    await _pump(tester, const CoverChoice(CoverCloth.forest));
    await tester.tap(find.byKey(const Key('cloth-custom')));
    await tester.pumpAndSettle();
    final field = find.byKey(const Key('custom-hex'));
    await tester.enterText(field, 'abc');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(tester.widget<TextField>(field).controller!.text, 'AABBCC');
  });
}
