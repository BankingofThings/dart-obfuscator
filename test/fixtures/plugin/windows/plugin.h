#ifndef FLUTTER_PLUGIN_PLUGIN_H_
#define FLUTTER_PLUGIN_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace plugin {

class Plugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  Plugin();

  virtual ~Plugin();

  // Disallow copy and assign.
  Plugin(const Plugin&) = delete;
  Plugin& operator=(const Plugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace plugin

#endif  // FLUTTER_PLUGIN_PLUGIN_H_
