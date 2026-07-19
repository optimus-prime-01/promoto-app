class PostModel {
  final String id;
  final String businessId;
  final String caption;
  final String? imageUrl;
  final String platform;
  final String status;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.businessId,
    required this.caption,
    this.imageUrl,
    required this.platform,
    required this.status,
    this.scheduledAt,
    this.publishedAt,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      caption: json['caption'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      platform: json['platform'] as String? ?? 'both',
      status: json['status'] as String? ?? 'draft',
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  String get platformDisplay {
    switch (platform) {
      case 'facebook':
        return 'Facebook';
      case 'instagram':
        return 'Instagram';
      case 'both':
        return 'FB + IG';
      default:
        return platform;
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'scheduled':
        return 'Scheduled';
      case 'published':
        return 'Published';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }
}
