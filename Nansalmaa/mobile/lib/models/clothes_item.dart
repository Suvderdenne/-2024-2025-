class ClothesItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String condition;
  final String size;
  final String sellerId;
  final DateTime createdAt;

  ClothesItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.condition,
    required this.size,
    required this.sellerId,
    required this.createdAt,
  });

  factory ClothesItem.fromJson(Map<String, dynamic> json) {
    return ClothesItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      condition: json['condition'] as String,
      size: json['size'] as String,
      sellerId: json['sellerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'condition': condition,
      'size': size,
      'sellerId': sellerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 