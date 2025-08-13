import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class SidebarSeller extends GetView<SellerDashboardController> {
  const SidebarSeller({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          // Logo Section
          Container(
            height: 60,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.store, color: Colors.blue, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Seller Portal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildMenuItem(
                  'dashboard',
                  'Dashboard',
                  Icons.dashboard_outlined,
                ),
                _buildMenuItem(
                  'products',
                  'Products',
                  Icons.inventory_2_outlined,
                ),
                _buildMenuItem(
                  'orders',
                  'Orders',
                  Icons.shopping_cart_outlined,
                ),
                _buildMenuItem(
                  'customers',
                  'Customers',
                  Icons.people_outline,
                ),
                _buildMenuItem(
                  'reports',
                  'Reports',
                  Icons.analytics_outlined,
                ),
                _buildMenuItem(
                  'settings',
                  'Settings',
                  Icons.settings_outlined,
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: controller.logout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Colors.red),
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
  
  Widget _buildMenuItem(String key, String title, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedMenu.value == key;
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Material(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => controller.navigateTo(key),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: isSelected ? Colors.blue : Colors.grey[600],
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.grey[800],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}