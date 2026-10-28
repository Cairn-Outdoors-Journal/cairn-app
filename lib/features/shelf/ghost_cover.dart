import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import 'notebook_cover.dart';

/// An empty place on the shelf, drawn as a dashed outline of a notebook with
/// a faint pressed cairn. Notebooks take these places as they are added;
/// tapping one starts a new notebook.
class GhostCover extends StatelessWidget {
  const GhostCover({required this.size, this.label, super.key});

  final CoverSize size;

  /// Written inside the large outline, e.g. "Start your first notebook".
  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final large = size == CoverSize.large;
    final box = large ? NotebookCover.largeSize : NotebookCover.smallSize;
    final radius = large
        ? const BorderRadius.horizontal(
            left: Radius.circular(3),
            right: Radius.circular(8),
          )
        : const BorderRadius.horizontal(
            left: Radius.circular(2),
            right: Radius.circular(5),
          );
    final markSize = large ? 52.0 : 43.0;
    return CustomPaint(
      painter: _DashedOutline(scheme.outline, radius),
      child: SizedBox.fromSize(
        size: box,
        child: Stack(
          children: [
            Positioned(
              left: large ? 24 : 11,
              top: large ? null : 29,
              bottom: large ? 46 : null,
              width: markSize,
              height: markSize,
              child: CustomPaint(
                painter: CairnMarkPainter(scheme.outline, large ? 3 : 3.4),
              ),
            ),
            if (large && label != null)
              Positioned(
                left: 24,
                right: 24,
                top: 28,
                child: Text(
                  label!,
                  style: TextStyle(
                    fontFamily: CairnFonts.writing,
                    fontSize: 22,
                    height: 1.15,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (large)
              Positioned(
                left: 24,
                right: 24,
                bottom: 22,
                child: Row(
                  children: [
                    Icon(Icons.add, size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'TAP TO START',
                      style: TextStyle(
                        fontFamily: CairnFonts.stamp,
                        fontSize: 9,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Where a shelf name and year will go: two faint bars.
class GhostLabel extends StatelessWidget {
  const GhostLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    Widget bar(double width) => Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [bar(52), const SizedBox(height: 5), bar(26)],
    );
  }
}

class _DashedOutline extends CustomPainter {
  const _DashedOutline(this.color, this.radius);

  final Color color;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()
      ..addRRect(radius.toRRect(Offset.zero & size).deflate(0.75));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + gap) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedOutline old) =>
      old.color != color || old.radius != radius;
}
