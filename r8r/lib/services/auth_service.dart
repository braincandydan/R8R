import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _currentUserId;
  String? _currentUserName;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;

  AuthService() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _currentUserId = prefs.getString('currentUserId');
    _currentUserName = prefs.getString('currentUserName');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // For MVP, we'll use simple authentication
    // In production, this would connect to your backend
    if (email.isNotEmpty && password.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = true;
      _currentUserId = email; // Using email as ID for now
      _currentUserName = email.split('@')[0]; // Extract username from email
      
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('currentUserId', _currentUserId!);
      await prefs.setString('currentUserName', _currentUserName!);
      
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signup(String email, String password, String username) async {
    // For MVP, we'll use simple signup
    // In production, this would connect to your backend
    if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = true;
      _currentUserId = email;
      _currentUserName = username;
      
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('currentUserId', _currentUserId!);
      await prefs.setString('currentUserName', _currentUserName!);
      
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _isAuthenticated = false;
    _currentUserId = null;
    _currentUserName = null;
    
    notifyListeners();
  }
}
