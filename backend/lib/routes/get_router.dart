import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:toko_online_getx/binding.dart';
import 'package:toko_online_getx/controller/add_productcontroller.dart';
import 'package:toko_online_getx/modules/admin/views/dashboard_view.dart';
import 'package:toko_online_getx/modules/auth/views/login_view.dart';
import 'package:toko_online_getx/modules/auth/views/register_view.dart';
import 'package:toko_online_getx/modules/seller/views/dashboard_view.dart';
import 'package:toko_online_getx/pages/add_product.dart';
import 'package:toko_online_getx/pages/product_view.dart';
import 'package:toko_online_getx/routes/app_routes.dart';
import 'package:toko_online_getx/routes/middlewares/auth_guard.dart';
import 'package:toko_online_getx/routes/middlewares/guest_guard.dart';
import 'package:toko_online_getx/routes/middlewares/role_guard.dart';
import 'package:toko_online_getx/modules/admin/views/products_management_view.dart';
import 'package:toko_online_getx/modules/admin/controllers/products_controller.dart';
import 'package:toko_online_getx/modules/admin/views/orders_management_view.dart';
import 'package:toko_online_getx/modules/admin/controllers/orders_controller.dart';


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
    name: SellerDashboardView.TAG,
    page: () => SellerDashboardView(),
    binding: InitialScreenBindings(),
    transition: Transition.fadeIn,
    middlewares: [AuthGuard(), SellerGuard()],
  ),
  GetPage(
    name: AddProduct.TAG, 
    page: () => AddProduct(),
    binding: BindingsBuilder((){
      Get.lazyPut(() => AddProductController());
    }),
  ),
  GetPage(
    name: ProductView.TAG,
    page: () => ProductView(),
    binding: InitialScreenBindings(),
    middlewares: [AuthGuard()],
  ),
  GetPage(
    name: AppRoutes.adminDashboard,
    page: () => AdminDashboardView(),
    transition: Transition.fadeIn,
    middlewares: [AuthGuard(), AdminGuard(),],
  ),
  GetPage(
  name: '/admin/products',
  page: () => ProductsManagementView(),
  binding: BindingsBuilder(() {
    Get.lazyPut(() => ProductsController());
  }),
  middlewares: [AuthGuard(), AdminGuard()],
  ),
  GetPage(
  name: '/admin/orders',
  page: () => OrdersManagementView(),
  binding: BindingsBuilder(() {
    Get.lazyPut(() => OrdersController());
  }),
  middlewares: [AuthGuard(), AdminGuard()],
  ),
  // Add other routes here...
];