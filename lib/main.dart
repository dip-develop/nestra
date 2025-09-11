import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:nestra/l10n/app_localizations.dart';
import 'package:nestra/src/core/cli/cli_commands.dart';
import 'package:nestra/src/core/di/di.dart';
import 'package:nestra/src/domain/usecases/apps_usecase.dart';
import 'package:nestra/src/presentation/cubit/apps/apps_cubit.dart';
import 'package:nestra/src/presentation/screens/browser/app_browser_screen.dart';
import 'package:nestra/src/presentation/screens/home/home_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  // Decide initial route: open specific app if provided via CLI, else Home.
  AppDefinitionForLaunch? launchApp;
  if (cmd is CliRunApp) {
    final app = await appsUC.get(cmd.appId);
    if (app != null) {
      launchApp = AppDefinitionForLaunch(app);
    }
  }
  runApp(MyApp(launchApp: launchApp));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.launchApp});

  final AppDefinitionForLaunch? launchApp;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AppsCubit>()..load(),
      child: MaterialApp(
        title: 'Nestra',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: launchApp == null
            ? const HomeScreen()
            : AppBrowserScreen(app: launchApp!.app),
      ),
    );
  }
}

// Lightweight wrapper to avoid importing domain types in top-level conditional logic
class AppDefinitionForLaunch {
  AppDefinitionForLaunch(this.app);
  final dynamic app; // AppDefinition
}
