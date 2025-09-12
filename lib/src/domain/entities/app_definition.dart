import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'app_definition.freezed.dart';
part 'app_definition.g.dart';

@HiveType(typeId: 1)
@freezed
abstract class AppDefinition with _$AppDefinition {
  const factory AppDefinition({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required Uri url,
    @HiveField(3) String? description,
    @HiveField(4) String? iconPath,
    @HiveField(5) required DateTime createdAt,
    @HiveField(6) required DateTime updatedAt,
  }) = _AppDefinition;

  factory AppDefinition.fromJson(Map<String, dynamic> json) =>
      _$AppDefinitionFromJson(json);
}
