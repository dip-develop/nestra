import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nestra/src/core/logging/logger.dart';
import 'package:nestra/src/domain/entities/app_definition.dart';
import 'package:nestra/src/domain/usecases/apps_usecase.dart';

sealed class AppsState {}

final class AppsInitial extends AppsState {}

final class AppsLoading extends AppsState {}

final class AppsReady extends AppsState {
  AppsReady(this.apps);
  final List<AppDefinition> apps;
}

final class AppsError extends AppsState {
  AppsError(this.message);
  final String message;
}

@injectable
class AppsCubit extends Cubit<AppsState> {
  AppsCubit(this._apps, this._logger) : super(AppsInitial());
  final AppsUseCase _apps;
  final AppLogger _logger;

  Future<void> load() async {
    emit(AppsLoading());
    try {
      final apps = await _apps.list();
      emit(AppsReady(apps));
    } catch (e, st) {
      _logger.error('load failed', e, st);
      emit(AppsError('Failed to load apps'));
    }
  }

  Future<void> addApp({
    required String name,
    required Uri url,
    String? iconPath,
    String? description,
  }) => _apps
      .create(
        name: name,
        url: url,
        iconPath: iconPath,
        description: description,
      )
      .then((_) => load())
      .catchError((e, st) {
        _logger.error('addApp failed', e);
      });

  Future<void> editApp({
    required String id,
    required String name,
    required Uri url,
    String? iconPath,
    String? description,
  }) async {
    try {
      await _apps.update(
        id: id,
        name: name,
        url: url,
        iconPath: iconPath,
        description: description,
      );
      await load();
    } catch (e, st) {
      _logger.error('editApp failed', e, st);
    }
  }

  Future<void> deleteApp(String id) async {
    try {
      await _apps.delete(id);
      await load();
    } catch (e, st) {
      _logger.error('deleteApp failed', e, st);
    }
  }
}
