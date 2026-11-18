import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:diia_my/data/content_repository.dart';
import 'package:diia_my/data/memory_user_store.dart';
import 'package:diia_my/domain/user_data.dart';

import 'domain/catalog_test.dart' show bundle;

class FailingSaveStore extends MemoryUserStore {
  FailingSaveStore({super.content});

  @override
  Future<void> saveContent(CachedContent content) =>
      throw Exception('simulated full storage');
}

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

  test('valid API content is cached and later works offline', () async {
    final store = MemoryUserStore();
    final online = ContentRepository(
      store: store,
      client: MockClient(
        (_) async =>
            http.Response.bytes(utf8.encode(jsonEncode(bundle())), 200),
      ),
      base: Uri.parse('https://quiz.example/'),
      loadBundled: () async => throw StateError('must not use bundle'),
    );
    expect((await online.load()).origin, 'server');

    final offline = ContentRepository(
      store: store,
      client: MockClient((_) async => throw Exception('offline')),
      base: Uri.parse('https://quiz.example/'),
      loadBundled: () async => throw StateError('must use cache'),
    );
    final cached = await offline.load();
    expect(cached.origin, 'cache');
    expect(cached.version, bundle()['content_version']);
  });

  test(
    'corrupt cache is ignored and bundled content remains available',
    () async {
      final store = MemoryUserStore(
        content: const CachedContent(
          version: 'broken',
          mode: 'draft',
          json: '{broken',
        ),
      );
      final repository = ContentRepository(
        store: store,
        client: MockClient((_) async => throw Exception('offline')),
        loadBundled: () async => jsonEncode(bundle()),
      );

      expect((await repository.load()).origin, 'bundled');
    },
  );

  test('failed cache update keeps the previous working snapshot', () async {
    final oldJson = jsonEncode(bundle());
    final store = FailingSaveStore(
      content: CachedContent(version: 'draft-1', mode: 'draft', json: oldJson),
    );
    final newer = {
      ...bundle(),
      'content_version': 'draft-2',
      'questions': [
        for (final question in bundle()['questions'] as List)
          {...question as Map<String, dynamic>, 'content_version': 'draft-2'},
      ],
    };
    final online = ContentRepository(
      store: store,
      client: MockClient(
        (_) async => http.Response.bytes(utf8.encode(jsonEncode(newer)), 200),
      ),
    );
    expect((await online.load()).version, 'draft-2');

    final offline = ContentRepository(
      store: store,
      client: MockClient((_) async => throw Exception('offline')),
      loadBundled: () async => throw StateError('must preserve cache'),
    );
    expect((await offline.load()).version, 'draft-1');
  });
}
