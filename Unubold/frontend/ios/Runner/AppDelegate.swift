import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyCKADU6YSAtT6eDVWkObqEO1gZ_rfpvxr4")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
