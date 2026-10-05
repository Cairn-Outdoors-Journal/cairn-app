import 'package:flutter/material.dart';

/// The bookshelf: the current notebook shown large, the rest as small covers
/// facing out. This is a placeholder until notebooks exist.
class ShelfScreen extends StatelessWidget {
  const ShelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shelf', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                'No notebooks yet.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
