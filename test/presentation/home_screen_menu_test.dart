import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nestra/l10n/app_localizations.dart';
import 'package:nestra/l10n/app_localizations_en.dart';
import 'package:nestra/src/core/di/di.dart';
import 'package:nestra/src/core/logging/logger.dart';
import 'package:nestra/src/domain/repositories/app_repository.dart';
import 'package:nestra/src/domain/usecases/apps_usecase.dart';
import 'package:nestra/src/presentation/cubit/apps/apps_cubit.dart';
import 'package:nestra/src/presentation/screens/home/home_screen.dart';
import '../support/fake_app_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    getIt.reset();
    // Wiring minimal DI for the screen.
    getIt.registerLazySingleton<AppRepository>(() => FakeAppRepository());
    getIt.registerLazySingleton(() => AppsUseCase(getIt()));
    getIt.registerLazySingleton<AppLogger>(() => LoggerImpl());
    getIt.registerFactory(() => AppsCubit(getIt(), getIt()));

    // Seed one app so the list has an item with a popup menu.
    final apps = getIt<AppsUseCase>();
    await apps.create(name: 'Example', url: Uri.parse('https://example.com'));
  });

  testWidgets('popup menu shows all actions', (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => getIt<AppsCubit>()..load(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(),
        ),
      ),
    );

    // Let load() complete and the list render.
    await tester.pumpAndSettle();

    // Open the popup menu of the first list tile (trailing IconButton inside PopupMenuButton).
    final menuButtonFinder = find.byType(PopupMenuButton<String>).first;
    await tester.tap(menuButtonFinder);
    await tester.pumpAndSettle();

    // Verify localized menu entries are present.
    final en = AppLocalizationsEn();
    expect(find.text(en.popupEdit), findsOneWidget);
    expect(find.text(en.popupClearCache), findsOneWidget);
    expect(find.text(en.popupCreateLauncher), findsOneWidget);
    expect(find.text(en.popupDelete), findsOneWidget);
  });
}
