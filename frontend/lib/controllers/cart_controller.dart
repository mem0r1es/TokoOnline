import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../models/order_history_item.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import 'package:flutter/material.dart';

class CartController extends GetxController {
  final CartService cartService = Get.find<CartService>();

  void addToCart({
    required String id,
    required String name,
    required double price,
    required String imageUrl,
    int quantity = 1,
  }) {
    // ✅ Pastikan CartService punya addItem(CartItem item)
    cartService.addItem(CartItem(
      id: id,
      name: name,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity,
    ));

    Get.snackbar(
      'Added to Cart',
      '$name added to cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void removeFromCart(String id) {
    cartService.removeItem(id);
    Get.snackbar(
      'Removed from Cart',
      'Item removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  void clearCart() {
    cartService.clearCart();
    Get.snackbar(
      'Cart Cleared',
      'All items removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  Future<bool> checkout({
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String paymentMethod,
  }) async {
    if (cartService.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Add items before checkout',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      final order = OrderHistoryItem(
        items: List.from(cartService.cartItems),  // ✅ Betul, pakai instance
        timestamp: DateTime.now(),
        fullName: fullName,
        email: email,
        phone: phone,
        address: address,
      );

      cartService.orderHistory.add(order);
      await cartService.saveOrderToSupabase(order, paymentMethod);
      cartService.clearCart();

      Get.snackbar(
        'Checkout Successful',
        'Order placed!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Checkout Failed',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
}

class CartController1 extends GetxController {
  var cartItems = <Product>[].obs;

  void addToCart(Product product) {
    // Jika produk sudah ada, tambah qty
    final index = cartItems.indexWhere((p) => p.title == product.title);
    if (index >= 0) {
      cartItems[index].quantity++;
      cartItems.refresh(); // ← supaya UI update
    } else {
      cartItems.add(product);
    }
  }
}
