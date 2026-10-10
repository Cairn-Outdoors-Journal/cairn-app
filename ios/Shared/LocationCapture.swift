import CoreLocation
import Foundation

/// Takes one location fix and records what happened.
///
/// Spike code for stage 5b: it exists to learn what iOS allows from each
/// capture surface (app, widget, Control Center, Action button) at each
/// permission level, so it records failures as carefully as successes.
final class LocationCapture: NSObject, CLLocationManagerDelegate {
  static let timeout: TimeInterval = 20

  /// Captures in flight, kept alive until they finish.
  private static var running = Set<LocationCapture>()

  private var manager: CLLocationManager?
  private var record: [String: Any] = [:]
  private var requestedAt = Date()
  private var completed = false
  private var done: ((String) -> Void)?

  /// "always", "whileInUse", "denied" or "notDetermined".
  static func permissionLevel(_ manager: CLLocationManager = CLLocationManager()) -> String {
    switch manager.authorizationStatus {
    case .authorizedAlways: return "always"
    case .authorizedWhenInUse: return "whileInUse"
    case .denied, .restricted: return "denied"
    case .notDetermined: return "notDetermined"
    @unknown default: return "unknown"
    }
  }

  /// Takes one fix and logs it. Returns the result code: "fix",
  /// "lastKnown", "timeout", "denied", "notDetermined" or "error".
  static func capture(source: String, appState: String) async -> String {
    await withCheckedContinuation { continuation in
      DispatchQueue.main.async {
        let capture = LocationCapture()
        running.insert(capture)
        capture.start(source: source, appState: appState) { result in
          running.remove(capture)
          continuation.resume(returning: result)
        }
      }
    }
  }

  private func start(source: String, appState: String, done: @escaping (String) -> Void) {
    let manager = CLLocationManager()
    self.manager = manager
    self.done = done
    requestedAt = Date()
    let permission = Self.permissionLevel(manager)
    record = [
      "id": UUID().uuidString,
      "platform": "ios",
      "source": source,
      "method": "direct",
      "permission": permission,
      "precise": manager.accuracyAuthorization == .fullAccuracy,
      "appState": appState,
      "requestedAt": Int(requestedAt.timeIntervalSince1970 * 1000),
      "quality": "best",
      "sharedLog": CaptureLog.usesAppGroup,
    ]

    if permission == "denied" || permission == "notDetermined" {
      complete(result: permission, location: nil, error: nil)
      return
    }

    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    DispatchQueue.main.asyncAfter(deadline: .now() + Self.timeout) { [weak self] in
      guard let self, !self.completed else { return }
      let last = self.manager?.location
      self.complete(result: last == nil ? "timeout" : "lastKnown", location: last, error: nil)
    }
    manager.requestLocation()
  }

  private func complete(result: String, location: CLLocation?, error: String?) {
    guard !completed else { return }
    completed = true
    manager?.delegate = nil
    let now = Date()
    record["result"] = result
    record["completedAt"] = Int(now.timeIntervalSince1970 * 1000)
    record["latencyMs"] = Int(now.timeIntervalSince(requestedAt) * 1000)
    if let location {
      record["lat"] = location.coordinate.latitude
      record["lon"] = location.coordinate.longitude
      record["accuracyM"] = location.horizontalAccuracy
      record["altitudeM"] = location.verticalAccuracy >= 0 ? location.altitude : NSNull()
      record["locationAgeMs"] = Int(now.timeIntervalSince(location.timestamp) * 1000)
    }
    if let error { record["error"] = error }
    CaptureLog.append(record)
    done?(result)
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    complete(result: "fix", location: locations.last, error: nil)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    let code = (error as? CLError)?.code
    // kCLErrorDenied here (with permission granted) means iOS refused location
    // in the current state, e.g. "While using" from the background.
    let result = code == .denied ? "deniedNow" : "error"
    complete(result: result, location: nil, error: "\(error)")
  }
}
