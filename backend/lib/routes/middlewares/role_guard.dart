// lib/routes/middlewares/role_guard.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/supabase_service.dart';
import 'package:toko_online_getx/routes/app_routes.dart';

class RoleGuard extends GetMiddleware {
  final List<String> allowedRoles;
  final SupabaseService _supabaseService = SupabaseService.to;
  
  RoleGuard({required this.allowedRoles});
  
  @override
  int? get priority => 2; // Run after AuthGuard
  
  @override
  RouteSettings? redirect(String? route) {
    // Get user roles
    final userRoles = _supabaseService.userRoles;
    
    // Check if user has any of the allowed roles
    final hasPermission = userRoles.any((role) => allowedRoles.contains(role));
    
    print('RoleGuard - User roles: $userRoles, Allowed: $allowedRoles, Has permission: $hasPermission');
    
    if (!hasPermission) {
      // User doesn't have required role
      _showAccessDeniedDialog();
      
      // Redirect based on user's actual role
      if (_supabaseService.isAdmin) {
        return const RouteSettings(name: AppRoutes.adminDashboard);
      } else if (_supabaseService.isSeller) {
        return const RouteSettings(name: AppRoutes.sellerDashboard);
      } else {
        // Buyer or no role - go to login
        return const RouteSettings(name: AppRoutes.login);
      }
    }
    
    // User has permission, continue
    return null;
  }
  
  void _showAccessDeniedDialog() {
    // Show dialog after frame is built to avoid build errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.dialog(
        AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.block, color: Colors.red),
              SizedBox(width: 8),
              Text('Access Denied'),
            ],
          ),
          content: const Text(
            'You don\'t have permission to access this page.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    });
  }
}

// Specific role guards for convenience
class SellerGuard extends RoleGuard {
  SellerGuard() : super(allowedRoles: ['seller', 'admin']); // Admin can access seller pages
}

class AdminGuard extends RoleGuard {
  AdminGuard() : super(allowedRoles: ['admin']);
}