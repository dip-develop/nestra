import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:nestra/src/core/cache/cache_paths.dart';
import 'package:nestra/src/domain/entities/app_definition.dart';

String _iconsRoot() => '${homeDir()}/.nestra/icons';

Future<void> _ensureDir(String path) async =>
    Directory(path).create(recursive: true);

// Note: No external converters; we use package:image for raster formats.

/// Returns a 256px PNG Nestra icon path if available; copies from build export if needed.
Future<String?> prepareNestraIcon256() async {
  final iconsDir = _iconsRoot();
  await _ensureDir(iconsDir);
  final target = File('$iconsDir/nestra-256.png');
  if (await target.exists()) return target.path;
  final exported = File('build/icons/nestra/256.png');
  if (await exported.exists()) {
    await exported.copy(target.path);
    return target.path;
  }
  return null;
}

/// Prepare a 256px PNG for the app icon if possible; returns the resulting path or null.
Future<String?> prepareAppIcon256(AppDefinition app) async {
  final iconsDir = _iconsRoot();
  await _ensureDir(iconsDir);
  final safe = sanitizeAppName(app.id);
  final target = File('$iconsDir/$safe.png');
  if (await target.exists()) return target.path;
  // Backward compatibility: older filename pattern
  final legacy = File('$iconsDir/$safe-256.png');
  if (await legacy.exists()) {
    await legacy.copy(target.path);
    return target.path;
  }

  final srcPath = app.iconPath;
  if (srcPath == null || srcPath.isEmpty) return null;
  final src = File(srcPath);
  if (!await src.exists()) return null;

  final lower = srcPath.toLowerCase();
  if (lower.endsWith('.png')) {
    // Resize to 256 if needed
    final bytes = await src.readAsBytes();
    final decoded = img.decodePng(bytes);
    if (decoded != null) {
      final resized = img.copyResize(decoded, width: 256, height: 256);
      await target.writeAsBytes(img.encodePng(resized));
      return target.path;
    }
    await src.copy(target.path);
    return target.path;
  }
  if (lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.webp')) {
    final bytes = await src.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      final resized = img.copyResize(decoded, width: 256, height: 256);
      await target.writeAsBytes(img.encodePng(resized));
      return target.path;
    }
    await src.copy(target.path);
    return target.path;
  }
  // SVG or unknown: just copy; desktop can often use SVG directly
  await src.copy(target.path);
  return target.path;
}

/// Downloads an icon from the given URL and stores it under ~/.nestra/icons.
/// If the URL is an SVG and a converter is available, also renders a 256px PNG
/// and returns its path; otherwise returns the saved file path.
Future<String?> downloadIconFromUrl(
  Uri url, {
  required String baseName, // Use AppDefinition.id when available
}) async {
  try {
    final client = http.Client();
    try {
      final resp = await client.get(url);
      if (resp.statusCode < 200 || resp.statusCode >= 400) {
        return null;
      }
      final iconsDir = _iconsRoot();
      await _ensureDir(iconsDir);
      final safe = sanitizeAppName(baseName.isEmpty ? url.host : baseName);
      // Try infer by content-type or URL
      final contentType = resp.headers['content-type'] ?? '';
      final isSvg =
          contentType.contains('image/svg') ||
          url.path.toLowerCase().endsWith('.svg');
      if (isSvg) {
        final svgFile = File('$iconsDir/$safe.svg');
        await svgFile.writeAsBytes(resp.bodyBytes);
        return svgFile.path;
      }
      // Raster path: decode and write a 256px PNG
      final decoded = img.decodeImage(resp.bodyBytes);
      if (decoded != null) {
        final resized = img.copyResize(decoded, width: 256, height: 256);
        final target = File('$iconsDir/$safe.png');
        await target.writeAsBytes(img.encodePng(resized));
        return target.path;
      }
      // Unknown: write raw bytes
      final raw = File('$iconsDir/$safe.bin');
      await raw.writeAsBytes(resp.bodyBytes);
      return raw.path;
    } finally {
      client.close();
    }
  } catch (_) {
    return null;
  }
}

/// Delete cached webview data for a given app name.
Future<bool> clearAppCache(String appName) async {
  try {
    final dir = Directory(perAppCachePath(appName));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    return true;
  } catch (_) {
    return false;
  }
}
