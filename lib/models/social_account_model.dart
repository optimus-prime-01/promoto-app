class SocialAccountModel {
  final String id;
  final String businessId;
  final String platform;
  final String platformUserId;
  final String? platformUsername;
  final bool isConnected;
  final DateTime connectedAt;
  final DateTime createdAt;

  const SocialAccountModel({
    required this.id,
    required this.businessId,
    required this.platform,
    required this.platformUserId,
    this.platformUsername,
    required this.isConnected,
    required this.connectedAt,
    required this.createdAt,
  });

  factory SocialAccountModel.fromJson(Map<String, dynamic> json) {
    return SocialAccountModel(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      platform: json['platform'] as String? ?? 'instagram',
      platformUserId: json['platformUserId'] as String? ?? '',
      platformUsername: json['platformUsername'] as String?,
      isConnected: json['isConnected'] as bool? ?? true,
      connectedAt: json['connectedAt'] != null
          ? DateTime.parse(json['connectedAt'] as String)
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  String get platformDisplay {
    switch (platform) {
      case 'instagram':
        return 'Instagram';
      case 'facebook':
        return 'Facebook';
      case 'whatsapp':
        return 'WhatsApp';
      default:
        return platform;
    }
  }
}
