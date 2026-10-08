// Entry point for the wrap-and-edit spike, separate from the app:
//   flutter run -t lib/spikes/page_composer/main.dart
import 'package:flutter/material.dart';

import '../../design/theme.dart';
import '../../design/tokens.dart';
import 'composer_spike_screen.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Cairn: wrap + edit spike',
      debugShowCheckedModeBanner: false,
      theme: cairnTheme(CairnColors.light, Brightness.light),
      home: const ComposerSpikeScreen(),
    ),
  );
}
