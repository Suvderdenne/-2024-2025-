class ClothesCategory {
  final int id;
  final String name;
  final String? description;

  ClothesCategory({
    required this.id,
    required this.name,
    this.description,
  });

  factory ClothesCategory.fromJson(Map<String, dynamic> json) {
    return ClothesCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
} 