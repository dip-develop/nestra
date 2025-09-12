// Dart script to export PNG icons from the SVG source
// Usage: dart run tool/export_icons.dart

import 'dart:io';

const svgSource = 'assets/branding/nestra_icon.svg';
const outRoot = 'build/icons/nestra';
const sizes = [16, 32, 48, 64, 128, 256, 512, 1024];

Future<bool> commandExists(String cmd) async {
  try {
    final which = await Process.run('which', [cmd]);
    return which.exitCode == 0 &&
        (which.stdout as String).toString().trim().isNotEmpty;
  } catch (_) {
    return false;
  }
}

Future<void> ensureDir(String path) async {
  await Directory(path).create(recursive: true);
}

Future<void> exportWithRsvg(int size) async {
  final out = '$outRoot/$size.png';
  await ensureDir(outRoot);
  final res = await Process.run('rsvg-convert', [
    '-w',
    '$size',
    '-h',
    '$size',
    '-o',
    out,
    svgSource,
  ]);
  if (res.exitCode != 0) {
    stderr.writeln('rsvg-convert failed for $size: ${res.stderr}');
  }
}

Future<void> exportWithInkscape(int size) async {
  final out = '$outRoot/$size.png';
  await ensureDir(outRoot);
  final res = await Process.run('inkscape', [
    '-o',
    out,
    '-w',
    '$size',
    '-h',
    '$size',
    svgSource,
  ]);
  if (res.exitCode != 0) {
    stderr.writeln('inkscape failed for $size: ${res.stderr}');
  }
}

Future<void> main() async {
  final hasRsvg = await commandExists('rsvg-convert');
  final hasInkscape = await commandExists('inkscape');
  if (!hasRsvg && !hasInkscape) {
    stderr.writeln('Neither rsvg-convert nor inkscape found in PATH.');
    exit(1);
  }
  for (final size in sizes) {
    if (hasRsvg) {
      await exportWithRsvg(size);
    } else {
      await exportWithInkscape(size);
    }
  }
  stdout.writeln('Exported icons to $outRoot');
}
