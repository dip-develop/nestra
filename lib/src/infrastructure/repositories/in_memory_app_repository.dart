import 'dart:collection';

import 'package:injectable/injectable.dart';
import 'package:nestra/src/domain/entities/app_definition.dart';
import 'package:nestra/src/domain/repositories/app_repository.dart';

@LazySingleton(as: AppRepository)
class InMemoryAppRepository implements AppRepository {
  final _store = HashMap<String, AppDefinition>();

  @override
  Future<AppDefinition> register(AppDefinition app) async {
    _store[app.id] = app;
    return app;
  }

  @override
  Future<List<AppDefinition>> list() async =>
      _store.values.toList(growable: false);

  @override
  Future<AppDefinition?> getById(String id) async => _store[id];

  @override
  Future<void> remove(String id) async {
    _store.remove(id);
  }

  @override
  Future<AppDefinition> update(AppDefinition app) async {
    if (!_store.containsKey(app.id)) {
      throw StateError('App not found: ${app.id}');
    }
    _store[app.id] = app;
    return app;
  }
}
