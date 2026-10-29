import 'package:cairn/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime now;

  /// A container watching today, as a screen would. Dispose it before the
  /// test ends so its midnight timer is cancelled.
  ProviderContainer start() {
    final container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(() => now)],
    );
    container.listen(todayProvider, (_, _) {});
    return container;
  }

  /// The states an app passes through on its way to and from the background.
  void goTo(WidgetTester tester, List<AppLifecycleState> states) {
    for (final state in states) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
  }

  testWidgets('today moves on at midnight', (tester) async {
    now = DateTime(2026, 6, 5, 23, 59);
    final container = start();
    expect(container.read(todayProvider), DateTime(2026, 6, 5));

    now = DateTime(2026, 6, 6, 0, 0, 1);
    await tester.pump(const Duration(minutes: 2));
    expect(container.read(todayProvider), DateTime(2026, 6, 6));
    container.dispose();
  });

  testWidgets('today catches up when the app comes back', (tester) async {
    now = DateTime(2026, 6, 5, 21);
    final container = start();
    expect(container.read(todayProvider), DateTime(2026, 6, 5));

    // Put away overnight; the midnight timer may not run in the background.
    goTo(tester, [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]);
    now = DateTime(2026, 6, 6, 7);
    goTo(tester, [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]);
    expect(container.read(todayProvider), DateTime(2026, 6, 6));
    container.dispose();
  });
}
