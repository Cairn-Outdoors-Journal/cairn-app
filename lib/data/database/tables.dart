import 'package:drift/drift.dart';

import '../../design/tokens.dart';

/// The kinds of record that sync, as named in the change log.
enum RecordType { notebook, page, pageItem, pocketItem, locationPoint, media }

enum ChangeOp { upsert, delete }

/// A notebook for one trip, or for a year of shorter hikes.
enum NotebookKind { trip, year }

enum PageItemKind { text, photo, sketch }

enum PocketItemKind { text, voice, photo }

enum MediaKind { photo, sketch, voice, gpx }

/// What saved a location point (ADR 0004).
enum PointTrigger { appOpen, actionButton, widget, controlCenter, tile, pocket }

/// Columns every synced record has (specs/sync-format.md, "Records and
/// changes"). There are no foreign keys: packs from other devices can arrive
/// in any order, so the repositories keep references consistent instead.
mixin SyncedRecord on Table {
  /// UUIDv7, generated on the phone.
  TextColumn get id => text()();

  /// Hybrid logical clock stamp of the record's last change.
  TextColumn get hlc => text()();

  /// Deleted records stay as tombstones so the deletion can sync.
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('Notebook')
class Notebooks extends Table with SyncedRecord {
  /// Added in schema 2; notebooks from schema 1 become yearly notebooks.
  TextColumn get kind =>
      textEnum<NotebookKind>().withDefault(const Constant('year'))();

  TextColumn get title => text()();

  /// The year on the spine. One notebook per year is the default.
  IntColumn get year => integer()();

  TextColumn get cover => textEnum<CoverCloth>()();

  /// A colour the person picked instead of a cloth, as 0xRRGGBB (schema 3).
  /// Null shows [cover].
  IntColumn get coverColor => integer().nullable()();

  /// Trips only: the trail or route ("Pacific Crest Trail"), the hiker's
  /// trail name ("Switchback"), and the first day (YYYY-MM-DD), which
  /// numbers the days.
  TextColumn get trail => text().nullable()();
  TextColumn get trailName => text().nullable()();
  TextColumn get startDay => text().nullable()();

  IntColumn get createdAtMs => integer()();
}

/// One day's page. Named `JournalPage` in Dart, since Flutter has a `Page`.
@DataClassName('JournalPage')
@TableIndex(name: 'pages_by_notebook', columns: {#notebookId, #day})
class Pages extends Table with SyncedRecord {
  TextColumn get notebookId => text()();

  /// The calendar day, as YYYY-MM-DD in the hiker's local time.
  TextColumn get day => text()();

  /// The template the page was started from; null for a blank page.
  TextColumn get template => text().nullable()();

  /// Stamped header fields. Sun and moon times are computed, not stored.
  TextColumn get place => text().nullable()();
  RealColumn get elevationM => real().nullable()();

  /// Weather as JSON, filled in when there is signal.
  TextColumn get weather => text().nullable()();

  IntColumn get createdAtMs => integer()();
}

/// Writing, a taped photo or a sketch on a page.
@DataClassName('PageItem')
@TableIndex(name: 'page_items_by_page', columns: {#pageId})
class PageItems extends Table with SyncedRecord {
  TextColumn get pageId => text()();
  TextColumn get kind => textEnum<PageItemKind>()();

  /// The template section text belongs to; null for free writing.
  TextColumn get section => text().nullable()();

  /// The writing for text; stroke data as JSON for sketches.
  TextColumn get body => text().nullable()();

  TextColumn get mediaId => text().nullable()();

  /// Placement in page points for taped items; rotation in radians.
  RealColumn get x => real().nullable()();
  RealColumn get y => real().nullable()();
  RealColumn get width => real().nullable()();
  RealColumn get height => real().nullable()();
  RealColumn get rotation => real().nullable()();

  /// Print and tape style for photos.
  TextColumn get style => text().nullable()();

  /// Stacking order; higher is on top.
  IntColumn get z => integer().withDefault(const Constant(0))();

  IntColumn get createdAtMs => integer()();
}

/// A quick capture waiting in the notebook's back pocket.
@DataClassName('PocketItem')
@TableIndex(name: 'pocket_items_by_notebook', columns: {#notebookId})
class PocketItems extends Table with SyncedRecord {
  TextColumn get notebookId => text()();
  TextColumn get kind => textEnum<PocketItemKind>()();

  /// The text, or a voice note's transcript.
  TextColumn get body => text().nullable()();

  TextColumn get mediaId => text().nullable()();
  IntColumn get capturedAtMs => integer()();

  /// The page item it became when laid out; null while in the pocket.
  TextColumn get placedItemId => text().nullable()();
}

/// One location fix (ADR 0004): never continuous tracking.
@DataClassName('LocationPoint')
@TableIndex(name: 'location_points_by_time', columns: {#recordedAtMs})
class LocationPoints extends Table with SyncedRecord {
  IntColumn get recordedAtMs => integer()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get accuracyM => real()();
  RealColumn get altitudeM => real().nullable()();
  RealColumn get pressureHpa => real().nullable()();
  TextColumn get trigger => textEnum<PointTrigger>()();
  TextColumn get pageId => text().nullable()();
  TextColumn get pocketItemId => text().nullable()();
}

/// A photo, sketch, voice note or GPX file. The bytes live encrypted in the
/// media folder, named by id.
@DataClassName('MediaRecord')
class Media extends Table with SyncedRecord {
  TextColumn get kind => textEnum<MediaKind>()();
  TextColumn get mimeType => text()();

  /// Size of the original file, before encryption.
  IntColumn get byteSize => integer()();

  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get createdAtMs => integer()();
}

/// Settings for this device that never sync: device id, clock state.
@DataClassName('MetaEntry')
class Meta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Every change to a synced record, in the order it was made. Sync reads the
/// changes not yet packed and sends them (specs/sync-format.md).
@DataClassName('Change')
@TableIndex(name: 'changes_by_pack', columns: {#packSeq})
class Changes extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get recordType => textEnum<RecordType>()();
  TextColumn get recordId => text()();
  TextColumn get hlc => text()();
  TextColumn get op => textEnum<ChangeOp>()();

  /// The whole record as JSON for an upsert; null for a delete.
  TextColumn get payload => text().nullable()();

  /// The pack this change was sent in; null until it syncs.
  IntColumn get packSeq => integer().nullable()();
}
