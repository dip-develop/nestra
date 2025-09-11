import 'package:flutter/material.dart';
import 'package:nestra/src/domain/usecases/copilot.dart';
import 'package:nestra/src/presentation/widgets/browser_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BrowserWidget(application: Copilot()));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
