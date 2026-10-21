import 'package:drift/drift.dart';

import '../../design/tokens.dart';
import '../database/database.dart';
import '../ids.dart';
import '../sync/record_writer.dart';
import 'cascade.dart';

class NotebookRepository {
  NotebookRepository(this._writer, this._removeDeletedMedia);

  final RecordWriter _writer;
  final Future<void> Function() _removeDeletedMedia;

  CairnDatabase get _db => _writer.db;

  /// A yearly notebook by default; trips add their trail, the hiker's
  /// trail name and the first day (YYYY-MM-DD).
  Future<Notebook> create({
    required String title,
    required int year,
    required CoverCloth cover,
    NotebookKind kind = NotebookKind.year,
    String? trail,
    String? trailName,
    String? startDay,
  }) {
    final id = newRecordId();
    return _writer.save(
      RecordType.notebook,
      _db.notebooks,
      (hlc) => Notebook(
        id: id,
        hlc: hlc,
        deleted: false,
        kind: kind,
        title: title,
        year: year,
        cover: cover,
        trail: trail,
        trailName: trailName,
        startDay: startDay,
        createdAtMs: _writer.clock.nowMs(),
      ),
    );
  }

  /// Saves edits made with `copyWith`: title, cover, trip details.
  Future<Notebook> update(Notebook notebook) => _writer.save(
    RecordType.notebook,
    _db.notebooks,
    (hlc) => notebook.copyWith(hlc: hlc),
  );

  Future<Notebook?> find(String id) => (_db.select(
    _db.notebooks,
  )..where((n) => n.id.equals(id) & n.deleted.not())).getSingleOrNull();

  /// The shelf: newest year first.
  Stream<List<Notebook>> watchAll() =>
      (_db.select(_db.notebooks)
            ..where((n) => n.deleted.not())
            ..orderBy([
              (n) => OrderingTerm.desc(n.year),
              (n) => OrderingTerm.desc(n.createdAtMs),
            ]))
          .watch();

  /// Deletes the notebook with its pages, their items, its pocket, the
  /// location points pinned to them and photos nothing else uses.
  Future<void> delete(String id) async {
    await _db.transaction(() async {
      final pages = await (_db.select(
        _db.pages,
      )..where((p) => p.notebookId.equals(id) & p.deleted.not())).get();
      for (final page in pages) {
        await deletePageAndItems(_writer, page.id);
      }
      final pocket = await (_db.select(
        _db.pocketItems,
      )..where((i) => i.notebookId.equals(id) & i.deleted.not())).get();
      for (final item in pocket) {
        await deletePocketItem(_writer, item);
      }
      await _writer.delete(RecordType.notebook, _db.notebooks, id);
    });
    await _removeDeletedMedia();
  }
}
