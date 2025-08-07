import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toko_online_getx/bindings/app_binding.dart';
import 'package:toko_online_getx/routes/app_routes.dart';

import 'data/services/supabase_service.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://mccdwczueketpqlbobyw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jY2R3Y3p1ZWtldHBxbGJvYnl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEyOTEwMTcsImV4cCI6MjA2Njg2NzAxN30.LAQPMZgZvIUtRVjzkLFh-wXO_RiP9IuwZ3kgSpYghqE',
  );
  
Get.put(SupabaseService());
  // Remove AuthController from here - let AuthBinding handle it
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check initial route based on auth status
    final supabaseService = Get.find<SupabaseService>();
    String initialRoute = AppPages.initial;
    
    if (supabaseService.isAuthenticated) {
      if (supabaseService.isAdmin) {
        initialRoute = AppRoutes.adminDashboard;
      } else if (supabaseService.isSeller) {
        initialRoute = AppRoutes.sellerDashboard;
      }
    }
    
    return GetMaterialApp(
      title: 'Seller Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      initialBinding: AppBinding(),
      // Optional: Unknown route handler
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const NotFoundView(),
      ),
    );
  }
}

// Simple 404 Page
class NotFoundView extends StatelessWidget {
  const NotFoundView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              '404 - Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.offAllNamed('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}