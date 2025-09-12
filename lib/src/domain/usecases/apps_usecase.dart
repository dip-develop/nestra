import 'package:injectable/injectable.dart';
import 'package:nestra/src/domain/entities/app_definition.dart';
import 'package:nestra/src/domain/repositories/app_repository.dart';
import 'package:nestra/src/domain/utils/app_id.dart';

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
    String? description,
  }) async {
    final now = DateTime.now();
    final app = AppDefinition(
      id: idFromUrl(url),
      name: name,
      url: url,
      description: description,
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
    String? description,
  }) async {
    final existing = await _repo.getById(id);
    if (existing == null) throw StateError('App not found: $id');
    final updated = existing.copyWith(
      name: name,
      url: url,
      description: description,
      iconPath: iconPath,
      updatedAt: DateTime.now(),
    );
    return _repo.update(updated);
  }

  Future<void> delete(String id) => _repo.remove(id);
}

// idFromUrl and sanitizeId moved to utils/app_id.dart for reuse
