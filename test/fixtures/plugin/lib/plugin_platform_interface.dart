import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'plugin_method_channel.dart';

abstract class PluginPlatform extends PlatformInterface {
  /// Constructs a PluginPlatform.
  PluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static PluginPlatform _instance = MethodChannelPlugin();

  /// The default instance of [PluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelPlugin].
  static PluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PluginPlatform] when
  /// they register themselves.
  static set instance(PluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
