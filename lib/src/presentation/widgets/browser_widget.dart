import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nestra/src/core/cache/cache_paths.dart';
import 'package:nestra/src/core/web/user_agent.dart';
import 'package:webview_cef/src/webview_inject_user_script.dart';
import 'package:webview_cef/webview_cef.dart';

import '../../domain/entities/app_definition.dart';

class BrowserWidget extends StatefulWidget {
  const BrowserWidget({super.key, required this.application});
  final AppDefinition application;

  @override
  State<BrowserWidget> createState() => _BrowserWidgetState();
}

class _BrowserWidgetState extends State<BrowserWidget> {
  WebViewController? _controller;
  final _webviewManager = WebviewManager();
  bool _initScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_initScheduled) {
        _initScheduled = true;
        initPlatformState();
      }
    });
  }

  void _createWebView() {
    var injectUserScripts = InjectUserScripts();
    injectUserScripts.add(
      UserScript(
        "console.log('injectScript_in_LoadStart')",
        ScriptInjectTime.LOAD_START,
      ),
    );
    injectUserScripts.add(
      UserScript(
        "console.log('injectScript_in_LoadEnd')",
        ScriptInjectTime.LOAD_END,
      ),
    );

    final controller = _webviewManager.createWebView(
      loading: const Center(child: CircularProgressIndicator()),
      injectUserScripts: injectUserScripts,
    );

    controller.setWebviewListener(
      WebviewEventsListener(
        onTitleChanged: (t) {},
        onUrlChanged: (url) {},
        onConsoleMessage: (level, message, source, line) {},
        onLoadStart: (controller, url) {},
        onLoadEnd: (controller, url) {},
      ),
    );

    setState(() {
      _controller = controller;
    });
  }

  Future<void> initPlatformState() async {
    // Compute per-app cache directory: ~/.nestra/cache/<app-id>
    final rootCachePath = perAppCachePath(widget.application.id);
    // Ensure the directory exists
    await Directory(rootCachePath).create(recursive: true);

    // TODO(dip): Pass rootCachePath to CEF once the plugin exposes it.
    // For now we only prepare the directory and initialize as usual.
    await _webviewManager
        .initialize(userAgent: kChromiumUserAgent)
        .timeout(const Duration(seconds: 20));
    if (!mounted) return;
    // Create WebView only after CEF initialized
    _createWebView();
    if (_controller == null) return;
    final url = widget.application.url.toString();
    await _controller!.initialize(url).timeout(const Duration(seconds: 20));
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return controller == null
        ? const Center(child: CircularProgressIndicator())
        : ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              return controller.value
                  ? controller.webviewWidget
                  : controller.loadingWidget;
            },
          );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _webviewManager.quit();
    super.dispose();
  }
}
