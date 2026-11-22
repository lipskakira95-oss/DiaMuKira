import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../domain/catalog.dart';
import '../domain/user_data.dart';

class ContentRepository {
  ContentRepository({
    this.client,
    this.base,
    this.store,
    bool? offlineOnly,
    Future<String> Function()? loadBundled,
  }) : offlineOnly = offlineOnly ?? const bool.fromEnvironment('OFFLINE_ONLY'),
       _loadBundled =
           loadBundled ??
           (() => rootBundle.loadString('assets/content/questions.json'));
  final http.Client? client;
  final Uri? base;
  final UserStore? store;
  final bool offlineOnly;
  final Future<String> Function() _loadBundled;
  Catalog _decode(String text, String origin) {
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Content must be an object');
    }
    return Catalog.fromJson(decoded, origin: origin);
  }

  Future<Catalog> load() async {
    const configured = String.fromEnvironment('API_BASE_URL');
    final endpoint =
        base ??
        (configured.isNotEmpty
            ? Uri.parse(configured)
            : (kIsWeb ? Uri.base : Uri.parse('http://10.0.2.2:8080/')));
    if (!offlineOnly) {
      final client = this.client ?? http.Client();
      try {
        final response = await client
            .get(endpoint.resolve('/api/v1/content'))
            .timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final text = utf8.decode(response.bodyBytes);
          final catalog = _decode(text, 'server');
          try {
            await store?.saveContent(
              CachedContent(
                version: catalog.version,
                mode: catalog.mode,
                json: text,
              ),
            );
          } on Exception {
            // A storage failure must not hide valid content from the user.
          }
          return catalog;
        }
      } on Exception {
        // The reviewed status of bundled data is validated like API content.
      } finally {
        if (this.client == null) client.close();
      }
    }
    try {
      final cached = await store?.loadContent();
      if (cached != null) {
        final catalog = _decode(cached.json, 'cache');
        if (catalog.version == cached.version && catalog.mode == cached.mode) {
          return catalog;
        }
      }
    } on Exception {
      // Corrupt or unavailable local data must not replace the bundled copy.
    }
    return _decode(await _loadBundled(), 'bundled');
  }
}
