// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toko_online_getx/models/add_productmodel.dart';
import 'package:toko_online_getx/modules/seller/views/dashboard_view.dart';
import 'package:toko_online_getx/pages/product_view.dart';
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
  var products = <AddProductmodel>[].obs;
  
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
    if (_supabaseService.currentUser.value != null) {
    print('✅ Found existing session, initializing dashboard data...');
    initializeDashboardData();
  }
  }

  Future<void> updateProductStatus(String productId, bool isActive) async {
    try {
      isLoading.value = true;
      print('🚀 Updating product status for ID: $productId to $isActive');
      
      // Panggil service untuk update ke database
      final success = await _supabaseService.updateProductStatus(productId, isActive);
      
      if (success) {
        // Perbarui status produk di daftar lokal
        final index = products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          products[index] = products[index].copyWith(isActive: isActive);
          products.refresh(); // Memaksa Obx untuk rebuild
          print('✅ Product status updated successfully in local list.');
        }
      } else {
        print('❌ Failed to update product status in Supabase.');
        Get.snackbar('Error', 'Failed to update product status.');
      }
    } catch (e) {
      print('❌ Error updating product status: $e');
      Get.snackbar('Error', 'An unexpected error occurred: ${e.toString()}');
    } finally {
      isLoading.value = false;
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
      // isLoading.value = true;
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
    } 
    // finally {
    //   isLoading.value = false;
    //   print('⏳ Loading state set to false.');
    // }
  }
  
  Future<void> loadDashboardStats() async {
    try {
      // isLoading.value = true;
      print('🚀 Fetching seller products length');
      final userId = _supabaseService.userId;
      if (userId == null) {
        print('❌ User belum login, tidak bisa memuat statistik dashboard');
        return;
      }
      // Load products count
      final productsData = await _supabaseService.getProducts(
        sellerId: userId,
      );

      products.value = productsData.map((data) => AddProductmodel.fromDatabase(data)).toList();

      print('📦 Total produk milik seller $userId: ${products.length}');
      for (var p in productsData) {
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
    } 
    // finally {
    //   isLoading.value = false;
    // }
  }

  Future<void> showproducts() async {
    try {
      print('🚀 Navigating to ProductView...');
      Get.toNamed(ProductView.TAG);
    } catch (e) {
      print('❌ Error navigating to ProductView: $e');
    }
  }
  
  void changeMenu(String menu) {
    selectedMenu.value = menu;
  }

  void navigateTo(String menuKey) {
    selectedMenu.value = menuKey; // Mengubah status menu yang aktif
    
    switch (menuKey) {
      case 'dashboard':
        Get.offAllNamed(SellerDashboardView.TAG); // Atau biarkan di halaman ini
        print('Navigating to dashboard...');
        break;
        
      case 'products':
        // Ganti dengan nama rute ke ProductView
        Get.offAllNamed(ProductView.TAG); 
        print('Navigating to products...');
        break;
        
      // case 'orders':
      //   // Ganti dengan nama rute ke OrdersView
      //   Get.toNamed(AppRoutes.orders); 
      //   print('Navigating to orders...');
      //   break;
        
      // Tambahkan case untuk menu lainnya
      default:
        break;
    }
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
  
  void refreshDashboard() async {
  try {
    isLoading.value = true; // Mulai loading
    print('🔄 Refreshing all dashboard data...');
    
    // Gunakan Future.wait untuk menjalankan keduanya secara paralel dan menunggu keduanya selesai
    await Future.wait([
      fetchSellerProfile(),
      loadDashboardStats(),
    ]);

  } catch (e) {
    print('❌ Error refreshing dashboard data: $e');
    Get.snackbar('Error', 'Failed to refresh data: ${e.toString()}');
  } finally {
    isLoading.value = false; // Hentikan loading setelah semua selesai
    print('✅ Dashboard refresh complete.');
  }
}
}