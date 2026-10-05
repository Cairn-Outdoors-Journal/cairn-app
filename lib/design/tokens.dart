import 'package:flutter/painting.dart';

/// Colour tokens from the product hub's ADR 0005 (visual identity).
///
/// The palette is borrowed from survey maps: ink for writing, contour brown
/// for routes and landforms, water blue, vegetation green, and blaze orange as
/// the single accent.
abstract final class CairnColors {
  static const light = CairnPalette(
    paper: Color(0xFFF7F7F4),
    ink: Color(0xFF1C1D1A),
    contour: Color(0xFF8A6A45),
    water: Color(0xFF2F6690),
    vegetation: Color(0xFF4F6B4A),
    blaze: Color(0xFFE2531B),
    blazeText: Color(0xFFB8430F),
    rule: Color(0xFFD9DAD3),
    pencil: Color(0xFF5E615A),
  );

  static const night = CairnPalette(
    paper: Color(0xFF11161A),
    ink: Color(0xFFE6E8E2),
    contour: Color(0xFFB58F63),
    water: Color(0xFF74AEDB),
    vegetation: Color(0xFF8DAA86),
    blaze: Color(0xFFFF7A3D),
    blazeText: Color(0xFFFF7A3D),
    rule: Color(0xFF343D44),
    pencil: Color(0xFF9AA19B),
  );

  /// Red on black for writing in the tent: protects night vision and battery.
  static const headlamp = CairnPalette(
    paper: Color(0xFF0A0606),
    ink: Color(0xFFE0503F),
    contour: Color(0xFFE0503F),
    water: Color(0xFFE0503F),
    vegetation: Color(0xFFE0503F),
    blaze: Color(0xFFE0503F),
    blazeText: Color(0xFFE0503F),
    rule: Color(0xFF4A1A14),
    pencil: Color(0xFFE0503F),
  );
}

/// One complete set of colours for a theme (light, night or headlamp).
class CairnPalette {
  const CairnPalette({
    required this.paper,
    required this.ink,
    required this.contour,
    required this.water,
    required this.vegetation,
    required this.blaze,
    required this.blazeText,
    required this.rule,
    required this.pencil,
  });

  /// The page.
  final Color paper;

  /// The user's writing and names.
  final Color ink;

  /// Routes, landforms and section labels.
  final Color contour;

  /// Lakes, rivers and springs.
  final Color water;

  /// Specimens and wildlife.
  final Color vegetation;

  /// The single accent: today's ribbon, summits, hazards. Fills only.
  final Color blaze;

  /// Blaze for text, darkened where needed to stay readable on [paper].
  final Color blazeText;

  /// Hairlines and form fields.
  final Color rule;

  /// Captions and secondary labels.
  final Color pencil;
}

/// The cloth colours a notebook cover can have. Covers can be changed at any
/// time.
enum CoverCloth {
  waxedCanvas(Color(0xFFB59A6E)),
  forest(Color(0xFF2F4A3A)),
  rust(Color(0xFFA2492B)),
  slate(Color(0xFF46525C)),
  ochre(Color(0xFFC49A2C));

  const CoverCloth(this.color);

  final Color color;
}
