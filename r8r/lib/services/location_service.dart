import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';

class LocationService extends ChangeNotifier {
  List<LocationModel> _locations = [];
  Position? _currentPosition;
  bool _isLoading = false;

  List<LocationModel> get locations => _locations;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;

  LocationService() {
    _initializeData();
  }

  void _initializeData() {
    // Mock data for MVP - in production, this would come from your backend
    _locations = [
      LocationModel(
        id: '1',
        name: 'Buffalo Wild Wings',
        address: '123 Main St, City, State 12345',
        phone: '(555) 123-4567',
        website: 'https://www.buffalowildwings.com',
        latitude: 40.7128,
        longitude: -74.0060,
        averageRating: 4.2,
        totalReviews: 156,
      ),
      LocationModel(
        id: '2',
        name: 'Wingstop',
        address: '456 Oak Ave, City, State 12345',
        phone: '(555) 987-6543',
        website: 'https://www.wingstop.com',
        latitude: 40.7589,
        longitude: -73.9851,
        averageRating: 4.5,
        totalReviews: 89,
      ),
      LocationModel(
        id: '3',
        name: 'Hooters',
        address: '789 Pine St, City, State 12345',
        phone: '(555) 456-7890',
        website: 'https://www.hooters.com',
        latitude: 40.7505,
        longitude: -73.9934,
        averageRating: 3.8,
        totalReviews: 234,
      ),
      LocationModel(
        id: '4',
        name: 'Local Wing House',
        address: '321 Elm St, City, State 12345',
        phone: '(555) 321-9876',
        website: 'https://www.localwinghouse.com',
        latitude: 40.7282,
        longitude: -73.7949,
        averageRating: 4.7,
        totalReviews: 45,
      ),
    ];
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Sort locations by distance
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
      location.address.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
