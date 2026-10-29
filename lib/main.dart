import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'design/font_licences.dart';

void main() {
  registerFontLicences();
  runApp(const ProviderScope(child: CairnApp()));
}
