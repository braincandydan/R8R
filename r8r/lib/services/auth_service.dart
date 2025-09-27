import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // For web, you need to get the OAuth 2.0 client ID from Firebase Console > Authentication > Sign-in method > Google
    clientId: kIsWeb ? '943531801651-ar2rdfbgbulg9lqntdig6km9rhqbvj4v.apps.googleusercontent.com' : null,
  );
  
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
      debugPrint('Starting Google sign-in...');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint('User cancelled Google sign-in');
        return false;
      }

      debugPrint('Google user obtained: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      debugPrint('Google auth tokens obtained');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('Firebase credential created');

      // Sign in to Firebase with the Google credential
      final UserCredential result = await _auth.signInWithCredential(credential);
      
      if (result.user != null) {
        debugPrint('Firebase sign-in successful: ${result.user!.email}');
        
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
      debugPrint('Firebase sign-in failed: no user returned');
      return false;
    } catch (e, stackTrace) {
      debugPrint('Google sign-in error: $e');
      debugPrint('Stack trace: $stackTrace');
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
