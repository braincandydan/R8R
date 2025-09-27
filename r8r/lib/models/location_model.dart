class LocationModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String website;
  final double latitude;
  final double longitude;
  final double averageRating;
  final int totalReviews;
  final String createdBy; // User who added this location
  final DateTime createdAt;
  final bool isVerified; // Admin can verify locations
  final List<String> tags; // e.g., ['wings', 'beer', 'sports-bar', 'outdoor-seating']
  final String? description; // User description of the place

  LocationModel({
    required this.id,
    required this.name,
    required this.address,
    this.phone = '',
    this.website = '',
    required this.latitude,
    required this.longitude,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    required this.createdBy,
    required this.createdAt,
    this.isVerified = false,
    this.tags = const [],
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'website': website,
      'latitude': latitude,
      'longitude': longitude,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isVerified': isVerified,
      'tags': tags,
      'description': description,
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      isVerified: json['isVerified'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      description: json['description'],
    );
  }

  String get formattedDistance {
    // This would be calculated by the LocationService
    return '0.5 mi'; // Placeholder
  }

  String get ratingDisplay {
    return '${averageRating.toStringAsFixed(1)} ⭐ (${totalReviews} reviews)';
  }

  String get tagsDisplay {
    return tags.map((tag) => '#$tag').join(' ');
  }

  bool get hasWings {
    return tags.contains('wings') || 
           name.toLowerCase().contains('wing') ||
           description?.toLowerCase().contains('wing') == true;
  }

  bool get hasBeer {
    return tags.contains('beer') || 
           tags.contains('bar') ||
           name.toLowerCase().contains('bar') ||
           description?.toLowerCase().contains('beer') == true;
  }

  /// Create a copy with updated fields
  LocationModel copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? website,
    double? latitude,
    double? longitude,
    double? averageRating,
    int? totalReviews,
    String? createdBy,
    DateTime? createdAt,
    bool? isVerified,
    List<String>? tags,
    String? description,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      tags: tags ?? this.tags,
      description: description ?? this.description,
    );
  }
}
