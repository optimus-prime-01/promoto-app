class CommentModel {
  final String id;
  final String postId;
  final String businessId;
  final String platformCommentId;
  final String authorName;
  final String text;
  final String? replyText;
  final String? aiSuggestedReply;
  final DateTime? repliedAt;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.businessId,
    required this.platformCommentId,
    required this.authorName,
    required this.text,
    this.replyText,
    this.aiSuggestedReply,
    this.repliedAt,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['postId'] as String,
      businessId: json['businessId'] as String,
      platformCommentId: json['platformCommentId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? 'Unknown',
      text: json['text'] as String? ?? '',
      replyText: json['replyText'] as String?,
      aiSuggestedReply: json['aiSuggestedReply'] as String?,
      repliedAt: json['repliedAt'] != null
          ? DateTime.parse(json['repliedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  CommentModel copyWith({
    String? replyText,
    String? aiSuggestedReply,
    DateTime? repliedAt,
  }) {
    return CommentModel(
      id: id,
      postId: postId,
      businessId: businessId,
      platformCommentId: platformCommentId,
      authorName: authorName,
      text: text,
      replyText: replyText ?? this.replyText,
      aiSuggestedReply: aiSuggestedReply ?? this.aiSuggestedReply,
      repliedAt: repliedAt ?? this.repliedAt,
      createdAt: createdAt,
    );
  }
}
