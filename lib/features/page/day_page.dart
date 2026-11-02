import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:drift/drift.dart' show Value;

import '../../data/database/database.dart';
import '../../data/journal.dart';
import '../../design/ribbon.dart';
import 'page_frame.dart';
import 'section_field.dart';
import 'stamped_header.dart';
import 'templates.dart';

/// One page of a notebook: the stamped header and the template's sections
/// to write in, laid out at the page's fixed size.
///
/// Today's page may not be stored yet ([page] is null). It is saved when the
/// person first writes, so a day with nothing written leaves no page.
class DayPage extends StatefulWidget {
  const DayPage({
    required this.journal,
    required this.notebook,
    required this.day,
    required this.page,
    this.template = PageTemplate.day,
    this.ribbon = false,
    this.focus,
    this.onContinued,
    this.canSwitchTemplate = false,
    super.key,
  });

  final Journal journal;
  final Notebook notebook;

  /// YYYY-MM-DD.
  final String day;

  /// The stored page, or null for today's page before anything is written.
  final JournalPage? page;

  /// The template for a page that isn't stored yet; a stored page uses its
  /// own.
  final PageTemplate template;

  /// Today's ribbon, on the first page of today.
  final bool ribbon;

  /// Where to put the cursor once the page's writing has loaded: set on a
  /// page that writing has just continued onto.
  final PageFocus? focus;

  /// Writing ran past the bottom of this page and continued on the page
  /// [pageId]; the cursor belongs there at [offset] in its free writing.
  final void Function(String pageId, int offset)? onContinued;

  /// Offers three lines instead of the full page, and back, while nothing
  /// is written: today's first page.
  final bool canSwitchTemplate;

  @override
  State<DayPage> createState() => DayPageState();
}

/// A place in a page's writing.
class PageFocus {
  const PageFocus(this.section, this.offset);

  final String? section;
  final int offset;
}

class DayPageState extends State<DayPage> {
  /// How long writing waits before it's saved, so a save doesn't follow
  /// every keystroke.
  static const saveDelay = Duration(milliseconds: 400);

  late PageTemplate _template;
  final _controllers = <String?, TextEditingController>{};
  final _focus = <String?, FocusNode>{};

  /// Sections edited since the last save.
  final _dirty = <String?>{};

  String? _pageId;
  StreamSubscription<List<PageItem>>? _items;
  Timer? _saveTimer;
  Future<void> _saving = Future.value();
  late final AppLifecycleListener _lifecycle;

  /// The section the person changed last, which is the one that gives up
  /// its end when the page overflows. Null until a change; a record so the
  /// free writing (key null) can be named too.
  ({String? key})? _lastEdited;
  bool _spilling = false;
  bool _focusApplied = false;

  /// The stored page's id, once there is one.
  String? get pageId => _pageId;

  @override
  void initState() {
    super.initState();
    _template = _templateOf(widget);
    _buildFields();
    _attach(widget.page?.id);
    // Writing is saved before the app goes into the background, where the
    // system may end it without warning.
    _lifecycle = AppLifecycleListener(onInactive: save, onHide: save);
  }

  @override
  void didUpdateWidget(DayPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final id = widget.page?.id;
    if (id != null && id != _pageId) _attach(id);
    // Only a change from outside, such as the stored page arriving, moves
    // the template; a switch made here waits for the store to catch up.
    final template = _templateOf(widget);
    if (template != _templateOf(oldWidget) && template != _template) {
      _template = template;
      _buildFields();
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    // Leaving the page saves what's waiting; the journal outlives the page.
    save();
    _items?.cancel();
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focus.values) {
      f.dispose();
    }
    super.dispose();
  }

  static PageTemplate _templateOf(DayPage page) {
    final stored = page.page;
    return stored == null
        ? page.template
        : PageTemplate.fromKey(stored.template);
  }

  /// Makes a field for each of the template's sections, keeping any that
  /// already exist.
  void _buildFields() {
    for (final section in _template.sections) {
      _controllers.putIfAbsent(section.key, TextEditingController.new);
      _focus.putIfAbsent(section.key, FocusNode.new);
    }
  }

  /// Follows the stored page's writing. Text written elsewhere (another
  /// page continuing onto this one) shows up, except in a field the person
  /// is editing.
  void _attach(String? id) {
    if (id == null || id == _pageId) return;
    _pageId = id;
    _items?.cancel();
    var first = true;
    _items = widget.journal.items.watchForPage(id).listen((items) {
      for (final item in items) {
        if (item.kind != PageItemKind.text) continue;
        final controller = _controllers[item.section];
        final body = item.body ?? '';
        if (controller == null || controller.text == body) continue;
        final editing =
            _dirty.contains(item.section) ||
            (_focus[item.section]?.hasFocus ?? false);
        if (first || !editing) controller.text = body;
      }
      if (first) _applyFocus();
      _showBlank();
      first = false;
    });
  }

  /// Puts the cursor where [DayPage.focus] asks, once. The text that just
  /// arrived may itself be too long, so it's checked like an edit.
  void _applyFocus() {
    final request = widget.focus;
    if (request == null || _focusApplied) return;
    final controller = _controllers[request.section];
    if (controller == null) return;
    _focusApplied = true;
    _lastEdited = (key: request.section);
    controller.selection = TextSelection.collapsed(
      offset: request.offset.clamp(0, controller.text.length),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus[request.section]?.requestFocus();
    });
  }

  /// Called with the height of the page's content after each layout.
  /// Content taller than the page means the last edit ran past the bottom.
  void _checkFit(double height) {
    final available = PaperPage.size.height - PaperPage.margin.vertical;
    final edited = _lastEdited;
    if (height <= available + 0.5 || edited == null || _spilling) return;
    _spilling = true;
    final overflow = height - available;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (mounted) await _spill(edited.key, overflow);
      } finally {
        _lastEdited = null;
        _spilling = false;
      }
    });
  }

  /// Keeps as much of [section]'s writing as fits, ending at a word, and
  /// moves the rest to the start of the next page for this day.
  Future<void> _spill(String? section, double overflow) async {
    final controller = _controllers[section];
    if (controller == null) return;
    final rowLabel = _template.sections
        .firstWhere((s) => s.key == section)
        .rowLabel;
    final style = PageText.writing(Theme.of(context).colorScheme);
    final measure = TextPainter(
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      strutStyle: StrutStyle.fromTextStyle(style),
    );
    final width = PaperPage.contentWidth - (rowLabel == null ? 0 : 46);
    double heightOf(String text) {
      measure
        ..text = TextSpan(text: text.isEmpty ? ' ' : text, style: style)
        ..layout(maxWidth: width);
      return measure.height;
    }

    final text = controller.text;
    final allowed = heightOf(text) - overflow;
    var low = 0;
    var high = text.length;
    while (low < high) {
      final mid = (low + high + 1) ~/ 2;
      if (heightOf(text.substring(0, mid)) <= allowed + 0.5) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    measure.dispose();
    var cut = low;
    if (cut < text.length) {
      final space = text.lastIndexOf(RegExp(r'\s'), cut);
      if (space > 0) cut = space;
    }
    final keep = text.substring(0, cut).trimRight();
    final rest = text.substring(cut).trimLeft();
    controller.value = TextEditingValue(
      text: keep,
      selection: TextSelection.collapsed(offset: keep.length),
    );
    _dirty.add(section);
    await save();
    final id = _pageId;
    if (rest.isEmpty || id == null) return;

    final journal = widget.journal;
    final next = await _nextPage(id);
    final items = await journal.items.watchForPage(next.id).first;
    final existing =
        items
            .where((i) => i.kind == PageItemKind.text && i.section == null)
            .firstOrNull
            ?.body ??
        '';
    await journal.items.saveSectionText(
      pageId: next.id,
      section: null,
      body: existing.isEmpty ? rest : '$rest\n$existing',
    );
    if (mounted) _focus[section]?.unfocus();
    widget.onContinued?.call(next.id, rest.length);
  }

  /// The page after this one on the same day, made if there isn't one.
  Future<JournalPage> _nextPage(String id) async {
    final journal = widget.journal;
    final pages = await journal.pages
        .watchForDay(widget.notebook.id, widget.day)
        .first;
    final index = pages.indexWhere((p) => p.id == id);
    if (index >= 0 && index + 1 < pages.length) return pages[index + 1];
    return journal.pages.create(
      notebookId: widget.notebook.id,
      day: widget.day,
      template: PageTemplate.continued.key,
    );
  }

  /// Nothing written in any section.
  bool get _blank => _controllers.values.every((c) => c.text.trim().isEmpty);

  /// Whether the page was blank when last drawn, which decides whether
  /// the template switch shows.
  bool _blankShown = true;

  void _showBlank() {
    final blank = _blank;
    if (blank != _blankShown) setState(() => _blankShown = blank);
  }

  Future<void> _switchTemplate(PageTemplate template) async {
    setState(() {
      _template = template;
      _buildFields();
    });
    final page = widget.page;
    final id = _pageId;
    if (page != null && id == page.id) {
      await widget.journal.pages.update(
        page.copyWith(template: Value(template.key)),
      );
    }
  }

  void _changed(String? section) {
    _showBlank();
    _lastEdited = (key: section);
    _dirty.add(section);
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDelay, save);
  }

  /// Saves the edited sections now. Saves run one after another, so a
  /// slow one never lands after a newer one.
  Future<void> save() {
    _saveTimer?.cancel();
    if (_dirty.isEmpty) return _saving;
    final edits = {
      for (final key in _dirty) key: _controllers[key]?.text ?? '',
    };
    _dirty.clear();
    return _saving = _saving.then((_) => _write(edits));
  }

  Future<void> _write(Map<String?, String> edits) async {
    final journal = widget.journal;
    var id = _pageId;
    if (id == null) {
      // Nothing written yet: today's page stays unsaved.
      if (edits.values.every((text) => text.trim().isEmpty)) return;
      final page = await journal.pages.findOrCreate(
        notebookId: widget.notebook.id,
        day: widget.day,
        template: _template.key,
      );
      id = page.id;
      if (mounted) _attach(id);
    }
    for (final MapEntry(:key, :value) in edits.entries) {
      await journal.items.saveSectionText(
        pageId: id,
        section: key,
        body: value,
      );
    }
  }

  List<Widget> _threeLinesIntro(ColorScheme palette) => [
    const SizedBox(height: 18),
    Text(
      'Three lines',
      style: PageText.writing(palette)
          .copyWith(fontSize: 34, fontWeight: FontWeight.w500, height: 1.1),
    ),
    const SizedBox(height: 4),
    Text(
      'For nights when a full page is too much.',
      style: PageText.writing(palette)
          .copyWith(fontSize: 15, color: palette.onSurfaceVariant),
    ),
  ];

  Widget _templateSwitch(ColorScheme palette) {
    final toThree = _template == PageTemplate.day;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          key: const Key('switch-template'),
          onPressed: () => _switchTemplate(
            toThree ? PageTemplate.threeLines : PageTemplate.day,
          ),
          style: TextButton.styleFrom(
            foregroundColor: palette.onSurfaceVariant,
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            textStyle: const TextStyle(fontSize: 14),
          ),
          child: Text(toThree ? 'Three lines instead' : 'Write a full page'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    final sections = <Widget>[];
    String? heading;
    for (final section in _template.sections) {
      if (section.heading != null && section.heading != heading) {
        sections
          ..add(const SizedBox(height: 14))
          ..add(SectionHeading(section.heading!))
          ..add(const SizedBox(height: 6));
      }
      heading = section.heading;
      sections.add(
        SectionField(
          key: Key('section-${section.key ?? 'free'}'),
          controller: _controllers[section.key]!,
          focusNode: _focus[section.key]!,
          label: section.rowLabel == null
              ? section.heading ?? 'Writing'
              : '${section.heading}, ${section.rowLabel}',
          rowLabel: section.rowLabel,
          onChanged: (_) => _changed(section.key),
        ),
      );
    }

    return ColoredBox(
      color: palette.surface,
      child: Stack(
        children: [
          Padding(
            padding: PaperPage.margin,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: double.infinity,
                child: _HeightReporter(
                  onLayout: _checkFit,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StampedHeader(
                        notebook: widget.notebook,
                        day: widget.day,
                        continued: _template == PageTemplate.continued,
                      ),
                      if (_template == PageTemplate.threeLines)
                        ..._threeLinesIntro(palette),
                      ...sections,
                      if (widget.canSwitchTemplate && _blankShown)
                        _templateSwitch(palette),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (widget.ribbon)
            Positioned(
              top: 0,
              right: 72,
              width: 16,
              height: 30,
              child: Semantics(
                label: 'Today',
                child: CustomPaint(painter: RibbonPainter(palette.tertiary)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Reports its child's height after each layout.
class _HeightReporter extends SingleChildRenderObjectWidget {
  const _HeightReporter({required this.onLayout, super.child});

  final ValueChanged<double> onLayout;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeightReporter(onLayout);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderHeightReporter renderObject,
  ) => renderObject.onLayout = onLayout;
}

class _RenderHeightReporter extends RenderProxyBox {
  _RenderHeightReporter(this.onLayout);

  ValueChanged<double> onLayout;

  @override
  void performLayout() {
    super.performLayout();
    onLayout(size.height);
  }
}
