import 'dart:math' as math;

import 'package:cairn/spikes/page_composer/wrap_layout.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _style = TextStyle(fontSize: 15, height: 1.5);
const _page = Size(320, 600);

const _paragraph =
    'Left Reds Meadow before the store opened, five days of food in the pack. '
    'The climb out was dust and switchbacks, then the lakes: Rosalie, Shadow, '
    'Garnet, each a colder blue than the last. Hops slipped at the Shadow Creek '
    'crossing and laughed about it for a mile. Reached camp with an hour of '
    'light. Banner Peak turned orange, and then all at once it did not.';

final _photo = Exclusion.rotatedRect(
  center: const Offset(240, 90),
  size: const Size(130, 140),
  angle: 2.5 * math.pi / 180,
  margin: 10,
);

WrapLayout _layout(String text, {List<Exclusion>? exclusions, Size? size}) =>
    WrapLayout.compute(
      text: text,
      style: _style,
      size: size ?? _page,
      exclusions: exclusions ?? [_photo],
    );

void main() {
  group('Exclusion', () {
    test(
      'an unrotated rectangle covers its own width in a band it crosses',
      () {
        final e = Exclusion.rotatedRect(
          center: const Offset(100, 100),
          size: const Size(40, 20),
          angle: 0,
        );

        expect(e.extentInBand(95, 105), (left: 80.0, right: 120.0));
        expect(e.extentInBand(200, 220), isNull);
      },
    );

    test('margin grows the covered area on every side', () {
      final e = Exclusion.rotatedRect(
        center: const Offset(100, 100),
        size: const Size(40, 20),
        angle: 0,
        margin: 5,
      );

      expect(e.extentInBand(85, 86), (left: 75.0, right: 125.0));
    });

    test('a rotated rectangle covers more width than its unrotated self', () {
      final flat = Exclusion.rotatedRect(
        center: const Offset(100, 100),
        size: const Size(40, 40),
        angle: 0,
      );
      final tilted = Exclusion.rotatedRect(
        center: const Offset(100, 100),
        size: const Size(40, 40),
        angle: math.pi / 4,
      );

      final f = flat.extentInBand(99, 101)!;
      final t = tilted.extentInBand(99, 101)!;
      expect(t.right - t.left, greaterThan(f.right - f.left));
    });
  });

  group('freeSegments', () {
    test('splits a band around an exclusion in the middle', () {
      final e = Exclusion.rotatedRect(
        center: const Offset(160, 50),
        size: const Size(60, 40),
        angle: 0,
      );

      expect(freeSegments(320, 40, 60, [e]), [
        (left: 0.0, right: 130.0),
        (left: 190.0, right: 320.0),
      ]);
    });

    test('an item near the right edge pushes text to its left only', () {
      // Only the tilted top-left corner reaches this band, leaving a wide gap
      // to its right; text must still not go there.
      final top = _photo.horizontalBounds;
      final segments = freeSegments(320, 0, 24, [_photo]);

      expect(segments, hasLength(1));
      expect(segments.single.left, 0);
      expect(segments.single.right, lessThanOrEqualTo(top.right));
    });

    test('text flows on both sides of an item in the middle', () {
      final centred = Exclusion.rotatedRect(
        center: const Offset(250, 50),
        size: const Size(60, 40),
        angle: 0,
      );

      expect(freeSegments(500, 40, 60, [centred]), hasLength(2));
    });

    test('leaves bands the exclusion does not reach untouched', () {
      expect(freeSegments(320, 300, 320, [_photo]), [
        (left: 0.0, right: 320.0),
      ]);
    });
  });

  group('WrapLayout', () {
    test('places every character exactly once, in order', () {
      for (final width in [180.0, 260.0, 320.0]) {
        final layout = _layout(_paragraph, size: Size(width, 900));
        final placed = layout.fragments
            .map((f) => _paragraph.substring(f.start, f.end))
            .join();

        expect(placed, _paragraph, reason: 'width $width');
        expect(layout.overflowed, isFalse);
        layout.dispose();
      }
    });

    test('never draws text over an exclusion', () {
      final layout = _layout(_paragraph);

      for (final f in layout.fragments) {
        final top = f.lineIndex * layout.lineHeight;
        final covered = _photo.extentInBand(top, top + layout.lineHeight);
        final left = f.offset.dx;
        final right = f.offset.dx + f.inkWidth;
        expect(right, lessThanOrEqualTo(f.segmentRight + 0.5));
        if (covered != null && right > left) {
          final overlaps = left < covered.right && right > covered.left;
          expect(overlaps, isFalse, reason: 'fragment at line ${f.lineIndex}');
        }
      }
      layout.dispose();
    });

    test('lines beside the photo are narrower than lines below it', () {
      final layout = _layout(_paragraph);
      final besidePhoto = layout.fragments.firstWhere((f) => f.lineIndex == 2);
      final belowPhoto = layout.fragments.firstWhere(
        (f) => f.offset.dy > 200 && f.end < _paragraph.length,
      );

      expect(besidePhoto.segmentRight, lessThan(200));
      expect(belowPhoto.segmentRight, _page.width);
      layout.dispose();
    });

    test('a hard newline always starts a new line', () {
      final layout = _layout('Day 47\nThousand Island Lake', exclusions: []);

      expect(layout.fragments, hasLength(2));
      expect(layout.fragments[0].endsWithNewline, isTrue);
      expect(layout.fragments[1].lineIndex, 1);
      expect(layout.fragments[1].start, 7);
      layout.dispose();
    });

    test('a trailing newline leaves an empty line for the caret', () {
      final layout = _layout('High\n', exclusions: []);

      expect(layout.fragments, hasLength(2));
      expect(layout.fragments.last.start, 5);
      expect(layout.fragments.last.end, 5);
      expect(layout.caretRect(5).top, layout.lineHeight);
      layout.dispose();
    });

    test('empty text still has a line for the caret', () {
      final layout = _layout('');

      expect(layout.fragments, hasLength(1));
      expect(layout.caretRect(0).topLeft, Offset.zero);
      layout.dispose();
    });

    test('reports overflow when the page is full', () {
      final layout = _layout(_paragraph * 4, size: const Size(320, 200));

      expect(layout.overflowed, isTrue);
      layout.dispose();
    });

    test('tapping where the caret is drawn finds the same position', () {
      const text = 'Hops slipped at the Shadow Creek crossing.\nAll of them.';
      final layout = _layout(text);

      for (var p = 0; p <= text.length; p++) {
        final caret = layout.caretRect(p);
        expect(
          layout.offsetAt(caret.centerLeft + const Offset(0.5, 0)),
          p,
          reason: 'position $p',
        );
      }
      layout.dispose();
    });

    test('selection rectangles follow the text across a wrap', () {
      final layout = _layout(_paragraph);
      final rects = layout.rectsFor(const TextRange(start: 0, end: 120));
      final lines = rects.map((r) => r.top).toSet();

      expect(lines.length, greaterThan(1));
      layout.dispose();
    });

    test('lays out a full page quickly', () {
      final stopwatch = Stopwatch()..start();
      final layout = _layout(_paragraph * 3, size: const Size(320, 1200));
      stopwatch.stop();

      // Generous bound for slow CI machines; on a laptop this takes ~2 ms.
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
      layout.dispose();
    });
  });
}
