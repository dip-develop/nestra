import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nestra/src/core/cache/cache_paths.dart';
import 'package:nestra/src/core/web/user_agent.dart';
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

    final controller = WebviewManager().createWebView(
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
    final rootCachePath = perAppCachePath(widget.application.id);
    await Directory(rootCachePath).create(recursive: true);

    await WebviewManager().initialize(
      userAgent: kChromiumUserAgent,
      persistSessionCookies: true,
      persistUserPreferences: true,
      cachePath: rootCachePath,
      initTimeout: const Duration(seconds: 10),
    );

    if (!mounted) return;
    _createWebView();
    if (_controller == null) return;
    final url = widget.application.url.toString();

    await _controller!.initialize(url);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return controller == null
        ? const Center(child: CircularProgressIndicator())
        : ValueListenableBuilder<bool>(
            valueListenable: controller,
            builder: (context, value, child) {
              return (controller.value)
                  ? controller.webviewWidget
                  : controller.loadingWidget;
            },
          );
  }

  @override
  void dispose() {
    _controller?.dispose();
    WebviewManager().quit();
    super.dispose();
  }
}
