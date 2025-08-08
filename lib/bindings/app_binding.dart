// lib/bindings/app_binding.dart

import 'package:get/get.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/seller/controllers/dashboard_controller.dart';
import '../modules/admin/controllers/dashboard_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(SellerDashboardController());
    Get.put(AdminDashboardController());
    
    // Future controllers can be added here
  }
}