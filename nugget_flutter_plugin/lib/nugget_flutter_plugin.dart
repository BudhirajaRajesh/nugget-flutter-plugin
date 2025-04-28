import 'nugget_flutter_plugin_platform_interface.dart';

class NuggetFlutterPlugin {
  Future<String?> getPlatformVersion() {
    return NuggetFlutterPluginPlatform.instance.getPlatformVersion();
  }

  void openChatSDK() {
    print("ChatSDK opened");
    return NuggetFlutterPluginPlatform.instance.openChatSDK();
  }
}
