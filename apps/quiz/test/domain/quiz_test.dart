import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:diia_my/domain/catalog.dart';
import 'package:diia_my/domain/quiz.dart';

Question question(
  String id,
  int position, {
  bool answer = true,
  String version = 'v1',
}) => Question(
  id: id,
  categoryId: 'children',
  categoryName: 'Діти 5–12 років',
  roundNumber: 1,
  roundTitle: 'Повага',
  position: position,
  text: 'Запитання $id',
  correctAnswer: answer,
  explanation: 'Пояснення $id',
  status: 'draft',
  contentVersion: version,
);

void main() {
  test(
    'one answer per question; next requires an answer; final score is stable',
    () {
      final attempt = QuizAttempt([
        question('q1', 1),
        question('q2', 2, answer: false),
      ]);
      expect(() => attempt.next(), throwsStateError);
      expect(attempt.submit(true), isTrue);
      expect(attempt.submit(false), isFalse);
      expect(attempt.score, 1);
      attempt.next();
      expect(attempt.current.id, 'q2');
      attempt.submit(true);
      expect(attempt.lastCorrect, isFalse);
      attempt.next();
      expect(attempt.finished, isTrue);
      expect(attempt.score, 1);
      expect(attempt.submit(false), isFalse);
    },
  );
  test('retries start from zero', () {
    final first = QuizAttempt([question('q1', 1)]);
    first.submit(true);
    first.next();
    expect(QuizAttempt(first.questions).score, 0);
  });
  test('shuffle preserves ID, answer and explanation; seeded tests are reproducible', () {
    final source = List.generate(
      7,
      (i) => question('q$i', i + 1, answer: i.isEven),
    );
    final first = QuizAttempt(source, shuffle: true, random: Random(42));
    final second = QuizAttempt(source, shuffle: true, random: Random(42));
    expect(first.questions.map((q) => q.id), second.questions.map((q) => q.id));
    expect(
      first.questions.map((q) => q.id).toSet(),
      source.map((q) => q.id).toSet(),
    );
    for (final q in first.questions) {
      expect(
        q.correctAnswer,
        source.firstWhere((original) => original.id == q.id).correctAnswer,
      );
      expect(q.explanation, 'Пояснення ${q.id}');
    }
    expect(source.first.id, 'q0');
  });
  test('progress keeps best score but separates content versions', () {
    final progress = SessionProgress();
    final perfect = QuizAttempt([question('q1', 1)]);
    perfect.submit(true);
    perfect.next();
    progress.record(perfect);
    final worse = QuizAttempt([question('q1', 1)]);
    worse.submit(false);
    worse.next();
    progress.record(worse);
    expect(progress.forRound(perfect.current)?.best, 1);
    expect(progress.forRound(perfect.current)?.last, 0);
    expect(progress.forRound(question('q1', 1, version: 'v2')), isNull);
    expect(
      () => progress.record(QuizAttempt([question('q1', 1)])),
      throwsStateError,
    );
  });
  test(
    'mixed rounds, versions, duplicate IDs and empty attempts are rejected',
    () {
      expect(() => QuizAttempt([]), throwsArgumentError);
      expect(
        () => QuizAttempt([question('q1', 1), question('q1', 2)]),
        throwsArgumentError,
      );
      expect(
        () =>
            QuizAttempt([question('q1', 1), question('q2', 2, version: 'v2')]),
        throwsArgumentError,
      );
    },
  );
}
