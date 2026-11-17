const categoryOrder = ['children', 'students', 'teachers', 'parents', 'media'];
const roundSizes = <String, List<int>>{
  'children': [7, 7, 7],
  'students': [9, 9, 9],
  'teachers': [9, 8, 8, 8],
  'parents': [10, 10, 10, 9],
  'media': [8, 8, 8, 8],
};

class Question {
  const Question({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.roundNumber,
    required this.roundTitle,
    required this.position,
    required this.text,
    required this.correctAnswer,
    required this.explanation,
    required this.status,
    required this.contentVersion,
  });
  final String id,
      categoryId,
      categoryName,
      roundTitle,
      text,
      explanation,
      status,
      contentVersion;
  final int roundNumber, position;
  final bool correctAnswer;

  factory Question.fromJson(Map<String, dynamic> json) {
    String text(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Missing $key');
      }
      return value;
    }

    int number(String key) {
      final value = json[key];
      if (value is! int || value < 1) throw FormatException('Invalid $key');
      return value;
    }

    final answer = json['correct_answer'];
    if (answer is! bool) throw const FormatException('Answer must be boolean');
    final category = text('category_id');
    final round = number('round_number');
    final limits = roundSizes[category];
    final position = number('position');
    if (limits == null ||
        round > limits.length ||
        position > limits[round - 1]) {
      throw const FormatException('Invalid category, round or position');
    }
    final status = text('status');
    if (!['draft', 'approved'].contains(status)) {
      throw const FormatException('Invalid review status');
    }
    return Question(
      id: text('id'),
      categoryId: category,
      categoryName: text('category_name'),
      roundNumber: round,
      roundTitle: text('round_title'),
      position: position,
      text: text('text'),
      correctAnswer: answer,
      explanation: text('explanation'),
      status: status,
      contentVersion: text('content_version'),
    );
  }
}

class Catalog {
  Catalog(
    List<Question> questions, {
    required this.version,
    required this.mode,
    this.origin = 'memory',
  }) : questions = List.unmodifiable(questions);
  final List<Question> questions;
  final String version, mode, origin;

  factory Catalog.fromJson(
    Map<String, dynamic> json, {
    String origin = 'unknown',
  }) {
    if (json['schema_version'] != 1 ||
        json['content_version'] is! String ||
        (json['content_version'] as String).trim().isEmpty ||
        !['draft', 'production'].contains(json['mode']) ||
        json['questions'] is! List) {
      throw const FormatException('Unsupported content envelope');
    }
    final questions = (json['questions'] as List).map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid question');
      }
      return Question.fromJson(value);
    }).toList();
    final ids = <String>{};
    final positions = <String>{};
    final names = <String, String>{};
    final rounds = <String, String>{};
    for (final q in questions) {
      final key = '${q.categoryId}/${q.roundNumber}';
      if (!ids.add(q.id) ||
          !positions.add('$key/${q.position}') ||
          q.contentVersion != json['content_version']) {
        throw const FormatException('Duplicate or mixed-version content');
      }
      if ((names.containsKey(q.categoryId) &&
              names[q.categoryId] != q.categoryName) ||
          (rounds.containsKey(key) && rounds[key] != q.roundTitle)) {
        throw const FormatException('Conflicting names');
      }
      names[q.categoryId] = q.categoryName;
      rounds[key] = q.roundTitle;
    }
    if (questions.isEmpty) throw const FormatException('Empty content');
    if (json['mode'] == 'production') {
      if (questions.any((q) => q.status != 'approved')) {
        throw const FormatException('Production contains drafts');
      }
      for (final category in roundSizes.entries) {
        for (var i = 0; i < category.value.length; i++) {
          if (questions
                  .where(
                    (q) =>
                        q.categoryId == category.key && q.roundNumber == i + 1,
                  )
                  .length !=
              category.value[i]) {
            throw const FormatException('Incomplete production content');
          }
        }
      }
    }
    questions.sort((a, b) {
      var result = categoryOrder
          .indexOf(a.categoryId)
          .compareTo(categoryOrder.indexOf(b.categoryId));
      if (result == 0) result = a.roundNumber.compareTo(b.roundNumber);
      if (result == 0) result = a.position.compareTo(b.position);
      return result;
    });
    return Catalog(
      questions,
      version: json['content_version'] as String,
      mode: json['mode'] as String,
      origin: origin,
    );
  }
  List<String> get categories => categoryOrder
      .where((id) => questions.any((q) => q.categoryId == id))
      .toList();
  List<Question> inCategory(String id) =>
      questions.where((q) => q.categoryId == id).toList();
  List<Question> inRound(String id, int round) => questions
      .where((q) => q.categoryId == id && q.roundNumber == round)
      .toList();
}
