String sanitizeId(String input) {
  final lower = input.toLowerCase();
  final replaced = lower.replaceAll(RegExp(r'[^a-z0-9\-]+'), '-');
  final collapsed = replaced.replaceAll(RegExp(r'-{2,}'), '-');
  return collapsed.replaceAll(RegExp(r'^-+|-+$'), '');
}

String idFromUrl(Uri url) {
  final host = url.host.toLowerCase();
  final parts = host.split('.').where((p) => p.isNotEmpty).toList();
  if (parts.length >= 3) {
    final base = parts[parts.length - 2];
    // pick first meaningful subdomain (skip generic ones)
    final ignore = {'www', 'm', 'mobile'};
    final sub = parts.firstWhere(
      (p) => !ignore.contains(p),
      orElse: () => parts.first,
    );
    if (ignore.contains(sub)) return sanitizeId(base);
    return sanitizeId('$base-$sub');
  } else if (parts.length == 2) {
    return sanitizeId(parts.first);
  } else if (parts.length == 1) {
    return sanitizeId(parts.first);
  }
  return sanitizeId(host);
}
