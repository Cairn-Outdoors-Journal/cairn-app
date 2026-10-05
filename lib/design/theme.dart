import 'package:flutter/material.dart';

import 'tokens.dart';

/// Builds the app's [ThemeData] from a [CairnPalette].
///
/// Cairn draws most of its surfaces itself, so this only maps the palette onto
/// the Material roles that built-in widgets read (text, dividers, buttons).
ThemeData cairnTheme(CairnPalette palette, Brightness brightness) {
  final scheme = ColorScheme(
    brightness: brightness,
    primary: palette.ink,
    onPrimary: palette.paper,
    secondary: palette.contour,
    onSecondary: palette.paper,
    tertiary: palette.blaze,
    onTertiary: palette.paper,
    error: palette.blazeText,
    onError: palette.paper,
    surface: palette.paper,
    onSurface: palette.ink,
    onSurfaceVariant: palette.pencil,
    outline: palette.rule,
    outlineVariant: palette.rule,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.paper,
    dividerColor: palette.rule,
    splashFactory: NoSplash.splashFactory,
  );
}
