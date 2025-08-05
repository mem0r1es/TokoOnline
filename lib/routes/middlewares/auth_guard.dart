// lib/routes/middlewares/auth_guard.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/supabase_service.dart';
import 'package:toko_online_getx/routes/app_routes.dart';

class AuthGuard extends GetMiddleware {
  final SupabaseService _supabaseService = SupabaseService.to;
  
  @override
  int? get priority => 1;
  
  @override
  RouteSettings? redirect(String? route) {
    // Check if user is authenticated
    final isAuthenticated = _supabaseService.isAuthenticated;
    
    // Debug print
    print('AuthGuard - Route: $route, Authenticated: $isAuthenticated');
    
    if (!isAuthenticated) {
      // User not logged in, redirect to login
      return const RouteSettings(name: AppRoutes.login);
    }
    
    // User is authenticated, continue to requested route
    return null;
  }
  
  @override
  GetPage? onPageCalled(GetPage? page) {
    // Optional: Log page access
    print('Accessing protected page: ${page?.name}');
    return page;
  }
  
  @override
  Widget onPageBuilt(Widget page) {
    // Optional: Wrap page with additional widgets if needed
    print('Page built: ${page.runtimeType}');
    return page;
  }
  
  @override
  void onPageDispose() {
    // Optional: Cleanup when leaving page
    print('Leaving protected page');
  }
}