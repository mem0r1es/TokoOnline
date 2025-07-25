import 'package:flutter_web/models/info_user.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_history_item.dart';
// import '../models/info_user.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class CheckoutService extends GetxService {
  var orderHistory = <OrderHistoryItem>[].obs;

  String? userId;

  @override
  void initState() {
    super.onInit();
    final email = Supabase.instance.client.auth.currentUser?.email;
    userId = Supabase.instance.client.auth.currentUser?.id;
    if (email != null) {
      loadOrderHistoryFromSupabase(email);
    }
  }

  Future<void> saveOrderToSupabase(OrderHistoryItem order, String paymentMethod) async {
  try {
    final info = order.infoUser.first;
    final timestamp = order.timestamp.toIso8601String();

    // Simpan setiap item sebagai 1 row
    for (final item in order.items) {
      await supabase.from('order_history').insert({
        'timestamp': timestamp,
        'full_name': info.fullName,
        'email': info.email,
        'phone': info.phone,
        'address': info.address,
        'payment_method': paymentMethod,
        'items': item.name,
        'item_quantity': item.quantity,
        'total_price': item.totalPrice, // total untuk item ini aja
      });
    }

    print('✅ Order saved per item!');
  } catch (e) {
    print('❌ Error saving order: $e');
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
  print("📥 Load order history untuk: $email");

  try {
    final response = await supabase
        .from('order_history')
        .select()
        .eq('email', email)
        .order('timestamp');

    orderHistory.clear();

    // Grup by timestamp
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final row in response) {
      final key = row['timestamp'];
      grouped.putIfAbsent(key, () => []).add(row);
    }

    for (final entry in grouped.entries) {
      final items = entry.value.map((item) => CartItem(
        id: item['items'],
        name: item['items'],
        quantity: item['item_quantity'],
        price: (item['total_price'] ?? 0).toDouble(),
        imageUrl: '', // opsional
      )).toList();

      final infoUser = InfoUser(
        fullName: entry.value.first['full_name'],
        email: entry.value.first['email'],
        phone: entry.value.first['phone'],
        address: entry.value.first['address'],
        timestamp: DateTime.tryParse(entry.key),
      );

      orderHistory.add(OrderHistoryItem(
        timestamp: DateTime.parse(entry.key),
        paymentMethod: entry.value.first['payment_method'] ?? '',
        infoUser: [infoUser],
        items: items,
        id: '', // kalau pakai
      ));
    }

    print("✅ Loaded ${orderHistory.length} order history (grouped)");
  } catch (e) {
    print('❌ Error load order: $e');
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
