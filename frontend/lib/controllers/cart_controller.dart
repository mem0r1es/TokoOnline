import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      quantity: json['quantity'],
    );
  }
}

class CartService extends GetxController {
  // Observable cart items
  var cartItems = <CartItem>[].obs;

  // Computed properties
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => cartItems.isEmpty;

  bool get isNotEmpty => cartItems.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadCartFromMemory();
  }

  void _loadCartFromMemory() {
    print('Cart loaded: ${cartItems.length} items');
  }

  void addItem({
    required String id,
    required String name,
    required double price,
    required String imageUrl,
    int quantity = 1,
  }) {
    int existingIndex = cartItems.indexWhere((item) => item.id == id);

    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity += quantity;
      cartItems.refresh();

      Get.snackbar(
        'Cart Updated',
        '$name quantity updated in cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } else {
      cartItems.add(
        CartItem(
          id: id,
          name: name,
          price: price,
          imageUrl: imageUrl,
          quantity: quantity,
        ),
      );

      Get.snackbar(
        'Added to Cart',
        '$name added to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }

    print(
      'Cart updated: ${cartItems.length} unique items, $itemCount total items',
    );
    _saveCartToMemory();
  }

  void removeItem(String id) {
    CartItem? item = cartItems.firstWhereOrNull((item) => item.id == id);

    cartItems.removeWhere((item) => item.id == id);

    Get.snackbar(
      'Removed from Cart',
      '${item?.name} removed from cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );

    print('Item removed from cart: ${item?.name}');
    _saveCartToMemory();
    }

  void updateQuantity(String id, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(id);
      return;
    }

    int index = cartItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      cartItems[index].quantity = newQuantity;
      cartItems.refresh();

      print('Quantity updated for ${cartItems[index].name}: $newQuantity');
      _saveCartToMemory();
    }
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

  void clearCart() {
    cartItems.clear();

    Get.snackbar(
      'Cart Cleared',
      'All items removed from cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );

    print('Cart cleared');
    _saveCartToMemory();
  }

  CartItem? getItem(String id) {
    return cartItems.firstWhereOrNull((item) => item.id == id);
  }

  bool hasItem(String id) {
    return cartItems.any((item) => item.id == id);
  }

  int getItemQuantity(String id) {
    CartItem? item = getItem(id);
    return item?.quantity ?? 0;
  }

  Future<bool> checkout() async {
    if (isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Add some items to cart before checkout',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      print('Starting checkout process...');
      print('Total items: $itemCount');
      print('Total price: Rp ${totalPrice.toStringAsFixed(0)}');

      await Future.delayed(Duration(seconds: 2));

      clearCart();

      Get.snackbar(
        'Checkout Successful',
        'Order placed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      print('Checkout error: $e');

      Get.snackbar(
        'Checkout Failed',
        'Something went wrong: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return false;
    }
  }

  void _saveCartToMemory() {
    print('Cart saved to memory');
  }

  void printCart() {
    print('=== CART CONTENTS ===');
    print('Total items: $itemCount');
    print('Total price: Rp ${totalPrice.toStringAsFixed(0)}');

    for (var item in cartItems) {
      print(
        '- ${item.name} x${item.quantity} = Rp ${item.totalPrice.toStringAsFixed(0)}',
      );
    }
    print('====================');
  }
}
