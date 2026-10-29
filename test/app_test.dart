import 'package:cairn/app.dart';
import 'package:cairn/data/journal.dart';
import 'package:cairn/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'data/helpers.dart';

void main() {
  late Journal journal;
  setUp(() async => journal = await memoryJournal());
  tearDown(() => journal.close());

  testWidgets('app opens to the shelf', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [journalProvider.overrideWith((ref) async => journal)],
        child: const CairnApp(),
      ),
    );
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
    }

    expect(find.text('Shelf'), findsOneWidget);
  });
}
