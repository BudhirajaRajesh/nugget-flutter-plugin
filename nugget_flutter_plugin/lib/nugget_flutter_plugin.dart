import 'nugget_flutter_plugin_platform_interface.dart';

// Export the handler setup so users can access it via the main plugin import.
export 'nugget_plugin_callback_handler.dart';

class NuggetFlutterPlugin {
 
  /// Opens the chat interface using a specific client token and deeplink.
  ///
  /// Delegates to the platform-specific implementation.
  /// Returns a [Future<void>] reflecting the asynchronous nature of the platform call
  /// and allowing for error handling.
  Future<void> openChatWithCustomDeeplink({required String clientToken, required String customDeeplink}) {
    return NuggetFlutterPluginPlatform.instance.openChatWithCustomDeeplink(clientToken: clientToken, customDeeplink: customDeeplink);
  }
}
