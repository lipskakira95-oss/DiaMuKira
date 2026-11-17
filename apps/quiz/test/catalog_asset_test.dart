import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diia_my/domain/catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'SQLite export bundled with Flutter has all 152 positions in 18 rounds',
    () async {
      final source = await rootBundle.loadString(
        'assets/content/questions.json',
      );
      final catalog = Catalog.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );
      expect(catalog.questions.length, 152);
      expect(catalog.categories.length, 5);
      expect(catalog.mode, 'draft');
      for (final entry in roundSizes.entries) {
        for (var i = 0; i < entry.value.length; i++) {
          expect(catalog.inRound(entry.key, i + 1).length, entry.value[i]);
        }
      }
    },
  );
}
