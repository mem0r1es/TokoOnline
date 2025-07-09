import 'package:flutter_web/models/info_user.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../models/order_history_item.dart';
import '../controllers/product_controller.dart';

final supabase = Supabase.instance.client;

class CartService extends GetxService {
  var cartItems = <CartItem>[].obs;
  var orderHistory = <OrderHistoryItem>[].obs;
  var infoUser = <InfoUser>[].obs;

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => cartItems.isEmpty;
  bool get isNotEmpty => cartItems.isNotEmpty;

  // void removeItem(String id) {
  //   cartItems.removeWhere((item) => item.id == id);
  //   cartItems.refresh();
  // }

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
  
  void addItem(CartItem item) {
  int existingIndex = cartItems.indexWhere((i) => i.id == item.id);
  final productController = Get.find<ProductController>();

  if (existingIndex >= 0) {
    cartItems[existingIndex].quantity += item.quantity;
    productController.decreaseStock(item.id); // ⬅ Kurangi stok
    cartItems.refresh();
    Get.snackbar('Cart Updated', '${item.name} quantity updated in cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  } else {
    cartItems.add(item);
    productController.decreaseStock(item.id); // ⬅ Kurangi stok
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

void increaseQuantity(String id) {
  int index = cartItems.indexWhere((item) => item.id == id);
  final productController = Get.find<ProductController>();

  if (index >= 0) {
    final product = productController.getProductById(id);
    final availableStock = product?.stock ?? 0;

    if (availableStock > 0) {
      cartItems[index].quantity++;
      productController.decreaseStock(id); // Kurangi stok produk
      cartItems.refresh();
      _saveCartToMemory();
    } else {
      // Stok habis ➔ Tampilkan notifikasi
      Get.snackbar(
        "Out of Stock",
        "${product?.title ?? 'This product'} is out of stock.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }
}

void decreaseQuantity(String id) {
  int index = cartItems.indexWhere((item) => item.id == id);
  final productController = Get.find<ProductController>();

  if (index >= 0) {
    if (cartItems[index].quantity > 1) {
      cartItems[index].quantity--;
      productController.increaseStock(id); // ⬅ Balikin stok
      cartItems.refresh();
      _saveCartToMemory();
    } else {
      removeItem(id);
    }
  }
}

void removeItem(String id) {
  cartItems.removeWhere((item) => item.id == id);
  final productController = Get.find<ProductController>();
  productController.increaseStock(id); // ⬅ Balikin stok
  cartItems.refresh();
}

  void _saveCartToMemory() {
    print('Cart saved to memory');
  }

  CartItem? getItem(String id) {
    return cartItems.firstWhereOrNull((item) => item.id == id);
  }

  Future<void> saveOrderToSupabase(OrderHistoryItem order, String paymentMethod) async {
  try {
    final fullName = order.infoUser.isNotEmpty ? order.infoUser.first.fullName ?? '' : '';
    final phone = order.infoUser.isNotEmpty ? order.infoUser.first.phone ?? '' : '';
    final address = order.infoUser.isNotEmpty ? order.infoUser.first.address ?? '' : '';
    final email = order.infoUser.isNotEmpty ? order.infoUser.first.email ?? '' : '';

    // final itemsText = order.items
    //     .map((item) => '${item.name} x${item.quantity} (Rp ${item.totalPrice.toStringAsFixed(0)})')
    //     .join(', ');

    // final totalPrice = order.items.fold(0.0, (sum, item) => sum + item.totalPrice);

    await supabase.from('order_history').insert({
      'timestamp': DateTime.now().toIso8601String(),
      'items': order.items.map((item) => item.name).join(', '),
      'total_price': order.items.fold(0.0, (sum, item) => sum + item.totalPrice),
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'email': email,
      'payment_method': paymentMethod,
      'item_quantity': order.items.map((item) => item.quantity).join(', '),
    });

    print('Order saved successfully');
  } catch (e) {
    print('Error saving order: $e');
  }
}

  Future<void> saveAddressToSupabase(InfoUser info) async {
  final user = supabase.auth.currentUser;
  final email = user?.email ?? info.email;

  try {
    await supabase.from('addresses').insert({
      'timestamp': info.timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'full_name': info.fullName,
      'phone': info.phone,
      'address': info.address,
      'email': email,
    });
    print('Address saved');
  } catch (e) {
    print('Error saving address: $e');
  }
}


}
