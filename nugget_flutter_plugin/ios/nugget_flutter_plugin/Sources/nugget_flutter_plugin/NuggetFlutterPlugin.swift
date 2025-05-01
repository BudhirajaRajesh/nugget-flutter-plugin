import Flutter
import UIKit
import NuggetSDK

// Define constants for method channel names and arguments
// ... existing code ...

// Conform to FlutterPlugin and the required NuggetSDK delegates
public class NuggetFlutterPlugin: NSObject, FlutterPlugin, 
                                    NuggetAuthProviderDelegate, 
                                    NuggetThemeProviderDelegate, // Use the actual protocol name
                                    NuggetFontProviderDelegate,  // Use the actual protocol name
                                    NuggetTicketCreationDelegate { // <-- REVERTED PROTOCOL NAME
    
    // Hold the channel for sending messages back to Dart
    let channel: FlutterMethodChannel
    // Hold the factory instance returned by the SDK initialization
    var nuggetFactory: NuggetFactory? // Assuming NuggetFactory is the type returned
    // Store theme/font data if needed for delegates
    var themeDataMap: [String: Any]?
    var fontDataMap: [String: Any]?
    
    // --- ADDED: Stream Handlers ---
    private let ticketSuccessHandler = TicketStreamHandler()
    private let ticketFailureHandler = TicketStreamHandler()
    // TODO: Add handlers for token and permission status later
    // private let tokenHandler = BasicStreamHandler<String>()
    // private let permissionHandler = BasicStreamHandler<Int>()
    // --- END ADDED ---

    // Initializer to store the channel
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "nugget_flutter_plugin", binaryMessenger: registrar.messenger())
        // Create instance, passing the channel
        let instance = NuggetFlutterPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)

        // --- ADDED: Event Channels for Native -> Dart streams ---
        let ticketSuccessEventChannel = FlutterEventChannel(name: "nugget_flutter_plugin/onTicketCreationSucceeded", binaryMessenger: registrar.messenger())
        ticketSuccessEventChannel.setStreamHandler(instance.ticketSuccessHandler)
        
        let ticketFailureEventChannel = FlutterEventChannel(name: "nugget_flutter_plugin/onTicketCreationFailed", binaryMessenger: registrar.messenger())
        ticketFailureEventChannel.setStreamHandler(instance.ticketFailureHandler)
        
        // TODO: Register other event channels (token, permission) here
        // let tokenEventChannel = FlutterEventChannel(name: "nugget_flutter_plugin/onTokenUpdated", binaryMessenger: registrar.messenger())
        // tokenEventChannel.setStreamHandler(instance.tokenHandler)
        // 
        // let permissionEventChannel = FlutterEventChannel(name: "nugget_flutter_plugin/onPermissionStatusUpdated", binaryMessenger: registrar.messenger())
        // permissionEventChannel.setStreamHandler(instance.permissionHandler)
        // --- END ADDED ---

        // Register the Platform View Factory
        let viewFactory = NuggetChatViewFactory(messenger: registrar.messenger(), pluginInstance: instance)
        registrar.register(viewFactory, withId: "com.yourcompany.nugget/chat_view") // Must match viewType in Dart
    }
    
    // Handle calls FROM Dart
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            handleInitialize(call: call, result: result)
        case "openChatWithCustomDeeplink":
            handleOpenChatWithCustomDeeplink(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // --- Method Call Handlers --- 

    private func handleInitialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Ensure args is a dictionary, but don't require apiKey
        guard let args = call.arguments as? [String: Any] else {
            // Return a generic invalid arguments error if casting fails
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments received for initialize method", details: nil))
            return
        }
        
        // Store theme/font data if provided
        self.themeDataMap = args["theme"] as? [String: Any]
        self.fontDataMap = args["font"] as? [String: Any]
        
        print("NuggetFlutterPlugin Swift: Initializing NuggetSDK...")
        
        // *** TODO: Create a separate instance for NuggetPushNotificationsListener ***
        // let notificationListener = ... // This needs to be created and managed
        // let notificationListener = NuggetPushListener() // Create an instance <- COMMENTED OUT
        
        // Call the native SDK initialization
        // IMPORTANT: Pass `self` for delegates the plugin implements
        // *** TODO: Update the notificationDelegate argument below ***
        self.nuggetFactory = NuggetSDK.initializeNuggetFactory(
            authDelegate: self, 
            notificationDelegate: .init(), // Pass nil for now
            customThemeProviderDelegate: self,
            customFontProviderDelegate: self, 
            ticketCreationDelegate: self 
        )

        if self.nuggetFactory != nil {
             print("NuggetFlutterPlugin Swift: NuggetSDK Initialized Successfully.")
            result(nil) // Indicate success to Dart
        } else {
             print("NuggetFlutterPlugin Swift: NuggetSDK Initialization Failed.")
            result(FlutterError(code: "INIT_FAILED", message: "Native NuggetSDK initialization returned nil", details: nil))
        }
    }

    private func handleOpenChatWithCustomDeeplink(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let customDeeplink = args["customDeeplink"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing required argument: customDeeplink", details: nil))
            return
        }
        
        print("NuggetFlutterPlugin Swift: Opening chat with deeplink: \(customDeeplink)")

        guard let factory = self.nuggetFactory else {
             print("NuggetFlutterPlugin Swift: Error - NuggetFactory is not initialized.")
            result(FlutterError(code: "NOT_INITIALIZED", message: "Nugget SDK is not initialized. Call initialize first.", details: nil))
            return
        }

        // Get the chat view controller from the SDK factory
        // Assuming the method exists and returns a UIViewController
        guard let chatViewController = factory.contentViewController(deeplink: customDeeplink) else {
            print("NuggetFlutterPlugin Swift: Error - Failed to get contentViewController from NuggetFactory.")
            result(FlutterError(code: "FACTORY_ERROR", message: "Failed to retrieve chat view controller from NuggetFactory", details: nil))
            return
        }
        
        // Present the view controller
        DispatchQueue.main.async {
            guard let rootViewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                 print("NuggetFlutterPlugin Swift: Error - Could not find root view controller.")
                result(FlutterError(code: "UI_ERROR", message: "Could not find root view controller to present/push chat", details: nil))
                return
            }
            
            // Attempt to find the topmost navigation controller
            var topNavController: UINavigationController? = nil
            var currentVC = rootViewController
            while let presented = currentVC.presentedViewController {
                currentVC = presented
            }
            
            if let navController = currentVC as? UINavigationController {
                topNavController = navController
            } else if let tabBarController = currentVC as? UITabBarController, 
                      let selectedNavController = tabBarController.selectedViewController as? UINavigationController {
                topNavController = selectedNavController
            } else {
                // If root itself isn't a nav controller, check its children (might be embedded)
                topNavController = currentVC.children.compactMap { $0 as? UINavigationController }.first
            }

            // Push if a navigation controller is found, otherwise present modally
            if let navController = topNavController {
                 print("NuggetFlutterPlugin Swift: Found UINavigationController. Pushing chat view controller...")
                navController.pushViewController(chatViewController, animated: true)
                result(nil) // Indicate success back to Dart
            } else {
                 print("NuggetFlutterPlugin Swift: No UINavigationController found. Presenting modally as fallback...")
                // Fallback to modal presentation
                chatViewController.modalPresentationStyle = .fullScreen // Or .automatic, .pageSheet etc.
                rootViewController.present(chatViewController, animated: true) {
                     print("NuggetFlutterPlugin Swift: Chat view controller presented modally (fallback).")
                    result(nil) // Indicate success back to Dart (even though it was modal)
                }
            }
        }
    }

    // MARK: - NuggetAuthProviderDelegate Implementation
    public func authManager(requiresAuthInfo completion: @escaping (NuggetAuthUserInfo?, Error?) -> Void) {
        print("NuggetFlutterPlugin Swift: Delegate method requiresAuthInfo called by SDK. Invoking Dart...")
        channel.invokeMethod("requireAuthInfo", arguments: nil) { flutterResult in
            DispatchQueue.main.async {
                self.handleAuthCompletion(flutterResult: flutterResult, sdkCompletion: completion)
            }
        }
    }

    public func authManager(requestRefreshAuthInfo completion: @escaping (NuggetAuthUserInfo?, Error?) -> Void) {
        print("NuggetFlutterPlugin Swift: Delegate method requestRefreshAuthInfo called by SDK. Invoking Dart...")
        channel.invokeMethod("refreshAuthInfo", arguments: nil) { flutterResult in
             DispatchQueue.main.async {
                 self.handleAuthCompletion(flutterResult: flutterResult, sdkCompletion: completion)
             }
        }
    }
    
    private func handleAuthCompletion(flutterResult: Any?, sdkCompletion: @escaping (NuggetAuthUserInfo?, Error?) -> Void) {
        guard let resultData = flutterResult else {
             print("NuggetFlutterPlugin Swift: Auth completion - Dart returned nil result (unexpected).")
             let error = NSError(domain: "PluginError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Auth failed: Dart returned nil"])
             sdkCompletion(nil, error)
             return
         }

         if let error = resultData as? FlutterError {
             print("NuggetFlutterPlugin Swift: Auth completion - Dart returned error: \(error.code) - \(error.message ?? "")")
             // Convert FlutterError to NSError for the SDK completion handler
             let nsError = NSError(domain: "FlutterError", 
                                 code: Int(error.code) ?? -1, 
                                 userInfo: [NSLocalizedDescriptionKey: error.message ?? "Error from Dart auth",
                                            "FlutterErrorDetails": error.details ?? "N/A"])
             sdkCompletion(nil, nsError)
         } else if let dict = resultData as? [String: Any] {
             print("NuggetFlutterPlugin Swift: Auth completion - Dart returned data. Parsing...")
             // Attempt to parse the dictionary using the Swift struct
             // *** TODO: Verify SwiftNuggetAuthUserInfo matches NuggetAuthUserInfo protocol ***
             if let userInfo = SwiftNuggetAuthUserInfo(fromDictionary: dict) {
                  print("NuggetFlutterPlugin Swift: Auth completion - Parsed successfully.")
                 sdkCompletion(userInfo, nil) // SUCCESS! Call SDK completion with Swift object
             } else {
                 print("NuggetFlutterPlugin Swift: Auth completion - Failed to parse dictionary from Dart.")
                 let error = NSError(domain: "PluginError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Auth failed: Could not parse auth info from Dart"])
                 sdkCompletion(nil, error)
             }
         } else {
              print("NuggetFlutterPlugin Swift: Auth completion - Dart returned unexpected type: \(type(of: resultData))")
              let error = NSError(domain: "PluginError", code: -4, userInfo: [NSLocalizedDescriptionKey: "Auth failed: Received unexpected data type from Dart"])
              sdkCompletion(nil, error)
         }
    }

    // MARK: - NuggetPushNotificationsListener Handling
    // *** We removed conformance. Listener logic needs to be in a separate object. ***

    // MARK: - NuggetTicketCreationDelegate Implementation
    public func ticketCreationSucceeded(with conversationID: String) {
        print("NuggetFlutterPlugin Swift: Delegate ticketCreationSucceeded. Sending event to Dart...")
        ticketSuccessHandler.sendEvent(data: conversationID)
    }

    public func ticketCreationFailed(withError errorMessage: String?) {
        print("NuggetFlutterPlugin Swift: Delegate ticketCreationFailed. Sending event to Dart...")
        ticketFailureHandler.sendEvent(data: errorMessage)
    }
    
    // MARK: - NuggetThemeProviderDelegate Implementation 
    // *** TODO: Verify actual protocol requirements ***
    public var customThemePaletteString: String? {
        return self.themeDataMap?["paletteHexString"] as? String
    }
    
    public var customThemeTintString: String? {
        return self.themeDataMap?["tintColorHex"] as? String
    }
    
    public var interfaceStyle: UIUserInterfaceStyle {
        guard let styleString = self.themeDataMap?["interfaceStyle"] as? String else {
            return .unspecified // Default if not provided or invalid
        }
        switch styleString {
            case "light": return .light
            case "dark": return .dark
            default: return .unspecified // Maps Dart 'system' to unspecified
        }
    }

    // MARK: - NuggetFontProviderDelegate Implementation
    // *** TODO: Verify FontPropertiesMapping protocol requirements ***
    public var customFontMapping: NuggetFontPropertiesMapping? {
        guard let fontMap = self.fontDataMap else {
            return nil
        }
        return SwiftNuggetFontMapping(fromDictionary: fontMap)
    }
}

// Placeholder class for the push notification listener
/*  <- COMMENT OUT START
class NuggetPushListener: NuggetPushNotificationsListener {
    // TODO: Implement required methods if any, and add logic 
    //       to communicate back to NuggetFlutterPlugin (e.g., via closures or NotificationCenter)
    // For now, just providing a basic class instance.
    override init() {
        super.init()
        print("NuggetPushListener initialized")
    }
    
    // Example of potential methods (replace with actual required methods)
    // override func onTokenUpdated(token: String) { ... }
    // override func onPermissionStatusUpdated(granted: Bool) { ... }
}
*/ // <- COMMENT OUT END

// MARK: - Platform View Factory
class NuggetChatViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    private weak var pluginInstance: NuggetFlutterPlugin?

    init(messenger: FlutterBinaryMessenger, pluginInstance: NuggetFlutterPlugin) {
        self.messenger = messenger
        self.pluginInstance = pluginInstance
        super.init()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return NuggetChatPlatformView(frame: frame, 
                                      viewIdentifier: viewId, 
                                      arguments: args, 
                                      pluginInstance: pluginInstance)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - Platform View
class NuggetChatPlatformView: NSObject, FlutterPlatformView {
    private let _view: UIView
    private var chatViewController: UIViewController?

    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, pluginInstance: NuggetFlutterPlugin?) {
        _view = UIView(frame: frame)
        _view.backgroundColor = .lightGray 
        super.init()

        guard let factory = pluginInstance?.nuggetFactory else {
            print("NuggetChatPlatformView Error: NuggetFactory not available.")
            // ... add error label ...
            return
        }

        // Parse arguments to get deeplink, default to empty string if not provided
        let creationArgs = args as? [String: Any]
        let deeplink = creationArgs?["deeplink"] as? String ?? "" // Default to empty string
        print("NuggetChatPlatformView: Initializing with deeplink: '\(deeplink)'")

        // Get the Chat View Controller from the Nugget SDK Factory using the deeplink
        guard let chatVC = factory.contentViewController(deeplink: deeplink) else { 
             print("NuggetChatPlatformView Error: Failed to get chat view controller from factory.contentViewController(deeplink:).")
             // TODO: Add error display to _view
             return
        }
        
        self.chatViewController = chatVC
        
        // Add the native view controller's view to our container view
        if let chatView = chatVC.view {
            chatView.frame = _view.bounds 
            // Fix: Explicitly specify UIView.AutoresizingMask
            chatView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            _view.addSubview(chatView)
             print("NuggetChatPlatformView: Native chat view added.")
        } else {
            print("NuggetChatPlatformView Error: Chat view controller's view is nil.")
            // TODO: Add error display to _view
        }
    }

    func view() -> UIView {
        return _view
    }
    
    deinit {
         print("NuggetChatPlatformView: Deinit")
    }
}

// MARK: - Swift Data Structures

// *** TODO: Verify this matches NuggetAuthUserInfo protocol ***
struct SwiftNuggetAuthUserInfo: NuggetAuthUserInfo {
    let clientID: Int
    let accessToken: String
    let userID: String
    let userName: String? // MADE OPTIONAL
    let photoURL: String
    let displayName: String
    
    init?(fromDictionary dict: [String: Any]) {
        guard let clientID = dict["clientID"] as? Int,
              let accessToken = dict["accessToken"] as? String,
              let userID = dict["userID"] as? String, 
              // let userName = dict["userName"] as? String, <- REMOVED GUARD let (will assign optional below)
              let photoURL = dict["photoURL"] as? String,
              let displayName = dict["displayName"] as? String
        else {
            print("SwiftNuggetAuthUserInfo: Failed to parse dictionary from Dart")
            return nil
        }
        self.clientID = clientID
        self.accessToken = accessToken
        self.userID = userID
        self.userName = dict["userName"] as? String // Assign optional value
        self.photoURL = photoURL
        self.displayName = displayName
    }
}

// *** TODO: Verify this matches NuggetFontPropertiesMapping protocol ***
class SwiftNuggetFontMapping: NuggetFontPropertiesMapping {
    let fontName: String
    let fontFamily: String
    let fontWeightMapping: [NuggetFontWeights : String]
    let fontSizeMappingDict: [String: Int]
    
    init?(fromDictionary dict: [String: Any]) {
        guard let fontName = dict["fontName"] as? String,
              let fontFamily = dict["fontFamily"] as? String,
              let rawWeightMap = dict["fontWeightMapping"] as? [String: String],
              let rawSizeMap = dict["fontSizeMapping"] as? [String: Int]
        else {
            print("SwiftNuggetFontMapping: Failed to parse dictionary from Dart")
            return nil
        }
        self.fontName = fontName
        self.fontFamily = fontFamily
        self.fontSizeMappingDict = rawSizeMap
        
        var finalWeightMap: [NuggetFontWeights: String] = [:]
        for (key, value) in rawWeightMap {
            if let weightEnum = NuggetFontWeights(string: key) {
                finalWeightMap[weightEnum] = value
            } else {
                 print("SwiftNuggetFontMapping: Warning - Unknown font weight key '\(key)' from Dart")
            }
        }
        self.fontWeightMapping = finalWeightMap
    }
    
    func fontSizeMapping(fontSize: NuggetFontSizes) -> Int {
        let key = fontSize.stringValue 
        return fontSizeMappingDict[key] ?? 14
    }
}

// *** TODO: Verify these extensions match SDK enums/protocols ***
extension NuggetFontWeights {
    init?(string: String) {
        switch string.lowercased() {
            case "light": self = .light
            case "regular": self = .regular
            case "medium": self = .medium
            case "semibold": self = .semiBold 
            case "bold": self = .bold
            case "extrabold": self = .extraBold
            case "black": self = .black
            default: return nil
        }
    }
}

extension NuggetFontSizes {
    var stringValue: String {
        switch self {
            case .font050: return "font050"
            case .font100: return "font100"
            case .font200: return "font200"
            case .font300: return "font300"
            case .font400: return "font400"
            case .font500: return "font500"
            case .font600: return "font600"
            case .font700: return "font700"
            case .font800: return "font800"
            case .font900: return "font900"
        }
    }
}

// --- ADDED: Generic Stream Handler ---
/// A basic stream handler that stores the event sink and provides a method to send events.
class TicketStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?

    /// Called when Flutter starts listening.
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("TicketStreamHandler: onListen called")
        self.eventSink = events
        return nil // No error
    }

    /// Called when Flutter stops listening.
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("TicketStreamHandler: onCancel called")
        self.eventSink = nil
        return nil // No error
    }

    /// Sends data to the Flutter side via the event sink.
    /// Make sure `onListen` has been called before sending events.
    func sendEvent(data: Any?) {
        guard let sink = self.eventSink else {
            print("TicketStreamHandler: Warning - eventSink is nil. Cannot send event.")
            return
        }
        // Ensure we send on the main thread if needed, though EventChannel handles this often
        DispatchQueue.main.async {
            sink(data)
        }
    }
}
// --- END ADDED ---
