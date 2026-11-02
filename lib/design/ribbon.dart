import 'package:flutter/rendering.dart';

/// The blaze ribbon with its swallowtail cut, the brand's "today" mark
/// (ADR 0005): on the current notebook's cover and on today's page.
class RibbonPainter extends CustomPainter {
  const RibbonPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final notch = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height * 0.8)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(notch, Paint()..color = color);
  }

  @override
  bool shouldRepaint(RibbonPainter old) => old.color != color;
}
