import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/rating_service.dart';
import '../models/rating_model.dart';

class QuickRateDialog extends StatefulWidget {
  final String locationId;
  final String locationName;

  const QuickRateDialog({
    super.key,
    required this.locationId,
    required this.locationName,
  });

  @override
  State<QuickRateDialog> createState() => _QuickRateDialogState();
}

class _QuickRateDialogState extends State<QuickRateDialog> {
  double _wingRating = 3.0;
  double _beerRating = 3.0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Rate',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.locationName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Wing Rating
            _buildRatingSection(
              context,
              title: 'Wings',
              subtitle: 'How were the wings?',
              icon: FontAwesomeIcons.drumstickBite,
              value: _wingRating,
              onChanged: (value) => setState(() => _wingRating = value),
              color: Colors.orange,
            ),

            const SizedBox(height: 16),

            // Beer Rating
            _buildRatingSection(
              context,
              title: 'Beer',
              subtitle: 'How was the beer?',
              icon: FontAwesomeIcons.beerMugEmpty,
              value: _beerRating,
              onChanged: (value) => setState(() => _beerRating = value),
              color: Colors.amber,
            ),

            const SizedBox(height: 24),

            // Overall Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSummaryItem('Wings', _wingRating, Colors.orange),
                  Container(
                    height: 20,
                    width: 1,
                    color: Colors.grey[300],
                  ),
                  _buildSummaryItem('Beer', _beerRating, Colors.amber),
                  Container(
                    height: 20,
                    width: 1,
                    color: Colors.grey[300],
                  ),
                  _buildSummaryItem(
                    'Total',
                    (_wingRating + _beerRating) / 2,
                    Theme.of(context).colorScheme.primary,
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.round()}/5',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: RatingBar.builder(
              initialRating: value,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, index) {
                if (index < value.round()) {
                  return Icon(
                    Icons.star,
                    color: color,
                    size: 20,
                  );
                } else {
                  return Icon(
                    Icons.star_border,
                    color: Colors.grey[400],
                    size: 20,
                  );
                }
              },
              onRatingUpdate: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double rating, Color color, {bool isTotal = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? color : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _submitRating() async {
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

    // Create rating with the selected values
    final rating = RatingModel(
      wingCrispiness: _wingRating.round(),
      wingFlavor: _wingRating.round(),
      wingSize: _wingRating.round(),
      beerSelection: _beerRating.round(),
      beerPairing: _beerRating.round(),
    );

    await ratingService.submitRating(
      locationId: widget.locationId,
      userId: authService.currentUserId!,
      userName: authService.currentUserName ?? 'Anonymous',
      rating: rating,
      comment: 'Quick rating: Wings ${_wingRating.round()}/5, Beer ${_beerRating.round()}/5',
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quick rating submitted! Wings: ${_wingRating.round()}/5, Beer: ${_beerRating.round()}/5'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
