import 'package:flutter_test/flutter_test.dart';
import 'package:plugin/plugin.dart';
import 'package:plugin/plugin_platform_interface.dart';
import 'package:plugin/plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPluginPlatform
    with MockPlatformInterfaceMixin
    implements PluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PluginPlatform initialPlatform = PluginPlatform.instance;

  test('$MethodChannelPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPlugin>());
  });

  test('getPlatformVersion', () async {
    Plugin plugin = Plugin();
    MockPluginPlatform fakePlatform = MockPluginPlatform();
    PluginPlatform.instance = fakePlatform;

    expect(await plugin.getPlatformVersion(), '42');
  });
}
