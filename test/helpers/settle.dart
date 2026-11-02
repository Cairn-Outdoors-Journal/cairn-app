import 'package:flutter_test/flutter_test.dart';

/// Lets database work started by the UI finish, then redraws. Database
/// work runs on real timers, which the test's fake clock never advances.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }
}
