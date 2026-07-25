import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/firebase_service.dart';
import '../services/migration_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final UserRepository _userRepository = UserRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseService.currentUser != null;
  String? get uid => _firebaseService.currentUser?.uid;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    try {
      print("AUTH INIT START");

      _isLoading = true;
      notifyListeners();

      _currentUser = await _userRepository.getUserProfile();

      if (_firebaseService.currentUser != null) {
        await MigrationService().runCreatedAtBackfillIfNeeded(
          _firebaseService.currentUser!.uid,
        );
      }

      print("AUTH INIT DONE");

      _errorMessage = null;
    } catch (e) {
      print("AUTH INIT ERROR => $e");
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

 Future<void> signup(
  String name,
  String email,
  String password,
) async {
  try {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    print("STEP 1");

    await _firebaseService.signUpWithEmail(
      email: email,
      password: password,
      displayName: name,
    );

    print("STEP 2");

    await _userRepository.createUserProfile(
      email: email,
      name: name,
    );

    print("STEP 3");

    _currentUser = await _userRepository.getUserProfile();

    print("STEP 4");
  } catch (e) {
    print("SIGNUP ERROR => $e");
    _errorMessage = e.toString();
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<void> login(
    String email,
    String password,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print("LOGIN STEP 1");

      await _firebaseService.signInWithEmail(
        email: email,
        password: password,
      );

      print("LOGIN STEP 2");

      _currentUser = await _userRepository.getUserProfile();

      if (_firebaseService.currentUser != null) {
        await MigrationService().runCreatedAtBackfillIfNeeded(
          _firebaseService.currentUser!.uid,
        );
      }

      print("LOGIN STEP 3");
    } catch (e) {
      print("LOGIN ERROR => $e");
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final credential = await _firebaseService.signInWithGoogle();

      await _userRepository.createUserProfile(
        email: credential.user?.email ?? "",
        name: credential.user?.displayName ?? "User",
        photoUrl: credential.user?.photoURL,
      );

      _currentUser = await _userRepository.getUserProfile();

      if (_firebaseService.currentUser != null) {
        await MigrationService().runCreatedAtBackfillIfNeeded(
          _firebaseService.currentUser!.uid,
        );
      }
    } catch (e) {
      print("GOOGLE ERROR => $e");
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firebaseService.signOut();

      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      print("LOGOUT ERROR => $e");
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String name,
    String? photoUrl,
    String? birthDate,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _userRepository.updateUserProfile(
        name: name,
        photoUrl: photoUrl,
        birthDate: birthDate,
      );

      _currentUser = UserModel(
        email: _currentUser?.email ?? "",
        name: name,
        photoUrl: photoUrl,
        birthDate: birthDate,
      );
    } catch (e) {
      print("UPDATE PROFILE ERROR => $e");
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _userRepository.sendPasswordResetEmail(email);
    } catch (e) {
      print("RESET PASSWORD ERROR => $e");
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
