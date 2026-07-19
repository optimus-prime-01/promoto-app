class BusinessModel {
  final String id;
  final String name;
  final String? category;
  final String? city;
  final String? state;
  final String? phone;
  final String? address;
  final String? website;
  final String? logoUrl;
  final double profileScore;
  final DateTime createdAt;

  const BusinessModel({
    required this.id,
    required this.name,
    this.category,
    this.city,
    this.state,
    this.phone,
    this.address,
    this.website,
    this.logoUrl,
    this.profileScore = 0,
    required this.createdAt,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      category: json['category'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logoUrl'] as String?,
      profileScore: double.tryParse(json['profileScore']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'city': city,
      'state': state,
      'phone': phone,
      'address': address,
      'website': website,
      'logoUrl': logoUrl,
      'profileScore': profileScore,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
