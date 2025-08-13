import 'package:get/get.dart';
import 'package:toko_online_getx/controller/add_productcontroller.dart';
import 'package:toko_online_getx/data/services/supabase_service.dart';
import 'package:toko_online_getx/modules/admin/controllers/dashboard_controller.dart';
import 'package:toko_online_getx/modules/auth/controllers/auth_controller.dart';
import 'package:toko_online_getx/modules/seller/controllers/dashboard_controller.dart';
import 'package:toko_online_getx/service/add_productservice.dart';


class InitialScreenBindings implements Bindings {
  
  InitialScreenBindings();

  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(SellerDashboardController());
    Get.put(AdminDashboardController());
    Get.put(SupabaseService());
    Get.put(AddProductService());
    Get.lazyPut(() =>AddProductController());
  }
}