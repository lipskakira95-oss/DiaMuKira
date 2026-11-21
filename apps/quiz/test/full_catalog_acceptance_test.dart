import 'dart:convert';

import 'package:diia_my/domain/catalog.dart';
import 'package:diia_my/domain/quiz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'all 152 positions form 18 playable rounds with sequential IDs',
    () async {
      final source = await rootBundle.loadString(
        'assets/content/questions.json',
      );
      final catalog = Catalog.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );
      expect(
        catalog.questions.map((q) => q.id),
        List.generate(
          152,
          (index) => 'q${(index + 1).toString().padLeft(3, '0')}',
        ),
      );

      final progress = SessionProgress();
      var completedRounds = 0;
      for (final category in catalog.categories) {
        final rounds = catalog
            .inCategory(category)
            .map((question) => question.roundNumber)
            .toSet();
        for (final round in rounds) {
          final attempt = QuizAttempt(catalog.inRound(category, round));
          while (!attempt.finished) {
            expect(attempt.submit(attempt.current.correctAnswer), isTrue);
            attempt.next();
          }
          progress.record(attempt);
          expect(progress.forRound(attempt.current)?.perfect, isTrue);
          completedRounds++;
        }
      }
      expect(completedRounds, 18);
    },
  );
}
