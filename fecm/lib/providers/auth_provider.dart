import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  User? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Check if user is logged in saat app start
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAuthenticated = await AuthService.isLoggedIn();

      if (_isAuthenticated) {
        _user = await AuthService.getProfile();
        if (_user == null) {
          _isAuthenticated = false;
        }
      }
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login function
  Future<bool> login(String email, String password) async {
    print('🔄 AuthProvider.login called'); // Debug print

    _isLoading = true;
    _error = null;
    notifyListeners();

    print('⏳ Loading state set to true'); // Debug print

    try {
      final result = await AuthService.login(
        email: email,
        password: password,
      );

      print('📥 AuthService result: $result'); // Debug print

      if (result != null && result['success'] == true) {
        _isAuthenticated = true;
        _user = User.fromJson(result['user']);
        _isLoading = false;
        notifyListeners();
        print('✅ Auth state updated successfully'); // Debug print
        return true;
      } else {
        _error = result?['message'] ?? 'Login gagal';
        _isLoading = false;
        notifyListeners();
        print('❌ Login failed with error: $_error'); // Debug print
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      print('💥 Exception in login: $e'); // Debug print
      return false;
    }
  }

  // Register function
  Future<bool> register({
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    required String password,
    required String passwordConfirm,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.register(
        email: email,
        username: username,
        firstName: firstName,
        lastName: lastName,
        password: password,
        passwordConfirm: passwordConfirm,
      );

      if (result != null && result['success'] == true) {
        _isAuthenticated = true;
        _user = User.fromJson(result['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Handle validation errors
        if (result?['errors'] != null) {
          final errors = result!['errors'] as Map<String, dynamic>;
          final errorMessages = <String>[];

          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.map((e) => e.toString()));
            } else {
              errorMessages.add(value.toString());
            }
          });

          _error = errorMessages.join(', ');
        } else {
          _error = result?['message'] ?? 'Registrasi gagal';
        }

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout function
  Future<void> logout() async {
    try {
      await AuthService.logout();
    } catch (e) {
      print('Logout error: $e');
    }

    _isAuthenticated = false;
    _user = null;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh user profile
  Future<void> refreshProfile() async {
    if (_isAuthenticated) {
      try {
        final updatedUser = await AuthService.getProfile();
        if (updatedUser != null) {
          _user = updatedUser;
          notifyListeners();
        }
      } catch (e) {
        print('Refresh profile error: $e');
      }
    }
  }
}
