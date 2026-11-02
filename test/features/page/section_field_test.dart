import 'package:cairn/features/page/section_field.dart';
import 'package:cairn/features/page/templates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('templates are found by their stored key', () {
    for (final template in PageTemplate.values) {
      expect(PageTemplate.fromKey(template.key), template);
    }
    expect(PageTemplate.fromKey('gone'), PageTemplate.blank);
  });

  test('section keys are unique within a template', () {
    for (final template in PageTemplate.values) {
      final keys = template.sections.map((s) => s.key);
      expect(keys.toSet(), hasLength(keys.length));
    }
  });

  testWidgets('a field is announced by its section and reports writing', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    final changes = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const SectionHeading('High / Low'),
              SectionField(
                controller: controller,
                focusNode: focus,
                label: 'High',
                rowLabel: 'HIGH',
                onChanged: changes.add,
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('HIGH / LOW'), findsOneWidget);
    expect(find.text('HIGH'), findsOneWidget);

    final handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.byType(EditableText)),
      isSemantics(label: 'High', isTextField: true),
    );
    handle.dispose();

    await tester.enterText(find.byType(TextField), 'Sunrise over the Sierra');
    expect(changes.last, 'Sunrise over the Sierra');
  });
}
