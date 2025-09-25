import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/location_service.dart';
import '../../services/rating_service.dart';
import '../../models/location_model.dart';

class LocationDetailScreen extends StatelessWidget {
  final String locationId;

  const LocationDetailScreen({
    super.key,
    required this.locationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<LocationService>(
        builder: (context, locationService, _) {
          final location = locationService.getLocationById(locationId);
          
          if (location == null) {
            return const Center(
              child: Text('Location not found'),
            );
          }

          return Consumer<RatingService>(
            builder: (context, ratingService, _) {
              final reviews = ratingService.getReviewsForLocation(locationId);
              final averageRating = ratingService.getAverageRatingForLocation(locationId);
              final totalReviews = ratingService.getTotalReviewsForLocation(locationId);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const FaIcon(
                                  FontAwesomeIcons.drumstickBite,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      location.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const FaIcon(
                                          FontAwesomeIcons.star,
                                          color: Colors.orange,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${averageRating.toStringAsFixed(1)} (${totalReviews} reviews)',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.locationDot,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  location.address,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.go('/rate/$locationId'),
                              icon: const FaIcon(FontAwesomeIcons.star),
                              label: const Text('Rate This Location'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (location.phone.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Call ${location.phone}')),
                                );
                              },
                              icon: const FaIcon(FontAwesomeIcons.phone),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          if (location.website.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Visit ${location.website}')),
                                );
                              },
                              icon: const FaIcon(FontAwesomeIcons.globe),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Contact information
                    if (location.phone.isNotEmpty || location.website.isNotEmpty)
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contact Information',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (location.phone.isNotEmpty)
                                ListTile(
                                  leading: const FaIcon(FontAwesomeIcons.phone),
                                  title: const Text('Phone'),
                                  subtitle: Text(location.phone),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              if (location.website.isNotEmpty)
                                ListTile(
                                  leading: const FaIcon(FontAwesomeIcons.globe),
                                  title: const Text('Website'),
                                  subtitle: Text(location.website),
                                  contentPadding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                        ),
                      ),

                    // Reviews section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Reviews (${reviews.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    if (reviews.isEmpty)
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.commentDots,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No reviews yet',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Be the first to share your experience!',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => context.go('/rate/$locationId'),
                                icon: const FaIcon(FontAwesomeIcons.star),
                                label: const Text('Write Review'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: reviews.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return _buildReviewCard(context, review);
                        },
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, review) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    review.userName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        review.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    review.overallRatingDisplay,
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Rating breakdown
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wings',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            review.wingRatingDisplay,
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Crispy: ${review.rating.wingCrispiness}/5',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Beer',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            review.beerRatingDisplay,
                            style: TextStyle(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Selection: ${review.rating.beerSelection}/5',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  review.comment!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
