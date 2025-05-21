// models/user_stats.dart

class CategoryLevelStat {
  final int correct;
  final int total;
  final double scorePercent;

  CategoryLevelStat({required this.correct, required this.total, required this.scorePercent});

  factory CategoryLevelStat.fromJson(Map<String, dynamic> json) {
    return CategoryLevelStat(
      correct: json['correct'],
      total: json['total'],
      scorePercent: json['score_percent'].toDouble(),
    );
  }
}

class UserStats {
  final double overallScore;
  final String estimatedLevel;
  final Map<String, Map<String, CategoryLevelStat>> categoryStats;

  UserStats({
    required this.overallScore,
    required this.estimatedLevel,
    required this.categoryStats,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, CategoryLevelStat>> parsedStats = {};
    Map<String, dynamic> rawStats = json['category_stats'];

    rawStats.forEach((category, levels) {
      Map<String, CategoryLevelStat> levelStats = {};
      (levels as Map<String, dynamic>).forEach((level, data) {
        levelStats[level] = CategoryLevelStat.fromJson(data);
      });
      parsedStats[category] = levelStats;
    });

    return UserStats(
      overallScore: json['overall_score_percent'].toDouble(),
      estimatedLevel: json['estimated_level'],
      categoryStats: parsedStats,
    );
  }
}
