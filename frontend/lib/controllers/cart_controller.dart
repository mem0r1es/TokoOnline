import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class OrderHistoryItem {
  final List<CartItem> items;
  final DateTime timestamp;
  final String fullName;
  final String email;
  final String phone;
  final String address;

  OrderHistoryItem({
    required this.items,
    required this.timestamp,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
  });
}

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
  var cartItems = <CartItem>[].obs;
  var orderHistory = <OrderHistoryItem>[].obs;

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => cartItems.isEmpty;

  bool get isNotEmpty => cartItems.isNotEmpty;

  @override
    void onInit() {
      super.onInit();
      _initCartAfterAuth();
    }

    void _initCartAfterAuth() async {
      // Tunggu Supabase selesai memuat user
      await Future.delayed(Duration(milliseconds: 500));

      final user = supabase.auth.currentUser;
      if (user != null) {
        print('User found: ${user.id}');
        await loadCartFromSupabase();
      } else {
        print('No user found yet, cart not loaded');
      }
    }

  Future<void> saveCartToSupabase() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('cart_items').delete().eq('user_id', user.id);

      for (var item in cartItems) {
        await supabase.from('cart_items').insert({
          'user_id': user.id,
          'product_id': item.id,
          'name': item.name,
          'price': item.price,
          'image_url': item.imageUrl,
          'quantity': item.quantity,
        });
      }

      print('Cart saved to Supabase for user: ${user.email}');
    } catch (e) {
      print('Failed to save cart: $e');
    }
  }

  Future<void> loadCartFromSupabase() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('cart_items')
          .select()
          .eq('user_id', user.id);

      cartItems.value = (data as List).map((json) {
        return CartItem(
          id: json['product_id'],
          name: json['name'],
          price: (json['price'] as num).toDouble(),
          imageUrl: json['image_url'],
          quantity: json['quantity'],
        );
      }).toList();

      print('Cart loaded from Supabase: ${cartItems.length} items');
    } catch (e) {
      print('Failed to load cart: $e');
    }
  }

  void _updateCartState() {
    _saveCartToMemory();
    saveCartToSupabase();
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
    _updateCartState();
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
    _updateCartState();
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
      _updateCartState();
    }
  }

  void increaseQuantity(String id) {
    int index = cartItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      cartItems[index].quantity++;
      cartItems.refresh();
      _updateCartState();
    }
  }

  void decreaseQuantity(String id) {
    int index = cartItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
        cartItems.refresh();
        _updateCartState();
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
    _updateCartState();
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

  Future<bool> checkout({
    required String userId,
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String paymentMethod,
  }) async {
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

      final newOrder = OrderHistoryItem(
        items: List.from(cartItems),
        timestamp: DateTime.now(),
        fullName: fullName,
        email: email,
        phone: phone,
        address: address,
      );
      orderHistory.add(newOrder);
      clearCart();

      await saveOrderToSupabase(
        newOrder,
        fullName,
        phone,
        address,
        email,
        paymentMethod,
      );

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

Future<void> saveOrderToSupabase(
  OrderHistoryItem order,
  String fullName,
  String phone,
  String address,
  String email,
  String paymentMethod,
) async {
  try {
    print('Saving order to Supabase...');

    final response = await supabase.from('order_history').insert({
      'timestamp': order.timestamp.toIso8601String(),
      'item': order.items.map((item) => item.name).join(', '),
      'total_price': order.items.fold(0.0, (sum, item) => sum + item.totalPrice),
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'email': email,
      'payment_method': paymentMethod,
    });

    print('Insert response: $response');

    if (response == null) {
      print('Failed: No response from Supabase');
    } else if (response.error != null) {
      print('Insert failed: ${response.error!.message}');
    } else {
      print('Insert success: ${response.data}');
    }
  } catch (e) {
    print('Error saving order to Supabase: $e');
  }
}
