import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/providers.dart';

/// Every notebook, newest year first.
final notebooksProvider = StreamProvider<List<Notebook>>((ref) async* {
  final journal = await ref.watch(journalProvider.future);
  yield* journal.notebooks.watchAll();
}, retry: noRetry);

/// The notebook shown large: opened last on this phone, else the newest.
final currentNotebookProvider = StreamProvider<Notebook?>((ref) async* {
  final journal = await ref.watch(journalProvider.future);
  yield* journal.notebooks.watchCurrent();
}, retry: noRetry);
