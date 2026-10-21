import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../clock.dart';
import '../../data/database/database.dart';
import '../../data/journal.dart';
import '../../data/providers.dart';
import '../../design/app_mark.dart';
import '../../design/tokens.dart';
import 'notebook_actions.dart';
import 'notebook_cover.dart';
import 'notebook_sheet.dart';
import 'shelf_providers.dart';

/// The bookshelf (ADR 0005): the current notebook large, the rest small
/// and face out below, and a small "+ New" in the header.
class ShelfScreen extends ConsumerWidget {
  const ShelfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journal = ref.watch(journalProvider);
    return Scaffold(
      body: SafeArea(
        child: switch (journal) {
          AsyncData(value: final journal) => _Shelf(journal),
          AsyncError(:final error) => _Problem('$error'),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _Shelf extends ConsumerWidget {
  const _Shelf(this.journal);

  final Journal journal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notebooks = ref.watch(notebooksProvider).value;
    final current = ref.watch(currentNotebookProvider).value;
    final today = ref.watch(clockProvider)();
    if (notebooks == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final others = [
      for (final n in notebooks)
        if (n.id != current?.id) n,
    ];
    final palette = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(onNew: () => _create(context, today)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Expanded(
                    child: Text(
                      'Shelf',
                      style: TextStyle(
                        fontFamily: CairnFonts.writing,
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (notebooks.isNotEmpty)
                    Text(
                      notebooks.length == 1
                          ? '1 NOTEBOOK'
                          : '${notebooks.length} NOTEBOOKS',
                      style: TextStyle(
                        fontFamily: CairnFonts.stamp,
                        fontSize: 10,
                        color: palette.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (current == null)
                _Empty(onStart: () => _create(context, today))
              else ...[
                const _SectionLabel('On the trail'),
                const SizedBox(height: 14),
                Center(
                  child: Semantics(
                    button: true,
                    label:
                        'Open ${current.title}, the current notebook. '
                        'Long-press for options.',
                    excludeSemantics: true,
                    child: GestureDetector(
                      key: const Key('current-notebook'),
                      onTap: () => _open(context, current),
                      onLongPress: () => _actions(context, current, true),
                      child: NotebookCover(
                        notebook: current,
                        size: CoverSize.large,
                        today: today,
                      ),
                    ),
                  ),
                ),
                if (others.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const _SectionLabel('On the shelf'),
                  const SizedBox(height: 14),
                  _Grid(
                    notebooks: others,
                    onOpen: (n) => _open(context, n),
                    onLongPress: (n) => _actions(context, n, false),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Opens the notebook, which also makes it the current one.
  Future<void> _open(BuildContext context, Notebook notebook) async {
    await journal.notebooks.markOpened(notebook.id);
    if (context.mounted) await context.push('/notebook/${notebook.id}');
  }

  Future<void> _create(BuildContext context, DateTime today) async {
    final draft = await showNotebookSheet(context, today: today);
    if (draft == null) return;
    final created = await journal.notebooks.create(
      kind: draft.kind,
      title: draft.title,
      year: draft.year,
      cover: draft.cover,
      trail: draft.trail,
      trailName: draft.trailName,
      startDay: draft.startDay,
    );
    // A notebook you just made is the one you'll write in next.
    await journal.notebooks.markOpened(created.id);
  }

  Future<void> _actions(
    BuildContext context,
    Notebook notebook,
    bool isCurrent,
  ) async {
    final action = await showNotebookActions(
      context,
      notebook,
      isCurrent: isCurrent,
    );
    if (action == null || !context.mounted) return;
    final notebooks = journal.notebooks;
    switch (action) {
      case NotebookAction.changeCover:
        final cloth = await showCoverPicker(context, notebook.cover);
        if (cloth != null && cloth != notebook.cover) {
          await notebooks.update(notebook.copyWith(cover: cloth));
        }
      case NotebookAction.edit:
        final draft = await showNotebookSheet(
          context,
          initial: NotebookDraft.of(notebook),
        );
        if (draft != null) await notebooks.update(draft.applyTo(notebook));
      case NotebookAction.makeCurrent:
        await notebooks.markOpened(notebook.id);
      case NotebookAction.delete:
        final pages = await notebooks.pageCount(notebook.id);
        if (!context.mounted) return;
        if (await confirmDeleteNotebook(context, notebook, pageCount: pages)) {
          await notebooks.delete(notebook.id);
        }
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onNew});

  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    return Container(
      height: 58,
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.outline)),
      ),
      child: Row(
        children: [
          const AppMark(),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Cairn',
              style: TextStyle(
                fontFamily: CairnFonts.writing,
                fontSize: 21,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onNew,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44),
              foregroundColor: palette.onSurface,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('New', semanticsLabel: 'New notebook'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: palette.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(height: 1, color: palette.outline)),
      ],
    );
  }
}

/// The rest of the shelf: four small covers per row, name and year below.
class _Grid extends StatelessWidget {
  const _Grid({
    required this.notebooks,
    required this.onOpen,
    required this.onLongPress,
  });

  final List<Notebook> notebooks;
  final ValueChanged<Notebook> onOpen;
  final ValueChanged<Notebook> onLongPress;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 4;
        const gap = 10.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: 14,
          children: [
            for (final notebook in notebooks)
              SizedBox(
                width: width,
                child: Semantics(
                  button: true,
                  label:
                      'Open ${notebook.title} ${notebook.year}. '
                      'Long-press for options.',
                  excludeSemantics: true,
                  child: GestureDetector(
                    key: Key('notebook-${notebook.id}'),
                    onTap: () => onOpen(notebook),
                    onLongPress: () => onLongPress(notebook),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NotebookCover(
                          notebook: notebook,
                          size: CoverSize.small,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          notebook.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                        Text(
                          '${notebook.year}',
                          style: TextStyle(
                            fontFamily: CairnFonts.stamp,
                            fontSize: 8.5,
                            color: palette.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
        children: [
          Text(
            'Your shelf is empty.',
            style: TextStyle(
              fontFamily: CairnFonts.writing,
              fontSize: 20,
              color: palette.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A notebook can hold one trip, or a year of shorter hikes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onStart,
            child: const Text('Start your first notebook'),
          ),
        ],
      ),
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text('The journal could not be opened.\n\n$message'),
    ),
  );
}
