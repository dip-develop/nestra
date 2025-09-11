import 'package:equatable/equatable.dart';

class AppDefinition extends Equatable {
  const AppDefinition({
    required this.id,
    required this.name,
    required this.url,
    this.iconPath,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final Uri url;
  final String? iconPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppDefinition copyWith({
    String? name,
    Uri? url,
    String? iconPath,
    DateTime? updatedAt,
  }) => AppDefinition(
    id: id,
    name: name ?? this.name,
    url: url ?? this.url,
    iconPath: iconPath ?? this.iconPath,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );

  @override
  List<Object?> get props => [id, name, url, iconPath, createdAt, updatedAt];
}
