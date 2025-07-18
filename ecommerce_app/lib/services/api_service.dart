import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };
  
  static Map<String, String> headersWithAuth(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Register user (seller only)
  static Future<RegisterResponse> register({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String contactNumber,
    required String password,
    required String passwordConfirm,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: headers,
      body: json.encode({
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'contact_number': contactNumber,
        'password': password,
        'password_confirm': passwordConfirm,
        // user_type will be automatically set to 'seller' in backend
      }),
    );

    if (response.statusCode == 201) {
      return RegisterResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // Login user
  static Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: headers,
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Get user profile
  static Future<User> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile/'),
      headers: headersWithAuth(token),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get profile: ${response.body}');
    }
  }

  // Logout user
  static Future<void> logout(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout/'),
      headers: headers,
      body: json.encode({
        'refresh_token': refreshToken,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to logout: ${response.body}');
    }
  }
}