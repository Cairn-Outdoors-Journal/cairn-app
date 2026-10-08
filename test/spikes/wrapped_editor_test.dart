import 'dart:math' as math;

import 'package:cairn/spikes/page_composer/wrap_layout.dart';
import 'package:cairn/spikes/page_composer/wrapped_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _page = Size(320, 500);
final _photo = Exclusion.rotatedRect(
  center: const Offset(240, 90),
  size: const Size(130, 140),
  angle: 2.5 * math.pi / 180,
  margin: 10,
);

Future<WrappedEditorState> _pumpEditor(
  WidgetTester tester, {
  String text = '',
  List<String>? changes,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: Align(
          alignment: Alignment.topLeft,
          child: WrappedEditor(
            size: _page,
            style: const TextStyle(fontSize: 15, height: 1.5),
            exclusions: [_photo],
            initialText: text,
            onChanged: changes?.add,
          ),
        ),
      ),
    ),
  );
  return tester.state<WrappedEditorState>(find.byType(WrappedEditor));
}

void main() {
  testWidgets('tapping opens the keyboard and places the caret', (
    tester,
  ) async {
    await _pumpEditor(tester, text: 'Day 47');

    await tester.tapAt(const Offset(2, 5));
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.testTextInput.isVisible, isTrue);
    final sent = tester.testTextInput.editingState!;
    expect(sent['text'], 'Day 47');
    expect(sent['selectionBase'], 0);
  });

  testWidgets('typing from the keyboard updates the text', (tester) async {
    final changes = <String>[];
    final editor = await _pumpEditor(tester, changes: changes);
    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 400));

    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'Frost on the tent',
        selection: TextSelection.collapsed(offset: 17),
      ),
    );
    await tester.pump();

    expect(editor.value.text, 'Frost on the tent');
    expect(changes, ['Frost on the tent']);
  });

  testWidgets('no keystrokes are lost in a fast burst of edits', (
    tester,
  ) async {
    final editor = await _pumpEditor(tester);
    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 400));

    const typed =
        'Hops slipped at the Shadow Creek crossing and laughed about it for a '
        'mile. Reached camp with an hour of light. Banner Peak turned orange, '
        'and then all at once it did not. Mosquitoes at Shadow Lake. All of them. ';
    var text = '';
    for (final char in typed.split('')) {
      text += char;
      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        ),
      );
      // One frame per keystroke, as on a device.
      await tester.pump();
    }

    expect(editor.value.text, typed);
  });

  testWidgets('deleting a character re-flows the text', (tester) async {
    final editor = await _pumpEditor(tester, text: 'Garnet Lake outlet');
    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 400));

    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'Garnet Lake outle',
        selection: TextSelection.collapsed(offset: 17),
      ),
    );
    await tester.pump();

    expect(editor.value.text, 'Garnet Lake outle');
  });

  testWidgets('double-tap selects a word and tells the keyboard', (
    tester,
  ) async {
    await _pumpEditor(tester, text: 'Banner Peak');

    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 400));

    final sent = tester.testTextInput.editingState!;
    expect(sent['selectionBase'], 0);
    expect(sent['selectionExtent'], 6);
  });

  group('key presses', () {
    Future<WrappedEditorState> focused(WidgetTester tester, String text) async {
      final editor = await _pumpEditor(tester, text: text);
      // Tap far below the text: the caret goes to the end.
      await tester.tapAt(const Offset(10, 480));
      await tester.pump(const Duration(milliseconds: 400));
      return editor;
    }

    testWidgets('backspace deletes the character before the caret', (
      tester,
    ) async {
      final editor = await focused(tester, 'All of them.');

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      expect(editor.value.text, 'All of the');
      expect(tester.testTextInput.editingState!['text'], 'All of the');
    });

    testWidgets('backspace removes an emoji as one character', (tester) async {
      final editor = await focused(tester, 'Summit 🏔️');

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      expect(editor.value.text, 'Summit ');
    });

    testWidgets('arrows move the caret and shift-arrows select', (
      tester,
    ) async {
      final editor = await focused(tester, 'Hops');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(editor.value.selection, const TextSelection.collapsed(offset: 3));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(
        editor.value.selection,
        const TextSelection(baseOffset: 3, extentOffset: 2),
      );
    });

    testWidgets('backspace with a selection deletes the selection', (
      tester,
    ) async {
      final editor = await focused(tester, 'Banner Peak');

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      for (var i = 0; i < 4; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      }
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      expect(editor.value.text, 'Banner ');
    });

    testWidgets('enter starts a new line', (tester) async {
      final editor = await focused(tester, 'Day 47');

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(editor.value.text, 'Day 47\n');
    });
  });
}
