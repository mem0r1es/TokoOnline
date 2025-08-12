
import 'cart_item.dart';
import 'info_user.dart';

class OrderHistoryItem {
  final String id;
  final DateTime timestamp;
  final List<CartItem> items;
  final List<InfoUser> infoUser;
  final String? cargoCategory;
  final String? cargoName;
  final String paymentMethod;
  final String status;
  final DateTime? estimatedArrival;
  final DateTime? updatedAt;
  final String? kategoriId;
  final double? ongkir;
  final int? totalBayar;

  OrderHistoryItem({
    required this.id,
    required this.timestamp,
    required this.items,
    required this.infoUser,
    required this.cargoCategory,
    required this.cargoName,
    required this.paymentMethod,
    required this.status,
    this.estimatedArrival,
    this.updatedAt,
    this.kategoriId,
    this.ongkir,
    this.totalBayar,
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
      cargoCategory: json['cargo_category'],
      cargoName: json['cargo_name'], status: '',
      kategoriId: json['cargo_id']?.toString(),
      ongkir: (json['ongkir'] as num?)?.toDouble(),
      totalBayar: json['total_bayar'] as int?,
      estimatedArrival: json['estimated_arrival'] != null
          ? DateTime.parse(json['estimated_arrival'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,

    );
  }
  String get capitalizedStatus {
  if (status.isEmpty) return '';
  return status[0].toUpperCase() + status.substring(1);
}

String get normalizedStatus => status.toLowerCase().trim();


  
}

