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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final locationService = Provider.of<LocationService>(context, listen: false);
              locationService.refreshRestaurants();
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              Provider.of<LocationService>(context, listen: false).getCurrentLocation();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              final locationService = Provider.of<LocationService>(context, listen: false);
              if (value == 'toggle_data') {
                locationService.toggleDataSource();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_data',
                child: Consumer<LocationService>(
                  builder: (context, locationService, _) {
                    return Row(
                      children: [
                        Icon(locationService.useRealData ? Icons.location_off : Icons.location_on),
                        const SizedBox(width: 8),
                        Text(locationService.useRealData ? 'Use Mock Data' : 'Use Real Data'),
                      ],
                    );
                  },
                ),
              ),
            ],
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/location/${location.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.drumstickBite,
                        color: const Color(0xFFFF6B35),
                        size: 20,
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
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.locationDot,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  location.address,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.star,
                            color: Colors.amber[600],
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location.averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.locationArrow,
                            size: 10,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            distanceText,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${location.totalReviews} reviews',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: GestureDetector(
                            onTap: () => _showQuickRateDialog(context, location),
                            child: FaIcon(
                              FontAwesomeIcons.bolt,
                              color: const Color(0xFFFF6B35),
                              size: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/rate/${location.id}'),
                          icon: const FaIcon(FontAwesomeIcons.star, size: 12),
                          label: const Text('Rate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
