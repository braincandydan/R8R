import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/location_service.dart';
import '../../models/location_model.dart';
import '../../widgets/quick_rate_dialog.dart';

class LocationListScreen extends StatefulWidget {
  const LocationListScreen({super.key});

  @override
  State<LocationListScreen> createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationService>(context, listen: false).getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search locations...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text('Find Locations'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              Provider.of<LocationService>(context, listen: false).getCurrentLocation();
            },
          ),
        ],
      ),
      body: Consumer<LocationService>(
        builder: (context, locationService, _) {
          if (locationService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<LocationModel> locations = locationService.locations;
          
          // Filter locations based on search
          if (_searchController.text.isNotEmpty) {
            locations = locationService.searchLocations(_searchController.text);
          }

          if (locations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.mapLocationDot,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isNotEmpty 
                        ? 'No locations found'
                        : 'No locations available',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchController.text.isNotEmpty
                        ? 'Try adjusting your search terms'
                        : 'Check back later for new wing spots',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return _buildLocationCard(context, location);
            },
          );
        },
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, LocationModel location) {
    final locationService = Provider.of<LocationService>(context, listen: false);
    final distance = locationService.getDistanceToLocation(location);
    final distanceText = distance > 0 ? '${(distance * 0.000621371).toStringAsFixed(1)} mi' : 'Distance unknown';

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => context.go('/location/${location.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.drumstickBite,
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
                          location.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.locationDot,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location.address,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      location.ratingDisplay,
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FaIcon(
                    FontAwesomeIcons.locationArrow,
                    size: 12,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    distanceText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (location.phone.isNotEmpty) ...[
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.phone, size: 16),
                      onPressed: () {
                        // TODO: Implement phone call functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Call ${location.phone}')),
                        );
                      },
                      tooltip: 'Call',
                    ),
                  ],
                  if (location.website.isNotEmpty) ...[
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.globe, size: 16),
                      onPressed: () {
                        // TODO: Implement website opening
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Visit ${location.website}')),
                        );
                      },
                      tooltip: 'Website',
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showQuickRateDialog(context, location),
                        icon: const FaIcon(FontAwesomeIcons.bolt, size: 14),
                        tooltip: 'Quick Rate',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.orange.withOpacity(0.1),
                          foregroundColor: Colors.orange,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.go('/rate/${location.id}'),
                        icon: const FaIcon(FontAwesomeIcons.star, size: 14),
                        label: const Text('Rate'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickRateDialog(BuildContext context, LocationModel location) {
    showDialog(
      context: context,
      builder: (context) => QuickRateDialog(
        locationId: location.id,
        locationName: location.name,
      ),
    );
  }
}
