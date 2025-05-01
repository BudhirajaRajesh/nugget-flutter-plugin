import Flutter
import UIKit
// Make sure NuggetSDK is imported if needed by GeneratedPluginRegistrant or other logic
// import NuggetSDK 

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Proceed with default Flutter plugin registration FIRST
    GeneratedPluginRegistrant.register(with: self)

    // Get the FlutterViewController created by FlutterAppDelegate
    guard let controller = window?.rootViewController as? FlutterViewController else {
      fatalError("rootViewController is not type FlutterViewController")
    }

    // Create a UINavigationController with the FlutterViewController as its root
    let navigationController = UINavigationController(rootViewController: controller)
    // Optionally hide the navigation bar if Flutter handles all navigation UI.
    // You might want to keep it visible if you expect native screens (like the chat)
    // to show a navigation bar with a back button.
    // navigationController.isNavigationBarHidden = true 

    // Set the UINavigationController as the window's root view controller
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible() // Ensure the window is set up correctly

    // Call the superclass implementation AFTER setting up the rootViewController
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
