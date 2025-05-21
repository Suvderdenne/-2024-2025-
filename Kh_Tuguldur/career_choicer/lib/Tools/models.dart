class CareerRecommendation {
  final String suggestedCareer;
  final List<String> highSchoolSubjects;
  final List<String> universities;

  CareerRecommendation({
    required this.suggestedCareer,
    required this.highSchoolSubjects,
    required this.universities,
  });

  factory CareerRecommendation.fromJson(Map<String, dynamic> json) {
    return CareerRecommendation(
      suggestedCareer: json['suggested_career'] ?? "",
      highSchoolSubjects: List<String>.from(json['high_school_subjects'] ?? []),
      universities: List<String>.from(json['universities'] ?? []),
    );
  }
}
