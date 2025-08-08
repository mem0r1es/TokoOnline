import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    print('✅ SellerDashboardController initialized.');

    // Pasang listener untuk currentUser.
    // fetchSellerProfile() hanya akan dijalankan saat currentUser berubah dari null ke non-null
    ever(_supabaseService.currentUser, (User? user) {
      if (user != null) {
        print('✅ User state changed to non-null. Fetching profile...');
        initializeDashboardData();
      } else {
        // User logout, reset state
        userName.value = '';
        shopName.value = '';
      }
    });

    // Panggil fetch awal jika user sudah ada (untuk kasus hot-reload)
    if (_supabaseService.currentUser.value != null) {
      initializeDashboardData();
    }
  }

  Future<void> initializeDashboardData() async {
    try {
      isLoading.value = true;
      print('🚀 Fetching all dashboard data...');
      
      // Panggil kedua metode fetch secara paralel untuk efisiensi
      await Future.wait([
        fetchSellerProfile(),
        loadDashboardStats(),
      ]);

    } catch (e) {
      print('❌ Error initializing dashboard data: $e');
    } finally {
      isLoading.value = false;
      print('⏳ Dashboard data fetching complete.');
    }
  }
  

  Future<void> fetchSellerProfile() async {
    try {
      isLoading.value = true;
      print('🚀 Fetching seller profile data...');
      final profileData = await _supabaseService.getProfileData();
      
      if (profileData != null) {
        userName.value = profileData['full_name'] ?? 'Seller';
        shopName.value = profileData['store_name'] ?? 'Toko Saya';
        print('✅ Profile data loaded. User: ${userName.value}, Shop: ${shopName.value}');
      } else {
        print('❌ Gagal memuat profil penjual. Data tidak ditemukan.');
      }
    } catch (e) {
      print('Error fetching seller profile: $e');
    } finally {
      isLoading.value = false;
      print('⏳ Loading state set to false.');
    }
  }
  
  Future<void> loadDashboardStats() async {
    try {
      isLoading.value = true;
      print('🚀 Fetching seller products length');
      final userId = _supabaseService.userId;
      if (userId == null) {
        print('❌ User belum login, tidak bisa memuat statistik dashboard');
        return;
      }
      // Load products count
      final products = await _supabaseService.getProducts(
        sellerId: userId,
      );
      print('📦 Total produk milik seller $userId: ${products.length}');
      for (var p in products) {
        print('➡️ ${p['name']} - seller_id: ${p['seller_id']}');
      }
      totalProducts.value = products.length;
      
      // Load orders count and revenue
      final orders = await _supabaseService.getOrders(
        sellerId: userId,
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
    fetchSellerProfile();
    loadDashboardStats();
  }
}