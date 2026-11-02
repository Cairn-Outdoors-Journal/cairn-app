/// Page templates. For now they are fixed; editing them (switching
/// sections on or off, renaming, reordering) comes in a later stage.
///
/// Each section's writing is stored as one text item whose `section` is the
/// section's [TemplateSection.key]. Keys never change, so renaming a section
/// later only changes its label.
library;

class TemplateSection {
  const TemplateSection(this.key, {this.heading, this.rowLabel});

  /// Stored on the page item; null is a page's free writing.
  final String? key;

  /// The label above the writing. Sections in a row under one heading,
  /// like High and Low, share it.
  final String? heading;

  /// A short label at the start of the line, for sections in a row.
  final String? rowLabel;
}

enum PageTemplate {
  /// The default day page (CONCEPT): The Day, High / Low, People, Trail
  /// Notes, Tomorrow.
  day('day', [
    TemplateSection('the_day', heading: 'The Day'),
    TemplateSection('high', heading: 'High / Low', rowLabel: 'HIGH'),
    TemplateSection('low', heading: 'High / Low', rowLabel: 'LOW'),
    TemplateSection('people', heading: 'People'),
    TemplateSection('trail_notes', heading: 'Trail Notes'),
    TemplateSection('tomorrow', heading: 'Tomorrow'),
  ]),

  /// For nights when a full page is too much.
  threeLines('three_lines', [
    TemplateSection('best', heading: 'Best moment'),
    TemplateSection('hardest', heading: 'Hardest moment'),
    TemplateSection('remember', heading: 'One thing to remember'),
  ]),

  /// The rest of a day that didn't fit on its first page.
  continued('continued', [TemplateSection(null)]),

  /// A page with no template: free writing.
  blank(null, [TemplateSection(null)]);

  const PageTemplate(this.key, this.sections);

  /// Stored in `pages.template`.
  final String? key;
  final List<TemplateSection> sections;

  static PageTemplate fromKey(String? key) =>
      values.firstWhere((t) => t.key == key, orElse: () => blank);
}
