import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Now", so screens that number days can be tested on a fixed date.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
