class CartHistoryItem {
  final String id;
  final String userId;
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;
  final bool isActive;
  final DateTime timestamp;

  CartHistoryItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.isActive,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'product_id': productId,
    'name': name,
    'price': price,
    'image_url': imageUrl,
    'quantity': quantity,
    'is_active': isActive,
    'timestamp': timestamp.toIso8601String(),
  };

  factory CartHistoryItem.fromMap(Map<String, dynamic> map) {
    return CartHistoryItem(
      id: map['id'],
      userId: map['user_id'],
      productId: map['product_id'],
      name: map['name'],
      price: map['price'],
      imageUrl: map['image_url'],
      quantity: map['quantity'],
      isActive: map['is_active'] ?? true,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
