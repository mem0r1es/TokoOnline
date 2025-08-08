import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toko_online_getx/service/add_productservice.dart';
import '../../../data/services/supabase_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService.to;
  final Rxn<User> currentUser = Rxn<User>();
  
  // Form Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final shopNameController = TextEditingController();
  final phoneController = TextEditingController();
  final shopDescriptionController = TextEditingController();
  
  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isInitialized = false.obs;
  
  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  
  @override
  void onInit() {
    super.onInit();

    _supabaseService.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      currentUser.value = session?.user;
      if (event == AuthChangeEvent.signedIn) {
        _redirectBasedOnRole();
      } else if (event == AuthChangeEvent.signedOut) {
        Get.offAllNamed(AppRoutes.login);
      }
    });
    if(_supabaseService.isAuthenticated) {
      _redirectBasedOnRole();
    } 
  }
  
  @override
  void onClose() {
    // Dispose controllers
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    shopNameController.dispose();
    phoneController.dispose();
    shopDescriptionController.dispose();
    super.onClose();
  }
  
  // ============= AUTH METHODS =============
  
  // void _checkAuthStatus() {
  //   if (!isInitialized.value) return;
    
  //   if (_supabaseService.isAuthenticated) {
  //     // Redirect based on role
  //     _redirectBasedOnRole();
  //   }
  // }
  
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _supabaseService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      if (result['success']) {
        // Clear form
        _clearLoginForm();
        
        // Show success message
        Get.snackbar(
          'Success',
          'Login successful!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        // Redirect based on role (roles already loaded in login method)
        _redirectBasedOnRole();
      } else {
        errorMessage.value = result['message'];
        Get.snackbar(
          'Login Failed',
          result['message'],
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _supabaseService.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        shopName: shopNameController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        shopDescription: shopDescriptionController.text.trim().isEmpty 
            ? null 
            : shopDescriptionController.text.trim(),
      );
      
      if (result['success']) {
        // Clear form
        _clearRegisterForm();
        
        // Show success message
        Get.snackbar(
          'Registration successful',
          'Please check your email to verify your account before logging in.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        
        // Redirect to seller dashboard
        // Get.offAllNamed(AppRoutes.sellerDashboard);
        Get.offAllNamed(AppRoutes.login);
      } else {
        errorMessage.value = result['message'];
        Get.snackbar(
          'Registration Failed',
          result['message'],
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> logout() async {
    try {
      await _supabaseService.logout();
      
      // Clear all forms
      _clearLoginForm();
      _clearRegisterForm();
      
      // Navigate to login
      Get.offAllNamed(AppRoutes.login);
      
      Get.snackbar(
        'Success',
        'Logged out successfully',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
  
  // ============= NAVIGATION METHODS =============
  
  void _redirectBasedOnRole() {
    // Delay dialog to avoid build context issues
    Future.delayed(Duration.zero, () {
      if (_supabaseService.isAdmin) {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else if (_supabaseService.isSeller) {
        Get.offAllNamed(AppRoutes.sellerDashboard);
      } else {
        // Buyer only - show upgrade option
        Get.defaultDialog(
          title: 'Access Restricted',
          middleText: 'This platform is for sellers and admins only. Would you like to register as a seller?',
          textConfirm: 'Yes, Register',
          textCancel: 'No',
          onConfirm: () {
            Get.back();
            Get.toNamed(AppRoutes.register);
          },
          onCancel: () {
            Get.back();
            logout();
          },
        );
      }
    });
    // if (_supabaseService.isSeller) {
    //   Get.offAllNamed(AppRoutes.sellerDashboard);
    // } else {
    //   // Logika untuk buyer atau role lain
    //   Get.offAllNamed(AppRoutes.login); // Contoh: mengalihkan buyer ke login
    // }
  }
  
  void navigateToRegister() {
    _clearLoginForm();
    Get.toNamed(AppRoutes.register);
  }
  
  void navigateToLogin() {
    _clearRegisterForm();
    Get.toNamed(AppRoutes.login);
  }
  
  // ============= FORM VALIDATION =============
  
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
  
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
  
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      // Basic phone validation
      if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }
  
  // ============= HELPER METHODS =============
  
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
  
  void _clearLoginForm() {
    emailController.clear();
    passwordController.clear();
    errorMessage.value = '';
  }
  
  void _clearRegisterForm() {
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    shopNameController.clear();
    phoneController.clear();
    shopDescriptionController.clear();
    errorMessage.value = '';
  }
  
  // ============= GETTERS =============
  
  bool get isAuthenticated => _supabaseService.isAuthenticated;
  bool get isAdmin => _supabaseService.isAdmin;
  bool get isSeller => _supabaseService.isSeller;
  String? get userEmail => _supabaseService.userEmail;
  String? get userId => _supabaseService.userId;
}
