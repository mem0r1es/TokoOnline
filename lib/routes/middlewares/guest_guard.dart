// lib/routes/middlewares/guest_guard.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/supabase_service.dart';
import '../route_helper.dart';

class GuestGuard extends GetMiddleware {
  final SupabaseService _supabaseService = SupabaseService.to;
  
  @override
  int? get priority => 1;
  
  @override
  RouteSettings? redirect(String? route) {
    // If user is already authenticated, redirect to their dashboard
    if (_supabaseService.isAuthenticated) {
      print('GuestGuard - User already authenticated, redirecting to dashboard');
      
      // Get appropriate dashboard based on role
      final dashboard = RouteHelper.defaultDashboard;
      return RouteSettings(name: dashboard);
    }
    
    // User is not authenticated, allow access to login/register
    return null;
  }
}