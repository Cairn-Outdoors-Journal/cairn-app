import 'dart:async';

import 'package:flutter/material.dart';

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

  @override
  State<DayPage> createState() => DayPageState();
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
    final template = _templateOf(widget);
    if (template != _template) {
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
      first = false;
    });
  }

  void _changed(String? section) {
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StampedHeader(
                      notebook: widget.notebook,
                      day: widget.day,
                      continued: _template == PageTemplate.continued,
                    ),
                    ...sections,
                  ],
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
