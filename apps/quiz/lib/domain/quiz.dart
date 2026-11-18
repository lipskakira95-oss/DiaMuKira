import 'dart:math';

import 'catalog.dart';
import 'user_data.dart';

class QuizAttempt {
  QuizAttempt(List<Question> source, {bool shuffle = false, Random? random}) {
    if (source.isEmpty) throw ArgumentError('A round cannot be empty');
    final first = source.first;
    if (source.map((q) => q.id).toSet().length != source.length ||
        source.any(
          (q) =>
              q.categoryId != first.categoryId ||
              q.roundNumber != first.roundNumber ||
              q.contentVersion != first.contentVersion,
        )) {
      throw ArgumentError('A round must have unique IDs and one version');
    }
    final ordered = List<Question>.of(source)
      ..sort((a, b) => a.position.compareTo(b.position));
    if (shuffle) ordered.shuffle(random ?? Random());
    questions = List.unmodifiable(ordered);
  }
  late final List<Question> questions;
  int _index = 0, _score = 0;
  bool _finished = false;
  bool? _lastCorrect;
  Question get current => questions[_index];
  int get number => _index + 1;
  int get total => questions.length;
  int get score => _score;
  bool get finished => _finished;
  bool? get lastCorrect => _lastCorrect;
  bool submit(bool answer) {
    if (_finished || _lastCorrect != null) return false;
    _lastCorrect = answer == current.correctAnswer;
    if (_lastCorrect!) _score++;
    return true;
  }

  void next() {
    if (_finished) return;
    if (_lastCorrect == null) {
      throw StateError('Answer the current question first');
    }
    if (_index == questions.length - 1) {
      _finished = true;
      return;
    }
    _index++;
    _lastCorrect = null;
  }
}

class RoundProgress {
  const RoundProgress({
    required this.last,
    required this.best,
    required this.total,
  });
  final int last, best, total;
  bool get perfect => best == total;
}

class SessionProgress {
  SessionProgress([Iterable<SavedRoundProgress> saved = const []]) {
    for (final item in saved) {
      _rounds[item.key] = RoundProgress(
        last: item.lastScore,
        best: item.bestScore,
        total: item.total,
      );
    }
  }

  final _rounds = <String, RoundProgress>{};
  String _key(Question q) =>
      '${q.contentVersion}/${q.categoryId}/${q.roundNumber}';
  RoundProgress? forRound(Question q) => _rounds[_key(q)];
  SavedRoundProgress record(QuizAttempt attempt) {
    if (!attempt.finished) throw StateError('Unfinished attempt');
    final question = attempt.current;
    final key = _key(question);
    final previous = _rounds[key];
    final updated = RoundProgress(
      last: attempt.score,
      best: max(previous?.best ?? 0, attempt.score),
      total: attempt.total,
    );
    _rounds[key] = updated;
    return SavedRoundProgress(
      contentVersion: question.contentVersion,
      categoryId: question.categoryId,
      roundNumber: question.roundNumber,
      lastScore: updated.last,
      bestScore: updated.best,
      total: updated.total,
    );
  }
}
