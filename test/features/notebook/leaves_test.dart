import 'package:cairn/data/database/database.dart';
import 'package:cairn/features/notebook/notebook_providers.dart';
import 'package:flutter_test/flutter_test.dart';

JournalPage page(String id, String day) => JournalPage(
  id: id,
  hlc: 'h',
  deleted: false,
  notebookId: 'n1',
  day: day,
  createdAtMs: 0,
);

void main() {
  test('today comes last, unstored, after the days written', () {
    final leaves = leavesOf([
      page('a', '2026-06-03'),
      page('b', '2026-06-04'),
    ], '2026-06-05');
    expect(leaves.map((l) => l.key), [
      '2026-06-03#0',
      '2026-06-04#0',
      '2026-06-05#0',
    ]);
    expect(leaves.last.page, isNull);
  });

  test("today's stored page keeps the same key", () {
    final leaves = leavesOf([page('t', '2026-06-05')], '2026-06-05');
    expect(leaves.single.key, '2026-06-05#0');
    expect(leaves.single.page?.id, 't');
  });

  test("a day's continued pages count up", () {
    final leaves = leavesOf([
      page('a', '2026-06-05'),
      page('b', '2026-06-05'),
      page('c', '2026-06-06'),
    ], '2026-06-06');
    expect(leaves.map((l) => l.key), [
      '2026-06-05#0',
      '2026-06-05#1',
      '2026-06-06#0',
    ]);
  });

  test('today goes in date order if the clock went back', () {
    final leaves = leavesOf([page('a', '2026-06-09')], '2026-06-05');
    expect(leaves.first.day, '2026-06-05');
    expect(leaves.first.page, isNull);
  });
}
