import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    LocationSpikePlugin.scheduleFromLaunchArguments()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // Stage 5b location spike bridge (lib/spikes/location_capture).
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "LocationSpikePlugin") {
      LocationSpikePlugin.register(with: registrar)
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CairnStorage") {
      registerStorageChannel(registrar.messenger())
    }
  }

  /// Phone backups never carry the journal (ADR 0011), so its folder is kept
  /// out of iCloud and computer backups.
  private func registerStorageChannel(_ messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "cairn/storage", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "excludeFromBackup", let path = call.arguments as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      var url = URL(fileURLWithPath: path, isDirectory: true)
      var values = URLResourceValues()
      values.isExcludedFromBackup = true
      do {
        try url.setResourceValues(values)
        result(nil)
      } catch {
        result(FlutterError(code: "exclude_failed", message: error.localizedDescription, details: nil))
      }
    }
  }
}
