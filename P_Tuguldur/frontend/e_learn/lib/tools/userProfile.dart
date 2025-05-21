class UserProfile {
  final String username;
  final String email;
  final double lastScore;
  final String level;
  final String lastCategory;

  UserProfile({
    required this.username,
    required this.email,
    required this.lastScore,
    required this.level,
    required this.lastCategory,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      email: json['email'],
      lastScore: json['last_score']?.toDouble() ?? 0.0,
      level: json['last_level'] ?? 'Unknown',
      lastCategory: json['incorrect_questions'] ?? 'N/A',
    );
  }
}
