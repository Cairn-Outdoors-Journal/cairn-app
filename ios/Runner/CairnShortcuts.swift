import AppIntents

/// Makes "Save location point" available in Shortcuts and to the Action
/// button without the person building a shortcut themselves.
@available(iOS 17.0, *)
struct CairnShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: CapturePointIntent(),
      phrases: [
        "Save a point in \(.applicationName)",
        "Mark this spot in \(.applicationName)",
      ],
      shortTitle: "Save point",
      systemImageName: "triangle"
    )
  }
}
