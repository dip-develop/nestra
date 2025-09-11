// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nestra/l10n/app_localizations.dart';
import 'package:nestra/l10n/app_localizations_en.dart';
import 'package:nestra/src/core/di/di.dart';
import 'package:nestra/src/core/logging/logger.dart';
import 'package:nestra/src/domain/repositories/app_repository.dart';
import 'package:nestra/src/domain/usecases/apps_usecase.dart';
import 'package:nestra/src/infrastructure/repositories/in_memory_app_repository.dart';
import 'package:nestra/src/presentation/cubit/apps/apps_cubit.dart';
import 'package:nestra/src/presentation/screens/home/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    getIt.reset();
    getIt.registerLazySingleton<AppRepository>(() => InMemoryAppRepository());
    getIt.registerLazySingleton(() => AppsUseCase(getIt()));
    getIt.registerLazySingleton<AppLogger>(() => LoggerImpl());
    getIt.registerFactory(() => AppsCubit(getIt(), getIt()));
  });

  testWidgets('Home screen empty state', (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => getIt<AppsCubit>()..load(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text(AppLocalizationsEn().homeNoApps), findsOneWidget);
  });
}
