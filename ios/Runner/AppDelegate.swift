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
  }
}
