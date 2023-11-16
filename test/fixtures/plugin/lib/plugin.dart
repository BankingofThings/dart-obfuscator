
import 'plugin_platform_interface.dart';

class Plugin {
  Future<String?> getPlatformVersion() {
    return PluginPlatform.instance.getPlatformVersion();
  }
}
