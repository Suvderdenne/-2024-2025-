class Game {
  final int id;
  final int playerId;
  final String playerName;
  final int score;
  final DateTime playedAt;
  final String? gameType;

  Game({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.score,
    required this.playedAt,
    this.gameType,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      playerId: json['player'],
      playerName: json['player_name'],
      score: json['score'],
      playedAt: DateTime.parse(json['played_at']),
      gameType: json['game_type_display'],
    );
  }
} 