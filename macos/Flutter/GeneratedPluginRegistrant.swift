//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import package_info_plus
import path_provider_foundation
import screen_retriever_macos
import tray_manager
import webview_cef
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  ScreenRetrieverMacosPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverMacosPlugin"))
  TrayManagerPlugin.register(with: registry.registrar(forPlugin: "TrayManagerPlugin"))
  WebviewCefPlugin.register(with: registry.registrar(forPlugin: "WebviewCefPlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
