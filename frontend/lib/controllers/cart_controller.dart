import 'package:flutter_web/controllers/auth_controller.dart';
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
  // Observable cart items
  var cartItems = <CartItem>[].obs;
  var orderHistory = <OrderHistoryItem>[].obs;

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
    
    // final authService = Get.find<AuthService>();
    // final email = authService.getUserEmail();
    // if (email != null) {
    //   loadOrderHistory(email);
    // }
  }

//   Future<void> loadOrderHistory(String email) async {
//   try {
//     final response = await supabase
//         .from('order_history')
//         .select('*')
//         .eq('email', email)
//         .order('timestamp', ascending: false);

//     // Map response ke model OrderHistoryItem
//     orderHistory.value = (response as List).map((data) {
//       return OrderHistoryItem(
//         items: [], // bisa diisi kalau simpan item detail
//         timestamp: DateTime.parse(data['timestamp']),
//         fullName: data['full_name'],
//         email: data['email'],
//         phone: data['phone'],
//         address: data['address'],
//       );
//     }).toList();

//     print('Order history loaded: ${orderHistory.length}');
//   } catch (e) {
//     print('Failed to load order history: $e');
//   }
// }


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

      await saveOrderToSupabase(newOrder, fullName, phone, address, email, paymentMethod);
      // await loadOrderHistory(email);


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
  // String userId,
  OrderHistoryItem order,
  String fullName,
  String phone,
  String address,
  String email,
  String paymentMethod,
) async {
  try {
    print('Saving order to Supabase...');

    final response = await supabase
    .from('order_history')
    .insert({
      // 'user_id': userId,
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


