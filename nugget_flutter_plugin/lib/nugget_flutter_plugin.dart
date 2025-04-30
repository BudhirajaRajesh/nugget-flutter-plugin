import 'nugget_flutter_plugin_platform_interface.dart';

class NuggetFlutterPlugin {
 
  void openChatWithCustomDeeplink({required String clientToken, required String customDeeplink}) {
    NuggetFlutterPluginPlatform.instance.openChatWithCustomDeeplink(clientToken: clientToken, customDeeplink: customDeeplink);
  }
}
