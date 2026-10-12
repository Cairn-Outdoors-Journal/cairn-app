import 'dart:math';

import 'package:flutter/foundation.dart';

/// A hybrid logical clock stamp (specs/sync-format.md, "Records and
/// changes"): wall time, a counter for changes in the same millisecond, and
/// the device id to break ties. Ordering stays correct when phone clocks drift
/// during weeks offline.
@immutable
class Hlc implements Comparable<Hlc> {
  const Hlc(this.wallMs, this.counter, this.deviceId);

  const Hlc.zero(this.deviceId) : wallMs = 0, counter = 0;

  /// Reads a stamp written by [pack].
  factory Hlc.parse(String packed) {
    final match = _packed.firstMatch(packed);
    if (match == null) throw FormatException('Not an HLC stamp', packed);
    return Hlc(
      int.parse(match[1]!),
      int.parse(match[2]!, radix: 16),
      match[3]!,
    );
  }

  static final _packed = RegExp(r'^(\d{15})-([0-9a-f]{4})-(.+)$');

  /// The counter is packed as four hex digits.
  static const maxCounter = 0xffff;

  final int wallMs;
  final int counter;
  final String deviceId;

  /// The stamp for the next change made on this device.
  Hlc tick(int nowMs) {
    if (nowMs > wallMs) return Hlc(nowMs, 0, deviceId);
    return Hlc(wallMs, _next(counter), deviceId);
  }

  /// The stamp after receiving [remote] from another device, so later local
  /// changes sort after everything this device has seen.
  Hlc receive(Hlc remote, int nowMs) {
    final wall = max(nowMs, max(wallMs, remote.wallMs));
    final int count;
    if (wall == wallMs && wall == remote.wallMs) {
      count = _next(max(counter, remote.counter));
    } else if (wall == wallMs) {
      count = _next(counter);
    } else if (wall == remote.wallMs) {
      count = _next(remote.counter);
    } else {
      count = 0;
    }
    return Hlc(wall, count, deviceId);
  }

  static int _next(int counter) {
    if (counter >= maxCounter) {
      throw StateError(
        'HLC counter overflow: over $maxCounter changes in 1 ms',
      );
    }
    return counter + 1;
  }

  /// A string that sorts in the same order as [compareTo].
  String pack() =>
      '${wallMs.toString().padLeft(15, '0')}-'
      '${counter.toRadixString(16).padLeft(4, '0')}-'
      '$deviceId';

  @override
  int compareTo(Hlc other) {
    if (wallMs != other.wallMs) return wallMs.compareTo(other.wallMs);
    if (counter != other.counter) return counter.compareTo(other.counter);
    return deviceId.compareTo(other.deviceId);
  }

  @override
  bool operator ==(Object other) =>
      other is Hlc &&
      other.wallMs == wallMs &&
      other.counter == counter &&
      other.deviceId == deviceId;

  @override
  int get hashCode => Object.hash(wallMs, counter, deviceId);

  @override
  String toString() => pack();
}
