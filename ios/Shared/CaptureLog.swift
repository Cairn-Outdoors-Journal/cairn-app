import Foundation

/// The stage 5b capture log: one JSON object per line, in the App Group
/// container so the app, its widget and its intents all write to one file.
enum CaptureLog {
  static let appGroup = "group.com.cairnjournal.app"
  private static let lock = NSLock()

  static var fileURL: URL {
    let container =
      FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
      ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return container.appendingPathComponent("captures.jsonl")
  }

  /// True when the shared container is available (false means the widget
  /// and the app would be writing to different files).
  static var usesAppGroup: Bool {
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) != nil
  }

  static func append(_ record: [String: Any]) {
    guard let data = try? JSONSerialization.data(withJSONObject: record) else { return }
    lock.lock()
    defer { lock.unlock() }
    let url = fileURL
    var line = data
    line.append(0x0A)
    if let handle = try? FileHandle(forWritingTo: url) {
      handle.seekToEndOfFile()
      handle.write(line)
      try? handle.close()
    } else {
      try? line.write(to: url)
    }
  }

  static func read() -> String {
    lock.lock()
    defer { lock.unlock() }
    return (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
  }

  static func clear() {
    lock.lock()
    defer { lock.unlock() }
    try? FileManager.default.removeItem(at: fileURL)
  }
}
