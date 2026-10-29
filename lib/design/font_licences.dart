import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Lists the bundled fonts on the app's licence page. All three are SIL OFL
/// 1.1, which asks for the licence to ship with the fonts.
void registerFontLicences() {
  const fonts = {
    'Newsreader': 'assets/fonts/newsreader/OFL.txt',
    'Schibsted Grotesk': 'assets/fonts/schibsted-grotesk/OFL.txt',
    'Martian Mono': 'assets/fonts/martian-mono/OFL.txt',
  };
  LicenseRegistry.addLicense(() async* {
    for (final MapEntry(key: name, value: path) in fonts.entries) {
      yield LicenseEntryWithLineBreaks([
        name,
      ], await rootBundle.loadString(path));
    }
  });
}
