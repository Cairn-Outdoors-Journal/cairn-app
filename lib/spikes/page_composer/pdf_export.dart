import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';

import 'wrap_layout.dart';

/// Renders a laid-out page to a one-page vector PDF.
///
/// The PDF does not re-wrap anything: every line is drawn exactly where
/// [WrapLayout] placed it on screen, with the same font file embedded, so the
/// printed page breaks lines identically to the app. Page units are the
/// layout's logical pixels, one pixel to one PDF point. [margin] adds blank
/// paper around the writing area.
Future<Uint8List> exportPagePdf({
  required WrapLayout layout,
  required Size pageSize,
  required ByteData font,
  required double fontSize,
  List<List<Offset>> photos = const [],
  int inkColor = 0xFF1C1D1A,
  int paperColor = 0xFFF7F7F4,
  int photoColor = 0xFF96A5AC,
  double margin = 0,
}) async {
  final document = PdfDocument();
  final pdfFont = PdfTtfFont(document, font);
  final page = PdfPage(
    document,
    pageFormat: PdfPageFormat(
      pageSize.width + margin * 2,
      pageSize.height + margin * 2,
    ),
  );
  final g = page.getGraphics();
  final paperHeight = pageSize.height + margin * 2;

  // PDF's origin is the bottom-left corner; the layout's is the top-left of
  // the writing area, inset by the margin.
  double x(double layoutX) => layoutX + margin;
  double flipY(double layoutY) => paperHeight - (layoutY + margin);

  g
    ..setFillColor(PdfColor.fromInt(paperColor))
    ..drawRect(0, 0, pageSize.width + margin * 2, paperHeight)
    ..fillPath();

  for (final polygon in photos) {
    g
      ..setFillColor(PdfColor.fromInt(photoColor))
      ..moveTo(x(polygon.first.dx), flipY(polygon.first.dy));
    for (final p in polygon.skip(1)) {
      g.lineTo(x(p.dx), flipY(p.dy));
    }
    g
      ..closePath()
      ..fillPath();
  }

  g.setFillColor(PdfColor.fromInt(inkColor));
  for (final f in layout.fragments) {
    final text = layout.text.substring(f.start, f.caretEnd);
    if (text.trim().isEmpty) continue;
    final y = flipY(
      f.offset.dy + f.painter.computeLineMetrics().first.baseline,
    );
    // Each character goes exactly where the screen put it. The PDF library
    // does no kerning of its own, so letting it space a whole line would make
    // lines up to a few points wider than on screen.
    for (final (:char, x: charX) in _characterPositions(f, text)) {
      if (char.trim().isEmpty) continue;
      g.drawString(pdfFont, fontSize, char, x(f.offset.dx + charX), y);
    }
  }

  return document.save();
}

/// Each user-perceived character of [text] with its x position inside the
/// fragment, as laid out on screen.
Iterable<({String char, double x})> _characterPositions(
  LineFragment fragment,
  String text,
) sync* {
  var index = 0;
  for (final char in text.characters) {
    final x = fragment.painter
        .getOffsetForCaret(TextPosition(offset: index), Rect.zero)
        .dx;
    yield (char: char, x: x);
    index += char.length;
  }
}

/// Right edge of a fragment's ink as the PDF draws it, relative to the
/// fragment's left edge, in points.
double pdfLineWidth(
  PdfDocument document,
  ByteData font,
  double size,
  LineFragment fragment,
  String text,
) {
  final pdfFont = PdfTtfFont(document, font);
  var right = 0.0;
  for (final (:char, :x) in _characterPositions(fragment, text)) {
    if (char.trim().isEmpty) continue;
    right = x + pdfFont.stringMetrics(char).advanceWidth * size;
  }
  return right;
}
