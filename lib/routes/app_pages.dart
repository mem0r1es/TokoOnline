// lib/routes/app_pages.dart

import 'package:get/get.dart';

import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/seller/views/dashboard_view.dart';
import '../modules/admin/views/dashboard_view.dart' as admin;

import 'app_routes.dart';
import 'middlewares/auth_guard.dart';
import 'middlewares/role_guard.dart';
import 'middlewares/guest_guard.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.initial;

  static final routes = [
    // ===== AUTH ROUTES =====
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
      middlewares: [
        GuestGuard(), // Redirect to dashboard if already logged in
      ],
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      transition: Transition.rightToLeft,
      middlewares: [
        GuestGuard(), // Redirect to dashboard if already logged in
      ],
    ),
    
    // ===== SELLER ROUTES =====
    GetPage(
      name: AppRoutes.sellerDashboard,
      page: () => const SellerDashboardView(),
      transition: Transition.fadeIn,
      middlewares: [
        AuthGuard(),     // Check if logged in
        SellerGuard(),   // Check if has seller role
      ],
    ),
    
    // ===== ADMIN ROUTES =====
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const admin.AdminDashboardView(),
      transition: Transition.fadeIn,
      middlewares: [
        AuthGuard(),    // Check if logged in
        AdminGuard(),   // Check if has admin role
      ],
    ),
    
    // ===== SELLER FEATURE ROUTES (COMING SOON) =====
    // GetPage(
    //   name: AppRoutes.sellerProducts,
    //   page: () => const SellerProductsView(),
    //   binding: SellerProductsBinding(),
    //   middlewares: [
    //     AuthGuard(),
    //     SellerGuard(),
    //   ],
    // ),
    // GetPage(
    //   name: AppRoutes.sellerOrders,
    //   page: () => const SellerOrdersView(),
    //   binding: SellerOrdersBinding(),
    //   middlewares: [
    //     AuthGuard(),
    //     SellerGuard(),
    //   ],
    // ),
    
    // ===== ADMIN FEATURE ROUTES (COMING SOON) =====
    // GetPage(
    //   name: AppRoutes.adminUsers,
    //   page: () => const AdminUsersView(),
    //   binding: AdminUsersBinding(),
    //   middlewares: [
    //     AuthGuard(),
    //     AdminGuard(),
    //   ],
    // ),
  ];
}