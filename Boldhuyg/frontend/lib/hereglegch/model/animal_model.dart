class Animal {
  final int id;
  final String animalName;
  final String? description;
  final String? imageBase64;
  final String? audioBase64;

  Animal({
    required this.id,
    required this.animalName,
    this.description,
    this.imageBase64,
    this.audioBase64,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      animalName: json['animal_name'],
      description: json['description'],
      imageBase64: json['image_base64'],
      audioBase64: json['audio_base64'],
    );
  }
}
