import Flutter
import UIKit

public class NuggetFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "nugget_flutter_plugin", binaryMessenger: registrar.messenger())
        let instance = NuggetFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "openChatSDK":
            result("ChatSDK is opened");
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
