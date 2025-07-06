import 'cart_item.dart';

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
