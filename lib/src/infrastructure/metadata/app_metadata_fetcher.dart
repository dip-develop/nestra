import 'dart:convert';
import 'dart:io';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:nestra/src/core/web/user_agent.dart';

@injectable
class AppMetadataFetcher {
  static const Map<String, String> _defaultHeaders = {
    'User-Agent': kChromiumUserAgent,
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
  };

  Future<AppMetadata> fetch(Uri url) async {
    final client = http.Client();
    try {
      final resp = await client.get(url, headers: _defaultHeaders);
      if (resp.statusCode >= 200 && resp.statusCode < 400) {
        final doc = html_parser.parse(utf8.decode(resp.bodyBytes));
        // Try manifest
        final manifestHref = _manifestHref(doc);
        if (manifestHref != null) {
          final manifestUri = _resolve(url, manifestHref);
          final m = await _fetchManifest(client, manifestUri);
          if (m != null) return m.withFallbacks(url, doc);
        }
        // Fallback to HTML meta
        final meta = _parseMeta(url, doc);
        return meta;
      }
      throw HttpException('HTTP ${resp.statusCode}');
    } finally {
      client.close();
    }
  }

  String? _manifestHref(dom.Document doc) {
    final el =
        doc.querySelector("link[rel='manifest']") ??
        doc.querySelector('link[rel="manifest"]');
    return el?.attributes['href'];
  }

  Future<AppMetadata?> _fetchManifest(http.Client client, Uri uri) async {
    final resp = await client.get(uri, headers: _defaultHeaders);
    if (resp.statusCode >= 200 && resp.statusCode < 400) {
      final map =
          json.decode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      final name = _cleanTitle((map['name'] ?? map['short_name']) as String?);
      final description = map['description'] as String?;
      final icons =
          (map['icons'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map((e) => e.cast<String, dynamic>())
              .toList() ??
          const <Map<String, dynamic>>[];
      final iconSrc = _pickBestIconSrc(icons);
      return AppMetadata(
        name: name,
        description: description,
        iconUrl: iconSrc != null ? _resolve(uri, iconSrc) : null,
        startUrl: _safeUri(map['start_url'], base: uri),
      );
    }
    return null;
  }

  AppMetadata _parseMeta(Uri pageUrl, dom.Document doc) {
    String? metaContent(String selector) =>
        doc.querySelector(selector)?.attributes['content'];
    final selectedName =
        doc.querySelector('title')?.text ??
        metaContent('meta[property="og:title"]') ??
        metaContent('meta[name="application-name"]');
    final name = _cleanTitle(selectedName);
    final description =
        metaContent('meta[name="description"]') ??
        metaContent('meta[property="og:description"]');
    // Collect all potential icons and pick by type priority and max size.
    final iconEls = doc.querySelectorAll(
      'link[rel~="icon"], link[rel="shortcut icon"], link[rel~="apple-touch-icon"], link[rel="apple-touch-icon"]',
    );
    Uri? iconUrl;
    if (iconEls.isNotEmpty) {
      final best = _pickBestLinkIcon(iconEls);
      if (best != null) {
        iconUrl = _resolve(pageUrl, best);
      }
    } else {
      // Legacy fallback to first available
      final iconHref =
          doc.querySelector('link[rel="icon"]')?.attributes['href'] ??
          doc.querySelector('link[rel="shortcut icon"]')?.attributes['href'] ??
          doc.querySelector('link[rel="apple-touch-icon"]')?.attributes['href'];
      iconUrl = iconHref != null ? _resolve(pageUrl, iconHref) : null;
    }
    return AppMetadata(name: name, description: description, iconUrl: iconUrl);
  }

  String? _cleanTitle(String? title) {
    if (title == null) return null;
    var t = title.trim();
    // Remove leading "Unsupported Browser |" (case-insensitive), then trim again.
    t = t.replaceFirst(
      RegExp(r'^(unsupported\s+browser\s*\|\s*)', caseSensitive: false),
      '',
    );
    return t.trim();
  }

  Uri _resolve(Uri base, String href) => base.resolve(href);

  Uri? _safeUri(dynamic v, {required Uri base}) {
    if (v is String && v.isNotEmpty) {
      return base.resolve(v);
    }
    return null;
  }

  String? _pickBestIconSrc(List<Map<String, dynamic>> icons) {
    Map<String, dynamic>? best;
    int bestType = -1;
    int bestSize = -1;
    for (final icon in icons) {
      final src = icon['src'] as String?;
      if (src == null) continue;
      final type = icon['type'] as String?;
      final sizes = icon['sizes'] as String?; // e.g., "192x192 512x512"
      final typeRank = _iconTypeRank(type, src);
      final sizeScore =
          _maxSizeFromSizes(sizes) ??
          (typeRank == 1 ? 100000 : 0); // svg often has no size
      if (typeRank > bestType ||
          (typeRank == bestType && sizeScore > bestSize)) {
        bestType = typeRank;
        bestSize = sizeScore;
        best = icon;
      }
    }
    return best?['src'] as String?;
  }

  // For HTML <link> icon candidates
  String? _pickBestLinkIcon(List<dom.Element> links) {
    String? bestHref;
    int bestType = -1;
    int bestSize = -1;
    for (final el in links) {
      final href = el.attributes['href'];
      if (href == null || href.isEmpty) continue;
      final type = el.attributes['type'];
      final sizes = el.attributes['sizes'];
      final typeRank = _iconTypeRank(type, href);
      final sizeScore =
          _maxSizeFromSizes(sizes) ?? (typeRank == 1 ? 100000 : 0);
      if (typeRank > bestType ||
          (typeRank == bestType && sizeScore > bestSize)) {
        bestType = typeRank;
        bestSize = sizeScore;
        bestHref = href;
      }
    }
    return bestHref;
  }

  // Ranking: png=3, webp=2, svg=1, others=0
  int _iconTypeRank(String? mime, String url) {
    final m = mime?.toLowerCase();
    if (m != null) {
      if (m.contains('image/png')) return 3;
      if (m.contains('image/webp')) return 2;
      if (m.contains('image/svg')) return 1;
    }
    final u = url.toLowerCase();
    if (u.endsWith('.png')) return 3;
    if (u.endsWith('.webp')) return 2;
    if (u.endsWith('.svg')) return 1;
    return 0;
  }

  int? _maxSizeFromSizes(String? sizes) {
    if (sizes == null || sizes.isEmpty) return null;
    int best = 0;
    for (final part in sizes.split(RegExp(r'\s+'))) {
      final sp = part.split('x');
      if (sp.length == 2) {
        final w = int.tryParse(sp[0]) ?? 0;
        final h = int.tryParse(sp[1]) ?? 0;
        if (w > best) best = w;
        if (h > best) best = h;
      }
    }
    return best > 0 ? best : null;
  }
}

class AppMetadata {
  AppMetadata({this.name, this.description, this.iconUrl, this.startUrl});
  final String? name;
  final String? description;
  final Uri? iconUrl;
  final Uri? startUrl;

  AppMetadata withFallbacks(Uri pageUrl, dom.Document doc) {
    final fallback = AppMetadataFetcher()._parseMeta(pageUrl, doc);
    return AppMetadata(
      name: name ?? fallback.name,
      description: description ?? fallback.description,
      iconUrl: iconUrl ?? fallback.iconUrl,
      startUrl: startUrl ?? fallback.startUrl,
    );
  }
}
