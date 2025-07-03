import 'package:flutter/material.dart'; // TAMBAH INI
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends GetxController {
  final supabase = Supabase.instance.client;

  // Observable untuk status login
  var isLoggedIn = false.obs;
  var currentUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    // Check initial auth state
    _checkAuthState();

    // Listen to auth changes
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        isLoggedIn.value = true;
        currentUser.value = session.user;
        print('User logged in: ${session.user.email}');
      } else {
        isLoggedIn.value = false;
        currentUser.value = null;
        print('User logged out');
      }
    });
  }

  void _checkAuthState() {
    final session = supabase.auth.currentSession;
    if (session != null) {
      isLoggedIn.value = true;
      currentUser.value = session.user;
      print('Existing session found: ${session.user.email}');
    } else {
      print('No existing session');
    }
  }

  // Register dengan email
  Future<bool> register(String email, String password, String fullName) async {
    try {
      print('Attempting to register: $email');

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        print('Registration successful: ${response.user!.email}');
        Get.snackbar(
          'Success',
          'Akun berhasil dibuat! Silakan cek email untuk verifikasi.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        print('Registration failed: No user returned');
        Get.snackbar(
          'Error',
          'Gagal membuat akun. Silakan coba lagi.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('Registration error: $e');
      Get.snackbar(
        'Error',
        'Gagal membuat akun: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Login dengan email
  Future<bool> login(String email, String password) async {
    try {
      print('Attempting to login: $email');

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('Login successful: ${response.user!.email}');
        Get.snackbar(
          'Success',
          'Login berhasil! Selamat datang ${response.user!.email}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        print('Login failed: No user returned');
        Get.snackbar(
          'Error',
          'Login gagal. Periksa email dan password Anda.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      String errorMessage = 'Login gagal: ';

      if (e.toString().contains('Invalid login credentials')) {
        errorMessage += 'Email atau password salah';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage += 'Silakan verifikasi email Anda terlebih dahulu';
      } else {
        errorMessage += e.toString();
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    try {
      print('Attempting Google Sign-In...');

      final response = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://localhost:3000',
        authScreenLaunchMode: LaunchMode.platformDefault,
      );

      if (response) {
        print('Google OAuth initiated successfully');
        Get.snackbar(
          'Info',
          'Mengarahkan ke Google untuk login...',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return true;
      } else {
        print('Google OAuth failed to initiate');
        Get.snackbar(
          'Error',
          'Gagal memulai login Google',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('Google Sign-In error: $e');
      Get.snackbar(
        'Error',
        'Login Google gagal: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      print('Attempting to logout...');

      await supabase.auth.signOut();

      print('Logout successful');
      Get.snackbar(
        'Success',
        'Logout berhasil! Sampai jumpa lagi.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Logout error: $e');
      Get.snackbar(
        'Error',
        'Logout gagal: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      print('Attempting password reset for: $email');

      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'http://localhost:3000/reset-password',
      );

      print('Password reset email sent');
      Get.snackbar(
        'Success',
        'Link reset password telah dikirim ke email Anda!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print('Password reset error: $e');
      Get.snackbar(
        'Error',
        'Gagal reset password: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Get user profile
  String? getUserEmail() {
    return currentUser.value?.email;
  }

  String? getUserName() {
    return currentUser.value?.userMetadata?['full_name'] ??
        currentUser.value?.email?.split('@')[0];
  }

  String? getUserId() {
    return currentUser.value?.id;
  }

  // Check if user is authenticated
  bool get isAuthenticated => isLoggedIn.value && currentUser.value != null;

  // Refresh session
  Future<void> refreshSession() async {
    try {
      print('Refreshing session...');
      await supabase.auth.refreshSession();
      print('Session refreshed successfully');
    } catch (e) {
      print('Session refresh error: $e');
    }
  }
}
