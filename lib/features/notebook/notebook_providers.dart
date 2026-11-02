import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/journal.dart';
import '../../data/providers.dart';

/// A notebook's stored pages, in day order.
final notebookPagesProvider = StreamProvider.family<List<JournalPage>, String>(
  (ref, notebookId) async* {
    final Journal journal = await ref.watch(journalProvider.future);
    yield* journal.pages.watchForNotebook(notebookId);
  },
  retry: noRetry,
  isAutoDispose: true,
);

/// One page as the notebook turns them: a stored page, or today's page
/// before anything is written on it.
class Leaf {
  const Leaf(this.day, this.page, this.indexInDay);

  /// YYYY-MM-DD.
  final String day;

  /// Null for today's page while it isn't stored.
  final JournalPage? page;

  /// 0 for a day's first page, 1 for the page it continues on, and so on.
  final int indexInDay;

  /// Stays the same when today's page is first stored, so the page being
  /// written on keeps its state.
  String get key => '$day#$indexInDay';
}

/// The notebook's pages in order, with today's page in its place even when
/// nothing is written on it yet.
List<Leaf> leavesOf(List<JournalPage> pages, String today) {
  final leaves = <Leaf>[];
  var hasToday = false;
  String? day;
  var index = 0;
  for (final page in pages) {
    index = page.day == day ? index + 1 : 0;
    day = page.day;
    if (page.day == today) hasToday = true;
    leaves.add(Leaf(page.day, page, index));
  }
  if (!hasToday) {
    final at = leaves.indexWhere((l) => l.day.compareTo(today) > 0);
    leaves.insert(at < 0 ? leaves.length : at, Leaf(today, null, 0));
  }
  return leaves;
}
