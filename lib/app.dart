import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design/theme.dart';
import 'design/tokens.dart';
import 'router.dart';

class CairnApp extends ConsumerWidget {
  const CairnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Cairn',
      debugShowCheckedModeBanner: false,
      theme: cairnTheme(CairnColors.light, Brightness.light),
      darkTheme: cairnTheme(CairnColors.night, Brightness.dark),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
