/// Calendar days as stored in the journal: YYYY-MM-DD in the hiker's local
/// time, compared as dates so time zones and daylight saving never shift
/// them.
library;

String dayKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

DateTime parseDayKey(String key) {
  final parts = key.split('-').map(int.parse).toList();
  return DateTime.utc(parts[0], parts[1], parts[2]);
}

/// The trip's day number on [today]: 1 on the start day. Zero or less
/// before the trip starts.
int dayOfTrip(String startDay, DateTime today) {
  final start = parseDayKey(startDay);
  final day = DateTime.utc(today.year, today.month, today.day);
  return day.difference(start).inDays + 1;
}
