import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/database/database.dart';
import '../../data/days.dart';
import '../../design/tokens.dart';

enum CoverSize { large, small }

/// A notebook seen face out (ADR 0005): the cloth, a darker spine and band,
/// and the ridge cairn pressed into it. The large cover, for the current
/// notebook, also carries its title and the ribbon; small covers carry no
/// text, with the name printed underneath by the shelf.
class NotebookCover extends StatelessWidget {
  const NotebookCover({
    required this.notebook,
    required this.size,
    this.today,
    super.key,
  });

  final Notebook notebook;
  final CoverSize size;

  /// Numbers a trip's days on the large cover; defaults to now.
  final DateTime? today;

  static const largeSize = Size(186, 252);
  static const smallSize = Size(72, 97);

  @override
  Widget build(BuildContext context) {
    return switch (size) {
      CoverSize.large => _LargeCover(notebook, today ?? DateTime.now()),
      CoverSize.small => _SmallCover(notebook),
    };
  }
}

class _SmallCover extends StatelessWidget {
  const _SmallCover(this.notebook);

  final Notebook notebook;

  @override
  Widget build(BuildContext context) {
    final shade = Colors.black.withValues(alpha: 0.32);
    return Container(
      width: NotebookCover.smallSize.width,
      height: NotebookCover.smallSize.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: coverColorOf(notebook),
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(2),
          right: Radius.circular(5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x291C1D1A),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.18)),
          ),
          Positioned(
            right: 9,
            top: 0,
            bottom: 0,
            width: 3,
            child: ColoredBox(color: shade),
          ),
          Positioned(
            left: 11,
            top: 29,
            width: 43,
            height: 43,
            child: CustomPaint(painter: CairnMarkPainter(shade, 3.4)),
          ),
        ],
      ),
    );
  }
}

class _LargeCover extends StatelessWidget {
  const _LargeCover(this.notebook, this.today);

  final Notebook notebook;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final cloth = coverColorOf(notebook);
    final ink = _CoverInk(cloth);
    final trail = notebook.trail;
    final trailName = notebook.trailName;

    return SizedBox(
      width: NotebookCover.largeSize.width,
      height: NotebookCover.largeSize.height + 22,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            bottom: 22,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: cloth,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(3),
                  right: Radius.circular(8),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x331C1D1A),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Color(0x241C1D1A),
                    blurRadius: 26,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 12,
                    child: ColoredBox(color: ink.spine),
                  ),
                  Positioned(
                    right: 24,
                    top: 0,
                    bottom: 0,
                    width: 8,
                    child: ColoredBox(color: ink.band),
                  ),
                  Positioned(
                    left: 28,
                    top: 28,
                    right: 44,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (trail != null && trail.isNotEmpty) ...[
                          Text(
                            trail.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: CairnFonts.label,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.26,
                              color: ink.quiet,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          notebook.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: CairnFonts.writing,
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            height: 1.05,
                            color: ink.title,
                          ),
                        ),
                        if (trailName != null && trailName.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            '“$trailName”',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: CairnFonts.writing,
                              fontStyle: FontStyle.italic,
                              fontSize: 17,
                              color: ink.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    left: 24,
                    bottom: 46,
                    width: 52,
                    height: 52,
                    child: CustomPaint(painter: CairnMarkPainter(ink.mark, 3)),
                  ),
                  Positioned(
                    left: 28,
                    bottom: 24,
                    child: Text(
                      coverStamp(notebook, today),
                      style: TextStyle(
                        fontFamily: CairnFonts.stamp,
                        fontSize: 9,
                        color: ink.quiet,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // The ribbon hangs out of the bottom of the current notebook.
          Positioned(
            right: 48,
            bottom: 0,
            width: 12,
            height: 34,
            child: CustomPaint(
              painter: _RibbonPainter(Theme.of(context).colorScheme.tertiary),
            ),
          ),
        ],
      ),
    );
  }
}

/// The colour the notebook is shown in: the custom colour the person
/// picked, or else its cloth.
Color coverColorOf(Notebook notebook) {
  final custom = notebook.coverColor;
  return custom == null ? notebook.cover.color : Color(0xFF000000 | custom);
}

/// The stamped line on the large cover: the trip's day, when it starts, or
/// a yearly notebook's year.
String coverStamp(Notebook notebook, DateTime today) {
  final start = notebook.startDay;
  if (notebook.kind != NotebookKind.trip || start == null) {
    return '${notebook.year}';
  }
  final day = dayOfTrip(start, today);
  if (day >= 1) return 'DAY $day';
  final date = parseDayKey(start);
  return 'STARTS ${date.day} ${shortMonths[date.month - 1].toUpperCase()}';
}

/// Colours for the large cover, worked out from the cloth so every cloth
/// gets a spine, band, pressed mark and lettering that belong to it. Pale
/// cloths take dark lettering.
class _CoverInk {
  _CoverInk(Color cloth)
    : spine = Color.lerp(cloth, Colors.black, 0.18)!,
      band = Color.lerp(cloth, Colors.black, 0.45)!,
      mark = Color.lerp(
        cloth,
        _isPale(cloth) ? Colors.black : Colors.white,
        0.14,
      )!,
      quiet = Color.lerp(cloth, _letter(cloth), 0.72)!,
      italic = Color.lerp(cloth, _letter(cloth), 0.82)!,
      title = Color.lerp(cloth, _letter(cloth), 0.94)!;

  final Color spine;
  final Color band;
  final Color mark;
  final Color quiet;
  final Color italic;
  final Color title;

  static bool _isPale(Color cloth) => coverLetterColor(cloth) == _ink;

  static Color _letter(Color cloth) => coverLetterColor(cloth);
}

const _ink = Color(0xFF1C1D1A);
const _paper = Color(0xFFF7F7F4);

/// Ink or paper, whichever stands out more on [cover] (WCAG contrast). With
/// any custom colour possible, a fixed brightness cut-off left mid-tones
/// such as orange with hard-to-read light lettering.
Color coverLetterColor(Color cover) {
  final l = cover.computeLuminance();
  double contrast(Color c) {
    final lc = c.computeLuminance();
    return (math.max(l, lc) + 0.05) / (math.min(l, lc) + 0.05);
  }

  return contrast(_ink) >= contrast(_paper) ? _ink : _paper;
}

/// The ridge cairn from the app icon, outlined, as pressed into a cover.
/// Drawn in a 100×100 box like the moodboard's SVG.
class CairnMarkPainter extends CustomPainter {
  const CairnMarkPainter(this.color, this.strokeWidth);

  final Color color;

  /// In the 100-unit box.
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final ridge = Path()
      ..moveTo(4, 76)
      ..lineTo(28, 56)
      ..lineTo(40, 64)
      ..lineTo(58, 42)
      ..lineTo(74, 58)
      ..lineTo(96, 47);
    canvas.drawPath(ridge, paint);
    for (final stone in const [
      Rect.fromLTWH(48, 35, 20, 6),
      Rect.fromLTWH(51, 27, 14, 6),
      Rect.fromLTWH(54, 19, 8, 6),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(stone, const Radius.circular(3)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CairnMarkPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

class _RibbonPainter extends CustomPainter {
  const _RibbonPainter(this.color);

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
  bool shouldRepaint(_RibbonPainter old) => old.color != color;
}
