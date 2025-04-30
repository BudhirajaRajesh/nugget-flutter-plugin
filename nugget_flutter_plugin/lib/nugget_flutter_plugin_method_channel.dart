import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'nugget_flutter_plugin_platform_interface.dart';

/// An implementation of [NuggetFlutterPluginPlatform] that uses method channels.
class MethodChannelNuggetFlutterPlugin extends NuggetFlutterPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nugget_flutter_plugin');

  @override
  // Implementation of the platform interface method.
  // Returns Future<void> because invokeMethod is asynchronous.
  // `await` ensures the platform call is sent before the Future completes,
  // and allows potential PlatformExceptions to be propagated.
  Future<void> openChatWithCustomDeeplink({required String clientToken, required String customDeeplink}) async {
    await methodChannel.invokeMethod('openChatWithCustomDeeplink', {
      'clientToken': clientToken,
      'customDeeplink': customDeeplink,
    });
  }
}
