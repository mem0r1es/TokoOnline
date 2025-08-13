// lib/modules/admin/widgets/sidebar_admin.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class SidebarAdmin extends StatelessWidget {
  const SidebarAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminDashboardController controller = Get.find<AdminDashboardController>();
    
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(3, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(width: 12),
                Text(
                  'Admin Portal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: Obx(() => ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  menuKey: 'dashboard',
                  isSelected: controller.selectedMenu.value == 'dashboard',
                  onTap: () => controller.changeMenu('dashboard'),
                ),
                _buildMenuItem(
                  icon: Icons.people_outline,
                  title: 'Users Management',
                  menuKey: 'users',
                  isSelected: controller.selectedMenu.value == 'users',
                  onTap: () => controller.changeMenu('users'),
                ),
                _buildMenuItem(
                  icon: Icons.store_outlined,
                  title: 'Sellers Management',
                  menuKey: 'sellers',
                  isSelected: controller.selectedMenu.value == 'sellers',
                  onTap: () => controller.changeMenu('sellers'),
                ),
                _buildMenuItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'All Products',
                  menuKey: 'products',
                  isSelected: controller.selectedMenu.value == 'products',
                  onTap: () => controller.changeMenu('products'),
                ),
                _buildMenuItem(
                  icon: Icons.shopping_cart_outlined,
                  title: 'All Orders',
                  menuKey: 'orders',
                  isSelected: controller.selectedMenu.value == 'orders',
                  onTap: () => controller.changeMenu('orders'),
                ),
                _buildMenuItem(
                  icon: Icons.category_outlined,
                  title: 'Categories',
                  menuKey: 'categories',
                  isSelected: controller.selectedMenu.value == 'categories',
                  onTap: () => controller.changeMenu('categories'),
                ),
                _buildMenuItem(
                  icon: Icons.payment_outlined,
                  title: 'Payments',
                  menuKey: 'payments',
                  isSelected: controller.selectedMenu.value == 'payments',
                  onTap: () => controller.changeMenu('payments'),
                ),
                _buildMenuItem(
                  icon: Icons.analytics_outlined,
                  title: 'Reports',
                  menuKey: 'reports',
                  isSelected: controller.selectedMenu.value == 'reports',
                  onTap: () => controller.changeMenu('reports'),
                ),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'System Settings',
                  menuKey: 'settings',
                  isSelected: controller.selectedMenu.value == 'settings',
                  onTap: () => controller.changeMenu('settings'),
                ),
              ],
            )),
          ),
          
          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () => controller.logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String menuKey,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Colors.red[50] : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.red : Colors.grey[700],
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.red : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hoverColor: Colors.red[50],
      ),
    );
  }
}