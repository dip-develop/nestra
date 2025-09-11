import 'package:injectable/injectable.dart';
import 'package:nestra/src/domain/entities/app_definition.dart';
import 'package:nestra/src/domain/repositories/app_repository.dart';

@LazySingleton()
class AppsUseCase {
  const AppsUseCase(this._repo);
  final AppRepository _repo;

  Future<List<AppDefinition>> list() => _repo.list();
  Future<AppDefinition?> get(String id) => _repo.getById(id);

  Future<AppDefinition> create({
    required String name,
    required Uri url,
    String? iconPath,
  }) async {
    final now = DateTime.now();
    final app = AppDefinition(
      id: now.microsecondsSinceEpoch.toString(),
      name: name,
      url: url,
      iconPath: iconPath,
      createdAt: now,
      updatedAt: now,
    );
    return _repo.register(app);
  }

  Future<AppDefinition> update({
    required String id,
    required String name,
    required Uri url,
    String? iconPath,
  }) async {
    final existing = await _repo.getById(id);
    if (existing == null) throw StateError('App not found: $id');
    final updated = existing.copyWith(
      name: name,
      url: url,
      iconPath: iconPath,
      updatedAt: DateTime.now(),
    );
    return _repo.update(updated);
  }

  Future<void> delete(String id) => _repo.remove(id);
}
