import 'dart:math' as math;
import 'dart:ui';

import 'package:cairn/design/tokens.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2 contrast ratio between two opaque colours.
double contrastRatio(Color a, Color b) {
  double channel(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);

  final la = luminance(a);
  final lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  const palettes = {
    'light': CairnColors.light,
    'night': CairnColors.night,
    'headlamp': CairnColors.headlamp,
  };

  for (final MapEntry(key: name, value: palette) in palettes.entries) {
    group('$name palette text is readable on paper (4.5:1)', () {
      final textColours = {
        'ink': palette.ink,
        'pencil': palette.pencil,
        'blazeText': palette.blazeText,
        'water': palette.water,
      };
      for (final MapEntry(key: role, value: colour) in textColours.entries) {
        test(role, () {
          expect(
            contrastRatio(colour, palette.paper),
            greaterThanOrEqualTo(4.5),
          );
        });
      }
    });
  }
}
