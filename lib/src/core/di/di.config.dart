// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:nestra/src/core/logging/logger.dart' as _i895;
import 'package:nestra/src/domain/repositories/app_repository.dart' as _i364;
import 'package:nestra/src/domain/usecases/apps_usecase.dart' as _i754;
import 'package:nestra/src/infrastructure/metadata/app_metadata_fetcher.dart'
    as _i605;
import 'package:nestra/src/infrastructure/repositories/hive_app_repository.dart'
    as _i804;
import 'package:nestra/src/presentation/cubit/apps/apps_cubit.dart' as _i387;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i605.AppMetadataFetcher>(() => _i605.AppMetadataFetcher());
    gh.lazySingleton<_i895.AppLogger>(() => _i895.LoggerImpl());
    gh.lazySingleton<_i364.AppRepository>(() => _i804.HiveAppRepository());
    gh.lazySingleton<_i754.AppsUseCase>(
      () => _i754.AppsUseCase(gh<_i364.AppRepository>()),
    );
    gh.factory<_i387.AppsCubit>(
      () => _i387.AppsCubit(gh<_i754.AppsUseCase>(), gh<_i895.AppLogger>()),
    );
    return this;
  }
}
