import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'nugget_flutter_plugin_platform_interface.dart';

/// An implementation of [NuggetFlutterPluginPlatform] that uses method channels.
class MethodChannelNuggetFlutterPlugin extends NuggetFlutterPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nugget_flutter_plugin');

  @override
  void openChatWithCustomDeeplink({required String clientToken, required String customDeeplink}) {
    methodChannel.invokeMethod<String>('openChatWithCustomDeeplink', {
      'clientToken': clientToken,
      'customDeeplink': customDeeplink,
    });
  }
}
