import 'package:flutter_web/models/cart_historyitem.dart';
import 'package:flutter_web/services/auth_service.dart';
import 'package:flutter_web/services/cart_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartController extends GetxController {
  final supabase = Supabase.instance.client;
  final AuthService authService = Get.find<AuthService>();
  final CartService cartService = Get.find<CartService>();

  var carthistory = <CartHistoryItem>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> fetchCart() async {
    final user = authService.currentUser.value;
    if (user == null) return;

    isLoading.value = true;
    try {
      // cartService.loadCartFromLocalStorage(user.email!);
      await cartService.loadCartFromSupabase(user.email!);
    } catch (e) {
      print('Error fetching cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveCartToSupabase() async {
    final user = authService.currentUser.value;
    if (user == null) return;

    await cartService.saveCartToSupabase(user.email!);
    fetchCart();
  }

  Future<void> removeItemFromSupabase(String productId) async {
    final user = authService.currentUser.value;
    if (user == null) return;

    await cartService.removeItemFromSupabase(user.email!, productId);
    fetchCart();
  }
}

