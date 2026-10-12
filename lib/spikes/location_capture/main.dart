// Entry point for the stage 5b location spike, separate from the app:
//   flutter run -t lib/spikes/location_capture/main.dart
import 'package:flutter/material.dart';

import '../../design/theme.dart';
import '../../design/tokens.dart';
import 'location_spike_screen.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Cairn: location capture spike',
      debugShowCheckedModeBanner: false,
      theme: cairnTheme(CairnColors.light, Brightness.light),
      home: const LocationSpikeScreen(),
    ),
  );
}
