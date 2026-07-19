class PostModel {
  final String id;
  final String businessId;
  final String content;
  final String? imageUrl;
  final String platform;
  final String status;
  final DateTime? scheduledAt;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.businessId,
    required this.content,
    this.imageUrl,
    required this.platform,
    required this.status,
    this.scheduledAt,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      platform: json['platform'] as String,
      status: json['status'] as String,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
