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
                      Text(
                        'Wing Ratings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildRatingSection(
                        context,
                        title: 'Crispiness',
                        subtitle: 'How crispy are the wings?',
                        icon: FontAwesomeIcons.cookie,
                        value: _wingCrispiness,
                        onChanged: (value) => setState(() => _wingCrispiness = value),
                      ),
                      
                      _buildRatingSection(
                        context,
                        title: 'Flavor',
                        subtitle: 'How tasty are the wings?',
                        icon: FontAwesomeIcons.utensils,
                        value: _wingFlavor,
                        onChanged: (value) => setState(() => _wingFlavor = value),
                      ),
                      
                      _buildRatingSection(
                        context,
                        title: 'Size',
                        subtitle: 'How big are the wings?',
                        icon: FontAwesomeIcons.weightScale,
                        value: _wingSize,
                        onChanged: (value) => setState(() => _wingSize = value),
                      ),

                      const SizedBox(height: 24),

                      // Beer ratings section
                      Text(
                        'Beer Ratings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildRatingSection(
                        context,
                        title: 'Selection',
                        subtitle: 'How good is the beer selection?',
                        icon: FontAwesomeIcons.beerMugEmpty,
                        value: _beerSelection,
                        onChanged: (value) => setState(() => _beerSelection = value),
                      ),
                      
                      _buildRatingSection(
                        context,
                        title: 'Pairing',
                        subtitle: 'How well do the beers pair with wings?',
                        icon: FontAwesomeIcons.handshake,
                        value: _beerPairing,
                        onChanged: (value) => setState(() => _beerPairing = value),
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
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
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
                Text(
                  '${value.round()}/5',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
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
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: onChanged,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _getRatingDescription(title, value.round()),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
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
