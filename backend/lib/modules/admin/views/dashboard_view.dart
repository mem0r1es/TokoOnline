// lib/modules/admin/views/dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/sidebar_admin.dart';
import 'package:toko_online_getx/modules/admin/views/users_management_view.dart';
import 'package:toko_online_getx/modules/admin/views/products_management_view.dart';
import 'package:toko_online_getx/modules/admin/views/orders_management_view.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminDashboardController controller = Get.find<AdminDashboardController>();
    
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          const SidebarAdmin(),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Welcome Message with Dynamic Title
                      Obx(() => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, ${controller.userName.value}!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getPageTitle(controller.selectedMenu.value),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )),
                      
                      // User Menu
                      Row(
                        children: [
                          // Notification Icon
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {
                              // TODO: Implement notifications
                            },
                          ),
                          const SizedBox(width: 16),
                          
                          // User Avatar & Dropdown
                          PopupMenuButton<String>(
                            offset: const Offset(0, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.red,
                                  child: Text(
                                    controller.userName.value.isNotEmpty
                                        ? controller.userName.value[0].toUpperCase()
                                        : 'A',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'profile',
                                child: Row(
                                  children: const [
                                    Icon(Icons.person_outline, size: 20),
                                    SizedBox(width: 12),
                                    Text('Profile'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'settings',
                                child: Row(
                                  children: const [
                                    Icon(Icons.settings_outlined, size: 20),
                                    SizedBox(width: 12),
                                    Text('Settings'),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: const [
                                    Icon(Icons.logout, size: 20, color: Colors.red),
                                    SizedBox(width: 12),
                                    Text('Logout', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'logout') {
                                controller.logout();
                              }
                              // TODO: Handle other menu items
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Dynamic Content Area
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: Obx(() {
                      // Show different content based on selected menu
                      switch(controller.selectedMenu.value) {
                        case 'dashboard':
                          return _buildDashboardContent(controller);
                        case 'users':
                          return UsersManagementView();
                        case 'sellers':
                          return Center(
                            child: Text(
                              'Sellers Management - Coming Soon',
                              style: TextStyle(fontSize: 24, color: Colors.grey),
                            ),
                          );
                        case 'products':
                          return ProductsManagementView(
                            // child: Text(
                            //   'Products Management - Coming Soon',
                            //   style: TextStyle(fontSize: 24, color: Colors.grey),
                            // ),
                          );
                        case 'orders':
                          return OrdersManagementView(
                            // child: Text(
                            //   'Orders Management - Coming Soon',
                            //   style: TextStyle(fontSize: 24, color: Colors.grey),
                            // ),
                          );
                        case 'categories':
                          return Center(
                            child: Text(
                              'Categories Management - Coming Soon',
                              style: TextStyle(fontSize: 24, color: Colors.grey),
                            ),
                          );
                        case 'payments':
                          return Center(
                            child: Text(
                              'Payments Management - Coming Soon',
                              style: TextStyle(fontSize: 24, color: Colors.grey),
                            ),
                          );
                        case 'reports':
                          return Center(
                            child: Text(
                              'Reports - Coming Soon',
                              style: TextStyle(fontSize: 24, color: Colors.grey),
                            ),
                          );
                        case 'settings':
                          return Center(
                            child: Text(
                              'System Settings - Coming Soon',
                              style: TextStyle(fontSize: 24, color: Colors.grey),
                            ),
                          );
                        default:
                          return _buildDashboardContent(controller);
                      }
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
  
  // Helper method untuk mendapatkan title berdasarkan menu
  String _getPageTitle(String menu) {
    switch(menu) {
      case 'dashboard': return 'Admin Dashboard';
      case 'users': return 'Users Management';
      case 'sellers': return 'Sellers Management';
      case 'products': return 'Products Management';
      case 'orders': return 'Orders Management';
      case 'categories': return 'Categories Management';
      case 'payments': return 'Payments Management';
      case 'reports': return 'Reports';
      case 'settings': return 'System Settings';
      default: return 'Admin Dashboard';
    }
  }
  
  // Dashboard Content Widget
  Widget _buildDashboardContent(AdminDashboardController controller) {
    return Obx(() {
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
                'Admin Dashboard Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Stats Cards - Row 1
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Users',
                      controller.totalUsers.value.toString(),
                      Icons.people_outline,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Active Sellers',
                      controller.totalSellers.value.toString(),
                      Icons.store_outlined,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total Products',
                      controller.totalProducts.value.toString(),
                      Icons.inventory_2_outlined,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Stats Cards - Row 2
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Orders',
                      controller.totalOrders.value.toString(),
                      Icons.shopping_cart_outlined,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total Revenue',
                      'Rp ${controller.totalRevenue.value.toStringAsFixed(0)}',
                      Icons.attach_money,
                      Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Pending Orders',
                      controller.pendingOrders.value.toString(),
                      Icons.pending_actions,
                      Colors.red,
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
                    'Manage Users',
                    Icons.people_outline,
                    () => controller.changeMenu('users'),
                  ),
                  const SizedBox(width: 16),
                  _buildQuickAction(
                    'Manage Sellers',
                    Icons.store_outlined,
                    () => controller.changeMenu('sellers'),
                  ),
                  const SizedBox(width: 16),
                  _buildQuickAction(
                    'View Reports',
                    Icons.analytics_outlined,
                    () => controller.changeMenu('reports'),
                  ),
                  const SizedBox(width: 16),
                  _buildQuickAction(
                    'System Settings',
                    Icons.settings_outlined,
                    () => controller.changeMenu('settings'),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Recent Activities Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Activities',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: View all activities
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Activity items would be loaded from controller
                      _buildActivityItem(
                        'New seller registered',
                        'Tech Store joined the platform',
                        Icons.store,
                        '5 minutes ago',
                      ),
                      _buildActivityItem(
                        'New order placed',
                        'Order #12345 - Rp 250,000',
                        Icons.shopping_cart,
                        '15 minutes ago',
                      ),
                      _buildActivityItem(
                        'Product reported',
                        'iPhone 15 Pro Max - Policy violation',
                        Icons.report,
                        '1 hour ago',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
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
            Icon(icon, color: Colors.red),
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
  
  Widget _buildActivityItem(String title, String subtitle, IconData icon, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.grey[700], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}