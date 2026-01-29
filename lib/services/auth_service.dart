import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream for tracking authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is a guest (anonymous)
  bool get isGuest => _auth.currentUser?.isAnonymous ?? false;

  /// Wrapper to handle exceptions with consistent error handling
  Future<T> _wrap<T>(Future<T> Function() action, [String? context]) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (e) {
      debugPrint('${context ?? "Auth"} error: $e');
      rethrow;
    }
  }

  /// Registration with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) =>
      _wrap(() async {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await cred.user?.updateDisplayName(name);

        await _db.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'isPremium': false,
        }, SetOptions(merge: true));

        return cred;
      }, 'Sign up');

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _wrap(
        () => _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),
        'Sign in',
      );

  /// Anonymous sign-in (guest mode)
  Future<UserCredential?> signInAnonymously() => _wrap(() async {
        // Don't sign in again if already anonymous
        if (_auth.currentUser?.isAnonymous == true) {
          return null;
        }

        final cred = await _auth.signInAnonymously();

        // Create guest user document with merge to prevent overwriting
        await _db.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'isGuest': true,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return cred;
      }, 'Anonymous sign in');

  /// Convert guest to full user
  Future<UserCredential> convertGuestToUser({
    required String email,
    required String password,
    required String name,
  }) =>
      _wrap(() async {
        final user = _auth.currentUser;
        if (user == null || !user.isAnonymous) {
          throw Exception('No guest user to convert');
        }

        // Link anonymous account with email/password
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        final cred = await user.linkWithCredential(credential);

        await cred.user?.updateDisplayName(name);

        await _db.collection('users').doc(user.uid).update({
          'email': email,
          'name': name,
          'isGuest': false,
          'convertedAt': FieldValue.serverTimestamp(),
        });

        return cred;
      }, 'Convert guest');

  /// Sign out
  Future<void> signOut() => _wrap(() => _auth.signOut(), 'Sign out');

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) =>
      _wrap(() => _auth.sendPasswordResetEmail(email: email), 'Password reset');

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) =>
      _wrap(() async {
        final user = _auth.currentUser;
        if (user != null) {
          if (displayName != null) {
            await user.updateDisplayName(displayName);
          }
          if (photoURL != null) {
            await user.updatePhotoURL(photoURL);
          }
          await user.reload();
        }
      }, 'Update profile');

  /// Delete account
  Future<void> deleteAccount() => _wrap(() async {
        final user = _auth.currentUser;
        if (user != null) {
          await _db.collection('users').doc(user.uid).delete();
          await user.delete();
        }
      }, 'Delete account');

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) => _wrap(() async {
        final doc = await _db.collection('users').doc(uid).get();
        return doc.data();
      }, 'Get user data');

  /// Update user data in Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) =>
      _wrap(() => _db.collection('users').doc(uid).update(data), 'Update user data');

  /// Map Firebase Auth exceptions to user-friendly messages
  String _mapError(FirebaseAuthException e) => switch (e.code) {
        'weak-password' => 'Password is too weak. Use at least 6 characters.',
        'email-already-in-use' =>
          'This email is already used by another account.',
        'invalid-email' => 'Invalid email format.',
        'user-not-found' => 'User with this email not found.',
        'wrong-password' => 'Incorrect password.',
        'user-disabled' => 'This account has been disabled.',
        'too-many-requests' =>
          'Too many login attempts. Please try again later.',
        'operation-not-allowed' =>
          'Anonymous sign-in is not enabled in Firebase settings.',
        'network-request-failed' =>
          'Network error. Check your internet connection.',
        _ => e.message ?? 'An authentication error occurred.',
      };
}
