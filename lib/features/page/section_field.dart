import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'page_frame.dart';

/// A section's label with a hairline running to the edge of the page
/// (moodboard, Day 47 page).
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(label.toUpperCase(), style: PageText.sectionLabel(palette)),
        const SizedBox(width: 8),
        Expanded(child: Divider(height: 1, color: palette.outline)),
      ],
    );
  }
}

/// Where the person writes: borderless, growing line by line, in the
/// writing face. Sections in a row put a short stamped label first.
class SectionField extends StatelessWidget {
  const SectionField({
    required this.controller,
    required this.focusNode,
    required this.label,
    this.rowLabel,
    this.inputFormatters,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// What a screen reader announces for the field.
  final String label;
  final String? rowLabel;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    final field = Semantics(
      label: label,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: PageText.writing(palette),
        cursorColor: palette.onSurface,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        decoration: const InputDecoration.collapsed(hintText: null),
      ),
    );
    final row = rowLabel;
    if (row == null) return field;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 46,
          child: Text(
            row,
            style: PageText.stamp(
              palette,
              size: 11,
            ).copyWith(color: palette.onSurfaceVariant),
          ),
        ),
        Expanded(child: field),
      ],
    );
  }
}
