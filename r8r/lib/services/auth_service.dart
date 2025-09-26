import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  bool _isAuthenticated = false;
  String? _currentUserId;
  String? _currentUserName;
  User? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  User? get currentUser => _currentUser;

  AuthService() {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      _isAuthenticated = user != null;
      _currentUserId = user?.uid;
      _currentUserName = user?.displayName ?? user?.email?.split('@')[0];
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Update user profile if needed
        await _updateUserProfile(result.user!);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> signup(String email, String password, String username) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(username);
        
        // Create user document in Firestore
        await _createUserDocument(result.user!, username);
        
        // Update user profile
        await _updateUserProfile(result.user!);
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Signup error: $e');
      return false;
    }
  }

  Future<void> _createUserDocument(User user, String username) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'username': username,
        'displayName': username,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating user document: $e');
    }
  }

  Future<void> _updateUserProfile(User user) async {
    try {
      // Update last login time
      await _firestore.collection('users').doc(user.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user profile: $e');
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result = await _auth.signInWithCredential(credential);
      
      if (result.user != null) {
        // Check if this is a new user
        final isNewUser = result.additionalUserInfo?.isNewUser ?? false;
        
        if (isNewUser) {
          // Create user document for new users
          await _createUserDocument(result.user!, result.user!.displayName ?? 'Google User');
        } else {
          // Update existing user's last login
          await _updateUserProfile(result.user!);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
