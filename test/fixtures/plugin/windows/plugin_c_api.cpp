#include "include/plugin/plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "plugin.h"

void PluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  plugin::Plugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
