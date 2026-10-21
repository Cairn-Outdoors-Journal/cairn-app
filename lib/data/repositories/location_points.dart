import 'dart:math';

import 'package:drift/drift.dart';

import '../database/database.dart';
import '../ids.dart';
import '../sync/record_writer.dart';

/// A location reading from the phone, before it is saved.
class LocationFix {
  const LocationFix({
    required this.latitude,
    required this.longitude,
    required this.accuracyM,
    required this.recordedAtMs,
    this.altitudeM,
    this.pressureHpa,
  });

  final double latitude;
  final double longitude;
  final double accuracyM;
  final int recordedAtMs;
  final double? altitudeM;
  final double? pressureHpa;
}

class LocationPointRepository {
  LocationPointRepository(this._writer);

  /// App opens save a new point only after moving this far or waiting this
  /// long since the last point (ADR 0004).
  static const appOpenMinDistanceM = 50.0;
  static const appOpenMinInterval = Duration(minutes: 10);

  final RecordWriter _writer;

  CairnDatabase get _db => _writer.db;

  Future<LocationPoint> record(
    LocationFix fix, {
    required PointTrigger trigger,
    String? pageId,
    String? pocketItemId,
  }) {
    final id = newRecordId();
    return _writer.save(
      RecordType.locationPoint,
      _db.locationPoints,
      (hlc) => LocationPoint(
        id: id,
        hlc: hlc,
        deleted: false,
        recordedAtMs: fix.recordedAtMs,
        latitude: fix.latitude,
        longitude: fix.longitude,
        accuracyM: fix.accuracyM,
        altitudeM: fix.altitudeM,
        pressureHpa: fix.pressureHpa,
        trigger: trigger,
        pageId: pageId,
        pocketItemId: pocketItemId,
      ),
    );
  }

  /// Saves a point for an app open, unless it would duplicate the last
  /// point. Returns null when skipped.
  Future<LocationPoint?> recordAppOpen(LocationFix fix) =>
      _db.transaction(() async {
        final last = await latest();
        if (last != null) {
          final elapsed = fix.recordedAtMs - last.recordedAtMs;
          final moved = distanceM(
            last.latitude,
            last.longitude,
            fix.latitude,
            fix.longitude,
          );
          if (elapsed < appOpenMinInterval.inMilliseconds &&
              moved < appOpenMinDistanceM) {
            return null;
          }
        }
        return record(fix, trigger: PointTrigger.appOpen);
      });

  Future<LocationPoint?> latest() =>
      (_db.select(_db.locationPoints)
            ..where((pt) => pt.deleted.not())
            ..orderBy([(pt) => OrderingTerm.desc(pt.recordedAtMs)])
            ..limit(1))
          .getSingleOrNull();

  /// Points recorded from [fromMs] up to, not including, [toMs].
  Stream<List<LocationPoint>> watchBetween(int fromMs, int toMs) =>
      (_db.select(_db.locationPoints)
            ..where(
              (pt) =>
                  pt.recordedAtMs.isBiggerOrEqualValue(fromMs) &
                  pt.recordedAtMs.isSmallerThanValue(toMs) &
                  pt.deleted.not(),
            )
            ..orderBy([(pt) => OrderingTerm.asc(pt.recordedAtMs)]))
          .watch();

  Future<void> delete(String id) =>
      _writer.delete(RecordType.locationPoint, _db.locationPoints, id);
}

/// Great-circle distance in metres (haversine).
double distanceM(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusM = 6371000.0;
  double rad(double deg) => deg * pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final a =
      pow(sin(dLat / 2), 2) +
      cos(rad(lat1)) * cos(rad(lat2)) * pow(sin(dLon / 2), 2);
  return 2 * earthRadiusM * asin(sqrt(a));
}
