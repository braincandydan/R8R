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

  LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.website,
    required this.latitude,
    required this.longitude,
    required this.averageRating,
    required this.totalReviews,
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
    );
  }

  String get formattedDistance {
    // This would be calculated by the LocationService
    return '0.5 mi'; // Placeholder
  }

  String get ratingDisplay {
    return '${averageRating.toStringAsFixed(1)} ⭐ (${totalReviews} reviews)';
  }
}
