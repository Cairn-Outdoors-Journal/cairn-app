import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/database/database.dart';
import '../../data/days.dart';
import '../../data/journal.dart';
import '../../design/tokens.dart';
import '../page/stamped_header.dart';
import 'notebook_providers.dart';

/// The Days tab on the notebook's right edge (moodboard, Day 47 page). People
/// and Map join it in later stages.
class DaysTab extends StatelessWidget {
  const DaysTab({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Align(
        alignment: Alignment.topCenter,
        child: Semantics(
          button: true,
          label: 'Days: jump to a day',
          excludeSemantics: true,
          child: GestureDetector(
            key: const Key('days-tab'),
            onTap: onTap,
            child: Container(
              width: 30,
              height: 78,
              decoration: BoxDecoration(
                color: palette.surfaceContainerLowest,
                border: Border.all(color: palette.outline),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(4),
                ),
              ),
              alignment: Alignment.center,
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  'DAYS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    // Blaze text: the tab of the page you're on.
                    color: palette.error,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lists the notebook's days, newest first, and answers with the index of
/// the page to turn to.
Future<int?> showDaysSheet(
  BuildContext context, {
  required Journal journal,
  required Notebook notebook,
  required List<Leaf> leaves,
  required String today,
}) => showModalBottomSheet<int>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.6,
    maxChildSize: 0.92,
    builder: (context, scroll) {
      final firsts = [
        for (var i = leaves.length - 1; i >= 0; i--)
          if (leaves[i].indexInDay == 0) i,
      ];
      return ListView.separated(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: firsts.length + 1,
        separatorBuilder: (context, i) => i == 0
            ? const SizedBox.shrink()
            : Divider(height: 1, color: Theme.of(context).colorScheme.outline),
        itemBuilder: (context, i) {
          if (i == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Days',
                style: TextStyle(
                  fontFamily: CairnFonts.writing,
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          final index = firsts[i - 1];
          return _DayRow(
            journal: journal,
            notebook: notebook,
            leaf: leaves[index],
            isToday: leaves[index].day == today,
            onTap: () => Navigator.of(context).pop(index),
          );
        },
      );
    },
  ),
);

class _DayRow extends StatefulWidget {
  const _DayRow({
    required this.journal,
    required this.notebook,
    required this.leaf,
    required this.isToday,
    required this.onTap,
  });

  final Journal journal;
  final Notebook notebook;
  final Leaf leaf;
  final bool isToday;
  final VoidCallback onTap;

  @override
  State<_DayRow> createState() => _DayRowState();
}

class _DayRowState extends State<_DayRow> {
  /// The day's first written line, to tell days apart.
  String? _firstLine;
  StreamSubscription<List<PageItem>>? _items;

  @override
  void initState() {
    super.initState();
    final page = widget.leaf.page;
    if (page != null) {
      _items = widget.journal.items.watchForPage(page.id).listen((items) {
        final line = items
            .map((i) => (i.body ?? '').trim())
            .firstWhere((b) => b.isNotEmpty, orElse: () => '')
            .split('\n')
            .first;
        if (mounted) setState(() => _firstLine = line);
      });
    }
  }

  @override
  void dispose() {
    _items?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    final day = widget.leaf.day;
    final number = tripDayNumber(widget.notebook, day);
    final date = formatDayWithWeekday(day).toUpperCase();
    final line = _firstLine;
    return InkWell(
      key: Key('day-$day'),
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  number == null ? date : 'DAY $number',
                  style: const TextStyle(
                    fontFamily: CairnFonts.stamp,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (number != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    date,
                    style: TextStyle(
                      fontFamily: CairnFonts.stamp,
                      fontSize: 10,
                      color: palette.onSurfaceVariant,
                    ),
                  ),
                ],
                const Spacer(),
                if (widget.isToday)
                  Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      color: palette.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              line == null || line.isEmpty ? 'Nothing written yet' : line,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: CairnFonts.writing,
                fontSize: 15,
                color: line == null || line.isEmpty
                    ? palette.onSurfaceVariant
                    : palette.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
