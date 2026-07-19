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
      if (raw is Map<String, dynamic>) {
        final result = <AuditSuggestion>[];
        raw.forEach((category, items) {
          if (items is List) {
            for (final item in items) {
              result.add(AuditSuggestion(
                category: category,
                text: item.toString(),
              ));
            }
          }
        });
        return result;
      }
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
      overallScore: double.tryParse(json['overallScore']?.toString() ?? '0') ?? 0,
      completenessScore: double.tryParse(json['completenessScore']?.toString() ?? '0') ?? 0,
      reviewScore: double.tryParse(json['reviewScore']?.toString() ?? '0') ?? 0,
      postScore: double.tryParse(json['postScore']?.toString() ?? '0') ?? 0,
      responseScore: double.tryParse(json['responseScore']?.toString() ?? '0') ?? 0,
      keywordScore: double.tryParse(json['keywordScore']?.toString() ?? '0') ?? 0,
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
