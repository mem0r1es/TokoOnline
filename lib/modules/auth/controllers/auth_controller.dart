import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  var isLoading = false.obs;

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
    required String contactNumber,
    required String storeName,
  }) async {
    try {
      isLoading.value = true;

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': 'seller',
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'contact_number': contactNumber,
          'store_name': storeName,
        },
      );

      final user = response.user;
      if (user != null) {
        await supabase.from('users').insert({
        'id': user.id, // foreign key ke auth.users
        'email': email,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'contact_number': contactNumber,
        'store_name': storeName,
        'user_type': 'seller', // default
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      
        Get.snackbar("Success", "Registration successful");
      } else {
        Get.snackbar("Error", "User registration failed");
      }
    } on AuthException catch (e) {
      Get.snackbar("Auth Error", e.message);
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      isLoading.value = true;

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        Get.snackbar("Success", "Login berhasil!");
        final data = await Supabase.instance.client
          .from('users')
          .select('user_type')
          .eq('id', response.user!.id)
          .single();

      final userType = data['user_type'];

      // Arahkan ke dashboard sesuai role
      if (userType == 'seller') {
        Get.offAllNamed('/seller-dashboard');
      } else {
        Get.offAllNamed('/admin-dashboard');
      }
        // Tambahkan redirect atau logika lain sesuai kebutuhan
      } else {
        Get.snackbar("Login Gagal", "Email atau password salah");
      }
    } on AuthException catch (e) {
      Get.snackbar("Auth Error", e.message);
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan saat login");
    } finally {
      isLoading.value = false;
    }
  }
}
