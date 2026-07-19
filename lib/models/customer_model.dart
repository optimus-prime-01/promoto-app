class CustomerModel {
  final String id;
  final String businessId;
  final String phone;
  final String? name;
  final String? email;
  final String? address;
  final String? city;
  final String? notes;
  final List<String> tags;
  final DateTime? dateOfBirth;
  final DateTime? anniversary;
  final DateTime? lastVisitedAt;
  final DateTime createdAt;

  const CustomerModel({
    required this.id,
    required this.businessId,
    required this.phone,
    this.name,
    this.email,
    this.address,
    this.city,
    this.notes,
    this.tags = const [],
    this.dateOfBirth,
    this.anniversary,
    this.lastVisitedAt,
    required this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      notes: json['notes'] as String?,
      tags: json['tags'] != null
          ? (json['tags'] as List<dynamic>).map((e) => e.toString()).toList()
          : [],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      anniversary: json['anniversary'] != null
          ? DateTime.tryParse(json['anniversary'] as String)
          : null,
      lastVisitedAt: json['lastVisitedAt'] != null
          ? DateTime.tryParse(json['lastVisitedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  String get displayName => name ?? phone;
}
