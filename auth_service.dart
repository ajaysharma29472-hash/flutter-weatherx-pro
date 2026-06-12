import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(AppConstants.userKey);
    if (json == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isEmpty || password.isEmpty) {
      throw AuthException('Email and password are required');
    }
    if (!email.contains('@')) {
      throw AuthException('Please enter a valid email address');
    }
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: email.split('@').first,
      email: email,
      createdAt: DateTime.now(),
    );

    await _saveUser(user);
    return user;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw AuthException('All fields are required');
    }
    if (!email.contains('@')) {
      throw AuthException('Please enter a valid email address');
    }
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );

    await _saveUser(user);
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userKey);
  }

  Future<UserModel> updateProfile({
    required UserModel user,
    String? name,
    String? email,
  }) async {
    final updated = user.copyWith(name: name, email: email);
    await _saveUser(updated);
    return updated;
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
