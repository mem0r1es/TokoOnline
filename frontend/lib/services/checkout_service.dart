import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_history_item.dart';
// import '../models/info_user.dart';
import '../services/cart_service.dart';

class CheckoutService extends GetxService {
  var orderHistory = <OrderHistoryItem>[].obs;

  Future<void> saveOrderToSupabase(OrderHistoryItem order, String paymentMethod) async {
    try {
      final fullName = order.infoUser.isNotEmpty ? order.infoUser.first.fullName ?? '' : '';
      final phone = order.infoUser.isNotEmpty ? order.infoUser.first.phone ?? '' : '';
      final address = order.infoUser.isNotEmpty ? order.infoUser.first.address ?? '' : '';
      final email = order.infoUser.isNotEmpty ? order.infoUser.first.email ?? '' : '';

      await supabase.from('order_history').insert({
        'timestamp': DateTime.now().toIso8601String(),
        'items': order.items.map((item) => '${item.name} x${item.quantity}').join(', '),
        'total_price': order.items.fold(0.0, (sum, item) => sum + item.totalPrice),
        'full_name': fullName,
        'phone': phone,
        'address': address,
        'email': email,
        'payment_method': paymentMethod,
      });

      print('Order saved successfully');
    } catch (e) {
      print('Error saving order: $e');
    }
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
      print('✅ Cart cleared from Supabase');
    } catch (e) {
      print('❌ Error clearing cart from Supabase: $e');
    }
  }


  Future<void> loadOrderHistoryFromSupabase(String email) async {
    final response = await supabase
        .from('order_history')
        .select()
        .eq('email', email);

    orderHistory.clear();
    for (final item in response) {
      final order = OrderHistoryItem(
        timestamp: DateTime.parse(item['timestamp'] ?? DateTime.now().toIso8601String()),
        items: [], // Kamu bisa parsing item details kalau simpan di Supabase dalam bentuk json atau string terstruktur
        infoUser: [], paymentMethod: '', // Bisa diisi kalau info lengkapnya disimpan
      );
      orderHistory.add(order);
    }
  }

}
