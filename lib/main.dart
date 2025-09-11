import 'package:flutter/material.dart';
import 'package:nestra/src/presentation/screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /* await windowManager.ensureInitialized();
  if (!kIsWeb) {
    final packageInfo = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
      packageName: 'dev.dip.nestra',
    );
  } */

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nestra',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}
