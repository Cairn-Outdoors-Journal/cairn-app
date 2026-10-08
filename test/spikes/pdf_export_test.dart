import 'dart:io';
import 'dart:math' as math;

import 'package:cairn/spikes/page_composer/composer_spike_screen.dart';
import 'package:cairn/spikes/page_composer/pdf_export.dart';
import 'package:cairn/spikes/page_composer/wrap_layout.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';

const _fontPath = 'assets/fonts/newsreader/Newsreader16pt-Regular.ttf';
const _fontSize = 16.0;
const _page = Size(350, 560);

void main() {
  late ByteData font;

  setUpAll(() async {
    font = ByteData.sublistView(File(_fontPath).readAsBytesSync());
    final loader = FontLoader('Newsreader')..addFont(Future.value(font));
    await loader.load();
  });

  WrapLayout layoutSample() {
    final photo = Exclusion.rotatedRect(
      center: const Offset(270, 110),
      size: const Size(132, 152),
      angle: 2.5 * math.pi / 180,
      margin: 10,
    );
    return WrapLayout.compute(
      text: sampleText,
      style: const TextStyle(
        fontFamily: 'Newsreader',
        fontSize: _fontSize,
        height: 1.5,
      ),
      size: _page,
      exclusions: [photo],
    );
  }

  test('every line is the same width in the PDF as on screen', () {
    final layout = layoutSample();
    final document = PdfDocument();
    var worst = 0.0;

    for (final f in layout.fragments) {
      final text = layout.text.substring(f.start, f.caretEnd).trimRight();
      if (text.isEmpty) continue;
      final screen = f.painter.computeLineMetrics().first.width;
      final pdf = pdfLineWidth(document, font, _fontSize, f, text);
      worst = math.max(worst, (pdf - screen).abs());

      // The PDF never runs past the space the screen gave the line.
      expect(f.offset.dx + pdf, lessThanOrEqualTo(f.segmentRight + 1));
    }

    // Characters sit exactly where the screen put them; the only possible
    // drift is inside a ligature such as "fi", well under half a point.
    expect(worst, lessThan(0.5));
    // ignore: avoid_print
    print(
      'largest line-width difference screen vs PDF: '
      '${worst.toStringAsFixed(2)} pt over ${layout.fragments.length} lines',
    );
    layout.dispose();
  });

  test('exports a one-page PDF with the font embedded', () async {
    final layout = layoutSample();
    final photo = Exclusion.rotatedRect(
      center: const Offset(270, 110),
      size: const Size(132, 152),
      angle: 2.5 * math.pi / 180,
    );

    final bytes = await exportPagePdf(
      layout: layout,
      pageSize: _page,
      font: font,
      fontSize: _fontSize,
      photos: [photo.polygon],
    );

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    final contents = String.fromCharCodes(bytes);
    expect(contents, contains('/FontFile2'), reason: 'font is embedded');

    final out = File('build/spikes/page.pdf')..createSync(recursive: true);
    out.writeAsBytesSync(bytes);
    layout.dispose();
  });
}
