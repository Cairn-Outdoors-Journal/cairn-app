import AppIntents
import Foundation
#if !CAIRN_EXTENSION
  import UIKit
#endif

/// "Save location point": runs from the Action button (through Shortcuts),
/// the home-screen widget and the Control Center button, without opening
/// Cairn.
@available(iOS 16.0, *)
struct CapturePointIntent: AppIntent {
  static var title: LocalizedStringResource = "Save location point"
  static var description = IntentDescription("Saves where you are now to today's page in Cairn.")
  static var openAppWhenRun: Bool = false

  @Parameter(title: "Source", default: "intent")
  var source: String

  init() {}

  init(source: String) {
    self.source = source
  }

  func perform() async throws -> some IntentResult & ProvidesDialog {
    let state = await Self.processState()
    let result = await LocationCapture.capture(source: source, appState: state)
    let message = result == "fix" ? "Point saved." : "No point saved (\(result))."
    return .result(dialog: IntentDialog(stringLiteral: message))
  }

  /// Where the intent is running: the widget extension's own process, or the
  /// app in the foreground or background.
  @MainActor
  private static func processState() -> String {
    #if CAIRN_EXTENSION
      return "extension"
    #else
      switch UIApplication.shared.applicationState {
      case .active: return "foreground"
      case .inactive: return "inactive"
      case .background: return "background"
      @unknown default: return "unknown"
      }
    #endif
  }
}
