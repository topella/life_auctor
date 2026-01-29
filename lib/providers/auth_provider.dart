import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_auctor/services/auth_service.dart';
import 'package:life_auctor/utils/app_constants.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;
  static const String _guestKey = 'is_guest_mode';

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;
  bool _initialized = false;

  User? get user => _user;
  bool get isLoading => _isLoading || !_initialized;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  bool get isAuthenticated => _user != null || (_userData?['isGuest'] == true);
  bool get isGuest => _userData?['isGuest'] == true;

  AuthProvider(this._authService) {
    _init();
  }

  Future<void> _init() async {
    // checking if guest mode was saved
    final prefs = await SharedPreferences.getInstance();
    final isGuestSaved = prefs.getBool(_guestKey) ?? false;

    if (isGuestSaved) {
      _userData = {
        'uid': 'guest_local',
        'isGuest': true,
        'displayName': 'Guest User',
      };
      _initialized = true;
      notifyListeners();
    } else {
      _initialized = true;
    }

    // listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData();
      } else if (!isGuest) {
        _userData = null;
      }
      notifyListeners();
    });
  }

  // Generate guest user data
  Map<String, dynamic> _guestData(User user) => {
    'uid': user.uid,
    'name': 'Guest',
    'email': 'No email',
    'isGuest': true,
    'isPremium': false,
  };

  // Generate registered user fallback data
  Map<String, dynamic> _registeredUserData(User user) => {
    'uid': user.uid,
    'name': user.displayName ?? 'User',
    'email': user.email ?? 'No email',
    'isGuest': false,
    'isPremium': false,
  };

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    if (_user == null) {
      _userData = null;
    } else if (_user!.isAnonymous) {
      //for guests local data
      _userData = _guestData(_user!);
    } else {
      //for registered users load from Firestore
      try {
        final data = await _authService.getUserData(_user!.uid);
        _userData = data ?? _registeredUserData(_user!);
      } catch (e) {
        debugPrint('Error loading user data: $e');
        _userData = _registeredUserData(_user!);
      }
    }

    notifyListeners();
  }

  // method to execute auth operations
  Future<bool> _exec(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) => _exec(
    () => _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
    ),
  );

  // sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) => _exec(
    () => _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    ),
  );

  // Sign in as guest
  Future<bool> signInAsGuest() => _exec(() async {
    // Set a fake local user for guest mode
    _user = null; // no Firebase user
    _userData = {
      'uid': 'guest_local',
      'isGuest': true,
      'displayName': 'Guest User',
    };
    // Save guest mode to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestKey, true);
    // Reset guest banner visibility so it shows again
    await prefs.setBool(AppConstants.prefKeyGuestBannerVisible, true);
  });

  // Sign out
  Future<void> signOut() async {
    await _exec(() async {
      await _authService.signOut();
      _user = null;
      _userData = null;
      // Clear guest mode from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestKey, false);
    });
  }

  // Reset password
  Future<bool> resetPassword(String email) =>
      _exec(() => _authService.sendPasswordResetEmail(email));

  // Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) => _exec(
    () => _authService.updateUserProfile(
      displayName: displayName,
      photoURL: photoURL,
    ),
  );

  // Delete account
  Future<bool> deleteAccount() => _exec(() async {
    await _authService.deleteAccount();
    _user = null;
    _userData = null;
  });

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
