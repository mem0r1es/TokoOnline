import 'package:flutter/material.dart';
import '../models/user_model.dart';

class DashboardSidebar extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;

  const DashboardSidebar({
    Key? key,
    required this.user,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.userType == 'admin';
    
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Column(
        children: [
          // Logo/Brand
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'batta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: ListView(
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  isActive: true,
                ),
                _buildNavItem(
                  icon: Icons.people_outline,
                  title: 'Users',
                ),
                _buildNavItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Products',
                ),
                _buildNavItem(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Orders',
                ),
                _buildNavItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Transactions',
                ),
                if (isAdmin) ...[
                  _buildNavItem(
                    icon: Icons.swap_horiz_outlined,
                    title: 'Swap Management',
                  ),
                  _buildNavItem(
                    icon: Icons.payment_outlined,
                    title: 'Payments & Refunds',
                  ),
                ],
                _buildNavItem(
                  icon: Icons.analytics_outlined,
                  title: 'Reports & Analytics',
                ),
                _buildNavItem(
                  icon: Icons.local_offer_outlined,
                  title: 'Promotions & Discounts',
                ),
                _buildNavItem(
                  icon: Icons.support_agent_outlined,
                  title: 'Disputes & Support',
                  badge: '2',
                ),
                _buildNavItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                ),
              ],
            ),
          ),
          
          // User Profile Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          user.firstName.isNotEmpty 
                              ? user.firstName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            user.userType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    String? badge,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.blue.shade600 : Colors.grey.shade600,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.blue.shade600 : Colors.grey.shade700,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: isActive ? Colors.blue.shade50 : null,
        onTap: () {},
      ),
    );
  }
}