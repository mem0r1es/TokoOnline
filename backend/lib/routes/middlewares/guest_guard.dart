// lib/routes/middlewares/guest_guard.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/supabase_service.dart';
import '../app_routes.dart';

class GuestGuard extends GetMiddleware {
  final SupabaseService _supabaseService = SupabaseService.to;
  
  @override
  int? get priority => 1;
  
  @override
  RouteSettings? redirect(String? route) {

    if (_supabaseService.isAuthenticated) {

      if (Get.currentRoute == route) {
        print('GuestGuard - User authenticated, redirecting from $route');
        
        if (_supabaseService.isAdmin) {
          return const RouteSettings(name: AppRoutes.adminDashboard);
        } else if (_supabaseService.isSeller) {
          return const RouteSettings(name: AppRoutes.sellerDashboard);
        }
      }
    }
    
    // User is not authenticated, allow access to login/register
    return null;
  }
}