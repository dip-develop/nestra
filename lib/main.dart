import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:nestra/l10n/app_localizations.dart';
import 'package:nestra/src/core/cli/cli_commands.dart';
import 'package:nestra/src/core/desktop/icon_helper.dart';
import 'package:nestra/src/core/di/di.dart';
import 'package:nestra/src/domain/entities/app_definition.dart';
import 'package:nestra/src/domain/usecases/apps_usecase.dart';
import 'package:nestra/src/presentation/cubit/apps/apps_cubit.dart';
import 'package:nestra/src/presentation/screens/browser/app_browser_screen.dart';
import 'package:nestra/src/presentation/screens/home/home_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  // CLI pre-UI handling (list, register, etc.).
  final parsed = parseCliArgs(args);
  final cmd = parsed.command;
  final appsUC = getIt<AppsUseCase>();
  await executePreUiCommand(cmd, apps: appsUC);
  await windowManager.ensureInitialized();
  final packageInfo = await PackageInfo.fromPlatform();
  launchAtStartup.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
    packageName: 'dev.dip.nestra',
  );

  AppDefinition? launchApp;
  if (cmd is CliRunApp) {
    final app = await appsUC.get(cmd.appId);
    launchApp = app;
  }

  // Note: Avoid direct GTK notifier usage; Flutter embedder manages GTK.

  // Prepare tray icon (prefer generated 256px PNG from our SVG asset)
  String? trayIconPath;
  if (Platform.isWindows) {
    trayIconPath = 'images/tray_icon.ico';
  } else {
    trayIconPath = await prepareNestraIcon256() ?? 'images/tray_icon.png';
  }
  await trayManager.setIcon(trayIconPath);
  Menu menu = Menu(
    items: [
      MenuItem(key: 'show_window', label: 'Show Window'),
      MenuItem.separator(),
      MenuItem(key: 'exit_app', label: 'Exit App'),
    ],
  );
  await trayManager.setContextMenu(menu);
  trayManager.addListener(_TrayHandler());

  runApp(MyApp(launchApp: launchApp));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.launchApp});

  final AppDefinition? launchApp;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AppsCubit>()..load(),
      child: MaterialApp(
        title: 'Nestra',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          ...GlobalUbuntuLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: launchApp == null
            ? const HomeScreen()
            : AppBrowserScreen(app: launchApp!),
      ),
    );
  }
}

class _TrayHandler with TrayListener {
  @override
  void onTrayIconMouseDown() async {
    // Show window when clicking tray icon
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show_window':
        await windowManager.show();
        await windowManager.focus();
        break;
      case 'exit_app':
        // Ensure clean exit on all platforms
        await trayManager.destroy();
        exit(0);
      default:
        break;
    }
  }
}
