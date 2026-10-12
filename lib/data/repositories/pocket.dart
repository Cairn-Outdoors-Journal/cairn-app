import 'package:drift/drift.dart';

import '../database/database.dart';
import '../ids.dart';
import '../sync/record_writer.dart';
import 'cascade.dart';
import 'page_items.dart';

/// The notebook's back pocket: quick captures waiting to be laid out.
class PocketRepository {
  PocketRepository(this._writer, this._items, this._removeDeletedMedia);

  final RecordWriter _writer;
  final PageItemRepository _items;
  final Future<void> Function() _removeDeletedMedia;

  CairnDatabase get _db => _writer.db;

  Future<PocketItem> add({
    required String notebookId,
    required PocketItemKind kind,
    String? body,
    String? mediaId,
  }) {
    final id = newRecordId();
    return _writer.save(
      RecordType.pocketItem,
      _db.pocketItems,
      (hlc) => PocketItem(
        id: id,
        hlc: hlc,
        deleted: false,
        notebookId: notebookId,
        kind: kind,
        body: body,
        mediaId: mediaId,
        capturedAtMs: _writer.clock.nowMs(),
      ),
    );
  }

  /// What's still in the pocket, oldest first.
  Stream<List<PocketItem>> watchWaiting(String notebookId) =>
      (_db.select(_db.pocketItems)
            ..where(
              (i) =>
                  i.notebookId.equals(notebookId) &
                  i.placedItemId.isNull() &
                  i.deleted.not(),
            )
            ..orderBy([(i) => OrderingTerm.asc(i.capturedAtMs)]))
          .watch();

  /// Lays the item out on a page: a photo is taped at [placement], text and
  /// voice transcripts become writing. The pocket item stays, linked to the
  /// page item, and the location point captured with it moves to the page.
  Future<PageItem> placeOnPage(
    PocketItem item, {
    required String pageId,
    required Placement placement,
  }) => _db.transaction(() async {
    final PageItem placed;
    switch (item.kind) {
      case PocketItemKind.photo:
        placed = await _items.addPhoto(
          pageId: pageId,
          mediaId: item.mediaId!,
          placement: placement,
        );
      case PocketItemKind.text:
      case PocketItemKind.voice:
        placed = await _items.addText(pageId: pageId, body: item.body ?? '');
    }
    await _writer.save(
      RecordType.pocketItem,
      _db.pocketItems,
      (hlc) => item.copyWith(hlc: hlc, placedItemId: Value(placed.id)),
    );
    final points = await (_db.select(
      _db.locationPoints,
    )..where((pt) => pt.pocketItemId.equals(item.id) & pt.deleted.not())).get();
    for (final point in points) {
      await _writer.save(
        RecordType.locationPoint,
        _db.locationPoints,
        (hlc) => point.copyWith(hlc: hlc, pageId: Value(pageId)),
      );
    }
    return placed;
  });

  /// Deletes the item, its point while it is still waiting, and its photo if
  /// nothing else uses it.
  Future<void> delete(String id) async {
    await _db.transaction(() async {
      final item = await (_db.select(
        _db.pocketItems,
      )..where((i) => i.id.equals(id) & i.deleted.not())).getSingleOrNull();
      if (item != null) await deletePocketItem(_writer, item);
    });
    await _removeDeletedMedia();
  }
}
