import 'package:flutter/material.dart';
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
    _createWebView();
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
    if (_controller == null) return;
    await _webviewManager
        .initialize(userAgent: 'nestra/userAgent')
        .timeout(const Duration(seconds: 20));
    if (!mounted) return;
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
