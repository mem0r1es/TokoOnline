import 'package:get/get.dart';
import 'package:toko_online_getx/bindings/seller_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/seller/views/dashboard_view.dart';
import '../bindings/auth_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.sellerDashboard,
      page: () => SellerDashboardView(),
      binding: SellerBinding(),
    ),
  ];
}