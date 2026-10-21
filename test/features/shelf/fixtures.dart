import 'package:cairn/data/database/database.dart';
import 'package:cairn/design/tokens.dart';

/// A notebook for widget tests; the moodboard's PCT trip by default.
Notebook notebook({
  NotebookKind kind = NotebookKind.trip,
  String title = 'PCT 2026',
  String? trail = 'Pacific Crest Trail',
  String? trailName = 'Switchback',
  String? startDay = '2026-04-20',
}) => Notebook(
  id: 'n1',
  hlc: 'h',
  deleted: false,
  kind: kind,
  title: title,
  year: 2026,
  cover: CoverCloth.forest,
  trail: trail,
  trailName: trailName,
  startDay: startDay,
  createdAtMs: 0,
);
