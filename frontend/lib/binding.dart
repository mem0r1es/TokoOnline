
import 'package:flutter_web/controllers/address_controller.dart';
import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:flutter_web/controllers/cargo_controller.dart';
import 'package:flutter_web/controllers/cart_controller.dart';
import 'package:flutter_web/controllers/checkout_controller.dart';
import 'package:flutter_web/controllers/product_controller.dart';
import 'package:flutter_web/controllers/scroll_controller.dart';
import 'package:flutter_web/controllers/search_controller.dart';
import 'package:flutter_web/controllers/shops_scroll.dart';
import 'package:flutter_web/services/cargo_service.dart';
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
    final AuthController authController = Get.put(AuthController());
    final CartService cartService = Get.put(CartService());
    final ProductService productService = Get.put(ProductService());
    final AddressController addressController = Get.put(AddressController());
    final CheckoutService checkoutService = Get.put(CheckoutService());
    final CartController cartController = Get.put(CartController());
    final CheckoutController checkoutController = Get.put(CheckoutController());
    final ProductController productController = Get.put(ProductController());
    final GeneralService generalService = Get.put(GeneralService());
    final ScrollControllerManager scrollControllerManager = Get.put(ScrollControllerManager());
    final CustomScrollController customScrollController = Get.put(CustomScrollController());
    final ShopsScrollController shopsScrollController =Get.put(ShopsScrollController());
    final SearchController searchController = Get.put(SearchController());
    final CargoService cargoService = Get.put(CargoService());
    final CargoController cargoController = Get.put(CargoController());
  }
}