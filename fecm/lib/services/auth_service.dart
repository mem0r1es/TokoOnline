import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  // Ganti dengan IP komputer lo kalo test di device fisik
  static const String baseUrl = 'http://localhost:8000/api/auth';
  static const storage = FlutterSecureStorage();

  // Google Sign In configuration - FIXED untuk Web
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '804408446728-l0v3hbai7qgpqflh06vitfosnlmmpne7.apps.googleusercontent.com', // Ganti dengan client ID lo
    scopes: ['email', 'profile', 'openid'],
    // serverClientId TIDAK DIPERLUKAN untuk Web - hanya untuk Android/iOS
  );

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

  // Google Sign In - FIXED untuk Web
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('🔄 Starting Google Sign In for Web...');
      print('📋 Client ID: ${_googleSignIn.clientId}');
      print('📋 Scopes: ${_googleSignIn.scopes}');

      // Clear any existing sign in untuk fresh start
      await _googleSignIn.signOut();
      print('🔄 Cleared existing Google session');

      // Trigger Google Sign In
      print('🔄 Calling _googleSignIn.signIn()...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ Google Sign In cancelled by user');
        return {'success': false, 'message': 'Google Sign In cancelled'};
      }

      print('✅ Google user found: ${googleUser.email}');
      print('👤 Display name: ${googleUser.displayName}');
      print('🔗 Photo URL: ${googleUser.photoUrl}');
      print('🆔 ID: ${googleUser.id}');

      // Get Google Auth details
      print('🔄 Getting authentication details...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print(
          '🔑 Access token: ${googleAuth.accessToken != null ? "Present (${googleAuth.accessToken!.length} chars)" : "Missing"}');
      print(
          '🔑 ID token: ${googleAuth.idToken != null ? "Present (${googleAuth.idToken!.length} chars)" : "Missing"}');

      // For Web, sometimes idToken might be null, use accessToken as fallback
      String? tokenToSend = googleAuth.idToken ?? googleAuth.accessToken;

      if (tokenToSend == null) {
        print('❌ Both ID token and Access token are null');
        return {
          'success': false,
          'message': 'Google authentication failed - no token received'
        };
      }

      print(
          '✅ Using token: ${googleAuth.idToken != null ? "ID Token" : "Access Token"}');

      // Send Google token to Django backend
      return await _sendGoogleTokenToBackend(
        googleToken: tokenToSend,
        email: googleUser.email,
        name: googleUser.displayName ?? '',
        photoUrl: googleUser.photoUrl,
        tokenType: googleAuth.idToken != null ? 'id_token' : 'access_token',
      );
    } catch (e) {
      print('❌ Google Sign In error: $e');
      print('❌ Error type: ${e.runtimeType}');
      return {
        'success': false,
        'message': 'Google Sign In failed: ${e.toString()}'
      };
    }
  }

  // Send Google token to Django backend
  static Future<Map<String, dynamic>?> _sendGoogleTokenToBackend({
    required String googleToken,
    required String email,
    required String name,
    String? photoUrl,
    String tokenType = 'id_token',
  }) async {
    try {
      print('🔄 Sending Google token to backend...');
      print('📤 Token type: $tokenType');
      print('📤 Token length: ${googleToken.length}');
      print('📤 Email: $email');
      print('📤 Name: $name');
      print('📤 Photo URL: $photoUrl');

      final response = await http.post(
        Uri.parse('$baseUrl/google-login/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'google_token': googleToken,
          'email': email,
          'name': name,
          'photo_url': photoUrl,
          'token_type': tokenType,
        }),
      );

      print('📥 Backend response status: ${response.statusCode}');
      print('📥 Backend response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save JWT tokens like normal login
        await storage.write(
            key: 'access_token', value: data['tokens']['access']);
        await storage.write(
            key: 'refresh_token', value: data['tokens']['refresh']);
        return data;
      } else {
        return data;
      }
    } catch (e) {
      print('❌ Backend communication error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Google Sign Out
  static Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      print('✅ Google Sign Out successful');
    } catch (e) {
      print('❌ Google Sign Out error: $e');
    }
  }

  // Check if user is signed in with Google
  static Future<bool> isSignedInWithGoogle() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      print('❌ Error checking Google sign in status: $e');
      return false;
    }
  }

  // Get current Google user
  static Future<GoogleSignInAccount?> getCurrentGoogleUser() async {
    try {
      return _googleSignIn.currentUser;
    } catch (e) {
      print('❌ Error getting current Google user: $e');
      return null;
    }
  }

  // Initialize Google Sign In (call this in app startup)
  static Future<void> initializeGoogleSignIn() async {
    try {
      print('🔄 Initializing Google Sign In for Web...');
      final result = await _googleSignIn.signInSilently();
      if (result != null) {
        print('✅ Google Sign In silently successful for: ${result.email}');
      } else {
        print('ℹ️ No existing Google session found');
      }
    } catch (e) {
      print('❌ Google Sign In silent initialization failed: $e');
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

    // Also sign out from Google
    await signOutGoogle();

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

  // Helper method to get auth method used (regular or Google)
  static Future<String> getAuthMethod() async {
    final isGoogleSignedIn = await isSignedInWithGoogle();
    final isRegularSignedIn = await isLoggedIn();

    if (isGoogleSignedIn) {
      return 'google';
    } else if (isRegularSignedIn) {
      return 'regular';
    } else {
      return 'none';
    }
  }
}
