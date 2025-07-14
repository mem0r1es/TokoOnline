import 'package:flutter_web/models/info_user.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_history_item.dart';
// import '../models/info_user.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class CheckoutService extends GetxService {
  var orderHistory = <OrderHistoryItem>[].obs;

  @override
  void initState() {
    super.onInit();
    final email = Supabase.instance.client.auth.currentUser?.email;
    if (email != null) {
      loadOrderHistoryFromSupabase(email);
    }
  }

  Future<void> saveOrderToSupabase(OrderHistoryItem order, String paymentMethod) async {
    try {
      final fullName = order.infoUser.isNotEmpty ? order.infoUser.first.fullName ?? '' : '';
      final phone = order.infoUser.isNotEmpty ? order.infoUser.first.phone ?? '' : '';
      final address = order.infoUser.isNotEmpty ? order.infoUser.first.address ?? '' : '';
      final email = order.infoUser.isNotEmpty ? order.infoUser.first.email ?? '' : '';

      await supabase.from('order_history').insert({
        'timestamp': order.timestamp.toIso8601String(),
        'full_name': order.infoUser.first.fullName,
        'email': order.infoUser.first.email,
        'phone': order.infoUser.first.phone,
        'address': order.infoUser.first.address,
        'payment_method': paymentMethod,
        // 'items': order.items.map((e) => '${e.name} x${e.quantity}').join(', '),
        // 'item_quantity': order.items.map((e) => e.quantity.toString()).join(','),
        // 'total_price': order.items.fold(0.0, (sum, item) => sum + item.totalPrice),
        'items': order.items.first.name,
        'item_quantity':order.items.first.quantity,
        'total_price':order.items.first.price,
      });

      print('Order saved successfully');
    } catch (e) {
      print('Error saving order: $e');
    }
  }

  // Future<void> clearCartFromSupabase(String userEmail) async {
  //   try {
  //     await supabase
  //         .from('cart_history')
  //         .update({
  //           'is_active': false,
  //           'quantity': 0,
  //           'timestamp': DateTime.now().toIso8601String(),
  //         })
  //         .eq('user_id', userEmail)
  //         .eq('is_active', true);  // Optional: hanya clear yang aktif
  //     print('✅ Cart cleared from Supabase');
  //   } catch (e) {
  //     print('❌ Error clearing cart from Supabase: $e');
  //   }
  // }


//   Future<void> loadOrderHistoryFromSupabase(String email) async {
//   final response = await supabase
//       .from('order_history')
//       .select()
//       .eq('email', email);

//   orderHistory.clear();

//   for (final item in response) {
//     final infoUser = InfoUser(
//       fullName: item['full_name'],
//       email: item['email'],
//       phone: item['phone'],
//       address: item['address'],
//       timestamp: DateTime.tryParse(item['timestamp']),
//     );

//     final order = OrderHistoryItem(
//       timestamp: DateTime.parse(item['timestamp']),
//       paymentMethod: item['payment_method'] ?? '',
//       infoUser: [infoUser],
//       items: [items],
//       // itemsText: item['items'] ?? '',
//       // itemQuantities: item['item_quantity'] ?? '',
//       // totalPrice: int.tryParse(item['total_price'].toString()) ?? 0,
//     );

//     orderHistory.add(order);
//   }
// }
Future<void> loadOrderHistoryFromSupabase(String email) async {
  final response = await supabase
      .from('order_history')
      .select()
      .eq('email', email);

  orderHistory.clear();

  for (final item in response) {
    // 1. Buat info user
    final infoUser = InfoUser(
      fullName: item['full_name'],
      email: item['email'],
      phone: item['phone'],
      address: item['address'],
      timestamp: DateTime.tryParse(item['timestamp']),
    );

    // 2. Buat satu CartItem dari data Supabase
    final singleCartItem = CartItem(
      id: item['items'], // bisa pakai nama sebagai ID sementara
      name: item['items'],
      price: double.tryParse(item['total_price'].toString()) ?? 0.0,
      imageUrl: '', // kosong karena gak disimpan
      quantity: int.tryParse(item['item_quantity'].toString()) ?? 1,
    );

    // 3. Bangun order object
    final order = OrderHistoryItem(
      timestamp: DateTime.parse(item['timestamp']),
      paymentMethod: item['payment_method'] ?? '',
      infoUser: [infoUser],
      items: [singleCartItem], // masukkan ke dalam list
    );

    orderHistory.add(order);
  }
}


// Future<void> loadOrderHistoryFromSupabase(String email) async {
//   final response = await supabase
//       .from('order_history')
//       .select()
//       .eq('email', email);

//   orderHistory.clear();

//   for (final item in response) {
//     final infoUser = InfoUser(
//       fullName: item['full_name'],
//       email: item['email'],
//       phone: item['phone'],
//       address: item['address'],
//       timestamp: DateTime.tryParse(item['timestamp']),
//     );

//     // fallback: parsing string ke list CartItem manual
//     List<CartItem> items = [];
//     try {
//       final rawItems = item['items'];
//       final totalPrice = double.tryParse(item['total_price'].toString()) ?? 0.0;

//       if (rawItems is String) {
//         items = _parseItemsFromString(rawItems, totalPrice);
//       } else if (rawItems is List) {
//         items = rawItems.map((e) => CartItem.fromJson(e)).toList();
//       }
//     } catch (e) {
//       print("❌ Error parsing items: $e");
//     }

//     final order = OrderHistoryItem(
//       timestamp: DateTime.parse(item['timestamp']),
//       items: items,
//       infoUser: [infoUser],
//       paymentMethod: item['payment_method'] ?? '',
//     );

//     orderHistory.add(order);
//   }
// }

// List<CartItem> _parseItemsFromString(String itemsString, double total) {
//   final parts = itemsString.split(',');
//   final perItemPrice = total / (parts.length == 0 ? 1 : parts.length);

//   return parts.map((itemStr) {
//     final part = itemStr.trim().split(' x');
//     final name = part[0].trim();
//     final quantity = part.length > 1 ? int.tryParse(part[1]) ?? 1 : 1;

//     return CartItem(
//       id: name,
//       name: name,
//       price: perItemPrice / quantity, // harga kira-kira aja
//       imageUrl: '',
//       quantity: quantity,
//     );
//   }).toList();
// }



}
