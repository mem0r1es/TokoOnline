import 'package:get/get.dart';
import '../../../data/services/supabase_service.dart';
import '../../auth/controllers/auth_controller.dart';

class SellerDashboardController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService.to;
  
  // Observable states
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString shopName = ''.obs;
  final RxInt totalProducts = 0.obs;
  final RxInt totalOrders = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxBool isLoading = false.obs;
  
  // Menu states
  final RxString selectedMenu = 'dashboard'.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadDashboardStats();
  }
  
  Future<void> loadUserData() async {
    try {
      final userId = _supabaseService.userId;
      if (userId == null) return;
      
      final profile = await _supabaseService.getProfile(userId);
      if (profile != null) {
        userName.value = profile['full_name'] ?? 'Seller';
        userEmail.value = profile['email'] ?? '';
        shopName.value = profile['shop_name'] ?? 'My Shop';
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
  
  Future<void> loadDashboardStats() async {
    try {
      isLoading.value = true;
      
      // Load products count
      final products = await _supabaseService.getProducts(
        sellerId: _supabaseService.userId,
      );
      totalProducts.value = products.length;
      
      // Load orders count and revenue
      final orders = await _supabaseService.getOrders(
        sellerId: _supabaseService.userId,
      );
      totalOrders.value = orders.length;
      
      // Calculate total revenue
      double revenue = 0;
      for (var order in orders) {
        revenue += (order['total_amount'] ?? 0).toDouble();
      }
      totalRevenue.value = revenue;
      
    } catch (e) {
      print('Error loading dashboard stats: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void changeMenu(String menu) {
    selectedMenu.value = menu;
  }
  
  Future<void> logout() async {
    try {
      // Show confirmation dialog
      final confirm = await Get.defaultDialog(
        title: 'Logout Confirmation',
        middleText: 'Are you sure you want to logout?',
        textConfirm: 'Yes, Logout',
        textCancel: 'Cancel',
        onConfirm: () => Get.back(result: true),
        onCancel: () => Get.back(result: false),
      );
      
      if (confirm == true) {
        // Call logout from AuthController
        final authController = Get.find<AuthController>();
        await authController.logout();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }
  
  void refreshDashboard() {
    loadUserData();
    loadDashboardStats();
  }
}