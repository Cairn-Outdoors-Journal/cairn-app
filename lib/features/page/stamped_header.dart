import 'package:flutter/material.dart';

import '../../data/database/database.dart';
import '../../data/days.dart';
import 'page_frame.dart';

/// The page's stamped header: the trip's day and the date, between a heavy
/// and a light ink rule (moodboard, Day 47 page).
///
/// Mile, weather, sun and camp rows join it in later stages, when there is
/// GPX, signal or a location to fill them from.
class StampedHeader extends StatelessWidget {
  const StampedHeader({
    required this.notebook,
    required this.day,
    this.continued = false,
    super.key,
  });

  final Notebook notebook;

  /// The page's day, YYYY-MM-DD.
  final String day;

  /// A second page for the same day.
  final bool continued;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    final number = tripDayNumber(notebook, day);
    final date = formatDayWithWeekday(day);
    final lead = number == null ? date.toUpperCase() : 'DAY $number';
    final trailing = [
      if (number != null) date.toUpperCase(),
      if (continued) 'CONTINUED',
    ].join(' · ');
    return Semantics(
      header: true,
      label: [
        if (number != null) 'Day $number',
        date,
        if (continued) 'continued',
      ].join(', '),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: palette.onSurface, width: 2),
            bottom: BorderSide(color: palette.onSurface),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              lead,
              style: PageText.stamp(
                palette,
                size: 24,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 12),
            // Long on a continued trip page; wraps rather than overflowing.
            Expanded(
              child: Text(
                trailing,
                textAlign: TextAlign.end,
                style: PageText.stamp(palette),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The trip's day number for [day], or null for a yearly notebook or a day
/// before the trip starts.
int? tripDayNumber(Notebook notebook, String day) {
  final start = notebook.startDay;
  if (notebook.kind != NotebookKind.trip || start == null) return null;
  final number = dayOfTrip(start, parseDayKey(day));
  return number >= 1 ? number : null;
}
