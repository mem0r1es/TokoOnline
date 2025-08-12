// File: controllers/auth_controller.dart
import 'package:flutter_web/models/profile_model.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.put(AuthService());

  var isLoggedIn = false.obs;
  var currentUser = Rxn<User>();
  final Rxn<ProfilModel> userProfile = Rxn<ProfilModel>();

  @override
  void onInit() {
    super.onInit();
    _checkInitialSession();
    Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      final user = session?.user;

      isLoggedIn.value = user != null;
      currentUser.value = user;

      if (user != null) {
        await _ensureUserProfileExists(); // ← Buat profil jika belum ada
        await fetchUserProfile();         // ← Ambil data terbaru
      } else {
        userProfile.value = null;
      }
    });
  }

  void _checkInitialSession() {
    final session = _authService.currentSession;
    if (session != null) {
      isLoggedIn.value = true;
      currentUser.value = session.user;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
  try {
    final currentEmail = Supabase.instance.client.auth.currentUser?.email;
    if (currentEmail == null) throw Exception("User tidak ditemukan");

    // Login ulang untuk verifikasi password lama
    final session = await Supabase.instance.client.auth.signInWithPassword(
      email: currentEmail,
      password: oldPassword,
    );

    if (session.user == null) throw Exception("Password lama salah");

    // Ganti password
    await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    Get.snackbar("Berhasil", "Password berhasil diubah");
  } catch (e) {
    _showError(e);
  }
}


  Future<void> register(String email, String password, String fullName) async {
    try {
      final response = await _authService.signUp(email, password, fullName);
      if (response?.user != null) {
        Get.snackbar('Success', 'Check your email for verification', backgroundColor: Get.theme.primaryColor);
        await _ensureUserProfileExists();
        await fetchUserProfile();
      }
    } catch (e) {
      _showError(e);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _authService.signIn(email, password);
      final user = response?.user;
      if (user != null) {
        Get.snackbar('Success', 'Welcome ${user.email}', backgroundColor: Get.theme.primaryColor);
        isLoggedIn.value = true;
        currentUser.value = user;
        await _ensureUserProfileExists();
        await fetchUserProfile();
        Get.back(); // ← Kembali ke halaman sebelumnya
      }
      return false; // ← Login gagal
    } catch (e) {
      _showError(e);
      return false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
      await _ensureUserProfileExists();
      await fetchUserProfile();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    isLoggedIn.value = false;
    currentUser.value = null;
    userProfile.value = null;
    Get.snackbar('Success', 'Logged out', backgroundColor: Get.theme.primaryColor);
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      Get.snackbar('Success', 'Reset email sent');
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> updateName(String newName) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("User tidak ditemukan");

      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': newName}),
      );

      currentUser.value = response.user;

      // Update juga ke tabel profiles
      await Supabase.instance.client
          .from('profiles')
          .update({'full_name': newName})
          .eq('id', user.id);

      await fetchUserProfile();

      Get.snackbar('Berhasil', 'Nama berhasil diperbarui');
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("User tidak ditemukan");

      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(email: newEmail),
      );

      currentUser.value = response.user;

      await Supabase.instance.client
          .from('profiles')
          .update({'email': newEmail})
          .eq('id', user.id);

      await fetchUserProfile();

      Get.snackbar('Berhasil', 'Email berhasil diperbarui. Verifikasi mungkin diperlukan.');
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> updatePassword(String newPassword) async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception("User tidak ditemukan");

    await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    Get.snackbar('Berhasil', 'Kata sandi berhasil diperbarui');
  } catch (e) {
    _showError(e);
  }
}


Future<void> updatePhone(String newPhone) async {
  try {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception("User tidak ditemukan");

    await Supabase.instance.client
        .from('profiles')
        .update({'phone': newPhone}) // pastikan field ini 'phone'
        .eq('id', userId);

    await fetchUserProfile();
    print('Nomor HP berhasil diupdate ke Supabase: $newPhone');
    Get.snackbar('Berhasil', 'Nomor HP berhasil diperbarui');
  } catch (e) {
    _showError(e);
  }
}

  Future<void> fetchUserProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception("User tidak ditemukan");

      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        userProfile.value = ProfilModel.fromMap(data);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data profil');
    }
  }

  Future<void> _ensureUserProfileExists() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final exists = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (exists == null) {
        final fullName = user.userMetadata?['full_name'] ?? '';
        final email = user.email ?? '';

        await Supabase.instance.client.from('profiles').insert({
          'id': user.id,
          'email': email,
          'full_name': fullName,
          'phone': null,
        });

        print('Profil baru dibuat untuk user ${user.id}');
      }
    } catch (e) {
      print('Gagal memastikan data profil: $e');
    }
  }

  // Getter
  String? get userEmail => currentUser.value?.email;
  String? get userName =>
      currentUser.value?.userMetadata?['full_name'] ??
      currentUser.value?.email?.split('@')[0];
  String? getUserEmail() => userEmail;
  String? getUserName() => userName;
  bool get isAuthenticated => isLoggedIn.value;

  void _showError(Object e) {
    Get.snackbar('Error', e.toString(), backgroundColor: Get.theme.colorScheme.error);
  }
}
