import 'package:flutter/material.dart';
import 'package:nestra/src/domain/entities/app_definition.dart';
import 'package:nestra/src/presentation/widgets/browser_widget.dart';
import 'package:window_manager/window_manager.dart';

class AppBrowserScreen extends StatefulWidget {
  const AppBrowserScreen({super.key, required this.app});

  final AppDefinition app;

  @override
  State<AppBrowserScreen> createState() => _AppBrowserScreenState();
}

class _AppBrowserScreenState extends State<AppBrowserScreen> {
  @override
  void initState() {
    super.initState();
    windowManager.setTitle(widget.app.name);
  }

  @override
  void didUpdateWidget(covariant AppBrowserScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.app.name != widget.app.name) {
      windowManager.setTitle(widget.app.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BrowserWidget(application: widget.app));
  }
}
