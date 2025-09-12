import 'dart:io';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:nestra/src/core/cache/cache_paths.dart';
import 'package:nestra/src/domain/entities/app_definition.dart';
import 'package:nestra/src/domain/repositories/app_repository.dart';
import 'package:nestra/src/infrastructure/repositories/hive_adapters/uri_adapter.dart';

@LazySingleton(as: AppRepository)
class HiveAppRepository implements AppRepository {
  Box<AppDefinition>? _box;
  bool _inited = false;

  Future<void> _ensureOpen() async {
    if (_box != null) return;
    final dir = Directory(dbRootDir());
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    if (!_inited) {
      // Initialize Hive under the configured DB directory (e.g., ~/.nestra/db)
      await Hive.initFlutter(dir.path);
      // Register adapters once (Uri and generated AppDefinition)
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(UriAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(AppDefinitionAdapter());
      }
      _inited = true;
    }

    // Open a typed box. If a legacy untyped box with Map values exists,
    // open it raw, migrate, then reopen typed.
    const boxName = 'apps';
    final exists = await Hive.boxExists(boxName);
    if (exists) {
      // Open raw to inspect legacy content
      final legacy = await Hive.openBox(boxName);
      final needsMigration = legacy.values.any((v) => v is Map);
      if (needsMigration) {
        final entries = legacy.toMap();
        final migratables = <String, AppDefinition>{};
        for (final entry in entries.entries) {
          final key = entry.key;
          final value = entry.value;
          if (key is String && value is Map) {
            try {
              final app = AppDefinition.fromJson(
                Map<String, dynamic>.from(value),
              );
              migratables[key] = app;
            } catch (_) {
              // Skip invalid entries
            }
          }
        }
        await legacy.clear();
        await legacy.close();
        _box = await Hive.openBox<AppDefinition>(boxName);
        if (migratables.isNotEmpty) {
          await _box!.putAll(migratables);
        }
      } else {
        await legacy.close();
        _box = await Hive.openBox<AppDefinition>(boxName);
      }
    } else {
      _box = await Hive.openBox<AppDefinition>(boxName);
    }
  }

  @override
  Future<AppDefinition> register(AppDefinition app) async {
    await _ensureOpen();
    await _box!.put(app.id, app);
    return app;
  }

  @override
  Future<List<AppDefinition>> list() async {
    await _ensureOpen();
    final list = _box!.values.toList(growable: false);
    return list;
  }

  @override
  Future<AppDefinition?> getById(String id) async {
    await _ensureOpen();
    return _box!.get(id);
  }

  @override
  Future<void> remove(String id) async {
    await _ensureOpen();
    await _box!.delete(id);
  }

  @override
  Future<AppDefinition> update(AppDefinition app) async {
    await _ensureOpen();
    if (!_box!.containsKey(app.id)) {
      throw StateError('App not found: ${app.id}');
    }
    await _box!.put(app.id, app);
    return app;
  }
}
