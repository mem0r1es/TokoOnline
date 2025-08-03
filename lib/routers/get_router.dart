import 'package:flutter_web/binding.dart';
import 'package:flutter_web/pages/favorite/favorite_page.dart';
import 'package:flutter_web/pages/history/history.dart';
import 'package:flutter_web/pages/history/order_detail.dart';
import 'package:flutter_web/pages/pengiriman/cargo.dart';
import 'package:flutter_web/pages/profile/edit_profil_page.dart';
import 'package:flutter_web/pages/search/search_page.dart';
import 'package:flutter_web/pages/shoppingcart/after_checkout.dart';
import 'package:flutter_web/pages/shoppingcart/cart.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import 'package:flutter_web/pages/about/about.dart';
import 'package:flutter_web/pages/contact/contact.dart';
import 'package:flutter_web/pages/homepage/home_page.dart';
import 'package:flutter_web/pages/profile/add_address.dart';
import 'package:flutter_web/pages/profile/address_page.dart';
import 'package:flutter_web/pages/profile/profile_page.dart';
import 'package:flutter_web/pages/shop/product_dialog.dart';
import 'package:flutter_web/pages/shop/shops.dart';

List<GetPage> get getRoutePages => _routes;

List<GetPage> _routes = [
  GetPage(name: HomePage.TAG, page: () => HomePage(), binding: InitialScreenBindings(),),
  GetPage(name: ShopsPage.TAG, page: () => ShopsPage(), binding: InitialScreenBindings(),),
  GetPage(name: AboutPage1.TAG, page: () => AboutPage1(), binding: InitialScreenBindings(),),
  GetPage(name: ContactPage1.TAG, page: () => ContactPage1(), binding: InitialScreenBindings(),),
  GetPage(name: ProfilePage.TAG, page: () => ProfilePage(), binding: InitialScreenBindings(),),
  GetPage(name: AddressPage.TAG, page: () => AddressPage(), binding: InitialScreenBindings(),),
  GetPage(name: AddAddress.TAG, page: () => AddAddress(), binding: InitialScreenBindings(),),
  GetPage(name: SearchResultPage.TAG, page: () => SearchResultPage.fromArguments(), binding: InitialScreenBindings(),),
  GetPage(name: ProductDialog.TAG, page: () => ProductDialog(), binding: InitialScreenBindings()),
  GetPage(name: ProductInfoPage.TAG, page: () => ProductInfoPage(), binding: InitialScreenBindings()),
  GetPage(name: FavoritePage.TAG, page: () => FavoritePage(), binding: InitialScreenBindings()),
  GetPage(name: CartPages.TAG, page: () => CartPages(), binding: InitialScreenBindings()), //'/shoppingcart'
  GetPage(name: CargoPage.TAG, page: () => CargoPage(), binding: InitialScreenBindings()),
  // GetPage(name: OrderDetailPage.TAG, page: () => OrderDetailPage(order: order,), binding: InitialScreenBindings()),
  GetPage(name: AfterCheckout.TAG, page: () => AfterCheckout(), binding: InitialScreenBindings()),
];