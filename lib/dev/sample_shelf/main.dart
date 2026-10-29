// The app with the moodboard's notebooks on the shelf, for trying the shelf
// by hand (developer tool, separate from the app):
//   flutter run -t lib/dev/sample_shelf/main.dart
// Adds the notebooks only when the shelf is empty; it writes to the same
// journal as the app on that phone.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../data/database/database.dart';
import '../../data/days.dart';
import '../../data/journal.dart';
import '../../data/providers.dart';
import '../../design/font_licences.dart';
import '../../design/tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicences();
  final container = ProviderContainer();
  try {
    await addSampleShelf(await container.read(journalProvider.future));
  } on Object catch (error) {
    // A locked journal: the app shows the unlock screen instead.
    debugPrint('Sample shelf not added: $error');
  }
  runApp(
    UncontrolledProviderScope(container: container, child: const CairnApp()),
  );
}

/// The notebooks on the moodboard's Shelf board, with the PCT current.
Future<void> addSampleShelf(Journal journal) async {
  final notebooks = journal.notebooks;
  if ((await notebooks.watchAll().first).isNotEmpty) return;
  Future<Notebook> year(String title, int year, CoverCloth cover) =>
      notebooks.create(title: title, year: year, cover: cover);
  Future<Notebook> trip(
    String title,
    int year,
    CoverCloth cover,
    String trail,
    String startDay,
  ) => notebooks.create(
    kind: NotebookKind.trip,
    title: title,
    year: year,
    cover: cover,
    trail: trail,
    startDay: startDay,
  );

  await year('Day hikes', 2023, CoverCloth.slate);
  await trip(
    'Lost Coast',
    2023,
    CoverCloth.forest,
    'Lost Coast Trail',
    '2023-09-14',
  );
  await year('Day hikes', 2024, CoverCloth.ochre);
  await trip(
    'Wonderland Trail',
    2024,
    CoverCloth.rust,
    'Wonderland Trail',
    '2024-08-02',
  );
  await year('Day hikes', 2025, CoverCloth.waxedCanvas);
  await trip(
    'John Muir Trail',
    2025,
    CoverCloth.slate,
    'John Muir Trail',
    '2025-07-10',
  );
  final today = DateTime.now();
  final start = today.subtract(const Duration(days: 46));
  final pct = await notebooks.create(
    kind: NotebookKind.trip,
    title: 'PCT ${today.year}',
    year: today.year,
    cover: CoverCloth.forest,
    trail: 'Pacific Crest Trail',
    trailName: 'Switchback',
    startDay: dayKey(start),
  );
  await notebooks.markOpened(pct.id);
}
