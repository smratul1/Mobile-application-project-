import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentEmail = prefs.getString('@current_email');
      if (currentEmail != null) {
        final usersMapStr = prefs.getString('@users_map');
        if (usersMapStr != null) {
          final map = jsonDecode(usersMapStr) as Map<String, dynamic>;
          final userData = map[currentEmail.toLowerCase()];
          if (userData != null) {
            _currentUser = UserModel.fromMap(userData as Map<String, dynamic>);
          }
        }
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersMapStr = prefs.getString('@users_map');
    if (usersMapStr == null) throw Exception('no_account');

    final map = jsonDecode(usersMapStr) as Map<String, dynamic>;
    final userData = map[email.toLowerCase()];
    if (userData == null) throw Exception('no_account');

    final user = UserModel.fromMap(userData as Map<String, dynamic>);
    if (user.password != password) throw Exception('wrong_password');

    await prefs.setString('@current_email', email.toLowerCase());
    _currentUser = user;
    notifyListeners();
  }

  Future<void> signup(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersMapStr = prefs.getString('@users_map');
    final map = usersMapStr != null
        ? jsonDecode(usersMapStr) as Map<String, dynamic>
        : <String, dynamic>{};

    if (map.containsKey(email.toLowerCase())) {
      throw Exception('already_exists');
    }

    final newUser = UserModel(
        email: email.toLowerCase(), name: name, password: password);
    map[email.toLowerCase()] = newUser.toMap();

    await prefs.setString('@users_map', jsonEncode(map));
    await prefs.setString('@current_email', email.toLowerCase());
    _currentUser = newUser;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('@current_email');
    _currentUser = null;
    notifyListeners();
  }
}
