import 'rating_model.dart';

class ReviewModel {
  final String id;
  final String locationId;
  final String userId;
  final String userName;
  final RatingModel rating;
  final String? comment;
  final DateTime timestamp;

  ReviewModel({
    required this.id,
    required this.locationId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locationId': locationId,
      'userId': userId,
      'userName': userName,
      'rating': rating.toJson(),
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      locationId: json['locationId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      rating: RatingModel.fromJson(json['rating'] ?? {}),
      comment: json['comment'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get overallRatingDisplay {
    final overallRating = rating.getOverallRating();
    return '${overallRating.toStringAsFixed(1)} ⭐';
  }

  String get wingRatingDisplay {
    final wingRating = rating.getWingRating();
    return '${wingRating.toStringAsFixed(1)} 🍗';
  }

  String get beerRatingDisplay {
    final beerRating = rating.getBeerRating();
    return '${beerRating.toStringAsFixed(1)} 🍺';
  }
}
