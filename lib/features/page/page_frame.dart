import 'dart:math';

import 'package:flutter/material.dart';

import '../../design/tokens.dart';

/// A page's size and margins, in page points (1/72 in).
///
/// Pages are fixed-size and paged, not scrolled: what's on screen is what
/// prints (CONCEPT). 6 × 11 in: close to a phone's shape below the top
/// bar, so the page fills the screen, and the same on every phone so a
/// page that's full on one is full on all.
abstract final class PaperPage {
  static const size = Size(432, 792);
  static const margin = EdgeInsets.fromLTRB(28, 22, 28, 26);
  static final contentWidth = size.width - margin.horizontal;
}

/// Text styles on the page, in page points. The sizes are the moodboard's
/// Day 47 page scaled from a 390-wide phone to the page.
abstract final class PageText {
  static TextStyle writing(ColorScheme palette) => TextStyle(
    fontFamily: CairnFonts.writing,
    fontSize: 18,
    height: 1.5,
    color: palette.onSurface,
  );

  static TextStyle sectionLabel(ColorScheme palette) => TextStyle(
    fontFamily: CairnFonts.label,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.7,
    color: palette.secondary,
  );

  static TextStyle stamp(ColorScheme palette, {double size = 12}) => TextStyle(
    fontFamily: CairnFonts.stamp,
    fontSize: size,
    color: palette.onSurface,
  );
}

/// Shows a page at its fixed size, scaled to fit the space it's given.
class PageFrame extends StatelessWidget {
  const PageFrame({required this.child, super.key});

  /// Laid out at [PaperPage.size].
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = PaperPage.size;
      final scale = min(
        constraints.maxWidth / size.width,
        constraints.maxHeight / size.height,
      );
      return SizedBox(
        width: size.width * scale,
        height: size.height * scale,
        child: FittedBox(
          child: SizedBox.fromSize(size: size, child: child),
        ),
      );
    },
  );
}
