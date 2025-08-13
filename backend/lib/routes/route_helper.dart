// lib/routes/route_helper.dart

import 'package:get/get.dart';
import '../data/services/supabase_service.dart';
import 'app_routes.dart';

class RouteHelper {
  static final SupabaseService _supabaseService = SupabaseService.to;
  
  /// Navigate to appropriate dashboard based on user role
  static void goToDashboard() {
    if (_supabaseService.isAdmin) {
      Get.offAllNamed(AppRoutes.adminDashboard);
    } else if (_supabaseService.isSeller) {
      Get.offAllNamed(AppRoutes.sellerDashboard);
    } else {
      // Buyer or no role
      Get.offAllNamed(AppRoutes.login);
    }
  }
  
  /// Get the default dashboard route for current user
  static String get defaultDashboard {
    if (_supabaseService.isAdmin) {
      return AppRoutes.adminDashboard;
    } else if (_supabaseService.isSeller) {
      return AppRoutes.sellerDashboard;
    } else {
      return AppRoutes.login;
    }
  }
  
  /// Check if user can access a specific route
  static bool canAccess(String route) {
    // Public routes (no auth needed)
    final publicRoutes = [
      AppRoutes.login,
      AppRoutes.register,
    ];
    
    if (publicRoutes.contains(route)) {
      return true;
    }
    
    // Must be authenticated for other routes
    if (!_supabaseService.isAuthenticated) {
      return false;
    }
    
    // Role-based routes
    final sellerRoutes = [
      AppRoutes.sellerDashboard,
      AppRoutes.sellerProducts,
      AppRoutes.sellerOrders,
      AppRoutes.sellerProfile,
      AppRoutes.sellerSettings,
    ];
    
    final adminRoutes = [
      AppRoutes.adminDashboard,
      AppRoutes.adminUsers,
      AppRoutes.adminProducts,
      AppRoutes.adminOrders,
      AppRoutes.adminReports,
      AppRoutes.adminSettings,
    ];
    
    // Check seller routes
    if (sellerRoutes.any((r) => route.startsWith(r))) {
      return _supabaseService.isSeller || _supabaseService.isAdmin;
    }
    
    // Check admin routes
    if (adminRoutes.any((r) => route.startsWith(r))) {
      return _supabaseService.isAdmin;
    }
    
    // Default deny
    return false;
  }
  
  /// Navigate with role check
  static void navigateTo(String route, {dynamic arguments}) {
    if (canAccess(route)) {
      Get.toNamed(route, arguments: arguments);
    } else {
      Get.snackbar(
        'Access Denied',
        'You don\'t have permission to access this page',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }
  
  /// Get accessible menu items for current user
  static List<MenuItem> getMenuItems() {
    final List<MenuItem> items = [];
    
    // Common items for all authenticated users
    if (_supabaseService.isAuthenticated) {
      items.add(MenuItem(
        title: 'Dashboard',
        icon: 'dashboard',
        route: defaultDashboard,
      ));
    }
    
    // Seller items
    if (_supabaseService.isSeller || _supabaseService.isAdmin) {
      items.addAll([
        MenuItem(
          title: 'Products',
          icon: 'inventory',
          route: AppRoutes.sellerProducts,
        ),
        MenuItem(
          title: 'Orders',
          icon: 'shopping_cart',
          route: AppRoutes.sellerOrders,
        ),
        MenuItem(
          title: 'Profile',
          icon: 'person',
          route: AppRoutes.sellerProfile,
        ),
      ]);
    }
    
    // Admin-only items
    if (_supabaseService.isAdmin) {
      items.addAll([
        MenuItem(
          title: 'Users',
          icon: 'people',
          route: AppRoutes.adminUsers,
        ),
        MenuItem(
          title: 'Reports',
          icon: 'analytics',
          route: AppRoutes.adminReports,
        ),
      ]);
    }
    
    // Settings for all authenticated users
    if (_supabaseService.isAuthenticated) {
      items.add(MenuItem(
        title: 'Settings',
        icon: 'settings',
        route: _supabaseService.isAdmin 
            ? AppRoutes.adminSettings 
            : AppRoutes.sellerSettings,
      ));
    }
    
    return items;
  }
}

/// Menu item model
class MenuItem {
  final String title;
  final String icon;
  final String route;
  final List<MenuItem>? subItems;
  
  MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    this.subItems,
  });
}