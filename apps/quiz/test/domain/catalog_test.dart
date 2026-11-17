import 'package:flutter_test/flutter_test.dart';
import 'package:diia_my/domain/catalog.dart';

Map<String, dynamic> bundle() => {
  'schema_version': 1,
  'content_version': 'draft-1',
  'mode': 'draft',
  'questions': [
    {
      'id': 'q1',
      'category_id': 'children',
      'category_name': 'Діти',
      'round_number': 1,
      'round_title': 'Повага',
      'position': 1,
      'text': 'Чи важлива повага?',
      'correct_answer': true,
      'explanation': 'Кожен заслуговує на повагу.',
      'status': 'draft',
      'content_version': 'draft-1',
    },
  ],
};

void main() {
  test(
    'reads the Go JSON contract without losing Ukrainian or boolean answers',
    () {
      final data = Catalog.fromJson(bundle());
      expect(data.questions.single.correctAnswer, isTrue);
      expect(data.questions.single.text, 'Чи важлива повага?');
    },
  );
  test('rejects unsupported schema, missing boolean, duplicate ID and draft production', () {
    expect(
      () => Catalog.fromJson({...bundle(), 'schema_version': 99}),
      throwsFormatException,
    );
    final missing = bundle();
    (missing['questions'] as List).first.remove('correct_answer');
    expect(() => Catalog.fromJson(missing), throwsFormatException);
    final duplicate = bundle();
    (duplicate['questions'] as List).add(
      (duplicate['questions'] as List).first,
    );
    expect(() => Catalog.fromJson(duplicate), throwsFormatException);
    expect(
      () => Catalog.fromJson({...bundle(), 'mode': 'production'}),
      throwsFormatException,
    );
  });
}
