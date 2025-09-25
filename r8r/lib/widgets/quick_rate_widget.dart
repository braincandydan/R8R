import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/rating_service.dart';
import '../models/rating_model.dart';

class QuickRateWidget extends StatefulWidget {
  final String locationId;
  final String locationName;
  final VoidCallback? onRatingSubmitted;

  const QuickRateWidget({
    super.key,
    required this.locationId,
    required this.locationName,
    this.onRatingSubmitted,
  });

  @override
  State<QuickRateWidget> createState() => _QuickRateWidgetState();
}

class _QuickRateWidgetState extends State<QuickRateWidget> {
  double _overallRating = 3.0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.bolt,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Rate',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.locationName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Rating section
            Column(
              children: [
                Text(
                  'How was your experience?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: RatingBar.builder(
                    initialRating: _overallRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemBuilder: (context, index) {
                      if (index < _overallRating.round()) {
                        return const Icon(
                          Icons.star,
                          color: Colors.amber,
                        );
                      } else {
                        return Icon(
                          Icons.star_border,
                          color: Colors.grey[400],
                        );
                      }
                    },
                    onRatingUpdate: (rating) {
                      setState(() {
                        _overallRating = rating;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getRatingDescription(_overallRating.round()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitQuickRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Quick Rate',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitQuickRating() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final ratingService = Provider.of<RatingService>(context, listen: false);

    if (authService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to submit a rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Create a quick rating with equal values for all categories
    final rating = RatingModel(
      wingCrispiness: _overallRating.round(),
      wingFlavor: _overallRating.round(),
      wingSize: _overallRating.round(),
      beerSelection: _overallRating.round(),
      beerPairing: _overallRating.round(),
    );

    await ratingService.submitRating(
      locationId: widget.locationId,
      userId: authService.currentUserId!,
      userName: authService.currentUserName ?? 'Anonymous',
      rating: rating,
      comment: 'Quick rating: ${_getRatingDescription(_overallRating.round())}',
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quick rating submitted: ${_overallRating.round()}/5 stars!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Rate Details',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to detailed rating if needed
            },
          ),
        ),
      );

      // Reset rating for next use
      setState(() {
        _overallRating = 3.0;
      });

      // Call callback if provided
      widget.onRatingSubmitted?.call();
    }
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 1: return 'Poor experience';
      case 2: return 'Below average';
      case 3: return 'Average experience';
      case 4: return 'Good experience';
      case 5: return 'Excellent experience';
      default: return '';
    }
  }
}
