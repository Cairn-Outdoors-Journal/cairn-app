import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'wrap_layout.dart';

/// Numbers the spike shows on screen, to judge whether editing keeps up.
class EditorStats {
  const EditorStats({
    this.layoutMicros = 0,
    this.editToFrameMicros = 0,
    this.fragments = 0,
    this.lines = 0,
    this.characters = 0,
    this.overflowed = false,
  });

  /// Time to compute the last layout.
  final int layoutMicros;

  /// Time from the keyboard's last edit to the frame that showed it.
  final int editToFrameMicros;

  final int fragments;
  final int lines;
  final int characters;
  final bool overflowed;
}

/// An editable block of text that flows around [exclusions] while typing.
///
/// This connects to the platform keyboard directly (as a [TextInputClient])
/// and draws text with [WrapLayout], because Flutter's built-in text fields
/// can only lay text out in a plain rectangle.
class WrappedEditor extends StatefulWidget {
  const WrappedEditor({
    super.key,
    required this.size,
    required this.style,
    this.exclusions = const [],
    this.initialText = '',
    this.cursorColor = const Color(0xFFE2531B),
    this.selectionColor = const Color(0x332F6690),
    this.showDebug = false,
    this.stats,
    this.onChanged,
  });

  final Size size;
  final TextStyle style;
  final List<Exclusion> exclusions;
  final String initialText;
  final Color cursorColor;
  final Color selectionColor;

  /// Outlines the exclusions and the free segments of each line.
  final bool showDebug;

  final ValueNotifier<EditorStats>? stats;
  final ValueChanged<String>? onChanged;

  @override
  State<WrappedEditor> createState() => WrappedEditorState();
}

class WrappedEditorState extends State<WrappedEditor> with TextInputClient {
  late TextEditingValue _value = TextEditingValue(
    text: widget.initialText,
    selection: TextSelection.collapsed(offset: widget.initialText.length),
  );
  final FocusNode _focusNode = FocusNode(debugLabel: 'WrappedEditor');
  TextInputConnection? _connection;
  WrapLayout? _layout;
  bool _layoutDirty = true;
  int _lastLayoutMicros = 0;
  Timer? _blink;
  bool _caretOn = true;
  int? _dragBase;

  /// The current text and selection. Exposed for tests.
  TextEditingValue get value => _value;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(WrappedEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size ||
        oldWidget.style != widget.style ||
        oldWidget.exclusions != widget.exclusions) {
      _layoutDirty = true;
    }
  }

  @override
  void dispose() {
    _blink?.cancel();
    _connection?.close();
    _focusNode.dispose();
    _layout?.dispose();
    super.dispose();
  }

  WrapLayout get _currentLayout {
    if (_layoutDirty || _layout == null) {
      final stopwatch = Stopwatch()..start();
      final next = WrapLayout.compute(
        text: _value.text,
        style: widget.style,
        size: widget.size,
        exclusions: widget.exclusions,
        textScaler: MediaQuery.textScalerOf(context),
      );
      stopwatch.stop();
      _layout?.dispose();
      _layout = next;
      _layoutDirty = false;
      _lastLayoutMicros = stopwatch.elapsedMicroseconds;
    }
    return _layout!;
  }

  // Focus and the keyboard connection.

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _openConnection();
      _restartBlink();
    } else {
      _connection?.close();
      _connection = null;
      _blink?.cancel();
    }
    setState(() {});
  }

  void _openConnection() {
    if (_connection?.attached ?? false) {
      _connection!.show();
      return;
    }
    _connection =
        TextInput.attach(
            this,
            const TextInputConfiguration(
              inputType: TextInputType.multiline,
              inputAction: TextInputAction.newline,
              textCapitalization: TextCapitalization.sentences,
            ),
          )
          ..setEditingState(_value)
          ..show();
    _reportGeometryAfterFrame();
  }

  /// Tells the platform where the editor and caret are, so the keyboard's
  /// candidate bar and floating cursor line up with the text.
  void _reportGeometryAfterFrame() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final connection = _connection;
      final box = context.findRenderObject() as RenderBox?;
      if (!mounted ||
          connection == null ||
          !connection.attached ||
          box == null) {
        return;
      }
      connection
        ..setEditableSizeAndTransform(box.size, box.getTransformTo(null))
        ..setCaretRect(_currentLayout.caretRect(_value.selection.extentOffset));
    });
  }

  void _restartBlink() {
    _blink?.cancel();
    _caretOn = true;
    _blink = Timer.periodic(const Duration(milliseconds: 530), (_) {
      if (mounted) setState(() => _caretOn = !_caretOn);
    });
  }

  void _setValue(TextEditingValue next, {required bool fromPlatform}) {
    final textChanged = next.text != _value.text;
    setState(() {
      _value = next;
      if (textChanged) _layoutDirty = true;
    });
    if (!fromPlatform) {
      _log('editor -> IME', next);
      _connection?.setEditingState(next);
    }
    if (textChanged) widget.onChanged?.call(next.text);
    _restartBlink();
    _reportGeometryAfterFrame();
  }

  /// Logs every exchange with the keyboard. Used to find why deletes were
  /// lost on Android; off by default.
  static const _trace = false;

  void _log(String direction, TextEditingValue v) {
    if (!_trace) return;
    debugPrint(
      'SPIKE $direction len=${v.text.length} sel=${v.selection.baseOffset}-'
      '${v.selection.extentOffset} composing=${v.composing.start}-'
      '${v.composing.end} attached=${_connection?.attached}',
    );
  }

  // TextInputClient.

  @override
  TextEditingValue? get currentTextEditingValue => _value;

  @override
  AutofillScope? get currentAutofillScope => null;

  @override
  void updateEditingValue(TextEditingValue value) {
    _log('IME -> editor', value);
    if (value == _value) return;
    final editStarted = Stopwatch()..start();
    _setValue(value, fromPlatform: true);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      editStarted.stop();
      _publishStats(editToFrameMicros: editStarted.elapsedMicroseconds);
    });
  }

  @override
  void performAction(TextInputAction action) {
    // Newlines arrive as text for multiline input; other actions end editing.
    if (action != TextInputAction.newline) _focusNode.unfocus();
  }

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) =>
      _trace ? debugPrint('SPIKE privateCommand $action') : null;

  @override
  void performSelector(String selectorName) =>
      _trace ? debugPrint('SPIKE selector $selectorName') : null;

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void connectionClosed() {
    if (_trace) debugPrint('SPIKE connectionClosed');
    _connection = null;
    _focusNode.unfocus();
  }

  // Key presses.
  //
  // Some edits arrive as key presses rather than text changes: Android
  // keyboards send backspace as a DEL key, and hardware keyboards send arrows
  // and delete keys. Flutter's own text fields handle these in the framework,
  // so this editor has to as well.

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final key = event.logicalKey;
    if (_trace) debugPrint('SPIKE key ${key.keyLabel}');
    if (key == LogicalKeyboardKey.backspace) {
      _deleteBackward();
    } else if (key == LogicalKeyboardKey.delete) {
      _deleteForward();
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _moveCaret(_previousBoundary(_value.selection.extentOffset), shift);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _moveCaret(_nextBoundary(_value.selection.extentOffset), shift);
    } else if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown) {
      final layout = _currentLayout;
      final caret = layout.caretRect(_value.selection.extentOffset);
      final dy = key == LogicalKeyboardKey.arrowUp
          ? -layout.lineHeight
          : layout.lineHeight;
      _moveCaret(layout.offsetAt(caret.center + Offset(0, dy)), shift);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _replaceSelection('\n');
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  /// Offset of the user-perceived character boundary before [offset].
  int _previousBoundary(int offset) {
    if (offset <= 0) return 0;
    return _value.text
        .substring(0, offset)
        .characters
        .skipLast(1)
        .string
        .length;
  }

  /// Offset of the user-perceived character boundary after [offset].
  int _nextBoundary(int offset) {
    final text = _value.text;
    if (offset >= text.length) return text.length;
    return offset + text.substring(offset).characters.first.length;
  }

  void _moveCaret(int offset, bool extend) {
    final selection = extend
        ? TextSelection(
            baseOffset: _value.selection.baseOffset,
            extentOffset: offset,
          )
        : TextSelection.collapsed(offset: offset);
    _setValue(
      _value.copyWith(selection: selection, composing: TextRange.empty),
      fromPlatform: false,
    );
  }

  void _replaceSelection(String replacement) {
    final selection = _value.selection;
    if (!selection.isValid) return;
    final text =
        selection.textBefore(_value.text) +
        replacement +
        selection.textAfter(_value.text);
    _setValue(
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(
          offset: selection.start + replacement.length,
        ),
      ),
      fromPlatform: false,
    );
  }

  void _deleteBackward() {
    final selection = _value.selection;
    if (!selection.isValid) return;
    if (!selection.isCollapsed) return _replaceSelection('');
    final end = selection.extentOffset;
    final start = _previousBoundary(end);
    if (start == end) return;
    _deleteRange(start, end);
  }

  void _deleteForward() {
    final selection = _value.selection;
    if (!selection.isValid) return;
    if (!selection.isCollapsed) return _replaceSelection('');
    final start = selection.extentOffset;
    final end = _nextBoundary(start);
    if (start == end) return;
    _deleteRange(start, end);
  }

  void _deleteRange(int start, int end) {
    final text = _value.text;
    _setValue(
      TextEditingValue(
        text: text.substring(0, start) + text.substring(end),
        selection: TextSelection.collapsed(offset: start),
      ),
      fromPlatform: false,
    );
  }

  // Gestures.

  Offset _toPage(Offset local) => local;

  void _onTapUp(TapUpDetails details) {
    final position = _currentLayout.offsetAt(_toPage(details.localPosition));
    _focusNode.requestFocus();
    _setValue(
      _value.copyWith(
        selection: TextSelection.collapsed(offset: position),
        composing: TextRange.empty,
      ),
      fromPlatform: false,
    );
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final position = _currentLayout.offsetAt(_toPage(details.localPosition));
    final word = _currentLayout.wordAt(position);
    _focusNode.requestFocus();
    _setValue(
      _value.copyWith(
        selection: TextSelection(
          baseOffset: word.start,
          extentOffset: word.end,
        ),
        composing: TextRange.empty,
      ),
      fromPlatform: false,
    );
  }

  void _onDragStart(DragStartDetails details) {
    _dragBase = _currentLayout.offsetAt(_toPage(details.localPosition));
    _focusNode.requestFocus();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final base = _dragBase;
    if (base == null) return;
    final extent = _currentLayout.offsetAt(_toPage(details.localPosition));
    _setValue(
      _value.copyWith(
        selection: TextSelection(baseOffset: base, extentOffset: extent),
        composing: TextRange.empty,
      ),
      fromPlatform: false,
    );
  }

  void _publishStats({int? editToFrameMicros}) {
    final stats = widget.stats;
    final layout = _layout;
    if (stats == null || layout == null) return;
    stats.value = EditorStats(
      layoutMicros: _lastLayoutMicros,
      editToFrameMicros: editToFrameMicros ?? stats.value.editToFrameMicros,
      fragments: layout.fragments.length,
      lines: layout.lineCount,
      characters: _value.text.length,
      overflowed: layout.overflowed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = _currentLayout;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _publishStats();
    });
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKeyEvent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: _onTapUp,
        onDoubleTapDown: _onDoubleTapDown,
        onPanStart: _onDragStart,
        onPanUpdate: _onDragUpdate,
        onPanEnd: (_) => _dragBase = null,
        child: CustomPaint(
          size: widget.size,
          painter: _EditorPainter(
            layout: layout,
            value: _value,
            focused: _focusNode.hasFocus,
            caretOn: _caretOn,
            cursorColor: widget.cursorColor,
            selectionColor: widget.selectionColor,
            exclusions: widget.exclusions,
            showDebug: widget.showDebug,
            pageWidth: widget.size.width,
          ),
        ),
      ),
    );
  }
}

class _EditorPainter extends CustomPainter {
  _EditorPainter({
    required this.layout,
    required this.value,
    required this.focused,
    required this.caretOn,
    required this.cursorColor,
    required this.selectionColor,
    required this.exclusions,
    required this.showDebug,
    required this.pageWidth,
  });

  final WrapLayout layout;
  final TextEditingValue value;
  final bool focused;
  final bool caretOn;
  final Color cursorColor;
  final Color selectionColor;
  final List<Exclusion> exclusions;
  final bool showDebug;
  final double pageWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (showDebug) _paintDebug(canvas);

    final selection = value.selection;
    if (focused && selection.isValid && !selection.isCollapsed) {
      final paint = Paint()..color = selectionColor;
      for (final r in layout.rectsFor(selection)) {
        canvas.drawRect(r, paint);
      }
    }

    for (final f in layout.fragments) {
      f.painter.paint(canvas, f.offset);
    }

    final composing = value.composing;
    if (composing.isValid && !composing.isCollapsed) {
      final paint = Paint()
        ..color = cursorColor
        ..strokeWidth = 1.5;
      for (final r in layout.rectsFor(composing)) {
        final y = r.bottom - 3;
        canvas.drawLine(Offset(r.left, y), Offset(r.right, y), paint);
      }
    }

    if (focused && caretOn && selection.isValid && selection.isCollapsed) {
      canvas.drawRect(
        layout.caretRect(selection.extentOffset),
        Paint()..color = cursorColor,
      );
    }
  }

  void _paintDebug(Canvas canvas) {
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x88E2531B);
    for (final e in exclusions) {
      canvas.drawPath(Path()..addPolygon(e.polygon, true), outline);
    }
    final band = Paint()..color = const Color(0x142F6690);
    for (var line = 0; line < layout.lineCount; line++) {
      final top = line * layout.lineHeight;
      for (final s in freeSegments(
        pageWidth,
        top,
        top + layout.lineHeight,
        exclusions,
      )) {
        canvas.drawRect(
          Rect.fromLTRB(s.left, top + 1, s.right, top + layout.lineHeight - 1),
          band,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_EditorPainter old) =>
      old.layout != layout ||
      old.value != value ||
      old.focused != focused ||
      old.caretOn != caretOn ||
      old.showDebug != showDebug ||
      old.exclusions != exclusions;
}
