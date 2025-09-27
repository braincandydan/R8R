import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../tools/seed_firebase_locations.dart';
import '../../services/location_service.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoading = false;
  String _statusMessage = '';

  void _setStatus(String message, {bool isLoading = false}) {
    setState(() {
      _statusMessage = message;
      _isLoading = isLoading;
    });
  }

  Future<void> _seedLocations() async {
    _setStatus('Seeding Firebase with hardcoded locations...', isLoading: true);
    
    try {
      await FirebaseLocationSeeder.seedFirebaseLocations();
      _setStatus('✅ Successfully seeded Firebase locations!');
      
      // Refresh the location service
      if (mounted) {
        await Provider.of<LocationService>(context, listen: false).refreshRestaurants();
      }
    } catch (e) {
      _setStatus('❌ Error seeding locations: $e');
    }
  }

  Future<void> _clearSeededLocations() async {
    _setStatus('Clearing seeded locations...', isLoading: true);
    
    try {
      await FirebaseLocationSeeder.clearSeededLocations();
      _setStatus('✅ Cleared all seeded locations!');
      
      // Refresh the location service
      if (mounted) {
        await Provider.of<LocationService>(context, listen: false).refreshRestaurants();
      }
    } catch (e) {
      _setStatus('❌ Error clearing locations: $e');
    }
  }

  Future<void> _listLocations() async {
    _setStatus('Fetching Firebase locations...', isLoading: true);
    
    try {
      await FirebaseLocationSeeder.listFirebaseLocations();
      _setStatus('✅ Check debug console for location list');
    } catch (e) {
      _setStatus('❌ Error listing locations: $e');
    }
  }

  Future<void> _refreshApp() async {
    _setStatus('Refreshing app data...', isLoading: true);
    
    try {
      if (mounted) {
        await Provider.of<LocationService>(context, listen: false).refreshRestaurants();
      }
      _setStatus('✅ App data refreshed!');
    } catch (e) {
      _setStatus('❌ Error refreshing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: const Color(0xFFD00000),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD00000).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  FaIcon(
                    FontAwesomeIcons.screwdriverWrench,
                    color: const Color(0xFFD00000),
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Location Management',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD00000),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage hardcoded locations in Firebase',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Status Message
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _statusMessage.startsWith('❌') 
                      ? Colors.red[50] 
                      : Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _statusMessage.startsWith('❌') 
                        ? Colors.red[200]! 
                        : Colors.green[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    if (_isLoading) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          color: _statusMessage.startsWith('❌') 
                              ? Colors.red[800] 
                              : Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Action Buttons
            _buildActionButton(
              icon: FontAwesomeIcons.seedling,
              title: 'Seed Firebase Locations',
              subtitle: 'Add hardcoded locations to Firebase database',
              onPressed: _isLoading ? null : _seedLocations,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            
            _buildActionButton(
              icon: FontAwesomeIcons.list,
              title: 'List Firebase Locations',
              subtitle: 'View all locations in Firebase (check console)',
              onPressed: _isLoading ? null : _listLocations,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            
            _buildActionButton(
              icon: FontAwesomeIcons.arrowsRotate,
              title: 'Refresh App Data',
              subtitle: 'Reload locations from Firebase',
              onPressed: _isLoading ? null : _refreshApp,
              color: const Color(0xFFD00000),
            ),
            const SizedBox(height: 12),
            
            _buildActionButton(
              icon: FontAwesomeIcons.trash,
              title: 'Clear Seeded Locations',
              subtitle: 'Remove all system-seeded locations (keeps user-added)',
              onPressed: _isLoading ? null : () => _showClearConfirmation(),
              color: Colors.orange,
            ),

            const Spacer(),
            
            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.circleInfo, 
                          color: Colors.blue[600], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'How it works:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Seed locations are stored in Firebase with createdBy: "seed_system"\n'
                    '• User-added locations have createdBy: [user_id]\n'
                    '• App loads both types automatically\n'
                    '• Seeding is safe - won\'t create duplicates',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          FaIcon(icon, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Seeded Locations?'),
        content: const Text(
          'This will remove all system-seeded locations from Firebase. '
          'User-added locations will remain untouched.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearSeededLocations();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
