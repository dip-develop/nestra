import 'dart:io';

/// Returns the user's home directory across platforms.
String homeDir() {
  final env = Platform.environment;
  final home = env['HOME'] ?? env['USERPROFILE'];
  if (home != null && home.isNotEmpty) return home;
  final drive = env['HOMEDRIVE'];
  final path = env['HOMEPATH'];
  if (drive != null && path != null) return '$drive$path';
  return '.'; // fallback
}

/// Root data directory for Nestra (~/.nestra).
String dataRootDir() => '${homeDir()}/.nestra';

/// Root cache directory for Nestra.
String cacheRootDir() => '${dataRootDir()}/cache';

/// Root database directory for Nestra.
String dbRootDir() => '${dataRootDir()}/db';

/// Sanitize app name for filesystem usage.
String sanitizeAppName(String name) => name
    .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// Per-app cache path using app name: ~/.nestra/cache/<sanitized-name>
String perAppCachePath(String appName) =>
    '${cacheRootDir()}/${sanitizeAppName(appName)}';
