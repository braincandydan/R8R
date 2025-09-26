import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/location_model.dart';
import '../models/rating_model.dart';
import '../models/review_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  static CollectionReference get _locations => _firestore.collection('locations');
  static CollectionReference get _reviews => _firestore.collection('reviews');
  static CollectionReference get _users => _firestore.collection('users');

  // Auth methods
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> createUserWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Location methods
  static Future<List<LocationModel>> getLocations() async {
    try {
      final snapshot = await _locations.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LocationModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error getting locations: $e');
      return [];
    }
  }

  static Future<void> addLocation(LocationModel location) async {
    try {
      await _locations.add(location.toJson());
    } catch (e) {
      print('Error adding location: $e');
      throw e;
    }
  }

  static Future<List<LocationModel>> searchLocations(String query) async {
    try {
      final snapshot = await _locations
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LocationModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  // Review methods
  static Future<List<ReviewModel>> getRecentReviews({int limit = 10}) async {
    try {
      final snapshot = await _reviews
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ReviewModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error getting recent reviews: $e');
      return [];
    }
  }

  static Future<List<ReviewModel>> getReviewsForLocation(String locationId) async {
    try {
      final snapshot = await _reviews
          .where('locationId', isEqualTo: locationId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ReviewModel.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error getting reviews for location: $e');
      return [];
    }
  }

  static Future<void> submitReview({
    required String locationId,
    required String locationName,
    required String userId,
    required String userName,
    required RatingModel rating,
    String? comment,
    List<Map<String, dynamic>>? wingRatings,
    List<Map<String, dynamic>>? beerRatings,
  }) async {
    try {
      final reviewData = {
        'locationId': locationId,
        'locationName': locationName,
        'userId': userId,
        'userName': userName,
        'rating': rating.toJson(),
        'comment': comment,
        'wingRatings': wingRatings ?? [],
        'beerRatings': beerRatings ?? [],
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _reviews.add(reviewData);
    } catch (e) {
      print('Error submitting review: $e');
      throw e;
    }
  }

  // Photo upload methods
  static Future<String> uploadPhoto(String path, List<int> data) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putData(data);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading photo: $e');
      throw e;
    }
  }

  // User profile methods
  static Future<void> updateUserProfile({
    required String userId,
    required String displayName,
    String? photoURL,
  }) async {
    try {
      await _users.doc(userId).set({
        'displayName': displayName,
        'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
}
