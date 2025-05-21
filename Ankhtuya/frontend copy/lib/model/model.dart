import 'dart:convert';
import 'dart:typed_data';

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Plant {
  final int id;
  final String name;
  final String description;
  final String watering;
  final String sunlight;
  final String temperature;
  final String imageBase64;
  final int? categoryId;

  Plant({
    required this.id,
    required this.name,
    required this.description,
    required this.watering,
    required this.sunlight,
    required this.temperature,
    required this.imageBase64,
    required this.categoryId,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      watering: json['watering'],
      sunlight: json['sunlight'],
      temperature: json['temperature'],
      imageBase64: json['image_base64'],
      categoryId: json['category'],
    );
  }

  Uint8List get imageBytes => base64Decode(imageBase64);
}
