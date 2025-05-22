class Player {
  final int id;
  final String name;
  final DateTime createdAt;

  Player({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
} 