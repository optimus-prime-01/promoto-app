class AuditModel {
  final String id;
  final String businessId;
  final double overallScore;
  final double completenessScore;
  final double reviewScore;
  final double postScore;
  final double responseScore;
  final double keywordScore;
  final List<AuditSuggestion> suggestions;
  final DateTime createdAt;

  const AuditModel({
    required this.id,
    required this.businessId,
    required this.overallScore,
    required this.completenessScore,
    required this.reviewScore,
    required this.postScore,
    required this.responseScore,
    required this.keywordScore,
    required this.suggestions,
    required this.createdAt,
  });

  factory AuditModel.fromJson(Map<String, dynamic> json) {
    List<AuditSuggestion> parseSuggestions(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw.map((e) {
          if (e is Map<String, dynamic>) {
            return AuditSuggestion.fromJson(e);
          }
          return AuditSuggestion(category: 'General', text: e.toString());
        }).toList();
      }
      return [];
    }

    return AuditModel(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      overallScore: (json['overallScore'] as num?)?.toDouble() ?? 0,
      completenessScore: (json['completenessScore'] as num?)?.toDouble() ?? 0,
      reviewScore: (json['reviewScore'] as num?)?.toDouble() ?? 0,
      postScore: (json['postScore'] as num?)?.toDouble() ?? 0,
      responseScore: (json['responseScore'] as num?)?.toDouble() ?? 0,
      keywordScore: (json['keywordScore'] as num?)?.toDouble() ?? 0,
      suggestions: parseSuggestions(json['suggestions']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

class AuditSuggestion {
  final String category;
  final String text;

  const AuditSuggestion({
    required this.category,
    required this.text,
  });

  factory AuditSuggestion.fromJson(Map<String, dynamic> json) {
    return AuditSuggestion(
      category: json['category'] as String? ?? 'General',
      text: json['text'] as String? ?? json['suggestion'] as String? ?? '',
    );
  }
}
