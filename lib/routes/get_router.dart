import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:toko_online_getx/binding.dart';
import 'package:toko_online_getx/modules/auth/views/login_view.dart';
import 'package:toko_online_getx/modules/auth/views/register_view.dart';
import 'package:toko_online_getx/modules/seller/views/dashboard_view.dart';
import 'package:toko_online_getx/pages/add_product.dart';
import 'package:toko_online_getx/routes/middlewares/auth_guard.dart';
import 'package:toko_online_getx/routes/middlewares/guest_guard.dart';
import 'package:toko_online_getx/routes/middlewares/role_guard.dart';

List<GetPage> get getRoutePages => _routes;

List<GetPage> _routes = [
  GetPage(
    name: LoginView.TAG,
    page: () => LoginView(),
    binding: InitialScreenBindings(),
    transition: Transition.fadeIn,
    middlewares: [GuestGuard()],
  ),
  GetPage(
    name: '/register',
    page: () => RegisterView(),
    binding: InitialScreenBindings(),
    transition: Transition.rightToLeft,
    middlewares: [GuestGuard()],
  ),
  GetPage(
    name: '/seller-dashboard',
    page: () => SellerDashboardView(),
    binding: InitialScreenBindings(),
    transition: Transition.fadeIn,
    middlewares: [AuthGuard(), SellerGuard()],
  ),
  GetPage(
    name: '/add-product', 
    page: () => AddProduct(),
    binding: InitialScreenBindings(),
  ),
  // Add other routes here...
];