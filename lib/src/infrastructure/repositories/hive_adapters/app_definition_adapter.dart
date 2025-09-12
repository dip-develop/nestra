import 'package:hive_ce/hive.dart';
import 'package:nestra/src/domain/entities/app_definition.dart';

/// Manual Hive adapter for AppDefinition to avoid generator constraints
/// (e.g., Uri and DateTime handling) and keep Freezed/json intact.
class AppDefinitionAdapter extends TypeAdapter<AppDefinition> {
  @override
  final int typeId = 1; // Keep stable across releases

  @override
  AppDefinition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return AppDefinition(
      id: fields[0] as String,
      name: fields[1] as String,
      url: Uri.parse(fields[2] as String),
      description: fields[3] as String?,
      iconPath: fields[4] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[6] as int),
    );
  }

  @override
  void write(BinaryWriter writer, AppDefinition obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.url.toString())
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.iconPath)
      ..writeByte(5)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(6)
      ..write(obj.updatedAt.millisecondsSinceEpoch);
  }
}
