import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends GetxService {
  final supabase = Supabase.instance.client;

  final Rxn<User> currentUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    refreshUser(); // Panggil sekali saat service dimuat
  }

  void refreshUser() {
    final user = supabase.auth.currentUser;
    currentUser.value = user;
  }

  Future<AuthResponse?> signUp(String email, String password, String fullName) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': 'buyer'},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(email: email, password: password);
      return response;
    } catch (e) {
      rethrow;
    }
  }

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

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'http://localhost:3000/reset-password',
    );
  }

  Future<bool> register(String email, String password, String fullName) async {
    try {
      print('Attempting to register: $email');

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': 'buyer',
        },
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

  Future<bool> login(String email, String password) async {
    try {
      print('Attempting to login: $email');

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      await Future.delayed(Duration(milliseconds: 1000));
      refreshUser(); // Update current user state

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

  Session? get currentSession => supabase.auth.currentSession;
}
