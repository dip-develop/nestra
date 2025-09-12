import 'dart:io';

import 'package:nestra/src/core/cache/cache_paths.dart';
import 'package:nestra/src/core/desktop/icon_helper.dart';
import 'package:nestra/src/domain/entities/app_definition.dart';

String _xdgApplicationsDir() => '${homeDir()}/.local/share/applications';

Future<void> _ensureDir(String path) async {
  await Directory(path).create(recursive: true);
}

/// Install a desktop entry for the Nestra hub (main app).
Future<File> installNestraDesktopEntry({String? iconPath}) async {
  final dir = _xdgApplicationsDir();
  await _ensureDir(dir);
  final file = File('$dir/nestra.desktop');
  final icon = iconPath ?? await prepareNestraIcon256();
  final content = [
    '[Desktop Entry]',
    'Type=Application',
    'Name=Nestra',
    'Exec=nestra',
    if (icon != null) 'Icon=$icon',
    'Terminal=false',
    'Categories=Network;Utility;',
    'StartupWMClass=Nestra',
  ].join('\n');
  await file.writeAsString(content);
  return file;
}

/// Install a desktop entry for a registered app.
Future<File> installAppDesktopEntry(
  AppDefinition app, {
  String? iconPath,
}) async {
  final dir = _xdgApplicationsDir();
  await _ensureDir(dir);
  final desktopId = 'nestra-${app.id}'.replaceAll(
    RegExp(r'[^A-Za-z0-9._-]'),
    '-',
  );
  final file = File('$dir/$desktopId.desktop');
  String? icon;
  final provided = iconPath ?? app.iconPath;
  if (provided != null && provided.toLowerCase().endsWith('.svg')) {
    icon = provided;
  } else {
    icon = provided != null
        ? await prepareAppIcon256(app)
        : await prepareNestraIcon256();
  }
  final content = [
    '[Desktop Entry]',
    'Type=Application',
    'Name=${app.name}',
    'Exec=nestra --app ${app.id}',
    if (icon != null) 'Icon=$icon',
    'Terminal=false',
    'Categories=Network;Utility;',
    'StartupWMClass=$desktopId',
  ].join('\n');
  await file.writeAsString(content);
  return file;
}

// Icon preparation is handled in icon_helper.dart
