import 'package:drift/drift.dart';

import '../database/database.dart';
import '../sync/record_writer.dart';

// Deletes that reach other records. Run them inside a transaction.

/// Deletes a page, everything on it and the location points pinned to it.
Future<void> deletePageAndItems(RecordWriter writer, String pageId) async {
  final db = writer.db;
  final items = await (db.select(
    db.pageItems,
  )..where((i) => i.pageId.equals(pageId) & i.deleted.not())).get();
  for (final item in items) {
    await deletePageItem(writer, item);
  }
  final points = await (db.select(
    db.locationPoints,
  )..where((pt) => pt.pageId.equals(pageId) & pt.deleted.not())).get();
  for (final point in points) {
    await writer.delete(RecordType.locationPoint, db.locationPoints, point.id);
  }
  await writer.delete(RecordType.page, db.pages, pageId);
}

Future<void> deletePageItem(RecordWriter writer, PageItem item) async {
  final db = writer.db;
  await writer.delete(RecordType.pageItem, db.pageItems, item.id);
  if (item.mediaId != null) await releaseMedia(writer, item.mediaId!);
}

/// Deletes a pocket item and, while it is still waiting in the pocket, the
/// location point captured with it. Once laid out, the point belongs to the
/// page.
Future<void> deletePocketItem(RecordWriter writer, PocketItem item) async {
  final db = writer.db;
  await writer.delete(RecordType.pocketItem, db.pocketItems, item.id);
  if (item.placedItemId == null) {
    final points = await (db.select(
      db.locationPoints,
    )..where((pt) => pt.pocketItemId.equals(item.id) & pt.deleted.not())).get();
    for (final point in points) {
      await writer.delete(
        RecordType.locationPoint,
        db.locationPoints,
        point.id,
      );
    }
  }
  if (item.mediaId != null) await releaseMedia(writer, item.mediaId!);
}

/// Deletes a media record once no page item, and no item still waiting in
/// a pocket, uses it. Its file goes in [MediaStore.removeDeletedFiles].
Future<void> releaseMedia(RecordWriter writer, String mediaId) async {
  final db = writer.db;
  final onPage =
      await (db.select(db.pageItems)
            ..where((i) => i.mediaId.equals(mediaId) & i.deleted.not())
            ..limit(1))
          .get();
  final inPocket =
      await (db.select(db.pocketItems)
            ..where(
              (i) =>
                  i.mediaId.equals(mediaId) &
                  i.placedItemId.isNull() &
                  i.deleted.not(),
            )
            ..limit(1))
          .get();
  if (onPage.isEmpty && inPocket.isEmpty) {
    await writer.delete(RecordType.media, db.media, mediaId);
  }
}
