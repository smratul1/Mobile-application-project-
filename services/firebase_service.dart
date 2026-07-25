import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() => _instance;

  FirebaseService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  GoogleSignIn? _googleSignIn;

  // =========================
  // CURRENT USER
  // =========================

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  // =========================
  // EMAIL SIGN UP
  // =========================

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(displayName);

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // =========================
  // EMAIL LOGIN
  // =========================

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // =========================
  // GOOGLE LOGIN
  // =========================

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      throw Exception(
        'Google Sign-In for Web is not configured yet.',
      );
    }

    try {
      _googleSignIn ??= GoogleSignIn();

      final GoogleSignInAccount? googleUser =
          await _googleSignIn!.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign In Cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(
        credential,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // =========================
  // SIGN OUT
  // =========================

  Future<void> signOut() async {
    try {
      await _googleSignIn?.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // =========================
  // UPDATE PROFILE
  // =========================

  Future<void> updateUserProfile({
    required String displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user != null) {
        await user.updateDisplayName(displayName);

        if (photoUrl != null && photoUrl.isNotEmpty) {
          await user.updatePhotoURL(photoUrl);
        }

        await user.reload();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // =========================
  // PASSWORD RESET
  // =========================

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // =========================
  // VERIFY EMAIL
  // =========================

  Future<void> verifyEmail() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // =========================
  // DELETE ACCOUNT
  // =========================

  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user != null) {
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // =========================
  // HANDLE ERRORS
  // =========================

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak.';

      case 'email-already-in-use':
        return 'Email is already in use.';

      case 'invalid-email':
        return 'Invalid email address.';

      case 'user-not-found':
        return 'User not found.';

      case 'wrong-password':
        return 'Incorrect password.';

      case 'invalid-credential':
        return 'Invalid email or password.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many requests. Please try again later.';

      case 'operation-not-allowed':
        return 'This sign in method is not enabled.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
