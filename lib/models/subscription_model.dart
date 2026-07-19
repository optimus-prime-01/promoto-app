class SubscriptionModel {
  final String id;
  final String userId;
  final String plan;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> features;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.features,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      plan: json['plan'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      features: json['features'] as Map<String, dynamic>,
    );
  }
}
