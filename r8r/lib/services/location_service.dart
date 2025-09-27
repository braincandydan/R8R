import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';
import '../data/seed_locations.dart';
import 'places_service.dart';

class LocationService extends ChangeNotifier {
  List<LocationModel> _locations = [];
  Position? _currentPosition;
  bool _isLoading = false;
  bool _useRealData = false; // Disabled to avoid API costs - use mock data and user-submitted locations

  List<LocationModel> get locations => _locations;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  bool get useRealData => _useRealData;

  LocationService() {
    _initializeData();
  }

  void _initializeData() {
    // Load mock data initially, then Firebase data will replace/supplement it
    _loadMockData();
    _loadFirebaseLocations();
  }

  void _loadMockData() {
    // Load seed locations for your area - customize in /lib/data/seed_locations.dart
    _locations = [
      ...SeedLocations.getSeedLocations(),
      ...SeedLocations.getChainLocations(),
    ];
    notifyListeners();
  }

  /// Load all locations from Firebase (seed + user-submitted, no API costs)
  Future<void> _loadFirebaseLocations() async {
    try {
      debugPrint('Loading all locations from Firebase...');
      
      final firebaseLocations = await UserLocationService.getAllLocations();
      
      if (firebaseLocations.isNotEmpty) {
        // Use Firebase as primary source, fallback to mock data if empty
        _locations = firebaseLocations;
        debugPrint('Loaded ${firebaseLocations.length} locations from Firebase');
      } else {
        // No Firebase data, use mock data
        debugPrint('No Firebase locations found, using mock data');
        _locations = [
          ...SeedLocations.getSeedLocations(),
          ...SeedLocations.getChainLocations(),
        ];
      }
      
      debugPrint('Total locations available: ${_locations.length}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading Firebase locations: $e');
      // Keep existing mock data if loading fails
    }
  }

  /// Remove duplicate locations based on name similarity
  List<LocationModel> _removeDuplicateLocations(List<LocationModel> locations) {
    final uniqueLocations = <LocationModel>[];
    final seenNames = <String>{};
    
    for (final location in locations) {
      final normalizedName = location.name.toLowerCase().trim();
      if (!seenNames.contains(normalizedName)) {
        seenNames.add(normalizedName);
        uniqueLocations.add(location);
      }
    }
    
    return uniqueLocations;
  }

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are not enabled');
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint('Current location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');

      // Load all locations from Firebase (seed + user-submitted)
      await _loadFirebaseLocations();
      
      // Sort all locations by distance
      _sortLocationsByDistance();
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _sortLocationsByDistance() {
    if (_currentPosition == null) return;

    _locations.sort((a, b) {
      final distanceA = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        a.latitude,
        a.longitude,
      );
      final distanceB = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        b.latitude,
        b.longitude,
      );
      return distanceA.compareTo(distanceB);
    });
    notifyListeners();
  }

  LocationModel? getLocationById(String id) {
    try {
      return _locations.firstWhere((location) => location.id == id);
    } catch (e) {
      return null;
    }
  }

  double getDistanceToLocation(LocationModel location) {
    if (_currentPosition == null) return 0.0;
    
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      location.latitude,
      location.longitude,
    );
  }

  List<LocationModel> searchLocations(String query) {
    if (query.isEmpty) return _locations;
    
    return _locations.where((location) =>
      location.name.toLowerCase().contains(query.toLowerCase()) ||
      location.address.toLowerCase().contains(query.toLowerCase()) ||
      location.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())) ||
      (location.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  /// Load user-submitted restaurants
  Future<void> loadRealRestaurants() async {
    try {
      debugPrint('Loading user-submitted restaurants...');
      
      List<LocationModel> userRestaurants;
      
      if (_currentPosition != null) {
        // Get nearby restaurants if we have location
        userRestaurants = await UserLocationService.searchNearbyLocations(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
        );
      } else {
        // Get all restaurants if no location
        userRestaurants = await UserLocationService.getAllLocations();
      }

      if (userRestaurants.isNotEmpty) {
        _locations = userRestaurants;
        if (_currentPosition != null) {
          _sortLocationsByDistance();
        }
        debugPrint('Loaded ${_locations.length} user-submitted restaurants');
      } else {
        debugPrint('No user restaurants found, keeping mock data');
        if (_currentPosition != null) {
          _sortLocationsByDistance();
        }
      }
    } catch (e) {
      debugPrint('Error loading user restaurants: $e');
      // Keep existing locations (mock data) if loading fails
      if (_currentPosition != null) {
        _sortLocationsByDistance();
      }
    }
  }

  /// Toggle between user-submitted and mock-only data (Google Places API disabled)
  void toggleDataSource() {
    _useRealData = !_useRealData;
    debugPrint('Data source toggled to: ${_useRealData ? "User-submitted + Mock" : "Mock Only"}');
    
    if (_useRealData) {
      _loadFirebaseLocations();
    } else {
      _loadMockData();
      if (_currentPosition != null) {
        _sortLocationsByDistance();
      }
    }
  }

  /// Refresh restaurant data from Firebase (seed + user-submitted, no API costs)
  Future<void> refreshRestaurants() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _loadFirebaseLocations();
      if (_currentPosition != null) {
        _sortLocationsByDistance();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
