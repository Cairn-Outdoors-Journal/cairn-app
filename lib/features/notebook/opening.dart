import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/database/database.dart';
import '../shelf/notebook_cover.dart';
import 'notebook_screen.dart';

/// What the shelf passes when it opens a notebook.
class OpenNotebook {
  const OpenNotebook(this.notebook, {required this.full});

  final Notebook notebook;

  /// The first open today: the book-opening plays in full.
  final bool full;
}

/// The route for an open notebook (CONCEPT, "Bookshelf and notebooks"):
///
/// - the first open of the day: the cover lifts and the pages riffle to
///   today's, in about 1.5 s;
/// - after that: a quick slide, under half a second;
/// - with reduce motion on: a short fade.
Page<void> notebookPage(BuildContext context, GoRouterState state) {
  final open = state.extra is OpenNotebook
      ? state.extra! as OpenNotebook
      : null;
  final calm = MediaQuery.disableAnimationsOf(context);
  final full = open != null && open.full && !calm;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: NotebookScreen(notebookId: state.pathParameters['id']!),
    transitionDuration: Duration(
      milliseconds: full ? 1500 : (calm ? 150 : 320),
    ),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondary, child) {
      if (full) {
        return _BookOpening(
          animation: animation,
          notebook: open.notebook,
          child: child,
        );
      }
      if (calm) return FadeTransition(opacity: animation, child: child);
      return _slide(animation, child);
    },
  );
}

Widget _slide(Animation<double> animation, Widget child) {
  final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
  return FadeTransition(
    opacity: curved,
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    ),
  );
}

/// The cover swings open on its spine, then a few pages riffle past and
/// settle on today's page. Closing the notebook is the quick slide back.
class _BookOpening extends AnimatedWidget {
  const _BookOpening({
    required Animation<double> animation,
    required this.notebook,
    required this.child,
  }) : super(listenable: animation);

  final Notebook notebook;
  final Widget child;

  static const _sheets = 4;

  Animation<double> get _animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final animation = _animation;
    if (animation.status == AnimationStatus.reverse) {
      return _slide(animation, child);
    }
    final t = animation.value;
    final palette = Theme.of(context).colorScheme;

    // 0–0.5: the cover opens. 0.4–0.95: the pages riffle.
    final cover = Curves.easeInOutCubic.transform(_span(t, 0, 0.5));
    final backdrop = 1 - _span(t, 0.35, 0.55);
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        IgnorePointer(
          child: ExcludeSemantics(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final coverWidth = min(width * 0.62, 280.0);
                final scale = coverWidth / NotebookCover.largeSize.width;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    for (var i = _sheets - 1; i >= 0; i--)
                      _Sheet(
                        turn: Curves.easeIn.transform(
                          _span(t, 0.4 + i * 0.12, 0.6 + i * 0.12),
                        ),
                        color: palette.surface,
                        edge: palette.outline,
                      ),
                    if (backdrop > 0)
                      Opacity(
                        opacity: backdrop,
                        child: ColoredBox(color: palette.surface),
                      ),
                    if (cover < 1)
                      Center(
                        child: Transform(
                          key: const Key('opening-cover'),
                          alignment: Alignment.centerLeft,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0012)
                            ..rotateY(-pi / 2 * cover),
                          child: Transform.scale(
                            scale: scale,
                            child: NotebookCover(
                              notebook: notebook,
                              size: CoverSize.large,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Where [t] is between [from] and [to], as 0–1.
  static double _span(double t, double from, double to) =>
      ((t - from) / (to - from)).clamp(0.0, 1.0);
}

/// One page turning over on the left edge, from flat (0) to gone (1).
class _Sheet extends StatelessWidget {
  const _Sheet({required this.turn, required this.color, required this.edge});

  final double turn;
  final Color color;
  final Color edge;

  @override
  Widget build(BuildContext context) {
    if (turn >= 1) return const SizedBox.shrink();
    return Transform(
      alignment: Alignment.centerLeft,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0008)
        ..rotateY(-pi / 2 * turn),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border(right: BorderSide(color: edge)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08 + 0.12 * turn),
              blurRadius: 12,
              offset: const Offset(4, 0),
            ),
          ],
        ),
      ),
    );
  }
}
