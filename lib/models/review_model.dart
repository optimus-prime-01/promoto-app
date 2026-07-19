class ReviewModel {
  final String id;
  final String businessId;
  final String reviewerName;
  final String? reviewerPhoto;
  final int rating;
  final String content;
  final String? reply;
  final String source;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.businessId,
    required this.reviewerName,
    this.reviewerPhoto,
    required this.rating,
    required this.content,
    this.reply,
    required this.source,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      reviewerName: json['reviewerName'] as String,
      reviewerPhoto: json['reviewerPhoto'] as String?,
      rating: json['rating'] as int,
      content: json['content'] as String,
      reply: json['reply'] as String?,
      source: json['source'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
