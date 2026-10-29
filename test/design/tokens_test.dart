import 'package:cairn/design/tokens.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/contrast.dart';

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
