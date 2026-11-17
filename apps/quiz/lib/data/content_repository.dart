import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../domain/catalog.dart';

class ContentRepository {
  ContentRepository({
    this.client,
    this.base,
    Future<String> Function()? loadBundled,
  }) : _loadBundled =
           loadBundled ??
           (() => rootBundle.loadString('assets/content/questions.json'));
  final http.Client? client;
  final Uri? base;
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
    final client = this.client ?? http.Client();
    try {
      final response = await client
          .get(endpoint.resolve('/api/v1/content'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return _decode(utf8.decode(response.bodyBytes), 'server');
      }
    } on Exception {
      // The reviewed status of bundled data is validated just like API content.
    } finally {
      if (this.client == null) client.close();
    }
    return _decode(await _loadBundled(), 'bundled');
  }
}
