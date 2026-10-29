import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/tokens.dart';

/// What a notebook's cover is made of: one of the five cloths (ADR 0005),
/// or a colour the person picked, as 0xRRGGBB. The cloth is kept with a
/// custom colour so dropping the custom one goes back to it.
@immutable
class CoverChoice {
  const CoverChoice(this.cloth, [this.custom]);

  final CoverCloth cloth;
  final int? custom;

  Color get color => custom == null ? cloth.color : Color(0xFF000000 | custom!);

  @override
  bool operator ==(Object other) =>
      other is CoverChoice && other.cloth == cloth && other.custom == custom;

  @override
  int get hashCode => Object.hash(cloth, custom);
}

/// "#2F4A3A" for 0x2F4A3A.
String hexOf(int rgb) =>
    '#${(rgb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// 0xRRGGBB from "2F4A3A", "#2f4a3a" or the short "#abc"; null otherwise.
int? parseHexColor(String text) {
  var hex = text.trim();
  if (hex.startsWith('#')) hex = hex.substring(1);
  if (hex.length == 3) hex = hex.split('').map((c) => '$c$c').join();
  if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) return null;
  return int.parse(hex, radix: 16);
}

/// The five cloths as swatches, then a sixth for a custom colour.
class CoverPicker extends StatelessWidget {
  const CoverPicker({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final CoverChoice selected;
  final ValueChanged<CoverChoice> onSelected;

  static String label(CoverCloth cloth) => switch (cloth) {
    CoverCloth.waxedCanvas => 'Waxed canvas',
    CoverCloth.forest => 'Forest',
    CoverCloth.rust => 'Rust',
    CoverCloth.slate => 'Slate',
    CoverCloth.ochre => 'Ochre',
    CoverCloth.lake => 'Lake',
  };

  @override
  Widget build(BuildContext context) {
    final custom = selected.custom;
    // One row: the cloths and the custom swatch shrink on narrow phones
    // rather than wrap.
    return LayoutBuilder(
      builder: (context, constraints) {
        const count = 7;
        const gap = 12.0;
        final size = ((constraints.maxWidth - gap * (count - 1)) / count).clamp(
          28.0,
          40.0,
        );
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final cloth in CoverCloth.values)
              _Swatch(
                key: Key('cloth-${cloth.name}'),
                label: label(cloth),
                color: cloth.color,
                size: size,
                selected: custom == null && cloth == selected.cloth,
                onTap: () => onSelected(CoverChoice(cloth)),
              ),
            _Swatch(
              key: const Key('cloth-custom'),
              label: custom == null
                  ? 'Custom colour'
                  : 'Custom colour ${hexOf(custom)}',
              color: custom == null ? null : selected.color,
              size: size,
              selected: custom != null,
              onTap: () async {
                final picked = await showCustomColorDialog(
                  context,
                  selected.color,
                );
                if (picked != null) {
                  onSelected(CoverChoice(selected.cloth, picked));
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.label,
    required this.color,
    required this.size,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;

  /// Null draws the empty "pick a colour" swatch.
  final Color? color;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: selected
                  ? scheme.onSurface
                  : color == null
                  ? scheme.outline
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: color == null
              ? Icon(Icons.add, size: 20, color: scheme.onSurfaceVariant)
              : null,
        ),
      ),
    );
  }
}

/// A colour wheel, a brightness bar and a hex field for a custom cover
/// colour. Returns 0xRRGGBB, or null when cancelled.
Future<int?> showCustomColorDialog(BuildContext context, Color initial) =>
    showDialog<int>(
      context: context,
      builder: (context) => _CustomColorDialog(initial),
    );

class _CustomColorDialog extends StatefulWidget {
  const _CustomColorDialog(this.initial);

  final Color initial;

  @override
  State<_CustomColorDialog> createState() => _CustomColorDialogState();
}

class _CustomColorDialogState extends State<_CustomColorDialog> {
  late HSVColor _hsv;
  late final TextEditingController _hex;
  String? _hexError;

  int get _rgb => _hsv.toColor().toARGB32() & 0xFFFFFF;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initial);
    _hex = TextEditingController(text: hexOf(_rgb).substring(1));
  }

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  /// The wheel or the brightness bar moved: update the hex field too.
  void _picked(HSVColor hsv) {
    setState(() {
      _hsv = hsv;
      _hex.text = hexOf(_rgb).substring(1);
      _hexError = null;
    });
  }

  void _typedHex(String text) {
    final rgb = parseHexColor(text);
    setState(() {
      if (rgb == null) {
        _hexError = text.trim().length < 6 ? null : 'Use 6 hex digits';
        return;
      }
      final typed = HSVColor.fromColor(Color(0xFF000000 | rgb));
      // Greys have no hue; keep the wheel's so the marker doesn't jump.
      _hsv = typed.saturation == 0 ? typed.withHue(_hsv.hue) : typed;
      _hexError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // The wheel row is a fixed 240 wide (the dialog measures its content
      // before laying it out); the default 40 inset leaves only 232 on a
      // 360-wide phone.
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Text('Custom colour'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ColorWheel(
                  key: const Key('custom-wheel'),
                  hsv: _hsv,
                  onChanged: _picked,
                ),
                const SizedBox(width: 16),
                Container(
                  key: const Key('custom-preview'),
                  width: 40,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Color(0xFF000000 | _rgb),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(2),
                      right: Radius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _BrightnessBar(
              key: const Key('custom-brightness'),
              hsv: _hsv,
              onChanged: _picked,
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('custom-hex'),
              controller: _hex,
              onChanged: _typedHex,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F#]')),
                LengthLimitingTextInputFormatter(7),
              ],
              style: const TextStyle(fontFamily: CairnFonts.stamp),
              decoration: InputDecoration(
                labelText: 'Hex',
                prefixText: '#',
                errorText: _hexError,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _hexError == null
              ? () => Navigator.of(context).pop(_rgb)
              : null,
          child: const Text('Use colour'),
        ),
      ],
    );
  }
}

/// Hue around the wheel, saturation from the centre out. Tap or drag.
class _ColorWheel extends StatelessWidget {
  const _ColorWheel({required this.hsv, required this.onChanged, super.key});

  static const diameter = 184.0;

  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;

  void _pick(Offset position) {
    const radius = diameter / 2;
    final offset = position - const Offset(radius, radius);
    final hue = (offset.direction * 180 / math.pi + 360) % 360;
    final saturation = (offset.distance / radius).clamp(0.0, 1.0);
    onChanged(hsv.withHue(hue).withSaturation(saturation));
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Colour wheel',
    value:
        'hue ${hsv.hue.round()} degrees, '
        'saturation ${(hsv.saturation * 100).round()}%',
    child: GestureDetector(
      onPanDown: (d) => _pick(d.localPosition),
      onPanUpdate: (d) => _pick(d.localPosition),
      child: CustomPaint(
        size: const Size.square(diameter),
        painter: _WheelPainter(hsv),
      ),
    ),
  );
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter(this.hsv);

  final HSVColor hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final centre = Offset(radius, radius);
    final rect = Rect.fromCircle(center: centre, radius: radius);
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..shader = SweepGradient(
          colors: [
            for (var hue = 0; hue <= 360; hue += 60)
              HSVColor.fromAHSV(1, hue % 360, 1, 1).toColor(),
          ],
        ).createShader(rect),
    );
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [Colors.white, Color(0x00FFFFFF)],
        ).createShader(rect),
    );
    // Darken the whole wheel to the chosen brightness.
    canvas.drawCircle(
      centre,
      radius,
      Paint()..color = Colors.black.withValues(alpha: 1 - hsv.value),
    );

    final angle = hsv.hue * math.pi / 180;
    final marker =
        centre +
        Offset(math.cos(angle), math.sin(angle)) * (hsv.saturation * radius);
    canvas
      ..drawCircle(marker, 10, Paint()..color = hsv.toColor())
      ..drawCircle(
        marker,
        10,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.white,
      )
      ..drawCircle(
        marker,
        11.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.black.withValues(alpha: 0.4),
      );
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.hsv != hsv;
}

/// Brightness, from black to the wheel's colour at full brightness.
class _BrightnessBar extends StatelessWidget {
  const _BrightnessBar({required this.hsv, required this.onChanged, super.key});

  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;

  /// As wide as the wheel and preview above it. A fixed width, because the
  /// dialog measures its content before laying it out.
  static const width = _ColorWheel.diameter + 16 + 40;

  @override
  Widget build(BuildContext context) {
    // The thumb's radius at each end counts as fully dark or fully bright,
    // so both ends are easy to hit.
    void pick(Offset position) => onChanged(
      hsv.withValue(
        ((position.dx - _thumbRadius) / (width - 2 * _thumbRadius)).clamp(
          0.0,
          1.0,
        ),
      ),
    );
    return Semantics(
      label: 'Brightness',
      value: '${(hsv.value * 100).round()}%',
      child: GestureDetector(
        onPanDown: (d) => pick(d.localPosition),
        onPanUpdate: (d) => pick(d.localPosition),
        child: CustomPaint(
          size: const Size(width, 28),
          painter: _BrightnessPainter(hsv),
        ),
      ),
    );
  }
}

const _thumbRadius = 10.0;

class _BrightnessPainter extends CustomPainter {
  const _BrightnessPainter(this.hsv);

  final HSVColor hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 6, size.width, size.height - 12),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      track,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.black, hsv.withValue(1).toColor()],
        ).createShader(track.outerRect),
    );
    final thumb = Offset(
      _thumbRadius + hsv.value * (size.width - 2 * _thumbRadius),
      size.height / 2,
    );
    canvas
      ..drawCircle(thumb, 10, Paint()..color = hsv.toColor())
      ..drawCircle(
        thumb,
        10,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.white,
      )
      ..drawCircle(
        thumb,
        11.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.black.withValues(alpha: 0.4),
      );
  }

  @override
  bool shouldRepaint(_BrightnessPainter old) => old.hsv != hsv;
}
