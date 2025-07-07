import 'package:get/get.dart';
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

  // ✅ Load cart dari Supabase untuk user yang sedang login
  Future<void> loadCartFromSupabase() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('cart_items')
          .select()
          .eq('user_id', user.id);

      cartItems.value = (response as List).map((item) {
        return CartItem(
          id: item['product_id'],
          name: item['name'],
          price: (item['price'] as num).toDouble(),
          imageUrl: item['image_url'],
          quantity: item['quantity'],
        );
      }).toList();

      print('✅ Cart loaded: ${cartItems.length} items');

    } catch (e) {
      print('❌ Failed to load cart: $e');
    }
  }

  // ✅ Dijalankan saat app mulai, jika user sudah login
  Future<void> loadCartIfLoggedIn() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      print('✅ User ditemukan: ${user.id}, load cart...');
      await loadCartFromSupabase();
    } else {
      print('⚠️ User belum login. Cart tidak dimuat.');
    }
  }

  void addItem(CartItem item) {
    final index = cartItems.indexWhere((i) => i.id == item.id);

    if (index >= 0) {
      cartItems[index].quantity += item.quantity;
    } else {
      cartItems.add(item);
    }

    cartItems.refresh();
    syncCartToSupabase();
  }

  void increaseQuantity(String id) {
    final index = cartItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      cartItems[index].quantity++;
      cartItems.refresh();
      syncCartToSupabase();
    }
  }

  void decreaseQuantity(String id) {
    final index = cartItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
      } else {
        cartItems.removeAt(index);
      }

      cartItems.refresh();
      syncCartToSupabase();
    }
  }

  void removeItem(String id) {
    cartItems.removeWhere((item) => item.id == id);
    cartItems.refresh();
    syncCartToSupabase();
  }

  void clearCart() {
    cartItems.clear();
    cartItems.refresh();
    syncCartToSupabase();
  }

  bool hasItem(String id) {
    return cartItems.any((item) => item.id == id);
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
        'item_quantity': order.items.map((item) => item.quantity).join(', '),
      });
    } catch (e) {
      print('❌ Failed to save order: $e');
    }
  }

  void syncCartToSupabase() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase
          .from('cart_items')
          .delete()
          .eq('user_id', user.id);
          
      for (final item in cartItems) {
        await supabase.from('cart_items').insert({
          'user_id': user.id,
          'product_id': item.id,
          'name': item.name,
          'price': item.price,
          'image_url': item.imageUrl,
          'quantity': item.quantity,
        });
      }

      print('✅ Cart synced to Supabase');

    } catch (e) {
      print('❌ Failed to sync cart: $e');
    }
  }
}
