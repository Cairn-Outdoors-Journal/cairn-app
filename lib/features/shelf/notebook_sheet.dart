import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../data/database/database.dart';
import '../../data/days.dart';
import '../../design/tokens.dart';
import 'cover_picker.dart';

/// What the notebook sheet collects. The shelf saves it.
@immutable
class NotebookDraft {
  const NotebookDraft({
    required this.kind,
    required this.title,
    required this.year,
    required this.cover,
    this.coverColor,
    this.trail,
    this.trailName,
    this.startDay,
  });

  /// A new notebook: this year's "Day hikes".
  factory NotebookDraft.fresh(DateTime today) => NotebookDraft(
    kind: NotebookKind.year,
    title: defaultYearTitle,
    year: today.year,
    cover: CoverCloth.forest,
  );

  factory NotebookDraft.of(Notebook notebook) => NotebookDraft(
    kind: notebook.kind,
    title: notebook.title,
    year: notebook.year,
    cover: notebook.cover,
    coverColor: notebook.coverColor,
    trail: notebook.trail,
    trailName: notebook.trailName,
    startDay: notebook.startDay,
  );

  static const defaultYearTitle = 'Day hikes';

  final NotebookKind kind;
  final String title;
  final int year;
  final CoverCloth cover;

  /// A custom colour (0xRRGGBB) in place of [cover]'s cloth.
  final int? coverColor;
  final String? trail;
  final String? trailName;
  final String? startDay;

  /// [notebook] with this draft's details; trip fields are cleared for a
  /// yearly notebook.
  Notebook applyTo(Notebook notebook) => notebook.copyWith(
    kind: kind,
    title: title,
    year: year,
    cover: cover,
    coverColor: Value(coverColor),
    trail: Value(trail),
    trailName: Value(trailName),
    startDay: Value(startDay),
  );
}

/// Opens the sheet for a new notebook ([initial] null) or for editing one.
/// Returns null when dismissed.
Future<NotebookDraft?> showNotebookSheet(
  BuildContext context, {
  NotebookDraft? initial,
  DateTime? today,
}) {
  return showModalBottomSheet<NotebookDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) =>
        NotebookForm(initial: initial, today: today ?? DateTime.now()),
  );
}

class NotebookForm extends StatefulWidget {
  const NotebookForm({required this.today, this.initial, super.key});

  final NotebookDraft? initial;
  final DateTime today;

  @override
  State<NotebookForm> createState() => _NotebookFormState();
}

class _NotebookFormState extends State<NotebookForm> {
  late NotebookKind _kind;
  late int _year;
  late CoverChoice _cover;
  late final TextEditingController _title;
  late final TextEditingController _trail;
  late final TextEditingController _trailName;
  String? _startDay;
  String? _titleError;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final draft = widget.initial ?? NotebookDraft.fresh(widget.today);
    _kind = draft.kind;
    _year = draft.year;
    _cover = CoverChoice(draft.cover, draft.coverColor);
    _title = TextEditingController(text: draft.title);
    _trail = TextEditingController(text: draft.trail ?? '');
    _trailName = TextEditingController(text: draft.trailName ?? '');
    _startDay = draft.startDay;
  }

  @override
  void dispose() {
    _title.dispose();
    _trail.dispose();
    _trailName.dispose();
    super.dispose();
  }

  void _setKind(NotebookKind kind) {
    setState(() {
      _kind = kind;
      // Swap the suggested title rather than leave "Day hikes" on a trip.
      if (kind == NotebookKind.trip &&
          _title.text == NotebookDraft.defaultYearTitle) {
        _title.clear();
      } else if (kind == NotebookKind.year && _title.text.trim().isEmpty) {
        _title.text = NotebookDraft.defaultYearTitle;
      }
    });
  }

  Future<void> _pickStartDay() async {
    final today = widget.today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDay == null ? today : parseDayKey(_startDay!),
      firstDate: DateTime(1950),
      lastDate: DateTime(today.year + 2, 12, 31),
      helpText: 'First day of the trip',
    );
    if (picked != null) setState(() => _startDay = dayKey(picked));
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Give the notebook a name');
      return;
    }
    String? optional(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    final trip = _kind == NotebookKind.trip;
    final start = trip ? _startDay : null;
    Navigator.of(context).pop(
      NotebookDraft(
        kind: _kind,
        title: title,
        year: start != null
            ? parseDayKey(start).year
            : trip
            ? widget.today.year
            : _year,
        cover: _cover.cloth,
        coverColor: _cover.custom,
        trail: trip ? optional(_trail) : null,
        trailName: trip ? optional(_trailName) : null,
        startDay: start,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trip = _kind == NotebookKind.trip;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _editing ? 'Edit notebook' : 'New notebook',
              style: const TextStyle(
                fontFamily: CairnFonts.writing,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<NotebookKind>(
              segments: const [
                ButtonSegment(value: NotebookKind.trip, label: Text('Trip')),
                ButtonSegment(value: NotebookKind.year, label: Text('Year')),
              ],
              selected: {_kind},
              showSelectedIcon: false,
              onSelectionChanged: (selection) => _setKind(selection.single),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('notebook-title'),
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: trip ? 'PCT 2026' : null,
                errorText: _titleError,
              ),
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
            ),
            if (trip) ...[
              const SizedBox(height: 12),
              TextField(
                key: const Key('notebook-trail'),
                controller: _trail,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Trail or route',
                  hintText: 'Pacific Crest Trail',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('notebook-trail-name'),
                controller: _trailName,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Your trail name',
                  hintText: 'Optional',
                ),
              ),
              const SizedBox(height: 12),
              _Row(
                label: 'First day',
                child: TextButton(
                  key: const Key('notebook-start-day'),
                  onPressed: _pickStartDay,
                  child: Text(
                    _startDay == null ? 'Choose' : formatDayKey(_startDay!),
                    style: const TextStyle(fontFamily: CairnFonts.stamp),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              _Row(
                label: 'Year',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Earlier year',
                      onPressed: () => setState(() => _year--),
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '$_year',
                      key: const Key('notebook-year'),
                      style: const TextStyle(
                        fontFamily: CairnFonts.stamp,
                        fontSize: 15,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Later year',
                      onPressed: () => setState(() => _year++),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text('Cover', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            CoverPicker(
              selected: _cover,
              onSelected: (choice) => setState(() => _cover = choice),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(_editing ? 'Save changes' : 'Create notebook'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      ),
      child,
    ],
  );
}
