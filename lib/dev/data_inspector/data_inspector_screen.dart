import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/database/database.dart';
import '../../data/journal.dart';
import '../../data/keys/local_keys.dart';
import '../../data/providers.dart';
import '../../data/repositories/location_points.dart';
import '../../data/repositories/page_items.dart';
import '../../design/tokens.dart';

class DataInspectorScreen extends ConsumerStatefulWidget {
  const DataInspectorScreen({super.key});

  @override
  ConsumerState<DataInspectorScreen> createState() =>
      _DataInspectorScreenState();
}

class _DataInspectorScreenState extends ConsumerState<DataInspectorScreen> {
  _Snapshot? _snapshot;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final journal = ref.watch(journalProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Data inspector')),
      body: journal.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => error is JournalKeyMissing
            ? const _UnlockForm()
            : _Message('Could not open the journal: $error'),
        data: (journal) {
          if (_snapshot == null && _error == null) _refresh(journal);
          return _body(journal);
        },
      ),
    );
  }

  Widget _body(Journal journal) {
    final snapshot = _snapshot;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: () => _run(journal, _addSampleDay),
              child: const Text('Add sample day'),
            ),
            OutlinedButton(
              onPressed: () => _run(journal, _deleteNewestNotebook),
              child: const Text('Delete newest notebook'),
            ),
            OutlinedButton(
              onPressed: () => _refresh(journal),
              child: const Text('Refresh'),
            ),
            OutlinedButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Recovery key'),
                    content: SelectableText(
                      journal.recoveryKey(),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                );
              },
              child: const Text('Recovery key'),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        ],
        if (snapshot != null) ...[
          const SizedBox(height: 16),
          Text(snapshot.fileCheck, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final entry in snapshot.counts.entries)
            Text('${entry.key}: ${entry.value}'),
          const SizedBox(height: 16),
          Text('Latest changes', style: theme.textTheme.titleMedium),
          for (final change in snapshot.changes)
            Text(
              '#${change.seq} ${change.op.name} ${change.recordType.name} '
              '${change.recordId.substring(0, 8)}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
        ],
      ],
    );
  }

  Future<void> _run(
    Journal journal,
    Future<void> Function(Journal) action,
  ) async {
    try {
      await action(journal);
      setState(() => _error = null);
    } catch (error) {
      setState(() => _error = '$error');
    }
    await _refresh(journal);
  }

  Future<void> _refresh(Journal journal) async {
    final db = journal.database;
    Future<int> live(TableInfo<Table, Object?> table) async {
      final rows = await db
          .customSelect(
            'SELECT count(*) AS n FROM "${table.actualTableName}" '
            'WHERE deleted = 0',
          )
          .getSingle();
      return rows.read<int>('n');
    }

    final counts = {
      'Notebooks': await live(db.notebooks),
      'Pages': await live(db.pages),
      'Page items': await live(db.pageItems),
      'Pocket items': await live(db.pocketItems),
      'Location points': await live(db.locationPoints),
      'Media': await live(db.media),
      'Unsent changes': (await journal.unsentChanges()).length,
    };
    final changes =
        await (db.select(db.changes)
              ..orderBy([(c) => OrderingTerm.desc(c.seq)])
              ..limit(15))
            .get();
    final snapshot = _Snapshot(counts, changes, await _checkFile());
    if (mounted) setState(() => _snapshot = snapshot);
  }

  /// Reads the first bytes of the database file: a plain SQLite file starts
  /// with "SQLite format 3".
  Future<String> _checkFile() async {
    final support = await getApplicationSupportDirectory();
    final file = File(p.join(support.path, 'journal', 'journal.db'));
    if (!file.existsSync()) return 'journal.db: not created yet';
    final handle = await file.open();
    try {
      final head = latin1.decode(await handle.read(15));
      return head == 'SQLite format 3'
          ? 'journal.db: NOT ENCRYPTED'
          : 'journal.db: encrypted (${file.lengthSync()} bytes)';
    } finally {
      await handle.close();
    }
  }

  static Future<void> _addSampleDay(Journal journal) async {
    final notebooks = await journal.notebooks.watchAll().first;
    final now = DateTime.now();
    final notebook = notebooks.isNotEmpty
        ? notebooks.first
        : await journal.notebooks.create(
            title: 'Sample trip ${now.year}',
            year: now.year,
            cover: CoverCloth.forest,
          );
    final day =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final page =
        await journal.pages.forDay(notebook.id, day) ??
        await journal.pages.create(notebookId: notebook.id, day: day);
    await journal.items.addText(
      pageId: page.id,
      body: 'Sample entry written at ${now.toIso8601String()}',
    );
    final random = Random();
    final photo = await journal.media.put(
      Uint8List.fromList(List.generate(200000, (_) => random.nextInt(256))),
      kind: MediaKind.photo,
      mimeType: 'application/octet-stream',
    );
    await journal.items.addPhoto(
      pageId: page.id,
      mediaId: photo.id,
      placement: const Placement(40, 120, 160, 120, rotation: -0.04),
    );
    await journal.pocket.add(
      notebookId: notebook.id,
      kind: PocketItemKind.text,
      body: 'A thought for later',
    );
    await journal.points.record(
      LocationFix(
        latitude: 37.7225,
        longitude: -119.173,
        accuracyM: 5,
        recordedAtMs: now.millisecondsSinceEpoch,
      ),
      trigger: PointTrigger.appOpen,
      pageId: page.id,
    );
    // Reading the photo back checks decryption on this device.
    final back = await journal.media.read(photo.id);
    if (back.length != photo.byteSize) {
      throw StateError('Photo read back with the wrong size');
    }
  }

  static Future<void> _deleteNewestNotebook(Journal journal) async {
    final notebooks = await journal.notebooks.watchAll().first;
    if (notebooks.isNotEmpty) {
      await journal.notebooks.delete(notebooks.first.id);
    }
  }
}

class _Snapshot {
  const _Snapshot(this.counts, this.changes, this.fileCheck);

  final Map<String, int> counts;
  final List<Change> changes;
  final String fileCheck;
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.all(24), child: Text(text));
}

/// Shown when the journal is here but its key isn't, as after a reset and
/// restore: type the recovery key to unlock it.
class _UnlockForm extends ConsumerStatefulWidget {
  const _UnlockForm();

  @override
  ConsumerState<_UnlockForm> createState() => _UnlockFormState();
}

class _UnlockFormState extends ConsumerState<_UnlockForm> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    try {
      await unlockRestoredJournal(_controller.text);
      ref.invalidate(journalProvider);
    } on FormatException catch (error) {
      setState(() => _error = error.message);
    } on WrongRecoveryKey {
      setState(() => _error = 'This key belongs to a different journal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'The journal is on this phone but its key is not. '
          'Enter the recovery key to unlock it.',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Recovery key',
            errorText: _error,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _unlock, child: const Text('Unlock')),
      ],
    );
  }
}
