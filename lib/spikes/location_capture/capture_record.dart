import 'dart:convert';

/// One attempt to save a location point, as logged by the native side.
class CaptureRecord {
  const CaptureRecord({
    required this.id,
    required this.platform,
    required this.source,
    required this.method,
    required this.permission,
    required this.appState,
    required this.result,
    required this.requestedAt,
    required this.latencyMs,
    this.precise,
    this.lat,
    this.lon,
    this.accuracyM,
    this.locationAgeMs,
    this.error,
  });

  factory CaptureRecord.fromJson(Map<String, Object?> json) => CaptureRecord(
    id: json['id'] as String? ?? '',
    platform: json['platform'] as String? ?? '?',
    source: json['source'] as String? ?? '?',
    method: json['method'] as String? ?? '?',
    permission: json['permission'] as String? ?? '?',
    appState: json['appState'] as String? ?? '?',
    result: json['result'] as String? ?? '?',
    requestedAt: DateTime.fromMillisecondsSinceEpoch(
      (json['requestedAt'] as num?)?.toInt() ?? 0,
    ),
    latencyMs: (json['latencyMs'] as num?)?.toInt() ?? 0,
    precise: json['precise'] as bool?,
    lat: (json['lat'] as num?)?.toDouble(),
    lon: (json['lon'] as num?)?.toDouble(),
    accuracyM: (json['accuracyM'] as num?)?.toDouble(),
    locationAgeMs: (json['locationAgeMs'] as num?)?.toInt(),
    error: json['error'] as String?,
  );

  final String id;
  final String platform;

  /// Where the capture came from: app, tile, widget, control, intent.
  final String source;

  /// How the fix was requested: direct, fgs (Android foreground service).
  final String method;

  /// always, whileInUse, denied (or notDetermined on iOS).
  final String permission;

  /// foreground or background when the capture started.
  final String appState;

  /// fix, lastKnown, timeout, noFix, denied, securityException, ...
  final String result;

  final DateTime requestedAt;
  final int latencyMs;
  final bool? precise;
  final double? lat;
  final double? lon;
  final double? accuracyM;
  final int? locationAgeMs;
  final String? error;

  bool get gotLocation => result == 'fix' || result == 'lastKnown';
}

/// Parses the native JSON-lines log, newest first. Bad lines are skipped.
List<CaptureRecord> parseCaptureLog(String log) {
  final records = <CaptureRecord>[];
  for (final line in const LineSplitter().convert(log)) {
    if (line.trim().isEmpty) continue;
    try {
      final decoded = jsonDecode(line);
      if (decoded is Map<String, Object?>) {
        records.add(CaptureRecord.fromJson(decoded));
      }
    } on FormatException {
      // A partly written line; the next read will have it.
    }
  }
  records.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  return records;
}
