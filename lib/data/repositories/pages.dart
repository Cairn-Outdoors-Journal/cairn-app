import 'package:drift/drift.dart';

import '../database/database.dart';
import '../ids.dart';
import '../sync/record_writer.dart';
import 'cascade.dart';

class PageRepository {
  PageRepository(this._writer, this._removeDeletedMedia);

  final RecordWriter _writer;
  final Future<void> Function() _removeDeletedMedia;

  CairnDatabase get _db => _writer.db;

  Future<JournalPage> create({
    required String notebookId,
    required String day,
    String? template,
  }) {
    final id = newRecordId();
    return _writer.save(
      RecordType.page,
      _db.pages,
      (hlc) => JournalPage(
        id: id,
        hlc: hlc,
        deleted: false,
        notebookId: notebookId,
        day: day,
        template: template,
        createdAtMs: _writer.clock.nowMs(),
      ),
    );
  }

  /// Saves edits made with `copyWith`, such as header fields.
  Future<JournalPage> update(JournalPage page) => _writer.save(
    RecordType.page,
    _db.pages,
    (hlc) => page.copyWith(hlc: hlc),
  );

  Future<JournalPage?> find(String id) => (_db.select(
    _db.pages,
  )..where((p) => p.id.equals(id) & p.deleted.not())).getSingleOrNull();

  /// The first page for [day] in the notebook, if there is one.
  Future<JournalPage?> forDay(String notebookId, String day) =>
      (_db.select(_db.pages)
            ..where(
              (p) =>
                  p.notebookId.equals(notebookId) &
                  p.day.equals(day) &
                  p.deleted.not(),
            )
            ..orderBy([(p) => OrderingTerm.asc(p.createdAtMs)])
            ..limit(1))
          .getSingleOrNull();

  /// The notebook's pages in day order.
  Stream<List<JournalPage>> watchForNotebook(String notebookId) =>
      (_db.select(_db.pages)
            ..where((p) => p.notebookId.equals(notebookId) & p.deleted.not())
            ..orderBy([
              (p) => OrderingTerm.asc(p.day),
              (p) => OrderingTerm.asc(p.createdAtMs),
            ]))
          .watch();

  /// Deletes the page, everything on it and the points pinned to it.
  Future<void> delete(String id) async {
    await _db.transaction(() => deletePageAndItems(_writer, id));
    await _removeDeletedMedia();
  }
}
