import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'nugget_flutter_plugin_method_channel.dart';

abstract class NuggetFlutterPluginPlatform extends PlatformInterface {
  /// Constructs a NuggetFlutterPluginPlatform.
  NuggetFlutterPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static NuggetFlutterPluginPlatform _instance =
      MethodChannelNuggetFlutterPlugin();

  /// The default instance of [NuggetFlutterPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelNuggetFlutterPlugin].
  static NuggetFlutterPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NuggetFlutterPluginPlatform] when
  /// they register themselves.
  static set instance(NuggetFlutterPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Opens the chat interface using a specific client token and deeplink.
  ///
  /// Returns a [Future<void>] because platform channel calls are asynchronous.
  /// This allows the caller to `await` the completion of the call and handle
  /// potential [PlatformException]s using `try-catch`.
  Future<void> openChatWithCustomDeeplink({required String clientToken, required String customDeeplink}) {
    throw UnimplementedError('openChatWithCustomDeeplink() has not been implemented');
  }
}
