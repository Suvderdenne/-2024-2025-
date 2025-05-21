// Question model for the application
class Question {
  final int id;
  final String questionText;
  final String type;
  final String? imageBase64;
  final String? audioBase64;
  final List<MatchingItem>? matchingItems;

  Question({
    required this.id,
    required this.questionText,
    required this.type,
    this.imageBase64,
    this.audioBase64,
    this.matchingItems,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      questionText: json['question_text'] ?? 'Асуултын текст байхгүй',
      type: json['type'] ?? 'Төрөл байхгүй',
      imageBase64: json['image_base64'],
      audioBase64: json['audio_base64'],
      matchingItems: json['matching_items'] != null
          ? (json['matching_items'] as List)
              .map((item) => MatchingItem.fromJson(item))
              .toList()
          : null,
    );
  }
}

class MatchingItem {
  final int id;
  final String leftText;
  final String rightText;
  final String? leftImageBase64;
  final String? rightImageBase64;

  MatchingItem({
    required this.id,
    required this.leftText,
    required this.rightText,
    this.leftImageBase64,
    this.rightImageBase64,
  });

  factory MatchingItem.fromJson(Map<String, dynamic> json) {
    return MatchingItem(
      id: json['id'] ?? 0,
      leftText: json['left_text'] ?? '',
      rightText: json['right_text'] ?? '',
      leftImageBase64: json['left_image_base64'],
      rightImageBase64: json['right_image_base64'],
    );
  }
}
