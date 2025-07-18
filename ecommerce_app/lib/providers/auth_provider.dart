import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _accessToken;
  String? _refreshToken;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null && _accessToken != null;

  // Initialize auth state from SharedPreferences
  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');

      if (userJson != null && accessToken != null && refreshToken != null) {
        _user = User.fromJson(json.decode(userJson));
        _accessToken = accessToken;
        _refreshToken = refreshToken;
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize auth: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.login(email: email, password: password);
      
      _user = response.user;
      _accessToken = response.tokens.access;
      _refreshToken = response.tokens.refresh;

      // Save to SharedPreferences
      await _saveAuthData();
      
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

  // Register
  Future<bool> register({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String contactNumber,
    required String userType,
    required String password,
    required String passwordConfirm,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.register(
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        contactNumber: contactNumber,
        userType: userType,
        password: password,
        passwordConfirm: passwordConfirm,
      );
      
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

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_refreshToken != null) {
        await ApiService.logout(_refreshToken!);
      }
    } catch (e) {
      // Even if logout fails on server, we still clear local data
      print('Logout error: $e');
    } finally {
      await _clearAuthData();
      _user = null;
      _accessToken = null;
      _refreshToken = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save auth data to SharedPreferences
  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null) {
      await prefs.setString('user', json.encode(_user!.toJson()));
    }
    if (_accessToken != null) {
      await prefs.setString('access_token', _accessToken!);
    }
    if (_refreshToken != null) {
      await prefs.setString('refresh_token', _refreshToken!);
    }
  }

  // Clear auth data from SharedPreferences
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}