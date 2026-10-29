import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/notebook/notebook_screen.dart';
import 'features/shelf/shelf_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const ShelfScreen()),
      GoRoute(
        path: '/notebook/:id',
        builder: (context, state) =>
            NotebookScreen(notebookId: state.pathParameters['id']!),
      ),
    ],
  );
});
