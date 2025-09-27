import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';

class PlacesService {
  // Use our backend proxy to avoid CORS issues on web
  static const String _baseUrl = '/api/places';
  
  // For mobile apps, you can use direct API calls
  static const String _directApiUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _apiKey = 'AIzaSyDXCtWihqMQe6E5jsjFxrhdtzX-COma5kk';
  
  // Detect if running on web
  static bool get _isWeb => kIsWeb;

  /// Search for restaurants that serve chicken wings and beer near a location
  static Future<List<LocationModel>> searchWingRestaurants({
    required double latitude,
    required double longitude,
    double radius = 8000, // 8km radius for better coverage
    int maxResults = 20,
  }) async {
    try {
      print('Searching for wing restaurants near $latitude, $longitude');
      
      // Search for restaurants with wing/beer keywords
      final restaurants = await _searchNearbyPlaces(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        type: 'restaurant',
        keyword: 'chicken wings beer bar grill pub buffalo',
      );

      print('Found ${restaurants.length} potential restaurants');

      // Get detailed info for each restaurant
      final wingRestaurants = <LocationModel>[];
      
      for (final place in restaurants.take(maxResults)) {
        try {
          final details = await _getPlaceDetails(place['place_id']);
          if (details != null) {
            final restaurant = _convertToLocationModel(details);
            if (_isLikelyWingRestaurant(restaurant, details)) {
              wingRestaurants.add(restaurant);
              print('Added: ${restaurant.name}');
            }
          }
        } catch (e) {
          print('Error getting details for place: $e');
          continue;
        }
      }

      print('Final wing restaurants: ${wingRestaurants.length}');
      return wingRestaurants;
    } catch (e) {
      print('Error searching for wing restaurants: $e');
      return [];
    }
  }

  /// Search for nearby places using Google Places API
  static Future<List<Map<String, dynamic>>> _searchNearbyPlaces({
    required double latitude,
    required double longitude,
    required double radius,
    required String type,
    String? keyword,
  }) async {
    Uri url;
    Map<String, String> queryParams;

    if (_isWeb) {
      // Use backend proxy for web to avoid CORS
      url = Uri.parse(_baseUrl);
      queryParams = {
        'type': 'nearby',
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'radius': radius.toString(),
      };
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }
    } else {
      // Direct API call for mobile apps
      if (_apiKey == 'YOUR_GOOGLE_PLACES_API_KEY') {
        throw Exception('Please set your Google Places API key in places_service.dart');
      }
      
      url = Uri.parse('$_directApiUrl/nearbysearch/json');
      queryParams = {
        'location': '$latitude,$longitude',
        'radius': radius.toString(),
        'type': type,
        'key': _apiKey,
      };
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }
    }

    final response = await http.get(url.replace(queryParameters: queryParams));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['status'] != 'OK') {
        throw Exception('Places API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
      }
      
      return List<Map<String, dynamic>>.from(data['results'] ?? []);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  /// Get detailed information about a specific place
  static Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
    Uri url;
    Map<String, String> queryParams;

    if (_isWeb) {
      // Use backend proxy for web to avoid CORS
      url = Uri.parse(_baseUrl);
      queryParams = {
        'type': 'details',
        'placeId': placeId,
        'fields': 'name,formatted_address,formatted_phone_number,website,geometry,rating,user_ratings_total,types,business_status,price_level',
      };
    } else {
      // Direct API call for mobile apps
      url = Uri.parse('$_directApiUrl/details/json');
      queryParams = {
        'place_id': placeId,
        'fields': 'name,formatted_address,formatted_phone_number,website,geometry,rating,user_ratings_total,types,business_status,price_level',
        'key': _apiKey,
      };
    }

    final response = await http.get(url.replace(queryParameters: queryParams));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['status'] == 'OK') {
        return data['result'];
      } else {
        print('Place details error: ${data['status']}');
        return null;
      }
    }
    return null;
  }

  /// Check if a restaurant is likely to serve wings and beer
  static bool _isLikelyWingRestaurant(LocationModel restaurant, Map<String, dynamic> placeDetails) {
    final types = List<String>.from(placeDetails['types'] ?? []);
    final name = restaurant.name.toLowerCase();
    final address = restaurant.address.toLowerCase();
    
    // Must be a restaurant, bar, or food establishment
    final isRestaurant = types.any((type) => [
      'restaurant',
      'bar',
      'food',
      'meal_takeaway',
      'meal_delivery',
    ].contains(type));
    
    if (!isRestaurant) return false;
    
    // Check for wing/beer indicators in name
    final wingKeywords = [
      'wing', 'buffalo', 'hooters', 'wingstop', 'bdubs', 'b-dubs',
      'pub', 'bar', 'grill', 'tavern', 'brewery', 'beer', 'ale',
      'sports', 'game', 'draft'
    ];
    
    final hasWingKeywords = wingKeywords.any((keyword) => 
      name.contains(keyword) || address.contains(keyword)
    );
    
    // Always include if it has wing keywords
    if (hasWingKeywords) return true;
    
    // Include general restaurants and bars that might serve wings
    final generalTypes = ['restaurant', 'bar', 'meal_takeaway'];
    return types.any((type) => generalTypes.contains(type));
  }

  /// Convert Google Places result to LocationModel
  static LocationModel _convertToLocationModel(Map<String, dynamic> placeDetails) {
    final geometry = placeDetails['geometry'] ?? {};
    final location = geometry['location'] ?? {};
    
    return LocationModel(
      id: placeDetails['place_id'] ?? '',
      name: placeDetails['name'] ?? 'Unknown Restaurant',
      address: placeDetails['formatted_address'] ?? '',
      phone: placeDetails['formatted_phone_number'] ?? '',
      website: placeDetails['website'] ?? '',
      latitude: (location['lat'] ?? 0.0).toDouble(),
      longitude: (location['lng'] ?? 0.0).toDouble(),
      averageRating: (placeDetails['rating'] ?? 0.0).toDouble(),
      totalReviews: placeDetails['user_ratings_total'] ?? 0,
    );
  }

  /// Search for specific restaurant chains known for wings
  static Future<List<LocationModel>> searchWingChains({
    required double latitude,
    required double longitude,
    double radius = 10000, // 10km for chains
  }) async {
    final wingChains = [
      'Buffalo Wild Wings',
      'Wingstop',
      'Hooters',
      'Wing Zone',
      'Atomic Wings',
      'Pluckers',
    ];

    final allResults = <LocationModel>[];
    
    for (final chain in wingChains) {
      try {
        final results = await _searchNearbyPlaces(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          type: 'restaurant',
          keyword: chain,
        );
        
        for (final place in results) {
          final details = await _getPlaceDetails(place['place_id']);
          if (details != null) {
            allResults.add(_convertToLocationModel(details));
          }
        }
      } catch (e) {
        print('Error searching for $chain: $e');
        continue;
      }
    }
    
    // Remove duplicates based on place_id
    final uniqueResults = <String, LocationModel>{};
    for (final restaurant in allResults) {
      uniqueResults[restaurant.id] = restaurant;
    }
    
    return uniqueResults.values.toList();
  }
}
