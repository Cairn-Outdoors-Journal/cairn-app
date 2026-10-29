import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/tokens.dart';
import '../shelf/shelf_providers.dart';

/// An open notebook. For now it only names the notebook; today's page and
/// paging between days come in stage 7b.
class NotebookScreen extends ConsumerWidget {
  const NotebookScreen({required this.notebookId, super.key});

  final String notebookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notebooks = ref.watch(notebooksProvider).value ?? const [];
    final notebook = notebooks.where((n) => n.id == notebookId).firstOrNull;
    final palette = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          notebook?.title ?? '',
          style: const TextStyle(
            fontFamily: CairnFonts.writing,
            fontSize: 21,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Center(
        child: Text(
          notebook == null
              ? 'This notebook is no longer on the shelf.'
              : 'Today’s page opens here soon.',
          style: TextStyle(color: palette.onSurfaceVariant),
        ),
      ),
    );
  }
}
