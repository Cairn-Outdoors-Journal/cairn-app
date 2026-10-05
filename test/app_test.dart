import 'package:cairn/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app opens to the shelf', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CairnApp()));
    await tester.pumpAndSettle();

    expect(find.text('Shelf'), findsOneWidget);
  });
}
