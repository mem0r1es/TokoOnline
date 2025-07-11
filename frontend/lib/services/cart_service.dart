import 'package:flutter_web/models/info_user.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../models/order_history_item.dart';
import '../controllers/product_controller.dart';
import '../models/cart_historyitem.dart';

final supabase = Supabase.instance.client;

class CartService extends GetxService {
  var cartItems = <CartItem>[].obs;
  var orderHistory = <OrderHistoryItem>[].obs;
  var infoUser = <InfoUser>[].obs;

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => cartItems.isEmpty;
  bool get isNotEmpty => cartItems.isNotEmpty;

  String? userId;

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
    productController.decreaseStock(item.id);
  } else {
    cartItems.add(item);
    productController.decreaseStock(item.id);
  }

  cartItems.refresh();
  _saveCartToMemory();

  Get.snackbar('Cart Updated', '${item.name} added to cart',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green,
    colorText: Colors.white,
    duration: Duration(seconds: 2),
  );

  // ❌ Hapus panggilan Supabase di sini
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

var isUpdating = false.obs;

void decreaseQuantity(String id) async {
  if (isUpdating.value) return;  // Cegah spam klik

  isUpdating.value = true;

  int index = cartItems.indexWhere((item) => item.id == id);
  final productController = Get.find<ProductController>();
  final user = Supabase.instance.client.auth.currentUser;
  final email = user?.email;

  if (index >= 0) {
    if (cartItems[index].quantity > 1) {
      cartItems[index].quantity--;
      productController.increaseStock(id);
      cartItems.refresh();

      if (email != null) {
        await supabase.from('cart_history').update({
          'quantity': cartItems[index].quantity,
          'timestamp': DateTime.now().toIso8601String(),
        })
        .eq('user_id', email)
        .eq('product_id', id);
      }
    } else {
      // Kalau quantity udah 1 ➔ remove
      cartItems.removeAt(index);
      productController.increaseStock(id);
      cartItems.refresh();

      if (email != null) {
        await supabase.from('cart_history').update({
          'quantity': 0,
          'is_active': false,
          'timestamp': DateTime.now().toIso8601String(),
        })
        .eq('user_id', email)
        .eq('product_id', id);
      }
    }
  }

  isUpdating.value = false;
}


  void removeItem(String id) async {
  cartItems.removeWhere((item) => item.id == id);
  final productController = Get.find<ProductController>();
  final user = Supabase.instance.client.auth.currentUser;
  final email = user?.email;

  productController.increaseStock(id);
  cartItems.refresh();

  if (email != null) {
    await supabase.from('cart_history').update({
      'quantity': 0,
      'is_active': false,
      'timestamp': DateTime.now().toIso8601String(),
    })
    .eq('user_id', email)
    .eq('product_id', id);
  }
}


    void _saveCartToMemory() {
      print('Cart saved to memory');
    }

    CartItem? getItem(String id) {
      return cartItems.firstWhereOrNull((item) => item.id == id);
    }

  //   Future<List<CartHistoryItem>> loadCartFromSupabase(String email) async {
  //   final response = await supabase.from('cart_history').select().eq('email', email);

  //   final List<CartHistoryItem> items = (response as List)
  //       .map((item) => CartHistoryItem.fromMap(item))
  //       .toList();

  //   return items;  // <- ini yang kurang
  // }

  Future<void> loadCartFromSupabase(String userEmail) async {
    final response = await supabase
      .from('cart_history')
      .select()
      .eq('user_id', userEmail)
      .eq('is_active', true);

    cartItems.clear();
    for (final item in response) {
      final cartItem = CartItem(
        id: item['product_id'],
        name: item['name'],
        price: (item['price'] as num).toDouble(),
        imageUrl: item['image_url'],
        quantity: item['quantity'],
      );
      cartItems.add(cartItem);
    }
  }

  Future<void> saveCartToSupabase(String userEmail) async {
  for (var item in cartItems) {
    // 1. Cek apakah item ini sudah ada di Supabase
    final existing = await supabase
      .from('cart_history')
      .select()
      .eq('user_id', userEmail)
      .eq('product_id', item.id)
      .eq('is_active', true)
      .maybeSingle();

    if (existing != null) {
      // 2. Kalau sudah ada ➔ update quantity-nya
      await supabase.from('cart_history').update({
        'quantity': item.quantity,  // ✅ Gunakan jumlah terbaru dari local
        'timestamp': DateTime.now().toIso8601String(),
      })
      .eq('user_id', userEmail)
      .eq('product_id', item.id);
    } else {
      // 3. Kalau belum ada ➔ insert baru
      await supabase.from('cart_history').upsert({
        'user_id': userEmail,
        'product_id': item.id,
        'name': item.name,
        'price': item.price,
        'image_url': item.imageUrl,
        'quantity': item.quantity,
        'is_active': true,
        'timestamp': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, product_id');
    }
  }
}


  Future<void> removeItemFromSupabase(String userEmail, String productId) async {
    await supabase
      .from('cart_history')
      .update({'is_active': false})
      .eq('user_id', userEmail)
      .eq('product_id', productId);
  }

  Future<void> clearCartFromSupabase(String userEmail) async {
    try {
      await supabase
          .from('cart_history')
          .update({
            'is_active': false,
            'quantity': 0,
            'timestamp': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userEmail)
          .eq('is_active', true);  // Optional: hanya clear yang aktif
      print('Cart cleared from Supabase');
    } catch (e) {
      print('Error clearing cart from Supabase: $e');
    }
  }

//   Future<void> saveOrderToSupabase(OrderHistoryItem order, String paymentMethod) async {
//   try {
//     final fullName = order.infoUser.isNotEmpty ? order.infoUser.first.fullName ?? '' : '';
//     final phone = order.infoUser.isNotEmpty ? order.infoUser.first.phone ?? '' : '';
//     final address = order.infoUser.isNotEmpty ? order.infoUser.first.address ?? '' : '';
//     final email = order.infoUser.isNotEmpty ? order.infoUser.first.email ?? '' : '';

//     // final itemsText = order.items
//     //     .map((item) => '${item.name} x${item.quantity} (Rp ${item.totalPrice.toStringAsFixed(0)})')
//     //     .join(', ');

//     // final totalPrice = order.items.fold(0.0, (sum, item) => sum + item.totalPrice);

//     await supabase.from('order_history').insert({
//       'timestamp': DateTime.now().toIso8601String(),
//       'items': order.items.map((item) => item.name).join(', '),
//       'total_price': order.items.fold(0.0, (sum, item) => sum + item.totalPrice),
//       'full_name': fullName,
//       'phone': phone,
//       'address': address,
//       'email': email,
//       'payment_method': paymentMethod,
//       'item_quantity': order.items.map((item) => item.quantity).join(', '),
//     });

//     print('Order saved successfully');
//   } catch (e) {
//     print('Error saving order: $e');
//   }
// }

//   Future<void> saveAddressToSupabase(InfoUser info) async {
//   final user = supabase.auth.currentUser;
//   final email = user?.email ?? info.email;

//   try {
//     await supabase.from('addresses').insert({
//       'timestamp': info.timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
//       'full_name': info.fullName,
//       'phone': info.phone,
//       'address': info.address,
//       'email': email,
//     });
//     print('Address saved');
//   } catch (e) {
//     print('Error saving address: $e');
//   }
// }


}
