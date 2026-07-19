class BusinessModel {
  final String id;
  final String name;
  final String category;
  final String city;
  final String? phone;
  final String? address;
  final String? logoUrl;
  final String? website;
  final int? auditScore;
  final DateTime createdAt;

  const BusinessModel({
    required this.id,
    required this.name,
    required this.category,
    required this.city,
    this.phone,
    this.address,
    this.logoUrl,
    this.website,
    this.auditScore,
    required this.createdAt,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      city: json['city'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      logoUrl: json['logoUrl'] as String?,
      website: json['website'] as String?,
      auditScore: json['auditScore'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'city': city,
      'phone': phone,
      'address': address,
      'logoUrl': logoUrl,
      'website': website,
      'auditScore': auditScore,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
