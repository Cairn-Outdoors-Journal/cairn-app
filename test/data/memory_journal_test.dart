import 'package:cairn/data/journal.dart';
import 'package:cairn/design/tokens.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late Journal journal;
  setUp(() async => journal = await memoryJournal());
  tearDown(() => journal.close());

  testWidgets(
    'an in-memory journal works inside a widget test (via runAsync)',
    (tester) async {
      final titles = await tester.runAsync(() async {
        await journal.notebooks.create(
          title: 'Day hikes',
          year: 2026,
          cover: CoverCloth.forest,
        );
        final shelf = await journal.notebooks.watchAll().first;
        return shelf.map((n) => n.title).toList();
      });
      expect(titles, ['Day hikes']);
    },
  );
}
