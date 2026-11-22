import 'dart:convert';
import 'dart:io';

import 'package:diia_my/domain/catalog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'release metadata matches the app and never promotes draft content',
    () async {
      final metadataFile = File('../../release/release.json');
      expect(metadataFile.existsSync(), isTrue);
      final metadata =
          jsonDecode(metadataFile.readAsStringSync()) as Map<String, dynamic>;
      final catalog = Catalog.fromJson(
        jsonDecode(await rootBundle.loadString('assets/content/questions.json'))
            as Map<String, dynamic>,
      );
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(metadata['schema_version'], 1);
      expect(metadata['app_name'], 'Дія Ми');
      expect(pubspec, contains('version: ${metadata['version']}'));
      expect(metadata['android_application_id'], 'ua.diiamy.diia_my');
      expect(metadata['ios_bundle_id'], 'ua.diiamy.diiaMy');
      expect(metadata['content_mode'], catalog.mode);
      expect(metadata['content_version'], catalog.version);
      expect(metadata['question_count'], catalog.questions.length);
      expect(metadata['round_count'], 18);
      expect(metadata['production_ready'], catalog.mode == 'production');
      if (catalog.mode != 'production') {
        expect(metadata['release_channel'], 'preview');
        expect(metadata['production_ready'], isFalse);
      }
    },
  );
}
