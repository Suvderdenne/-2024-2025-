// models/quiz_question.dart

class Choice {
  final int id;
  final String text;

  Choice({required this.id, required this.text});

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(id: json['id'], text: json['text']);
  }
}

class QuizQuestion {
  final int id;
  final String text;
  final List<Choice> choices;

  QuizQuestion({required this.id, required this.text, required this.choices});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    var choicesList = (json['choices'] as List).map((c) => Choice.fromJson(c)).toList();
    return QuizQuestion(id: json['id'], text: json['text'], choices: choicesList);
  }
}
