import 'package:cairn/features/page/page_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<Size> frameIn(WidgetTester tester, Size space) async {
    await tester.pumpWidget(
      Center(
        child: SizedBox.fromSize(
          size: space,
          child: const Align(
            alignment: Alignment.topLeft,
            child: PageFrame(child: SizedBox.expand(key: Key('page'))),
          ),
        ),
      ),
    );
    return tester.getSize(find.byType(PageFrame));
  }

  testWidgets('keeps the page shape, fitting the narrower side', (
    tester,
  ) async {
    // A phone: the width decides.
    expect(await frameIn(tester, const Size(360, 700)), const Size(360, 540));
    // A wide space: the height decides.
    expect(await frameIn(tester, const Size(600, 324)), const Size(216, 324));
  });

  testWidgets('lays the page out at its own size in page points', (
    tester,
  ) async {
    await frameIn(tester, const Size(360, 700));
    final page = tester.renderObject<RenderBox>(find.byKey(const Key('page')));
    expect(page.size, PaperPage.size);
  });
}
