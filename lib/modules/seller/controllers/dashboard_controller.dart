// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toko_online_getx/models/add_productmodel.dart';
import 'package:toko_online_getx/modules/seller/views/dashboard_view.dart';
import 'package:toko_online_getx/pages/product_view.dart';
import 'package:toko_online_getx/pages/order_page.dart';
import '../../../data/services/supabase_service.dart';
import '../../auth/controllers/auth_controller.dart';

class SellerDashboardController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService.to;
  final supabase = Supabase.instance.client;
  
  // Observable states
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString shopName = ''.obs;
  final RxInt totalProducts = 0.obs;
  final RxInt totalOrders = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxBool isLoading = false.obs;

  // Products
  var products = <AddProductmodel>[].obs;

  // Orders
  var orders = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingOrders = false.obs;
  
  // Menu states
  final RxString selectedMenu = 'dashboard'.obs;
  
  @override
  void onInit() {
    super.onInit();
    print('✅ SellerDashboardController initialized.');

    ever(_supabaseService.currentUser, (User? user) {
      if (user != null) {
        print('✅ User state changed to non-null. Fetching profile...');
        initializeDashboardData();
        fetchSellerOrders();
      } else {
        userName.value = '';
        shopName.value = '';
      }
    });

    if (_supabaseService.currentUser.value != null) {
      print('✅ Found existing session, initializing dashboard data...');
      initializeDashboardData();
      fetchSellerOrders();
    }
  }

  Future<void> updateProductStatus(String productId, bool isActive) async {
    try {
      isLoading.value = true;
      print('🚀 Updating product status for ID: $productId to $isActive');
      
      final success = await _supabaseService.updateProductStatus(productId, isActive);
      
      if (success) {
        final index = products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          products[index] = products[index].copyWith(isActive: isActive);
          products.refresh();
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
      print('🚀 Fetching seller profile data...');
      final profileData = await _supabaseService.getProfileData();
      
      if (profileData != null) {
        userName.value = profileData['full_name'] ?? 'Seller';
        userEmail.value = _supabaseService.currentUser.value?.email ?? '';
        shopName.value = profileData['store_name'] ?? 'Toko Saya';
        print('✅ Profile data loaded. User: ${userName.value}, Shop: ${shopName.value}');
      } else {
        print('❌ Gagal memuat profil penjual. Data tidak ditemukan.');
      }
    } catch (e) {
      print('Error fetching seller profile: $e');
    } 
  }
  
  Future<void> loadDashboardStats() async {
    try {
      final userId = _supabaseService.userId;
      if (userId == null) {
        print('❌ User belum login, tidak bisa memuat statistik dashboard');
        return;
      }

      // Load products
      final productsData = await _supabaseService.getProducts(sellerId: userId);
      products.value = productsData.map((data) => AddProductmodel.fromDatabase(data)).toList();
      totalProducts.value = products.length;
      
      // Load orders
      await fetchSellerOrders();
    } catch (e) {
      print('Error loading dashboard stats: $e');
    } 
  }
  
  Future<void> fetchSellerOrders() async {
    isLoadingOrders.value = true;
    try {
      final currentShopName = shopName.value;
      if (currentShopName.isEmpty) {
        print('❌ Seller not logged in or shop name not available.');
        isLoadingOrders.value = false;
        return;
      }
      
      print('🚀 Fetching orders for shop: $currentShopName');
      
      final response = await supabase
          .from('order_history')
          .select()
          .eq('seller', currentShopName)
          .order('timestamp', ascending: false);

      orders.value = response.cast<Map<String, dynamic>>();
      totalOrders.value = orders.length;
      
      double revenue = 0;
      for (var order in orders.value) {
        revenue += (order['total_price'] ?? 0).toDouble(); 
      }
      totalRevenue.value = revenue;

      print('✅ Fetched ${orders.length} orders for seller $currentShopName');
    } catch (e) {
      print('❌ Error fetching seller orders: $e');
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus, {DateTime? estimatedArrival}) async {
    try {
      print('🚀 Updating order ID: $orderId to status: $newStatus');
      
      // --- LOGIKA BARU DITAMBAHKAN DI SINI ---
      if (newStatus == 'dibatalkan') {
        print('⚠️ Status dibatalkan, menghapus pesanan...');
        await supabase
            .from('order_history')
            .delete()
            .eq('order_id', orderId);
        
        Get.snackbar('Sukses', 'Pesanan berhasil dibatalkan dan dihapus.');

      } else {
        Map<String, dynamic> updateData = {
          'status': newStatus,
          'updated_at': DateTime.now().toIso8601String(),
        };

        if (estimatedArrival != null) {
          updateData['estimated_arrival'] = estimatedArrival.toIso8601String();
        }

        await supabase
            .from('order_history')
            .update(updateData)
            .eq('order_id', orderId); 

        Get.snackbar('Sukses', 'Status pesanan berhasil diperbarui.');
      }
      // --- AKHIR DARI LOGIKA BARU ---
      
      print('✅ Perubahan berhasil. Memuat ulang data pesanan...');
      await fetchSellerOrders();
    } catch (e) {
      print('❌ Error updating/deleting order: $e');
      Get.snackbar('Error', 'Gagal memproses pesanan: ${e.toString()}');
    }
  }

  Future<void> showProducts() async {
    try {
      print('🚀 Navigating to ProductView...');
      Get.toNamed(ProductView.TAG);
    } catch (e) {
      print('❌ Error navigating to ProductView: $e');
    }
  }

  Future<void> showOrders() async {
    try {
      print('🚀 Navigating to OrderPage...');
      await fetchSellerOrders();
      Get.toNamed(OrderPage.TAG);
    } catch (e) {
      print('❌ Error navigating to OrderPage: $e');
    }
  }
  
  void changeMenu(String menu) {
    selectedMenu.value = menu;
  }

  void navigateTo(String menuKey) {
    selectedMenu.value = menuKey;
    switch (menuKey) {
      case 'dashboard':
        Get.offAllNamed(SellerDashboardView.TAG);
        break;
      case 'products':
        Get.offAllNamed(ProductView.TAG); 
        break;
      case 'orders':
        Get.offAllNamed(OrderPage.TAG); 
        break;
      default:
        break;
    }
  }
  
  Future<void> logout() async {
    try {
      final confirm = await Get.defaultDialog(
        title: 'Konfirmasi Logout',
        middleText: 'Apakah Anda yakin ingin logout?',
        textConfirm: 'Ya, Logout',
        textCancel: 'Batal',
        onConfirm: () => Get.back(result: true),
        onCancel: () => Get.back(result: false),
      );
      
      if (confirm == true) {
        final authController = Get.find<AuthController>();
        await authController.logout();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal logout: ${e.toString()}');
    }
  }
  
  void refreshDashboard() async {
    try {
      isLoading.value = true;
      print('🔄 Refreshing all dashboard data...');
      await Future.wait([
        fetchSellerProfile(),
        loadDashboardStats(),
        fetchSellerOrders(),
      ]);
    } catch (e) {
      print('❌ Error refreshing dashboard data: $e');
      Get.snackbar('Error', 'Gagal memuat ulang data: ${e.toString()}');
    } finally {
      isLoading.value = false;
      print('✅ Dashboard refresh complete.');
    }
  }
}