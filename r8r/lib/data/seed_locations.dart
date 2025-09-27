import '../models/location_model.dart';

/// Seed locations for your area - customize these for your local wing spots!
/// These appear when no user-submitted locations exist yet.
class SeedLocations {
  
  /// Update these coordinates to your city/area
  static const double defaultLatitude = 49.9033; // Kelowna, BC (your location)
  static const double defaultLongitude = -119.4911;

  /// Base locations - customize these for your local area!
  static List<LocationModel> getSeedLocations() {
    return [
      // Example: Kelowna, BC area locations
      LocationModel(
        id: 'seed_1',
        name: 'White Spot',
        address: '1405 Harvey Ave, Kelowna, BC V1Y 6E8',
        phone: '(250) 762-2212',
        website: 'https://www.whitespot.ca',
        latitude: 49.8880,
        longitude: -119.4960,
        averageRating: 4.2,
        totalReviews: 156,
        createdBy: 'system',
        createdAt: DateTime.now(),
        tags: ['wings', 'beer', 'family-friendly', 'patio'],
        description: 'Classic Canadian restaurant with great wings and local beer selection',
      ),
      
      LocationModel(
        id: 'seed_2',
        name: 'Earls Kitchen + Bar',
        address: '1405 Pandosy St, Kelowna, BC V1Y 1P5',
        phone: '(250) 762-2777',
        website: 'https://www.earls.ca',
        latitude: 49.8765,
        longitude: -119.4944,
        averageRating: 4.5,
        totalReviews: 89,
        createdBy: 'system',
        createdAt: DateTime.now(),
        tags: ['wings', 'craft-beer', 'upscale', 'patio'],
        description: 'Upscale casual dining with excellent wing varieties and craft beer',
      ),

      LocationModel(
        id: 'seed_3',
        name: 'Boston Pizza',
        address: '1876 Cooper Rd, Kelowna, BC V1Y 8B7',
        phone: '(250) 860-3344',
        website: 'https://www.bostonpizza.com',
        latitude: 49.9156,
        longitude: -119.4522,
        averageRating: 3.8,
        totalReviews: 234,
        createdBy: 'system',
        createdAt: DateTime.now(),
        tags: ['wings', 'beer', 'sports-bar', 'family-friendly'],
        description: 'Sports bar atmosphere with wing nights and game viewing',
      ),

      LocationModel(
        id: 'seed_4',
        name: 'The Keg',
        address: '1310 Water St, Kelowna, BC V1Y 9P3',
        phone: '(250) 979-3557',
        website: 'https://www.kegrestaurants.com',
        latitude: 49.8944,
        longitude: -119.4944,
        averageRating: 4.7,
        totalReviews: 45,
        createdBy: 'system',
        createdAt: DateTime.now(),
        tags: ['wings', 'beer', 'upscale', 'lake-view'],
        description: 'Premium steakhouse with amazing wings and lakefront patio',
      ),

      // Add more locations for your area here...
      // You can also include chains if they exist locally:
      
      LocationModel(
        id: 'seed_5',
        name: 'Local Pub & Grill',
        address: '123 Main St, Kelowna, BC V1Y 1A1',
        phone: '(250) 555-0123',
        website: '',
        latitude: 49.8944,
        longitude: -119.5000,
        averageRating: 4.3,
        totalReviews: 67,
        createdBy: 'system',
        createdAt: DateTime.now(),
        tags: ['wings', 'beer', 'local', 'live-music'],
        description: 'Local favorite with wing nights every Tuesday and live music weekends',
      ),
    ];
  }

  /// Get popular wing chains (if they exist in your area)
  static List<LocationModel> getChainLocations() {
    return [
      // Add chain restaurants if they exist in your area
      // Example:
      // LocationModel(
      //   id: 'chain_1',
      //   name: 'Buffalo Wild Wings',
      //   address: 'Address in your city',
      //   latitude: your_city_lat,
      //   longitude: your_city_lng,
      //   // ... other details
      // ),
    ];
  }
}
