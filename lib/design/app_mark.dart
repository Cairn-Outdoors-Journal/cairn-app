import 'package:flutter/material.dart';

import 'tokens.dart';

/// The app icon (ADR 0005) at header size: the ridge cairn with its orange
/// top stone, the spine shade and the ribbon, on ink.
class AppMark extends StatelessWidget {
  const AppMark({this.size = 28, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size / 4),
    child: CustomPaint(size: Size.square(size), painter: _AppMarkPainter()),
  );
}

class _AppMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const ink = Color(0xFF1C1D1A);
    const paper = Color(0xFFF7F7F4);
    final blaze = CairnColors.light.blaze;
    canvas.scale(size.width / 100, size.height / 100);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), Paint()..color = ink);
    final ridge = Path()
      ..moveTo(0, 76)
      ..lineTo(28, 56)
      ..lineTo(40, 64)
      ..lineTo(58, 42)
      ..lineTo(74, 58)
      ..lineTo(100, 47);
    canvas.drawPath(
      Path.from(ridge)
        ..lineTo(100, 100)
        ..lineTo(0, 100)
        ..close(),
      Paint()..color = CoverCloth.slate.color,
    );
    canvas.drawPath(
      ridge,
      Paint()
        ..color = paper
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    void stone(Rect rect, Color color) => canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = color,
    );
    stone(const Rect.fromLTWH(48, 35, 20, 6), paper);
    stone(const Rect.fromLTWH(51, 27, 14, 6), paper);
    stone(const Rect.fromLTWH(54, 19, 8, 6), blaze);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 11, 100),
      Paint()..color = Colors.black.withValues(alpha: 0.38),
    );
    canvas.drawPath(
      Path()
        ..moveTo(79.5, 0)
        ..lineTo(86.5, 0)
        ..lineTo(86.5, 20)
        ..lineTo(83, 17)
        ..lineTo(79.5, 20)
        ..close(),
      Paint()..color = blaze,
    );
  }

  @override
  bool shouldRepaint(_AppMarkPainter old) => false;
}
