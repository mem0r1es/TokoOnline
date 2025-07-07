import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../models/order_history_item.dart';

final supabase = Supabase.instance.client;

class CartService extends GetxService {
  var cartItems = <CartItem>[].obs;
  var orderHistory = <OrderHistoryItem>[].obs;

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => cartItems.isEmpty;
  bool get isNotEmpty => cartItems.isNotEmpty;

  void removeItem(String id) {
    cartItems.removeWhere((item) => item.id == id);
    cartItems.refresh();
  }

  bool hasItem(String id) {
    return cartItems.any((item) => item.id == id);
  }

  void updateQuantity(String id, int newQuantity) {
    int index = cartItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      cartItems[index].quantity = newQuantity;
      cartItems.refresh();
    }
  }

  void clearCart() {
    cartItems.clear();
  }
  
  void increaseQuantity(String id) {
    int index = cartItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      cartItems[index].quantity++;
      cartItems.refresh();
      _saveCartToMemory();
    }
  }

  void decreaseQuantity(String id) {
    int index = cartItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
        cartItems.refresh();
        _saveCartToMemory();
      } else {
        removeItem(id);
      }
    }
  }

  void addItem(CartItem item) {
  int existingIndex = cartItems.indexWhere((i) => i.id == item.id);

  if (existingIndex >= 0) {
    cartItems[existingIndex].quantity += item.quantity;
    cartItems.refresh();
    Get.snackbar('Cart Updated', '${item.name} quantity updated in cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  } else {
    cartItems.add(item);
    Get.snackbar('Added to Cart', '${item.name} added to cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  print('Cart updated: ${cartItems.length} unique items');
  _saveCartToMemory();
}


  void _saveCartToMemory() {
    print('Cart saved to memory');
  }

  CartItem? getItem(String id) {
    return cartItems.firstWhereOrNull((item) => item.id == id);
  }

  Future<void> saveOrderToSupabase(OrderHistoryItem order, String paymentMethod) async {
    try {
      await supabase.from('order_history').insert({
        'timestamp': order.timestamp.toIso8601String(),
        'item': order.items.map((item) => item.name).join(', '),
        'total_price': order.items.fold(0.0, (sum, item) => sum + item.totalPrice),
        'full_name': order.fullName,
        'phone': order.phone,
        'address': order.address,
        'email': order.email,
        'payment_method': paymentMethod,
      });
    } catch (e) {
      print('Error saving order: $e');
    }
  }
}
