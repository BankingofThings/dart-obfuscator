import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'plugin_platform_interface.dart';

/// An implementation of [PluginPlatform] that uses method channels.
class MethodChannelPlugin extends PluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
