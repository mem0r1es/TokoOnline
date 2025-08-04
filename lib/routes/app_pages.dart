// lib/routes/app_pages.dart

import 'package:get/get.dart';
import 'package:toko_online_getx/bindings/auth_binding.dart';
import 'package:toko_online_getx/bindings/seller_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/seller/views/dashboard_view.dart';
// Import admin views & bindings when created
// import '../modules/admin/bindings/admin_binding.dart';
// import '../modules/admin/views/dashboard_view.dart';

import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.initial;

  static final routes = [
    // ===== AUTH ROUTES =====
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // ===== SELLER ROUTES =====
    GetPage(
      name: AppRoutes.sellerDashboard,
      page: () => const SellerDashboardView(),
      binding: SellerBinding(),
      transition: Transition.fadeIn,
      // Nanti akan ditambah middleware di sini
    ),
    
    // ===== ADMIN ROUTES =====
    // GetPage(
    //   name: AppRoutes.adminDashboard,
    //   page: () => const AdminDashboardView(),
    //   binding: AdminBinding(),
    //   transition: Transition.fadeIn,
    //   // Nanti akan ditambah middleware di sini
    // ),
    
    // ===== SELLER FEATURE ROUTES (COMING SOON) =====
    // GetPage(
    //   name: AppRoutes.sellerProducts,
    //   page: () => const SellerProductsView(),
    //   binding: SellerProductsBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.sellerOrders,
    //   page: () => const SellerOrdersView(),
    //   binding: SellerOrdersBinding(),
    // ),
    
    // ===== ADMIN FEATURE ROUTES (COMING SOON) =====
    // GetPage(
    //   name: AppRoutes.adminUsers,
    //   page: () => const AdminUsersView(),
    //   binding: AdminUsersBinding(),
    // ),
  ];
}