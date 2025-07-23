import 'package:flutter_web/controllers/favorite_controller.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.put(AuthService());

  var isLoggedIn = false.obs;
  var currentUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    _checkInitialSession();
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session != null) {
        isLoggedIn.value = true;
        currentUser.value = session.user;
      } else {
        isLoggedIn.value = false;
        currentUser.value = null;
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

  Future<void> register(String email, String password, String fullName) async {
    try {
      final response = await _authService.signUp(email, password, fullName);
      if (response?.user != null) {
        Get.snackbar('Success', 'Check your email for verification', backgroundColor: Get.theme.primaryColor);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Get.theme.colorScheme.error);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _authService.signIn(email, password);
      if (response?.user != null) {
        Get.snackbar('Success', 'Welcome ${response!.user!.email}', backgroundColor: Get.theme.primaryColor);
        
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Get.theme.colorScheme.error);
    }
    
  }

  Future<void> loginWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Get.theme.colorScheme.error);
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    Get.snackbar('Success', 'Logged out', backgroundColor: Get.theme.primaryColor);
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      Get.snackbar('Success', 'Reset email sent');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  String? get userEmail => currentUser.value?.email;
  String? get userName => currentUser.value?.userMetadata?['full_name'] ?? currentUser.value?.email?.split('@')[0];
    // Get user profile
  String? getUserEmail() {
    return currentUser.value?.email;
  }

  String? getUserName(){
    return currentUser.value?.userMetadata?['full_name'] ?? currentUser.value?.email?.split('@')[0];
  }
  bool get isAuthenticated => isLoggedIn.value;
}
