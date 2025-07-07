import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../models/order_history_item.dart';
import '../services/cart_service.dart';
import '../controllers/product_controller.dart'; // ✅ ditambahkan
import 'package:flutter/material.dart';

class CartController extends GetxController {
  final CartService cartService = Get.find<CartService>();

  @override
  void onInit() {
    super.onInit();
  }

  void addToCart({
    required String id,
    required String name,
    required double price,
    required String imageUrl,
    int quantity = 1,
  }) {
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
        items: List.from(cartService.cartItems),
        timestamp: DateTime.now(),
        fullName: fullName,
        email: email,
        phone: phone,
        address: address,
      );

      // ✅ KURANGI STOK DI SINI, SAAT CHECKOUT BERHASIL
      final productController = Get.find<ProductController>();
      for (final item in cartService.cartItems) {
        productController.decreaseStock(item.id, quantity: item.quantity); // ✅ ditambahkan
      }

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
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
}
