class AuditCategory {
  final String name;
  final int score;
  final int maxScore;
  final List<String> suggestions;

  const AuditCategory({
    required this.name,
    required this.score,
    required this.maxScore,
    required this.suggestions,
  });

  factory AuditCategory.fromJson(Map<String, dynamic> json) {
    return AuditCategory(
      name: json['name'] as String,
      score: json['score'] as int,
      maxScore: json['maxScore'] as int,
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

class AuditModel {
  final String id;
  final String businessId;
  final int totalScore;
  final int maxScore;
  final List<AuditCategory> categories;
  final DateTime createdAt;

  const AuditModel({
    required this.id,
    required this.businessId,
    required this.totalScore,
    required this.maxScore,
    required this.categories,
    required this.createdAt,
  });

  factory AuditModel.fromJson(Map<String, dynamic> json) {
    return AuditModel(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      totalScore: json['totalScore'] as int,
      maxScore: json['maxScore'] as int,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => AuditCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
