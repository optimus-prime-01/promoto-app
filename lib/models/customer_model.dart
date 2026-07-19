class CustomerModel {
  final String id;
  final String businessId;
  final String name;
  final String? email;
  final String? phone;
  final String? notes;
  final int visitCount;
  final DateTime? lastVisit;
  final DateTime createdAt;

  const CustomerModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.email,
    this.phone,
    this.notes,
    required this.visitCount,
    this.lastVisit,
    required this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      notes: json['notes'] as String?,
      visitCount: json['visitCount'] as int,
      lastVisit: json['lastVisit'] != null
          ? DateTime.parse(json['lastVisit'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
