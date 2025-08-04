import 'package:get/get.dart';
import '../modules/seller/controllers/dashboard_controller.dart';

class SellerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerDashboardController>(
      () => SellerDashboardController(),
    );
  }
}