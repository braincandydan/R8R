import 'package:flutter/foundation.dart';
import '../models/rating_model.dart';
import '../models/review_model.dart';

class RatingService extends ChangeNotifier {
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;

  List<ReviewModel> get reviews => _reviews;
  List<ReviewModel> get recentReviews => getRecentReviews();
  bool get isLoading => _isLoading;

  RatingService() {
    _initializeData();
  }

  void _initializeData() {
    // Mock data for MVP - in production, this would come from your backend
    _reviews = [
      ReviewModel(
        id: '1',
        locationId: '1',
        locationName: 'Buffalo Wild Wings',
        userId: 'user1',
        userName: 'WingLover42',
        rating: RatingModel(
          wingCrispiness: 4,
          wingFlavor: 5,
          wingSize: 3,
          beerSelection: 4,
          beerPairing: 4,
        ),
        comment: 'Great wings! The buffalo sauce was perfect. Beer selection was decent.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ReviewModel(
        id: '2',
        locationId: '1',
        locationName: 'Buffalo Wild Wings',
        userId: 'user2',
        userName: 'BeerMaster',
        rating: RatingModel(
          wingCrispiness: 3,
          wingFlavor: 4,
          wingSize: 4,
          beerSelection: 5,
          beerPairing: 5,
        ),
        comment: 'Amazing beer selection! Wings were good but could be crispier.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ReviewModel(
        id: '3',
        locationId: '2',
        locationName: 'Wingstop',
        userId: 'user3',
        userName: 'SpiceQueen',
        rating: RatingModel(
          wingCrispiness: 5,
          wingFlavor: 5,
          wingSize: 4,
          beerSelection: 3,
          beerPairing: 3,
        ),
        comment: 'Perfect crispy wings with amazing flavor! The heat level was just right.',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
    notifyListeners();
  }

  Future<void> submitRating({
    required String locationId,
    required String userId,
    required String userName,
    required RatingModel rating,
    String? comment,
    String? locationName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In production, this would submit to your backend
      final newReview = ReviewModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        locationId: locationId,
        locationName: locationName,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        timestamp: DateTime.now(),
        createdAt: DateTime.now(),
      );

      _reviews.insert(0, newReview); // Add to beginning of list
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Error submitting rating: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ReviewModel> getReviewsForLocation(String locationId) {
    return _reviews.where((review) => review.locationId == locationId).toList();
  }

  List<ReviewModel> getRecentReviews({int limit = 10}) {
    final sortedReviews = List<ReviewModel>.from(_reviews);
    sortedReviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedReviews.take(limit).toList();
  }

  double getAverageRatingForLocation(String locationId) {
    final locationReviews = getReviewsForLocation(locationId);
    if (locationReviews.isEmpty) return 0.0;

    double totalRating = 0.0;
    for (final review in locationReviews) {
      totalRating += review.rating.getOverallRating();
    }

    return totalRating / locationReviews.length;
  }

  int getTotalReviewsForLocation(String locationId) {
    return getReviewsForLocation(locationId).length;
  }
}
