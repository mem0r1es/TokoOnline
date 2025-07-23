import 'cart_item.dart';
import 'info_user.dart';

class OrderHistoryItem {
  final String id;
  final DateTime timestamp;
  final List<CartItem> items;
  final List<InfoUser> infoUser;
  final String paymentMethod;

  OrderHistoryItem({
    required this.id,
    required this.timestamp,
    required this.items,
    required this.infoUser,
    required this.paymentMethod,
  });

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) {
    return OrderHistoryItem(
      id: json['id'], // dan ini
      timestamp: DateTime.parse(json['timestamp']),
      infoUser: (json['info_user'] as List<dynamic>)
    .map((user) => InfoUser.fromJson(user))
    .toList(),
      paymentMethod: json['payment_method'],
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item))
          .toList(),
    );
  }
  
}

