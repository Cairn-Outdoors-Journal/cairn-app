import CoreLocation
import Flutter
import UIKit

/// Bridge for the stage 5b location spike screen (lib/spikes/location_capture).
final class LocationSpikePlugin: NSObject, FlutterPlugin {
  private let manager = CLLocationManager()

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "cairn/location_spike", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(LocationSpikePlugin(), channel: channel)
  }

  /// Test hook: launched with `--spike-capture-after <seconds>`, Cairn takes
  /// one capture after that delay, whether or not it is still in the
  /// foreground. Switching to another app in the meantime approximates the
  /// Action button running the intent while Cairn is in the background.
  static func scheduleFromLaunchArguments() {
    let args = ProcessInfo.processInfo.arguments
    guard let flag = args.firstIndex(of: "--spike-capture-after"), flag + 1 < args.count,
      let delay = Double(args[flag + 1])
    else { return }
    var task = UIBackgroundTaskIdentifier.invalid
    task = UIApplication.shared.beginBackgroundTask(withName: "spike-capture") {
      UIApplication.shared.endBackgroundTask(task)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
      let state: String
      switch UIApplication.shared.applicationState {
      case .active: state = "foreground"
      case .inactive: state = "inactive"
      default: state = "background"
      }
      Task {
        _ = await LocationCapture.capture(source: "timer", appState: state)
        UIApplication.shared.endBackgroundTask(task)
      }
    }
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "status":
      result([
        "permission": LocationCapture.permissionLevel(manager),
        "precise": manager.accuracyAuthorization == .fullAccuracy,
        "sharedLog": CaptureLog.usesAppGroup,
      ])
    case "readLog":
      result(CaptureLog.read())
    case "clearLog":
      CaptureLog.clear()
      result(nil)
    case "captureNow":
      Task {
        let state = await MainActor.run { () -> String in
          UIApplication.shared.applicationState == .active ? "foreground" : "background"
        }
        let outcome = await LocationCapture.capture(source: "app", appState: state)
        result(outcome)
      }
    case "requestWhileUsing":
      manager.requestWhenInUseAuthorization()
      result(nil)
    case "requestAlways":
      // iOS asks for "While using" first; this then offers the upgrade.
      manager.requestAlwaysAuthorization()
      result(nil)
    case "openSettings":
      if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
