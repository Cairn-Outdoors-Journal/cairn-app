import 'package:cairn/design/font_licences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every bundled font has its licence registered', () async {
    registerFontLicences();
    final packages = <String>{};
    await for (final entry in LicenseRegistry.licenses) {
      packages.addAll(entry.packages);
    }
    expect(
      packages,
      containsAll(['Newsreader', 'Schibsted Grotesk', 'Martian Mono']),
    );
  });
}
