class Word {
  final int id;
  final String english;
  final String mongolian;
  final String? imageBase64;
  final String? audioBase64;

  Word({
    required this.id,
    required this.english,
    required this.mongolian,
    this.imageBase64,
    this.audioBase64,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      english: json['english'],
      mongolian: json['mongolian'],
      imageBase64: json['image_base64'],
      audioBase64: json['audio_base64'],
    );
  }
}
