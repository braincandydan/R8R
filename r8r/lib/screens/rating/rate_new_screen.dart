import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../services/rating_service.dart';
import '../../models/rating_model.dart';
import '../../models/location_model.dart';

class RateNewScreen extends StatefulWidget {
  const RateNewScreen({super.key});

  @override
  State<RateNewScreen> createState() => _RateNewScreenState();
}

class _RateNewScreenState extends State<RateNewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  
  LocationModel? _selectedLocation;
  String _customLocationName = '';
  String _customLocationAddress = '';
  bool _isCustomLocation = false;
  bool _isSubmitting = false;
  
  List<WingRating> _wingRatings = [];
  List<BeerRating> _beerRatings = [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Experience'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Selection Section
              _buildLocationSection(),
              const SizedBox(height: 24),

              // Wing Ratings Section
              _buildWingSection(),
              const SizedBox(height: 24),

              // Beer Ratings Section
              _buildBeerSection(),
              const SizedBox(height: 24),

              // Comment Section
              _buildCommentSection(),
              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.mapLocationDot,
                color: const Color(0xFFFF6B35),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Location',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Location Selection Toggle
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isCustomLocation = false),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: !_isCustomLocation 
                          ? const Color(0xFFFF6B35).withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !_isCustomLocation 
                            ? const Color(0xFFFF6B35)
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.magnifyingGlass,
                          color: !_isCustomLocation 
                              ? const Color(0xFFFF6B35)
                              : Colors.grey[600],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Select Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: !_isCustomLocation 
                                ? const Color(0xFFFF6B35)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isCustomLocation = true),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isCustomLocation 
                          ? const Color(0xFFFF6B35).withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isCustomLocation 
                            ? const Color(0xFFFF6B35)
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.plus,
                          color: _isCustomLocation 
                              ? const Color(0xFFFF6B35)
                              : Colors.grey[600],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isCustomLocation 
                                ? const Color(0xFFFF6B35)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (!_isCustomLocation) ...[
            // Location Picker
            Consumer<LocationService>(
              builder: (context, locationService, _) {
                final locations = locationService.locations;
                return DropdownButtonFormField<LocationModel>(
                  value: _selectedLocation,
                  decoration: const InputDecoration(
                    labelText: 'Choose Location',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  items: locations.map((location) {
                    return DropdownMenuItem<LocationModel>(
                      value: location,
                      child: Text(location.name),
                    );
                  }).toList(),
                  onChanged: (location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a location';
                    }
                    return null;
                  },
                );
              },
            ),
          ] else ...[
            // Custom Location Fields
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Restaurant Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant),
              ),
              onChanged: (value) => _customLocationName = value,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter restaurant name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              onChanged: (value) => _customLocationAddress = value,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
              const SizedBox(width: 12),
              Text(
                'Wings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addWingRating,
                icon: const FaIcon(FontAwesomeIcons.plus, size: 12),
                label: const Text('Add Wings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_wingRatings.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  FaIcon(
                    FontAwesomeIcons.drumstickBite,
                    color: Colors.grey[400],
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No wings added yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "Add Wings" to rate your wing order',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._wingRatings.asMap().entries.map((entry) {
              final index = entry.key;
              final wingRating = entry.value;
              return _buildWingRatingCard(index, wingRating);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildWingRatingCard(int index, WingRating wingRating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Text(
                'Wing Order ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _removeWingRating(index),
                child: FaIcon(
                  FontAwesomeIcons.trash,
                  color: Colors.red[600],
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Flavor Input
          TextFormField(
            initialValue: wingRating.flavor,
            decoration: const InputDecoration(
              labelText: 'Wing Flavor',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.local_dining),
            ),
            onChanged: (value) => wingRating.flavor = value,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter wing flavor';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          
          // Rating Slider
          Text(
            'Rating: ${wingRating.rating.toStringAsFixed(1)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Slider(
            value: wingRating.rating,
            min: -10,
            max: 10,
            divisions: 20,
            activeColor: Colors.orange,
            onChanged: (value) {
              setState(() {
                wingRating.rating = value;
              });
            },
          ),
          
          // Photo Section
          if (wingRating.photoPath.isNotEmpty)
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  wingRating.photoPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image),
                    );
                  },
                ),
              ),
            ),
          
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _takeWingPhoto(index),
            icon: const FaIcon(FontAwesomeIcons.camera, size: 12),
            label: Text(wingRating.photoPath.isEmpty ? 'Take Photo' : 'Change Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeerSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.beer,
                color: Colors.amber[700],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Beer',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addBeerRating,
                icon: const FaIcon(FontAwesomeIcons.plus, size: 12),
                label: const Text('Add Beer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_beerRatings.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  FaIcon(
                    FontAwesomeIcons.beer,
                    color: Colors.grey[400],
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No beer added yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "Add Beer" to rate your beer',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._beerRatings.asMap().entries.map((entry) {
              final index = entry.key;
              final beerRating = entry.value;
              return _buildBeerRatingCard(index, beerRating);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildBeerRatingCard(int index, BeerRating beerRating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Text(
                'Beer ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _removeBeerRating(index),
                child: FaIcon(
                  FontAwesomeIcons.trash,
                  color: Colors.red[600],
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Beer Type Input
          TextFormField(
            initialValue: beerRating.type,
            decoration: const InputDecoration(
              labelText: 'Beer Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.local_drink),
            ),
            onChanged: (value) => beerRating.type = value,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter beer type';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          
          // Rating Slider
          Text(
            'Rating: ${beerRating.rating.toStringAsFixed(1)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Slider(
            value: beerRating.rating,
            min: -10,
            max: 10,
            divisions: 20,
            activeColor: Colors.amber[700],
            onChanged: (value) {
              setState(() {
                beerRating.rating = value;
              });
            },
          ),
          
          // Photo Section
          if (beerRating.photoPath.isNotEmpty)
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  beerRating.photoPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image),
                    );
                  },
                ),
              ),
            ),
          
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _takeBeerPhoto(index),
            icon: const FaIcon(FontAwesomeIcons.camera, size: 12),
            label: Text(beerRating.photoPath.isEmpty ? 'Take Photo' : 'Change Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.comment,
                color: Colors.grey[700],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Overall Comment',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Share your overall experience (optional)',
              border: OutlineInputBorder(),
              hintText: 'Tell us about your visit...',
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitRating,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Submit Review',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  void _addWingRating() {
    setState(() {
      _wingRatings.add(WingRating());
    });
  }

  void _removeWingRating(int index) {
    setState(() {
      _wingRatings.removeAt(index);
    });
  }

  void _addBeerRating() {
    setState(() {
      _beerRatings.add(BeerRating());
    });
  }

  void _removeBeerRating(int index) {
    setState(() {
      _beerRatings.removeAt(index);
    });
  }

  void _takeWingPhoto(int index) {
    // For now, simulate taking a photo
    setState(() {
      _wingRatings[index].photoPath = 'https://via.placeholder.com/150x150/FF6B35/FFFFFF?text=Wing+Photo+${index + 1}';
    });
  }

  void _takeBeerPhoto(int index) {
    // For now, simulate taking a photo
    setState(() {
      _beerRatings[index].photoPath = 'https://via.placeholder.com/150x150/FFA500/FFFFFF?text=Beer+Photo+${index + 1}';
    });
  }

  Future<void> _submitRating() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_wingRatings.isEmpty && _beerRatings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one wing or beer rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final ratingService = Provider.of<RatingService>(context, listen: false);
      
      // Create location if custom
      String locationId;
      String locationName;
      
      if (_isCustomLocation) {
        locationId = DateTime.now().millisecondsSinceEpoch.toString();
        locationName = _customLocationName;
        // In a real app, you'd save this to the backend
      } else {
        locationId = _selectedLocation!.id;
        locationName = _selectedLocation!.name;
      }

      // Calculate overall rating
      double totalRating = 0;
      int ratingCount = 0;
      
      for (var wing in _wingRatings) {
        totalRating += wing.rating;
        ratingCount++;
      }
      
      for (var beer in _beerRatings) {
        totalRating += beer.rating;
        ratingCount++;
      }
      
      final overallRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;
      
      // Build comment with details
      String comment = '';
      if (_wingRatings.isNotEmpty) {
        comment += 'Wings: ${_wingRatings.map((w) => '${w.flavor} (${w.rating.toStringAsFixed(1)})').join(', ')}\n';
      }
      if (_beerRatings.isNotEmpty) {
        comment += 'Beer: ${_beerRatings.map((b) => '${b.type} (${b.rating.toStringAsFixed(1)})').join(', ')}\n';
      }
      if (_commentController.text.trim().isNotEmpty) {
        comment += _commentController.text.trim();
      }

      // Create rating
      final rating = RatingModel(
        wingCrispiness: 3,
        wingFlavor: 3,
        wingSize: 3,
        beerSelection: 3,
        beerPairing: 3,
      );

      await ratingService.submitRating(
        locationId: locationId,
        userId: authService.currentUserId!,
        userName: authService.currentUserName ?? 'Anonymous',
        rating: rating,
        comment: comment.isEmpty ? null : comment,
        locationName: locationName,
      );

      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review submitted for $locationName!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class WingRating {
  String flavor = '';
  double rating = 0.0;
  String photoPath = '';
}

class BeerRating {
  String type = '';
  double rating = 0.0;
  String photoPath = '';
}
