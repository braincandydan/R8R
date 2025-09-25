import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../services/rating_service.dart';
import '../../models/rating_model.dart';

class RatingScreen extends StatefulWidget {
  final String locationId;

  const RatingScreen({
    super.key,
    required this.locationId,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  double _wingCrispiness = 3.0;
  double _wingFlavor = 3.0;
  double _wingSize = 3.0;
  double _beerSelection = 3.0;
  double _beerPairing = 3.0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final ratingService = Provider.of<RatingService>(context, listen: false);
    final locationService = Provider.of<LocationService>(context, listen: false);

    if (authService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to submit a rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final location = locationService.getLocationById(widget.locationId);
    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final rating = RatingModel(
      wingCrispiness: _wingCrispiness.round(),
      wingFlavor: _wingFlavor.round(),
      wingSize: _wingSize.round(),
      beerSelection: _beerSelection.round(),
      beerPairing: _beerPairing.round(),
    );

    await ratingService.submitRating(
      locationId: widget.locationId,
      userId: authService.currentUserId!,
      userName: authService.currentUserName ?? 'Anonymous',
      rating: rating,
      comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/location/${widget.locationId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Location'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<LocationService>(
        builder: (context, locationService, _) {
          final location = locationService.getLocationById(widget.locationId);
          
          if (location == null) {
            return const Center(
              child: Text('Location not found'),
            );
          }

          return Consumer<RatingService>(
            builder: (context, ratingService, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location header
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.drumstickBite,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      location.name,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      location.address,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Wing ratings section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.drumstickBite,
                                  color: Colors.orange[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Wing Ratings',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            _buildRatingSection(
                              context,
                              title: 'Crispiness',
                              subtitle: 'How crispy are the wings?',
                              icon: FontAwesomeIcons.cookie,
                              value: _wingCrispiness,
                              onChanged: (value) => setState(() => _wingCrispiness = value),
                              category: 'wing',
                            ),
                            
                            _buildRatingSection(
                              context,
                              title: 'Flavor',
                              subtitle: 'How tasty and well-seasoned are the wings?',
                              icon: FontAwesomeIcons.utensils,
                              value: _wingFlavor,
                              onChanged: (value) => setState(() => _wingFlavor = value),
                              category: 'wing',
                            ),
                            
                            _buildRatingSection(
                              context,
                              title: 'Size',
                              subtitle: 'How big and meaty are the wings?',
                              icon: FontAwesomeIcons.weightScale,
                              value: _wingSize,
                              onChanged: (value) => setState(() => _wingSize = value),
                              category: 'wing',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Beer ratings section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.beerMugEmpty,
                                  color: Colors.amber[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Beer Ratings',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            _buildRatingSection(
                              context,
                              title: 'Selection',
                              subtitle: 'How good is the beer selection?',
                              icon: FontAwesomeIcons.beerMugEmpty,
                              value: _beerSelection,
                              onChanged: (value) => setState(() => _beerSelection = value),
                              category: 'beer',
                            ),
                            
                            _buildRatingSection(
                              context,
                              title: 'Pairing',
                              subtitle: 'How well do the beers pair with wings?',
                              icon: FontAwesomeIcons.handshake,
                              value: _beerPairing,
                              onChanged: (value) => setState(() => _beerPairing = value),
                              category: 'beer',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Overall rating summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.star,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Overall Rating',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildOverallRatingItem(
                                  context,
                                  icon: FontAwesomeIcons.drumstickBite,
                                  label: 'Wings',
                                  rating: (_wingCrispiness + _wingFlavor + _wingSize) / 3,
                                  color: Colors.orange,
                                ),
                                _buildOverallRatingItem(
                                  context,
                                  icon: FontAwesomeIcons.beerMugEmpty,
                                  label: 'Beer',
                                  rating: (_beerSelection + _beerPairing) / 2,
                                  color: Colors.amber,
                                ),
                                _buildOverallRatingItem(
                                  context,
                                  icon: FontAwesomeIcons.star,
                                  label: 'Total',
                                  rating: (_wingCrispiness + _wingFlavor + _wingSize + _beerSelection + _beerPairing) / 5,
                                  color: Theme.of(context).colorScheme.primary,
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Comment section
                      Text(
                        'Additional Comments (Optional)',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Share your thoughts about this location...',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: ratingService.isLoading ? null : _submitRating,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: ratingService.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Submit Rating',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          );
        },
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
    required String category,
  }) {
    final categoryColor = category == 'wing' ? Colors.orange : Colors.amber;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  icon,
                  color: categoryColor,
                  size: 18,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${value.round()}/5',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: RatingBar.builder(
              initialRating: value,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
              itemBuilder: (context, index) {
                if (index < value.round()) {
                  return Icon(
                    Icons.star,
                    color: categoryColor,
                  );
                } else {
                  return Icon(
                    Icons.star_border,
                    color: Colors.grey[400],
                  );
                }
              },
              onRatingUpdate: onChanged,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getRatingDescription(title, value.round()),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallRatingItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double rating,
    required Color color,
    bool isTotal = false,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: isTotal 
                ? Border.all(color: color.withOpacity(0.3), width: 2)
                : null,
          ),
          child: FaIcon(
            icon,
            color: color,
            size: isTotal ? 24 : 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? color : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getRatingDescription(String category, int rating) {
    switch (category) {
      case 'Crispiness':
        switch (rating) {
          case 1: return 'Very Soft';
          case 2: return 'Soft';
          case 3: return 'Good';
          case 4: return 'Crispy';
          case 5: return 'Perfect';
          default: return '';
        }
      case 'Flavor':
        switch (rating) {
          case 1: return 'Bland';
          case 2: return 'Mild';
          case 3: return 'Good';
          case 4: return 'Great';
          case 5: return 'Amazing';
          default: return '';
        }
      case 'Size':
        switch (rating) {
          case 1: return 'Very Small';
          case 2: return 'Small';
          case 3: return 'Average';
          case 4: return 'Large';
          case 5: return 'Huge';
          default: return '';
        }
      case 'Selection':
        switch (rating) {
          case 1: return 'Poor';
          case 2: return 'Limited';
          case 3: return 'Decent';
          case 4: return 'Good';
          case 5: return 'Excellent';
          default: return '';
        }
      case 'Pairing':
        switch (rating) {
          case 1: return 'Poor Match';
          case 2: return 'Okay';
          case 3: return 'Good';
          case 4: return 'Great';
          case 5: return 'Perfect';
          default: return '';
        }
      default:
        return '';
    }
  }
}
