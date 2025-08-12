// lib/modules/admin/controllers/dashboard_controller.dart

// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/supabase_service.dart';

class AdminDashboardController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService.to;
  
  // Observable states
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxBool isLoading = false.obs;
  
  // Dashboard stats
  final RxInt totalUsers = 0.obs;
  final RxInt totalSellers = 0.obs;
  final RxInt totalProducts = 0.obs;
  final RxInt totalOrders = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxInt pendingOrders = 0.obs;
  
  // Menu states - TAMBAHAN BARU
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
        userName.value = profile['full_name'] ?? 'Admin';
        userEmail.value = profile['email'] ?? '';
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
  
  Future<void> loadDashboardStats() async {
    try {
      isLoading.value = true;
      
      // Load total users (with profiles)
      final usersResponse = await _supabaseService.client
          .from('profiles')
          .select('id, roles');
      
      if (usersResponse != null) {
        final users = usersResponse as List;
        totalUsers.value = users.length;
        
        // Count sellers (users with seller role)
        totalSellers.value = users.where((user) {
          final roles = user['roles'] as List?;
          return roles != null && roles.contains('seller');
        }).length;
      }
      
      // Load total products
      final products = await _supabaseService.getProducts();
      totalProducts.value = products.length;
      
      // Load orders
      final orders = await _supabaseService.getOrders();
      totalOrders.value = orders.length;
      
      // Count pending orders and calculate revenue
      double revenue = 0;
      int pending = 0;
      
      for (var order in orders) {
        revenue += (order['total_amount'] ?? 0).toDouble();
        if (order['status'] == 'pending') {
          pending++;
        }
      }
      
      totalRevenue.value = revenue;
      pendingOrders.value = pending;
      
    } catch (e) {
      print('Error loading dashboard stats: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // TAMBAHAN BARU - Method untuk ganti menu
  void changeMenu(String menu) {
    selectedMenu.value = menu;
    print('Menu changed to: $menu');
    
    // Optional: Load specific data when menu changes
    switch(menu) {
      case 'dashboard':
        // Reload dashboard stats when returning to dashboard
        loadDashboardStats();
        break;
      case 'users':
        // Users controller will handle its own data loading
        print('Loading users data...');
        break;
      case 'sellers':
        print('Loading sellers data...');
        break;
      // Add other cases as needed
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
        // Direct logout without AuthController
        await _supabaseService.logout();
        
        // Navigate to login
        Get.offAllNamed('/login');
        
        Get.snackbar(
          'Success',
          'Logged out successfully',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
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
  
  // Get recent activities (for dashboard feed)
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      // Get recent orders
      final recentOrders = await _supabaseService.client
          .from('orders_order')
          .select('*, profiles!user_id(full_name)')
          .order('created_at', ascending: false)
          .limit(5);
      
      // Get recent products
      final recentProducts = await _supabaseService.client
          .from('products')
          .select('*, profiles!seller_id(store_name)')
          .order('created_at', ascending: false)
          .limit(5);
      
      // Combine and sort by date
      List<Map<String, dynamic>> activities = [];
      
      if (recentOrders != null) {
        for (var order in recentOrders) {
          activities.add({
            'type': 'order',
            'title': 'New Order #${order['id'].toString().substring(0, 8)}',
            'description': '${order['profiles']?['full_name'] ?? 'Customer'} placed an order',
            'amount': order['total_amount'],
            'created_at': order['created_at'],
            'status': order['status'],
          });
        }
      }
      
      if (recentProducts != null) {
        for (var product in recentProducts) {
          activities.add({
            'type': 'product',
            'title': product['name'],
            'description': 'Added by ${product['profiles']?['store_name'] ?? 'Seller'}',
            'price': product['price'],
            'created_at': product['created_at'],
          });
        }
      }
      
      // Sort by created_at
      activities.sort((a, b) => 
        DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at']))
      );
      
      return activities.take(10).toList();
    } catch (e) {
      print('Error getting recent activities: $e');
      return [];
    }
  }
}