// A developer screen for the data layer, separate from the app:
//   flutter run -t lib/dev/data_inspector/main.dart
// Shows what is stored, checks the database file is encrypted on the device,
// and adds sample data.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/theme.dart';
import '../../design/tokens.dart';
import 'data_inspector_screen.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Cairn: data inspector',
        debugShowCheckedModeBanner: false,
        theme: cairnTheme(CairnColors.light, Brightness.light),
        home: const DataInspectorScreen(),
      ),
    ),
  );
}
