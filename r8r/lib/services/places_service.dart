import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/location_model.dart';

/// UserLocationService - Handles user-submitted locations via Firebase
/// Google Places API is DISABLED to avoid costs - this service provides
/// all location functionality through Firebase Firestore (free tier)
class UserLocationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get all user-submitted locations
  static Future<List<LocationModel>> getAllLocations() async {
    try {
      final querySnapshot = await _firestore
          .collection('locations')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => LocationModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error getting locations: $e');
      return [];
    }
  }

  /// Search locations near a specific point
  static Future<List<LocationModel>> searchNearbyLocations({
    required double latitude,
    required double longitude,
    double radiusKm = 50, // 50km radius
  }) async {
    try {
      // Get all locations first (for simplicity)
      // In production, you'd use GeoFlutterFire or similar for geo queries
      final allLocations = await getAllLocations();
      
      // Filter by distance
      final nearbyLocations = allLocations.where((location) {
        final distance = _calculateDistance(
          latitude, longitude,
          location.latitude, location.longitude,
        );
        return distance <= radiusKm;
      }).toList();

      // Sort by distance
      nearbyLocations.sort((a, b) {
        final distanceA = _calculateDistance(
          latitude, longitude, a.latitude, a.longitude,
        );
        final distanceB = _calculateDistance(
          latitude, longitude, b.latitude, b.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      return nearbyLocations;
    } catch (e) {
      print('Error searching nearby locations: $e');
      return [];
    }
  }

  /// Add a new location
  static Future<String?> addLocation(LocationModel location) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to add locations');
      }

      // Create location with user info
      final locationData = location.copyWith(
        createdBy: user.uid,
        createdAt: DateTime.now(),
      ).toJson();

      // Remove id from data since Firestore will generate it
      locationData.remove('id');

      final docRef = await _firestore.collection('locations').add(locationData);
      print('Location added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding location: $e');
      return null;
    }
  }

  /// Update location ratings when a review is added
  static Future<void> updateLocationRating(String locationId, double newRating) async {
    try {
      final locationDoc = _firestore.collection('locations').doc(locationId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(locationDoc);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final currentRating = (data['averageRating'] ?? 0.0).toDouble();
        final currentTotal = (data['totalReviews'] ?? 0) as int;
        
        // Calculate new average
        final newTotal = currentTotal + 1;
        final newAverage = ((currentRating * currentTotal) + newRating) / newTotal;
        
        transaction.update(locationDoc, {
          'averageRating': newAverage,
          'totalReviews': newTotal,
        });
      });
    } catch (e) {
      print('Error updating location rating: $e');
    }
  }

  /// Search locations by name or tags
  static Future<List<LocationModel>> searchLocations(String query) async {
    try {
      final allLocations = await getAllLocations();
      
      if (query.isEmpty) return allLocations;
      
      final searchQuery = query.toLowerCase();
      
      return allLocations.where((location) {
        return location.name.toLowerCase().contains(searchQuery) ||
               location.address.toLowerCase().contains(searchQuery) ||
               location.tags.any((tag) => tag.toLowerCase().contains(searchQuery)) ||
               (location.description?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  /// Get locations by user
  static Future<List<LocationModel>> getLocationsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('locations')
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => LocationModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error getting user locations: $e');
      return [];
    }
  }

  /// Calculate distance between two points in kilometers
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * 
        sin(dLon / 2) * sin(dLon / 2);
    
    final double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }
  
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Get popular tags for autocomplete
  static Future<List<String>> getPopularTags() async {
    try {
      final querySnapshot = await _firestore.collection('locations').get();
      
      final Map<String, int> tagCounts = {};
      
      for (final doc in querySnapshot.docs) {
        final tags = List<String>.from(doc.data()['tags'] ?? []);
        for (final tag in tags) {
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
      }
      
      // Sort by popularity and return top tags
      final sortedTags = tagCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      return sortedTags.take(20).map((e) => e.key).toList();
    } catch (e) {
      print('Error getting popular tags: $e');
      return ['wings', 'beer', 'bar', 'grill', 'pub', 'sports-bar'];
    }
  }
}
