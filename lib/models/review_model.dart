class ReviewModel {
  final String id;
  final String businessId;
  final String reviewerName;
  final int rating;
  final String? text;
  final String? replyText;
  final DateTime? repliedAt;
  final String? aiSuggestedReply;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.businessId,
    required this.reviewerName,
    required this.rating,
    this.text,
    this.replyText,
    this.repliedAt,
    this.aiSuggestedReply,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      reviewerName: json['reviewerName'] as String? ?? 'Anonymous',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      text: json['text'] as String?,
      replyText: json['replyText'] as String?,
      repliedAt: json['repliedAt'] != null
          ? DateTime.parse(json['repliedAt'] as String)
          : null,
      aiSuggestedReply: json['aiSuggestedReply'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  bool get hasReply => replyText != null && replyText!.isNotEmpty;
}
