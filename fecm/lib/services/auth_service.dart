import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  // Ganti dengan IP komputer lo kalo test di device fisik
  static const String baseUrl = 'http://localhost:8000/api/auth';
  static const storage = FlutterSecureStorage();

  // Register user baru
  static Future<Map<String, dynamic>?> register({
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      print('Registering user: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/register/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'password': password,
          'password_confirm': passwordConfirm,
        }),
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        // Save tokens
        await storage.write(
            key: 'access_token', value: data['tokens']['access']);
        await storage.write(
            key: 'refresh_token', value: data['tokens']['refresh']);
        return data;
      } else {
        return data;
      }
    } catch (e) {
      print('Register error: $e');
      return {
        'success': false,
        'message':
            'Network error: Pastikan Django server jalan di localhost:8000'
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Logging in user: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save tokens
        await storage.write(
            key: 'access_token', value: data['tokens']['access']);
        await storage.write(
            key: 'refresh_token', value: data['tokens']['refresh']);
        return data;
      } else {
        return data;
      }
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message':
            'Network error: Pastikan Django server jalan di localhost:8000'
      };
    }
  }

  // Get user profile
  static Future<User?> getProfile() async {
    final token = await storage.read(key: 'access_token');

    if (token == null) {
      print('No access token found');
      return null;
    }

    try {
      print('Getting profile with token');

      final response = await http.get(
        Uri.parse('$baseUrl/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Profile response status: ${response.statusCode}');
      print('Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return User.fromJson(data['user']);
        }
      } else if (response.statusCode == 401) {
        // Token expired, clear storage
        await storage.deleteAll();
      }
    } catch (e) {
      print('Get profile error: $e');
    }

    return null;
  }

  // Logout user
  static Future<void> logout() async {
    final accessToken = await storage.read(key: 'access_token');
    final refreshToken = await storage.read(key: 'refresh_token');

    if (accessToken != null && refreshToken != null) {
      try {
        print('Logging out user');

        final response = await http.post(
          Uri.parse('$baseUrl/logout/'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'refresh': refreshToken,
          }),
        );

        print('Logout response status: ${response.statusCode}');
        print('Logout response body: ${response.body}');
      } catch (e) {
        print('Logout error: $e');
      }
    }

    // Always clear local storage
    await storage.deleteAll();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'access_token');
    return token != null;
  }

  // Refresh access token
  static Future<String?> refreshToken() async {
    final refreshToken = await storage.read(key: 'refresh_token');

    if (refreshToken == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/refresh/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'refresh': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final newAccessToken = data['access'];
          await storage.write(key: 'access_token', value: newAccessToken);
          return newAccessToken;
        }
      }
    } catch (e) {
      print('Refresh token error: $e');
    }

    return null;
  }
}
