class CarPart {
  final int id;
  final String name;
  final String? category;
  final String? brand;
  final String? price;
  final String? description;
  final String? imageUrl;
  final String? timestamp;

  CarPart({
    required this.id,
    required this.name,
    this.category,
    this.brand,
    this.price,
    this.description,
    this.imageUrl,
    this.timestamp,
  });

  factory CarPart.fromJson(Map<String, dynamic> json) {
    return CarPart(
      id: json['id'],
      name: json['Нэр'],
      category: json['Төрөл'],
      brand: json['brand'],
      price: json['Үнэ'],
      description: json['Тайлбар'],
      imageUrl: json['Зураг'],
      timestamp: json['Орсон_цаг'],
    );
  }
}
