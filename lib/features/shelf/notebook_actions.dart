import 'package:flutter/material.dart';

import '../../data/database/database.dart';
import '../../design/tokens.dart';
import 'notebook_sheet.dart';

enum NotebookAction { changeCover, edit, makeCurrent, delete }

/// The long-press menu for a notebook on the shelf.
Future<NotebookAction?> showNotebookActions(
  BuildContext context,
  Notebook notebook, {
  required bool isCurrent,
}) {
  return showModalBottomSheet<NotebookAction>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      Widget item(NotebookAction action, IconData icon, String label) =>
          ListTile(
            leading: Icon(icon),
            title: Text(label),
            onTap: () => Navigator.of(context).pop(action),
          );
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                notebook.title,
                style: const TextStyle(
                  fontFamily: CairnFonts.writing,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            item(
              NotebookAction.changeCover,
              Icons.palette_outlined,
              'Change cover',
            ),
            item(NotebookAction.edit, Icons.edit_outlined, 'Edit details'),
            if (!isCurrent)
              item(
                NotebookAction.makeCurrent,
                Icons.bookmark_outline,
                'Make current',
              ),
            item(NotebookAction.delete, Icons.delete_outline, 'Delete'),
          ],
        ),
      );
    },
  );
}

/// Picks a new cloth for the cover.
Future<CoverCloth?> showCoverPicker(BuildContext context, CoverCloth current) {
  return showModalBottomSheet<CoverCloth>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change cover',
              style: TextStyle(
                fontFamily: CairnFonts.writing,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            CoverClothPicker(
              selected: current,
              onSelected: (cloth) => Navigator.of(context).pop(cloth),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Asks before deleting, saying how much goes with the notebook.
Future<bool> confirmDeleteNotebook(
  BuildContext context,
  Notebook notebook, {
  required int pageCount,
}) async {
  final pages = switch (pageCount) {
    0 => 'It has no pages yet.',
    1 => 'Its 1 page, and everything on it, goes too.',
    _ => 'Its $pageCount pages, and everything on them, go too.',
  };
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final error = Theme.of(context).colorScheme.error;
      return AlertDialog(
        title: Text('Delete “${notebook.title}”?'),
        content: Text('$pages This can’t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: error),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
