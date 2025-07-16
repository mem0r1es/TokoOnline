import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  User? _user;
  bool _isLoading = false;
  String? _error;
  String _authMethod = 'none'; // 'regular', 'google', 'none'

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get authMethod => _authMethod;

  // Check if user is logged in saat app start
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAuthenticated = await AuthService.isLoggedIn();
      _authMethod = await AuthService.getAuthMethod();

      if (_isAuthenticated) {
        _user = await AuthService.getProfile();
        if (_user == null) {
          _isAuthenticated = false;
          _authMethod = 'none';
        }
      }
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      _authMethod = 'none';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Initialize Google Sign In
  Future<void> initializeGoogleSignIn() async {
    try {
      await AuthService.initializeGoogleSignIn();
    } catch (e) {
      print('Google Sign In initialization error: $e');
    }
  }

  // Regular login function
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.login(
        email: email,
        password: password,
      );

      if (result != null && result['success'] == true) {
        _isAuthenticated = true;
        _user = User.fromJson(result['user']);
        _authMethod = 'regular';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result?['message'] ?? 'Login gagal';
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

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.signInWithGoogle();

      if (result != null && result['success'] == true) {
        _isAuthenticated = true;
        _user = User.fromJson(result['user']);
        _authMethod = 'google';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result?['message'] ?? 'Google Sign In failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Google Sign In error: $e';
      _isLoading = false;
      notifyListeners();
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
        _authMethod = 'regular';
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

  // Enhanced logout function
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService
          .logout(); // This now handles both regular and Google logout
    } catch (e) {
      print('Logout error: $e');
    }

    _isAuthenticated = false;
    _user = null;
    _error = null;
    _authMethod = 'none';
    _isLoading = false;
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

  // Check if user is signed in with Google
  Future<bool> isSignedInWithGoogle() async {
    return await AuthService.isSignedInWithGoogle();
  }

  // Get current Google user info
  Future<void> getCurrentGoogleUser() async {
    try {
      final googleUser = await AuthService.getCurrentGoogleUser();
      if (googleUser != null) {
        print('Current Google user: ${googleUser.email}');
      }
    } catch (e) {
      print('Error getting current Google user: $e');
    }
  }
}
