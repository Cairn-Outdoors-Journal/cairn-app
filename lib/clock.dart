import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Now", so screens that number days can be tested on a fixed date.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Today's date, kept current: it moves on at midnight and whenever the
/// app comes back from the background, so a trip's "Day N" (and, from 7b,
/// today's page) never shows yesterday.
final todayProvider = NotifierProvider<Today, DateTime>(Today.new);

class Today extends Notifier<DateTime> {
  Timer? _midnight;
  AppLifecycleListener? _lifecycle;

  @override
  DateTime build() {
    ref.watch(clockProvider);
    _lifecycle ??= AppLifecycleListener(onResume: _refresh);
    ref.onDispose(() {
      _midnight?.cancel();
      _lifecycle?.dispose();
      _lifecycle = null;
    });
    return _scheduleNext();
  }

  /// Today's date, with a timer set for the next midnight.
  DateTime _scheduleNext() {
    final now = ref.read(clockProvider)();
    _midnight?.cancel();
    // Built from the date parts, so daylight-saving days still end at
    // midnight.
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(tomorrow.difference(now), _refresh);
    return DateTime(now.year, now.month, now.day);
  }

  void _refresh() {
    final today = _scheduleNext();
    if (today != state) state = today;
  }
}
