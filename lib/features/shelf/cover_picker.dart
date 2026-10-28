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
  };

  @override
  Widget build(BuildContext context) {
    final custom = selected.custom;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final cloth in CoverCloth.values)
          _Swatch(
            key: Key('cloth-${cloth.name}'),
            label: label(cloth),
            color: cloth.color,
            selected: custom == null && cloth == selected.cloth,
            onTap: () => onSelected(CoverChoice(cloth)),
          ),
        _Swatch(
          key: const Key('cloth-custom'),
          label: custom == null
              ? 'Custom colour'
              : 'Custom colour ${hexOf(custom)}',
          color: custom == null ? null : selected.color,
          selected: custom != null,
          onTap: () async {
            final picked = await showCustomColorDialog(context, selected.color);
            if (picked != null) onSelected(CoverChoice(selected.cloth, picked));
          },
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;

  /// Null draws the empty "pick a colour" swatch.
  final Color? color;
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
          width: 40,
          height: 40,
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

/// RGB sliders and a hex field for a custom cover colour. Returns 0xRRGGBB,
/// or null when cancelled.
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
  late int _rgb;
  late final TextEditingController _hex;
  String? _hexError;

  int get _r => (_rgb >> 16) & 0xFF;
  int get _g => (_rgb >> 8) & 0xFF;
  int get _b => _rgb & 0xFF;

  @override
  void initState() {
    super.initState();
    _rgb = widget.initial.toARGB32() & 0xFFFFFF;
    _hex = TextEditingController(text: hexOf(_rgb).substring(1));
  }

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  /// A slider moved: update the colour and the hex field together.
  void _setChannel(int shift, double value) {
    setState(() {
      _rgb = (_rgb & ~(0xFF << shift)) | (value.round() << shift);
      _hex.text = hexOf(_rgb).substring(1);
      _hexError = null;
    });
  }

  void _typedHex(String text) {
    final rgb = parseHexColor(text);
    setState(() {
      if (rgb == null) {
        _hexError = text.trim().length < 6 ? null : 'Use 6 hex digits';
      } else {
        _rgb = rgb;
        _hexError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(0xFF000000 | _rgb);
    return AlertDialog(
      title: const Text('Custom colour'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: const Key('custom-preview'),
              width: 72,
              height: 97,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(2),
                  right: Radius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _ChannelSlider(
              label: 'R',
              value: _r,
              onChanged: (v) => _setChannel(16, v),
            ),
            _ChannelSlider(
              label: 'G',
              value: _g,
              onChanged: (v) => _setChannel(8, v),
            ),
            _ChannelSlider(
              label: 'B',
              value: _b,
              onChanged: (v) => _setChannel(0, v),
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

class _ChannelSlider extends StatelessWidget {
  const _ChannelSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 16,
        child: Text(
          label,
          style: const TextStyle(fontFamily: CairnFonts.stamp),
        ),
      ),
      Expanded(
        child: Slider(
          key: Key('custom-$label'),
          // The default unfilled track is nearly the paper colour; a rule
          // line shows how far each channel can go.
          inactiveColor: Theme.of(context).colorScheme.outline,
          value: value.toDouble(),
          max: 255,
          divisions: 255,
          label: '$value',
          onChanged: onChanged,
        ),
      ),
      SizedBox(
        width: 32,
        child: Text(
          '$value',
          textAlign: TextAlign.end,
          style: const TextStyle(fontFamily: CairnFonts.stamp, fontSize: 12),
        ),
      ),
    ],
  );
}
