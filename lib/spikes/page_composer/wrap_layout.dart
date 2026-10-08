import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// A shape the writing has to flow around, in page coordinates.
///
/// Taped items are rotated rectangles, so an exclusion is a polygon rather
/// than a box.
class Exclusion {
  const Exclusion(this.polygon);

  /// A rectangle of [size] centred on [center], rotated by [angle] radians and
  /// grown by [margin] on every side.
  factory Exclusion.rotatedRect({
    required Offset center,
    required Size size,
    required double angle,
    double margin = 0,
  }) {
    final hw = size.width / 2 + margin;
    final hh = size.height / 2 + margin;
    final c = math.cos(angle);
    final s = math.sin(angle);
    Offset corner(double x, double y) =>
        center + Offset(x * c - y * s, x * s + y * c);
    return Exclusion([
      corner(-hw, -hh),
      corner(hw, -hh),
      corner(hw, hh),
      corner(-hw, hh),
    ]);
  }

  final List<Offset> polygon;

  /// The leftmost and rightmost points of the whole shape.
  ({double left, double right}) get horizontalBounds {
    var left = double.infinity;
    var right = double.negativeInfinity;
    for (final p in polygon) {
      left = math.min(left, p.dx);
      right = math.max(right, p.dx);
    }
    return (left: left, right: right);
  }

  /// The horizontal extent this shape covers between [top] and [bottom], or
  /// null if it doesn't reach that band.
  ({double left, double right})? extentInBand(double top, double bottom) {
    var points = _clip(polygon, (p) => p.dy >= top, (a, b) => _atY(a, b, top));
    points = _clip(points, (p) => p.dy <= bottom, (a, b) => _atY(a, b, bottom));
    if (points.isEmpty) return null;
    var left = double.infinity;
    var right = double.negativeInfinity;
    for (final p in points) {
      left = math.min(left, p.dx);
      right = math.max(right, p.dx);
    }
    return (left: left, right: right);
  }
}

/// One clipping step of Sutherland–Hodgman against a horizontal edge.
List<Offset> _clip(
  List<Offset> polygon,
  bool Function(Offset) inside,
  Offset Function(Offset, Offset) intersect,
) {
  final out = <Offset>[];
  for (var i = 0; i < polygon.length; i++) {
    final current = polygon[i];
    final previous = polygon[(i + polygon.length - 1) % polygon.length];
    final currentIn = inside(current);
    final previousIn = inside(previous);
    if (currentIn) {
      if (!previousIn) out.add(intersect(previous, current));
      out.add(current);
    } else if (previousIn) {
      out.add(intersect(previous, current));
    }
  }
  return out;
}

Offset _atY(Offset a, Offset b, double y) {
  final t = (y - a.dy) / (b.dy - a.dy);
  return Offset(a.dx + (b.dx - a.dx) * t, y);
}

/// The parts of the line band [top, bottom) that no exclusion covers, left to
/// right.
///
/// An item close to one edge of the page pushes text to its other side only,
/// the way a floated picture does in print: no words squeezed into the gap
/// between the item and the page edge, or into the sliver beside a tilted
/// corner. Text flows on both sides only of an item with at least
/// [minSideGap] free on each side.
List<({double left, double right})> freeSegments(
  double width,
  double top,
  double bottom,
  List<Exclusion> exclusions, {
  double minSideGap = 100,
}) {
  var segments = [(left: 0.0, right: width)];
  for (final exclusion in exclusions) {
    final inBand = exclusion.extentInBand(top, bottom);
    if (inBand == null) continue;
    final bounds = exclusion.horizontalBounds;
    final covered = (
      left: bounds.left < minSideGap ? 0.0 : inBand.left,
      right: width - bounds.right < minSideGap ? width : inBand.right,
    );
    final next = <({double left, double right})>[];
    for (final s in segments) {
      if (covered.right <= s.left || covered.left >= s.right) {
        next.add(s);
        continue;
      }
      if (covered.left > s.left) next.add((left: s.left, right: covered.left));
      if (covered.right < s.right) {
        next.add((left: covered.right, right: s.right));
      }
    }
    segments = next;
  }
  return segments;
}

/// A run of text placed on one line, inside one free segment.
class LineFragment {
  LineFragment({
    required this.start,
    required this.end,
    required this.endsWithNewline,
    required this.offset,
    required this.segmentRight,
    required this.lineIndex,
    required this.painter,
  });

  /// First character, inclusive.
  final int start;

  /// One past the last character. Includes the trailing newline if the line
  /// ended at one.
  final int end;

  final bool endsWithNewline;

  /// Top-left corner in page coordinates.
  final Offset offset;

  /// Right edge of the free segment this fragment was laid out in.
  final double segmentRight;

  /// Which line band (0 = top of the page) the fragment sits in.
  final int lineIndex;

  /// Paints the fragment's visible text (without the newline).
  final TextPainter painter;

  /// The last offset a caret can take inside this fragment.
  int get caretEnd => endsWithNewline ? end - 1 : end;

  /// Width of the drawn glyphs, ignoring trailing spaces.
  double get inkWidth {
    final lines = painter.computeLineMetrics();
    return lines.isEmpty ? 0 : lines.first.width;
  }
}

/// Text laid out line by line around [Exclusion]s on a fixed-size page.
///
/// Each line band is split into the segments the exclusions leave free, and
/// each segment takes as much text as fits. Text that doesn't fit on the page
/// is reported through [overflowed] rather than drawn.
class WrapLayout {
  WrapLayout._({
    required this.text,
    required this.fragments,
    required this.lineHeight,
    required this.overflowed,
  });

  factory WrapLayout.compute({
    required String text,
    required TextStyle style,
    required Size size,
    List<Exclusion> exclusions = const [],
    double minSegmentWidth = 48,
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    final strut = StrutStyle.fromTextStyle(style, forceStrutHeight: true);
    final lineHeight = _lineHeight(style, strut, textScaler);
    final fragments = <LineFragment>[];
    final length = text.length;
    var offset = 0;
    var line = 0;
    var placedAll = false;

    while (!placedAll) {
      final top = line * lineHeight;
      if (top + lineHeight > size.height + 1e-6) break;
      final segments = freeSegments(
        size.width,
        top,
        top + lineHeight,
        exclusions,
      ).where((s) => s.right - s.left >= minSegmentWidth);

      for (final segment in segments) {
        if (offset == length) {
          // An empty line is needed for the caret when the text is empty or
          // ends with a newline.
          final needsEmptyLine =
              fragments.isEmpty || fragments.last.endsWithNewline;
          if (needsEmptyLine) {
            fragments.add(
              _fragment(
                text: text,
                start: offset,
                end: offset,
                endsWithNewline: false,
                segment: segment,
                top: top,
                line: line,
                style: style,
                strut: strut,
                textScaler: textScaler,
              ),
            );
          }
          placedAll = true;
          break;
        }

        final (:end, :endsWithNewline) = _fitLine(
          text: text,
          start: offset,
          maxWidth: segment.right - segment.left,
          style: style,
          strut: strut,
          textScaler: textScaler,
        );
        fragments.add(
          _fragment(
            text: text,
            start: offset,
            end: end,
            endsWithNewline: endsWithNewline,
            segment: segment,
            top: top,
            line: line,
            style: style,
            strut: strut,
            textScaler: textScaler,
          ),
        );
        offset = end;
        if (endsWithNewline) break;
      }
      line++;
    }

    final overflowed =
        offset < length ||
        (offset == length &&
            (fragments.isEmpty || fragments.last.endsWithNewline) &&
            !placedAll);
    return WrapLayout._(
      text: text,
      fragments: fragments,
      lineHeight: lineHeight,
      overflowed: overflowed,
    );
  }

  final String text;
  final List<LineFragment> fragments;
  final double lineHeight;

  /// True if some text didn't fit on the page.
  final bool overflowed;

  int get lineCount => fragments.isEmpty
      ? 0
      : fragments.map((f) => f.lineIndex).reduce(math.max) + 1;

  /// The fragment a caret at [position] belongs to.
  LineFragment fragmentFor(int position) {
    for (final f in fragments) {
      if (f.start <= position && position < f.end) return f;
    }
    return fragments.last;
  }

  /// Where the caret for [position] is drawn, in page coordinates.
  Rect caretRect(int position, {double width = 2}) {
    final f = fragmentFor(position);
    final local = f.painter.getOffsetForCaret(
      TextPosition(offset: (position - f.start).clamp(0, f.caretEnd - f.start)),
      Rect.zero,
    );
    return Rect.fromLTWH(
      f.offset.dx + local.dx,
      f.offset.dy,
      width,
      lineHeight,
    );
  }

  /// The text offset closest to [point], in page coordinates.
  int offsetAt(Offset point) {
    if (fragments.isEmpty) return 0;
    final line = (point.dy / lineHeight).floor();
    final lastLine = fragments.last.lineIndex;
    if (line > lastLine) return text.length;

    var candidates = fragments.where((f) => f.lineIndex == line).toList();
    if (candidates.isEmpty) {
      // Nothing on this band (an item covers it): use the nearest line below,
      // or above if there is none.
      final below = fragments.where((f) => f.lineIndex > line);
      final nearest = below.isNotEmpty ? below.first.lineIndex : lastLine;
      candidates = fragments.where((f) => f.lineIndex == nearest).toList();
    }

    var chosen = candidates.first;
    for (final f in candidates) {
      chosen = f;
      if (point.dx <= f.segmentRight) break;
    }
    final local = chosen.painter.getPositionForOffset(point - chosen.offset);
    return (chosen.start + local.offset).clamp(chosen.start, chosen.caretEnd);
  }

  /// Rectangles covering [range], in page coordinates, one or more per line.
  List<Rect> rectsFor(TextRange range) {
    final rects = <Rect>[];
    for (final f in fragments) {
      final start = math.max(range.start, f.start);
      final end = math.min(range.end, f.caretEnd);
      if (start >= end) continue;
      final boxes = f.painter.getBoxesForSelection(
        TextSelection(baseOffset: start - f.start, extentOffset: end - f.start),
      );
      for (final box in boxes) {
        rects.add(
          Rect.fromLTRB(
            f.offset.dx + box.left,
            f.offset.dy,
            f.offset.dx + box.right,
            f.offset.dy + lineHeight,
          ),
        );
      }
    }
    return rects;
  }

  /// The word around [position], for double-tap selection.
  TextRange wordAt(int position) {
    final f = fragmentFor(position);
    final local = f.painter.getWordBoundary(
      TextPosition(offset: (position - f.start).clamp(0, f.caretEnd - f.start)),
    );
    return TextRange(start: f.start + local.start, end: f.start + local.end);
  }

  void dispose() {
    for (final f in fragments) {
      f.painter.dispose();
    }
  }
}

double _lineHeight(TextStyle style, StrutStyle strut, TextScaler textScaler) {
  final probe = TextPainter(
    text: TextSpan(text: 'Mg', style: style),
    textDirection: TextDirection.ltr,
    strutStyle: strut,
    textScaler: textScaler,
  )..layout();
  final height = probe.height;
  probe.dispose();
  return height;
}

/// How much text from [start] fits on one line [maxWidth] wide.
({int end, bool endsWithNewline}) _fitLine({
  required String text,
  required int start,
  required double maxWidth,
  required TextStyle style,
  required StrutStyle strut,
  required TextScaler textScaler,
}) {
  // Only measure a window: a phone-width line never holds more than a few
  // hundred characters, and shaping the whole remaining text on every line
  // would make layout quadratic.
  final windowEnd = math.min(text.length, start + 400);
  final newline = text.indexOf('\n', start);
  final hasNewline = newline != -1 && newline < windowEnd;
  final window = text.substring(start, hasNewline ? newline : windowEnd);

  final probe = TextPainter(
    text: TextSpan(text: window, style: style),
    textDirection: TextDirection.ltr,
    strutStyle: strut,
    textScaler: textScaler,
    maxLines: 1,
  )..layout(maxWidth: maxWidth);
  var lineEnd = probe.didExceedMaxLines
      ? probe.getLineBoundary(const TextPosition(offset: 0)).end
      : window.length;
  probe.dispose();

  // Spaces at a soft wrap stay on the line they end.
  while (lineEnd < window.length && window.codeUnitAt(lineEnd) == 0x20) {
    lineEnd++;
  }
  // Always make progress, even in a segment too narrow for one character.
  if (lineEnd == 0 && window.isNotEmpty) lineEnd = 1;

  var end = start + lineEnd;
  var endsWithNewline = false;
  if (hasNewline && end == newline) {
    end += 1;
    endsWithNewline = true;
  }
  return (end: end, endsWithNewline: endsWithNewline);
}

LineFragment _fragment({
  required String text,
  required int start,
  required int end,
  required bool endsWithNewline,
  required ({double left, double right}) segment,
  required double top,
  required int line,
  required TextStyle style,
  required StrutStyle strut,
  required TextScaler textScaler,
}) {
  final visible = text.substring(start, endsWithNewline ? end - 1 : end);
  final painter = TextPainter(
    text: TextSpan(text: visible, style: style),
    textDirection: TextDirection.ltr,
    strutStyle: strut,
    textScaler: textScaler,
  )..layout();
  return LineFragment(
    start: start,
    end: end,
    endsWithNewline: endsWithNewline,
    offset: Offset(segment.left, top),
    segmentRight: segment.right,
    lineIndex: line,
    painter: painter,
  );
}
