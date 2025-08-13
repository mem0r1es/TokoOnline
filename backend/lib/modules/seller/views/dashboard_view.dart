import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toko_online_getx/data/services/supabase_service.dart';
import 'package:toko_online_getx/pages/add_product.dart';
import 'package:toko_online_getx/widgets/seller_top_bar.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/sidebar_seller.dart';

class SellerDashboardView extends GetView<SellerDashboardController> {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  static final String TAG = '/seller-dashboard';
  SellerDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = _supabaseService.currentUser.value;
    if (user == null) {
      return const Center(child: Text('Please login first'));
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          const SidebarSeller(),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                const SellerTopBar(),
                // Dashboard Content
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      return RefreshIndicator(
                        onRefresh: () async => controller.refreshDashboard(),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Page Title
                              const Text(
                                'Dashboard Overview',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Stats Cards
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Total Products',
                                      controller.totalProducts.value.toString(),
                                      Icons.inventory_2_outlined,
                                      Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Total Orders',
                                      controller.totalOrders.value.toString(),
                                      Icons.shopping_cart_outlined,
                                      Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Total Revenue',
                                      'Rp ${controller.totalRevenue.value.toStringAsFixed(0)}',
                                      Icons.attach_money,
                                      Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Quick Actions
                              const Text(
                                'Quick Actions',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildQuickAction(
                                    'Add Product',
                                    Icons.add_box_outlined,
                                    () {
                                    Get.toNamed(AddProduct.TAG);
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  _buildQuickAction(
                                    'View Orders',
                                    Icons.receipt_long_outlined,
                                    () {
                                      // TODO: Navigate to orders
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  _buildQuickAction(
                                    'View Reports',
                                    Icons.analytics_outlined,
                                    () {
                                      // TODO: Navigate to reports
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickAction(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}