//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import local_notifier
import package_info_plus
import screen_retriever_macos
import tray_manager
import webview_cef
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  LocalNotifierPlugin.register(with: registry.registrar(forPlugin: "LocalNotifierPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  ScreenRetrieverMacosPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverMacosPlugin"))
  TrayManagerPlugin.register(with: registry.registrar(forPlugin: "TrayManagerPlugin"))
  WebviewCefPlugin.register(with: registry.registrar(forPlugin: "WebviewCefPlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
