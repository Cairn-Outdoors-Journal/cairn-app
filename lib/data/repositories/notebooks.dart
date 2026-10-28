import 'package:drift/drift.dart';

import '../../design/tokens.dart';
import '../database/database.dart';
import '../ids.dart';
import '../sync/record_writer.dart';
import 'cascade.dart';

class NotebookRepository {
  NotebookRepository(this._writer, this._removeDeletedMedia);

  /// The notebook opened last on this phone. Kept in `meta`, so it never
  /// syncs: each phone has its own current notebook.
  static const _currentKey = 'current_notebook_id';

  final RecordWriter _writer;
  final Future<void> Function() _removeDeletedMedia;

  CairnDatabase get _db => _writer.db;

  /// A yearly notebook by default; trips add their trail, the hiker's
  /// trail name and the first day (YYYY-MM-DD).
  Future<Notebook> create({
    required String title,
    required int year,
    required CoverCloth cover,
    int? coverColor,
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
        coverColor: coverColor,
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
              (n) => OrderingTerm.desc(n.id),
            ]))
          .watch();

  /// The notebook shown large on the shelf: the one opened last on this
  /// phone, or the newest one if that was deleted or none was opened yet.
  Stream<Notebook?> watchCurrent() => _db
      .customSelect(
        'SELECT * FROM notebooks WHERE deleted = 0 '
        'ORDER BY id = (SELECT value FROM meta WHERE key = ?) DESC, '
        // Ids are UUIDv7, so they break ties between notebooks created in
        // the same millisecond.
        'created_at_ms DESC, id DESC LIMIT 1',
        variables: [Variable.withString(_currentKey)],
        readsFrom: {_db.notebooks, _db.meta},
      )
      .watchSingleOrNull()
      .map((row) => row == null ? null : _db.notebooks.map(row.data));

  /// Makes [id] the current notebook on this phone. Not a journal change,
  /// so nothing is logged for sync.
  Future<void> markOpened(String id) => _db
      .into(_db.meta)
      .insertOnConflictUpdate(
        MetaCompanion.insert(key: _currentKey, value: id),
      );

  /// How many pages the notebook has, for the delete confirmation.
  Future<int> pageCount(String id) {
    final count = _db.pages.id.count();
    return (_db.selectOnly(_db.pages)
          ..addColumns([count])
          ..where(_db.pages.notebookId.equals(id) & _db.pages.deleted.not()))
        .map((row) => row.read(count)!)
        .getSingle();
  }

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
