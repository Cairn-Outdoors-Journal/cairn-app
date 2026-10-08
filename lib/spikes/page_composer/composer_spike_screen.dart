import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import '../../design/tokens.dart';
import 'pdf_export.dart';
import 'wrap_layout.dart';
import 'wrapped_editor.dart';

const sampleText =
    'Left Reds Meadow before the store opened, five days of food in the pack. '
    'The climb out was dust and switchbacks, then the lakes: Rosalie, Shadow, '
    'Garnet, each a colder blue than the last. Hops slipped at the Shadow Creek '
    'crossing and laughed about it for a mile.\n'
    'Reached camp with an hour of light. Banner Peak turned orange, and then '
    'all at once it didn\'t.';

/// A test page for writing that wraps around a taped photo while editing.
///
/// Tap the text to type. Drag the photo to move it and use the arrows to
/// tilt it; the writing re-flows on every frame. The PDF button exports the
/// page as it is now and opens the system print preview.
class ComposerSpikeScreen extends StatefulWidget {
  const ComposerSpikeScreen({super.key});

  @override
  State<ComposerSpikeScreen> createState() => _ComposerSpikeScreenState();
}

class _ComposerSpikeScreenState extends State<ComposerSpikeScreen> {
  static const _photoSize = Size(132, 152);
  static const _pagePadding = 20.0;
  static const _fontSize = 16.0;
  static const _fontAsset =
      'assets/fonts/newsreader/Newsreader16pt-Regular.ttf';

  Offset? _photoCenter;
  double _angle = 2.5 * math.pi / 180;
  bool _showDebug = false;
  final _stats = ValueNotifier(const EditorStats());
  GlobalKey<WrappedEditorState> _editorKey = GlobalKey();
  bool _exporting = false;

  // The page geometry from the last build, for exporting.
  Size _pageSize = Size.zero;
  Offset _lastPhotoCenter = Offset.zero;

  @override
  void dispose() {
    _stats.dispose();
    super.dispose();
  }

  void _tilt(double degrees) =>
      setState(() => _angle += degrees * math.pi / 180);

  Future<void> _exportPdf() async {
    final editor = _editorKey.currentState;
    if (editor == null || _exporting) return;
    // Match the size the text is drawn at, including the phone's text-size
    // setting, so characters land exactly where the screen put them.
    final fontSize = MediaQuery.textScalerOf(context).scale(_fontSize);
    setState(() => _exporting = true);
    try {
      final font = await rootBundle.load(_fontAsset);
      final photo = Exclusion.rotatedRect(
        center: _lastPhotoCenter,
        size: _photoSize,
        angle: _angle,
      );
      final bytes = await exportPagePdf(
        layout: editor.layout,
        pageSize: _pageSize,
        font: font,
        fontSize: fontSize,
        photos: [photo.polygon],
        margin: 36,
      );
      await Printing.layoutPdf(
        name: 'Cairn day 47',
        onLayout: (_) async => bytes,
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const palette = CairnColors.light;
    final style = TextStyle(
      fontSize: 16,
      height: 1.5,
      color: palette.ink,
      fontFamily: 'Newsreader',
    );

    return Scaffold(
      backgroundColor: palette.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Wrap + edit spike',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tilt left',
                    onPressed: () => _tilt(-3),
                    icon: const Icon(Icons.rotate_left),
                  ),
                  IconButton(
                    tooltip: 'Tilt right',
                    onPressed: () => _tilt(3),
                    icon: const Icon(Icons.rotate_right),
                  ),
                  IconButton(
                    tooltip: 'Show shapes',
                    isSelected: _showDebug,
                    onPressed: () => setState(() => _showDebug = !_showDebug),
                    icon: const Icon(Icons.grid_on_outlined),
                    selectedIcon: const Icon(Icons.grid_on),
                  ),
                  IconButton(
                    tooltip: 'Export PDF',
                    onPressed: _exporting ? null : _exportPdf,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                  ),
                  IconButton(
                    tooltip: 'Reset text',
                    onPressed: () => setState(() => _editorKey = GlobalKey()),
                    icon: const Icon(Icons.restart_alt),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _stats,
              builder: (context, s, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'layout ${(s.layoutMicros / 1000).toStringAsFixed(1)} ms · '
                  'edit→frame ${(s.editToFrameMicros / 1000).toStringAsFixed(1)} ms · '
                  '${s.lines} lines · ${s.characters} chars'
                  '${s.overflowed ? ' · PAGE FULL' : ''}',
                  style: TextStyle(
                    fontFamily: 'Menlo',
                    fontSize: 11,
                    color: palette.pencil,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final pageSize = Size(
                    constraints.maxWidth - _pagePadding * 2,
                    constraints.maxHeight - _pagePadding,
                  );
                  final center =
                      _photoCenter ??
                      Offset(pageSize.width - _photoSize.width / 2 - 4, 110);
                  final exclusion = Exclusion.rotatedRect(
                    center: center,
                    size: _photoSize,
                    angle: _angle,
                    margin: 10,
                  );
                  _pageSize = pageSize;
                  _lastPhotoCenter = center;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _pagePadding,
                      0,
                      _pagePadding,
                      _pagePadding,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        WrappedEditor(
                          key: _editorKey,
                          size: pageSize,
                          style: style,
                          exclusions: [exclusion],
                          initialText: sampleText,
                          showDebug: _showDebug,
                          stats: _stats,
                        ),
                        Positioned(
                          left: center.dx - _photoSize.width / 2,
                          top: center.dy - _photoSize.height / 2,
                          child: GestureDetector(
                            // Add to the stored position, not the one captured
                            // at the last build: several drag updates can
                            // arrive between frames.
                            onPanUpdate: (d) => setState(
                              () => _photoCenter =
                                  (_photoCenter ?? center) + d.delta,
                            ),
                            child: Transform.rotate(
                              angle: _angle,
                              child: const _TapedPhoto(size: _photoSize),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An instant-film print with a strip of masking tape.
class _TapedPhoto extends StatelessWidget {
  const _TapedPhoto({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(7, 7, 7, 26),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x2E1C1D1A),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
                BoxShadow(
                  color: Color(0x141C1D1A),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              color: const Color(0xFF96A5AC),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(6),
              child: const Text(
                'BANNER PEAK',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Positioned(
            top: -10,
            left: size.width / 2 - 30,
            child: Transform.rotate(
              angle: -5 * math.pi / 180,
              child: Container(
                width: 60,
                height: 20,
                color: const Color(0xC7DED0AA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
