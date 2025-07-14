import 'cart_item.dart';
import 'info_user.dart';

class OrderHistoryItem {
  final DateTime timestamp;
  final List<CartItem> items;
  final List<InfoUser> infoUser;
  final String paymentMethod;

  OrderHistoryItem({
    required this.timestamp,
    required this.items,
    required this.infoUser,
    required this.paymentMethod,
  });
  
}

