
import 'package:flutter_web/controllers/address_controller.dart';
import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:flutter_web/controllers/cargo_controller.dart';
import 'package:flutter_web/controllers/cart_controller.dart';
import 'package:flutter_web/controllers/checkout_controller.dart';
import 'package:flutter_web/controllers/product_controller.dart';
import 'package:flutter_web/controllers/profile_image_controller.dart';
import 'package:flutter_web/controllers/scroll_controller.dart';
import 'package:flutter_web/controllers/search_controller.dart';
import 'package:flutter_web/controllers/shops_scroll.dart';
import 'package:flutter_web/pages/account/EditProfil/edit_profil_page.dart';
import 'package:flutter_web/services/cargo_service.dart';
import 'package:flutter_web/services/order_tracking_service.dart';
import 'package:flutter_web/services/scroll_controller_manager.dart';
import 'package:flutter_web/services/cart_service.dart';
import 'package:flutter_web/services/checkout_service.dart';
import 'package:flutter_web/services/general_service.dart';
import 'package:flutter_web/services/product_service.dart';
import 'package:get/get.dart';


class InitialScreenBindings implements Bindings {

  InitialScreenBindings();

  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(CartService());
    Get.put(ProductService());
    Get.put(AddressController());
    Get.put(CheckoutService());
    Get.put(CartController());
    Get.put(CheckoutController());
    Get.put(ProductController());
    Get.put(GeneralService());
    Get.put(ScrollControllerManager());
    Get.put(CustomScrollController());
    Get.put(ShopsScrollController());
    Get.put(SearchController());
    Get.put(CargoController());
    Get.put(OrderTrackingService());
    Get.put(CargoService());
    Get.put(ProfileImageController());
    Get.put(EditProfilePage);

  }
}