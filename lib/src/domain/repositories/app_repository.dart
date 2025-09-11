import 'package:nestra/src/domain/entities/app_definition.dart';

abstract interface class AppRepository {
  Future<AppDefinition> register(AppDefinition app);
  Future<List<AppDefinition>> list();
  Future<AppDefinition?> getById(String id);
  Future<void> remove(String id);
  Future<AppDefinition> update(AppDefinition app);
}
