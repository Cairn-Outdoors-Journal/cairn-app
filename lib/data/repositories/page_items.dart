import 'package:drift/drift.dart';

import '../database/database.dart';
import '../ids.dart';
import '../sync/record_writer.dart';
import 'cascade.dart';

/// Where a taped item sits on the page, in page points.
class Placement {
  const Placement(this.x, this.y, this.width, this.height, {this.rotation = 0});

  final double x;
  final double y;
  final double width;
  final double height;

  /// Radians, clockwise.
  final double rotation;
}

class PageItemRepository {
  PageItemRepository(this._writer, this._removeDeletedMedia);

  final RecordWriter _writer;
  final Future<void> Function() _removeDeletedMedia;

  CairnDatabase get _db => _writer.db;

  Future<PageItem> addText({
    required String pageId,
    required String body,
    String? section,
  }) => _add(
    pageId: pageId,
    kind: PageItemKind.text,
    body: body,
    section: section,
  );

  Future<PageItem> addPhoto({
    required String pageId,
    required String mediaId,
    required Placement placement,
    String? style,
  }) => _add(
    pageId: pageId,
    kind: PageItemKind.photo,
    mediaId: mediaId,
    placement: placement,
    style: style,
  );

  Future<PageItem> addSketch({
    required String pageId,
    required String strokes,
    required Placement placement,
  }) => _add(
    pageId: pageId,
    kind: PageItemKind.sketch,
    body: strokes,
    placement: placement,
  );

  /// Saves edits made with `copyWith`: new text, a moved or tilted photo.
  Future<PageItem> update(PageItem item) => _writer.save(
    RecordType.pageItem,
    _db.pageItems,
    (hlc) => item.copyWith(hlc: hlc),
  );

  Future<PageItem?> find(String id) => (_db.select(
    _db.pageItems,
  )..where((i) => i.id.equals(id) & i.deleted.not())).getSingleOrNull();

  /// The page's items, bottom of the stack first.
  Stream<List<PageItem>> watchForPage(String pageId) =>
      (_db.select(_db.pageItems)
            ..where((i) => i.pageId.equals(pageId) & i.deleted.not())
            ..orderBy([
              (i) => OrderingTerm.asc(i.z),
              (i) => OrderingTerm.asc(i.createdAtMs),
            ]))
          .watch();

  /// Deletes the item, and its photo if nothing else uses it.
  Future<void> delete(String id) async {
    await _db.transaction(() async {
      final item = await find(id);
      if (item != null) await deletePageItem(_writer, item);
    });
    await _removeDeletedMedia();
  }

  Future<PageItem> _add({
    required String pageId,
    required PageItemKind kind,
    String? body,
    String? section,
    String? mediaId,
    Placement? placement,
    String? style,
  }) => _db.transaction(() async {
    // New taped items go on top of the stack.
    final top = _db.pageItems.z.max();
    final z =
        await (_db.selectOnly(_db.pageItems)
              ..addColumns([top])
              ..where(
                _db.pageItems.pageId.equals(pageId) &
                    _db.pageItems.deleted.not(),
              ))
            .map((row) => row.read(top))
            .getSingle();
    final id = newRecordId();
    return _writer.save(
      RecordType.pageItem,
      _db.pageItems,
      (hlc) => PageItem(
        id: id,
        hlc: hlc,
        deleted: false,
        pageId: pageId,
        kind: kind,
        section: section,
        body: body,
        mediaId: mediaId,
        x: placement?.x,
        y: placement?.y,
        width: placement?.width,
        height: placement?.height,
        rotation: placement?.rotation,
        style: style,
        z: (z ?? -1) + 1,
        createdAtMs: _writer.clock.nowMs(),
      ),
    );
  });
}
