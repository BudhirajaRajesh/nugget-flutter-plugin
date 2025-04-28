import 'package:flutter_test/flutter_test.dart';
import 'package:nugget_flutter_plugin/nugget_flutter_plugin.dart';
import 'package:nugget_flutter_plugin/nugget_flutter_plugin_platform_interface.dart';
import 'package:nugget_flutter_plugin/nugget_flutter_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNuggetFlutterPluginPlatform
    with MockPlatformInterfaceMixin
    implements NuggetFlutterPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NuggetFlutterPluginPlatform initialPlatform = NuggetFlutterPluginPlatform.instance;

  test('$MethodChannelNuggetFlutterPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNuggetFlutterPlugin>());
  });

  test('getPlatformVersion', () async {
    NuggetFlutterPlugin nuggetFlutterPlugin = NuggetFlutterPlugin();
    MockNuggetFlutterPluginPlatform fakePlatform = MockNuggetFlutterPluginPlatform();
    NuggetFlutterPluginPlatform.instance = fakePlatform;

    expect(await nuggetFlutterPlugin.getPlatformVersion(), '42');
  });
}
