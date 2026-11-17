import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:diia_my/data/content_repository.dart';

import 'domain/catalog_test.dart' show bundle;

void main() {
  test('reads UTF8 content from the configured Go API', () async {
    final repository = ContentRepository(
      client: MockClient((request) async {
        expect(request.url.toString(), 'https://quiz.example/api/v1/content');
        return http.Response.bytes(utf8.encode(jsonEncode(bundle())), 200);
      }),
      base: Uri.parse('https://quiz.example/'),
      loadBundled: () async => throw StateError('must not use bundle'),
    );
    final catalog = await repository.load();
    expect(catalog.origin, 'server');
    expect(catalog.questions.first.text, 'Чи важлива повага?');
  });
  test(
    'unavailable or malformed API falls back to the validated bundle',
    () async {
      for (final response in [
        http.Response('unavailable', 503),
        http.Response('[]', 200),
        http.Response('{broken', 200),
      ]) {
        final repository = ContentRepository(
          client: MockClient((_) async => response),
          loadBundled: () async => jsonEncode(bundle()),
        );
        expect((await repository.load()).origin, 'bundled');
      }
    },
  );
  test(
    'invalid bundled data fails explicitly instead of returning empty content',
    () async {
      final repository = ContentRepository(
        client: MockClient((_) async => http.Response('', 503)),
        loadBundled: () async => '{}',
      );
      expect(repository.load(), throwsFormatException);
    },
  );
}
