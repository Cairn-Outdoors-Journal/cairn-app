import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// A new record id: UUIDv7, so ids sort roughly by creation time
/// (specs/sync-format.md). They are only ever stored encrypted.
String newRecordId() => _uuid.v7();

/// A new device id: random, so it reveals nothing about the phone.
String newDeviceId() => _uuid.v4();
