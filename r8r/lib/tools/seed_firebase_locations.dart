import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/seed_locations.dart';
import '../services/places_service.dart';

/// Tool to seed Firebase with initial locations
/// Run this once to populate your database with starter locations
class FirebaseLocationSeeder {
  
  /// Seed Firebase with your local wing spots
  static Future<void> seedFirebaseLocations() async {
    try {
      print('🌱 Starting Firebase location seeding...');
      
      final locations = [
        ...SeedLocations.getSeedLocations(),
        ...SeedLocations.getChainLocations(),
      ];
      
      int successCount = 0;
      int errorCount = 0;
      
      for (final location in locations) {
        try {
          // Check if location already exists
          final existingQuery = await FirebaseFirestore.instance
              .collection('locations')
              .where('name', isEqualTo: location.name)
              .where('address', isEqualTo: location.address)
              .get();
          
          if (existingQuery.docs.isNotEmpty) {
            print('⏭️  Skipping ${location.name} - already exists');
            continue;
          }
          
          // Add location to Firebase
          final locationData = location.toJson();
          locationData.remove('id'); // Let Firestore generate ID
          locationData['createdBy'] = 'seed_system'; // Mark as seeded
          locationData['createdAt'] = DateTime.now().millisecondsSinceEpoch;
          
          await FirebaseFirestore.instance
              .collection('locations')
              .add(locationData);
          
          print('✅ Added: ${location.name}');
          successCount++;
          
        } catch (e) {
          print('❌ Error adding ${location.name}: $e');
          errorCount++;
        }
      }
      
      print('🎉 Seeding complete!');
      print('✅ Successfully added: $successCount locations');
      if (errorCount > 0) {
        print('❌ Errors: $errorCount locations');
      }
      
    } catch (e) {
      print('💥 Fatal error during seeding: $e');
    }
  }
  
  /// Remove all seeded locations (for testing)
  static Future<void> clearSeededLocations() async {
    try {
      print('🧹 Clearing seeded locations...');
      
      final seededDocs = await FirebaseFirestore.instance
          .collection('locations')
          .where('createdBy', isEqualTo: 'seed_system')
          .get();
      
      for (final doc in seededDocs.docs) {
        await doc.reference.delete();
        print('🗑️  Deleted: ${doc.data()['name']}');
      }
      
      print('✅ Cleared ${seededDocs.docs.length} seeded locations');
      
    } catch (e) {
      print('❌ Error clearing seeded locations: $e');
    }
  }
  
  /// Check what locations exist in Firebase
  static Future<void> listFirebaseLocations() async {
    try {
      print('📋 Current Firebase locations:');
      
      final snapshot = await FirebaseFirestore.instance
          .collection('locations')
          .orderBy('createdAt', descending: true)
          .get();
      
      if (snapshot.docs.isEmpty) {
        print('📭 No locations found in Firebase');
        return;
      }
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final createdBy = data['createdBy'] ?? 'unknown';
        final isSeeded = createdBy == 'seed_system';
        final icon = isSeeded ? '🌱' : '👤';
        
        print('$icon ${data['name']} - ${data['address']} (by: $createdBy)');
      }
      
      print('📊 Total: ${snapshot.docs.length} locations');
      
    } catch (e) {
      print('❌ Error listing locations: $e');
    }
  }
}
