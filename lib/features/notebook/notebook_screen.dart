import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../clock.dart';
import '../../data/database/database.dart';
import '../../data/days.dart';
import '../../data/journal.dart';
import '../../data/providers.dart';
import '../page/day_page.dart';
import '../page/page_frame.dart';
import '../shelf/shelf_providers.dart';
import 'days_sheet.dart';
import 'notebook_providers.dart';

/// An open notebook: its pages side by side, opened at today's (moodboard,
/// Day 47 page).
class NotebookScreen extends ConsumerWidget {
  const NotebookScreen({required this.notebookId, super.key});

  final String notebookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = Theme.of(context).colorScheme;
    final journal = ref.watch(journalProvider).value;
    final notebooks = ref.watch(notebooksProvider);
    final pages = ref.watch(notebookPagesProvider(notebookId));
    final notebook = notebooks.value
        ?.where((n) => n.id == notebookId)
        .firstOrNull;
    final error = notebooks.error ?? pages.error;

    final Widget body;
    if (error != null) {
      body = _Message('The notebook could not be opened.\n\n$error');
    } else if (journal == null || !notebooks.hasValue || !pages.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else if (notebook == null) {
      body = const _Message('This notebook is no longer on the shelf.');
    } else {
      body = _Pages(
        journal: journal,
        notebook: notebook,
        pages: pages.requireValue,
      );
    }

    return Scaffold(
      // The keyboard slides over the page, which scrolls to keep the cursor
      // in view, rather than shrinking the page.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopBar(title: notebook?.title ?? ''),
            Divider(height: 1, color: palette.outline),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _Pages extends ConsumerStatefulWidget {
  const _Pages({
    required this.journal,
    required this.notebook,
    required this.pages,
  });

  final Journal journal;
  final Notebook notebook;
  final List<JournalPage> pages;

  @override
  ConsumerState<_Pages> createState() => _PagesState();
}

class _PagesState extends ConsumerState<_Pages> {
  PageController? _controller;

  /// Writing that just continued onto another page: where the cursor goes
  /// once that page is showing.
  ({String pageId, int offset})? _continued;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onContinued(String pageId, int offset) =>
      setState(() => _continued = (pageId: pageId, offset: offset));

  @override
  Widget build(BuildContext context) {
    final today = dayKey(ref.watch(todayProvider));
    final leaves = leavesOf(widget.pages, today);
    final todayIndex = leaves.indexWhere(
      (l) => l.day == today && l.indexInDay == 0,
    );
    final controller = _controller ??= PageController(initialPage: todayIndex);

    // Turn to the page writing continued onto, once it's in the list.
    final continued = _continued;
    if (continued != null) {
      final index = leaves.indexWhere((l) => l.page?.id == continued.pageId);
      if (index >= 0 && controller.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (controller.hasClients && controller.page?.round() != index) {
            controller.animateToPage(
              index,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: PageView.builder(
            controller: controller,
            itemCount: leaves.length,
            onPageChanged: (index) {
              // The cursor was placed; turning elsewhere ends the request.
              if (_continued != null &&
                  leaves[index].page?.id != _continued!.pageId) {
                setState(() => _continued = null);
              }
            },
            findChildIndexCallback: (key) {
              final index = leaves.indexWhere((l) => ValueKey(l.key) == key);
              return index < 0 ? null : index;
            },
            itemBuilder: (context, index) {
              final leaf = leaves[index];
              final isTodayFirst = leaf.day == today && leaf.indexInDay == 0;
              final focus =
                  continued != null && leaf.page?.id == continued.pageId
                  ? PageFocus(null, continued.offset)
                  : null;
              return _PageSlot(
                key: ValueKey(leaf.key),
                child: DayPage(
                  // A new key when writing continues here, so the page
                  // takes the cursor even if it was already built.
                  key: ValueKey('${leaf.key}/${focus?.offset}'),
                  journal: widget.journal,
                  notebook: widget.notebook,
                  day: leaf.day,
                  page: leaf.page,
                  ribbon: isTodayFirst,
                  canSwitchTemplate: isTodayFirst,
                  focus: focus,
                  onContinued: _onContinued,
                ),
              );
            },
          ),
        ),
        DaysTab(
          onTap: () async {
            final index = await showDaysSheet(
              context,
              journal: widget.journal,
              notebook: widget.notebook,
              leaves: leaves,
              today: today,
            );
            if (index != null && controller.hasClients) {
              controller.jumpToPage(index);
            }
          },
        ),
      ],
    );
  }
}

/// One page in the notebook, scaled to fit, and scrollable when the
/// keyboard covers its lower half.
class _PageSlot extends StatelessWidget {
  const _PageSlot({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: constraints.maxHeight,
        child: Align(
          alignment: Alignment.topCenter,
          child: PageFrame(child: child),
        ),
      ),
    ),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    return SizedBox(
      height: 54,
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/'),
                style: TextButton.styleFrom(
                  foregroundColor: palette.onSurface,
                  minimumSize: const Size(44, 44),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Shelf', semanticsLabel: 'Back to the shelf'),
              ),
            ),
          ),
          Expanded(
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 96),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ),
  );
}
