class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String seller;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.seller,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'quantity': quantity,
    'seller' : seller,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'],
    name: json['name'],
    price: json['price'].toDouble(),
    imageUrl: json['imageUrl'],
    quantity: json['quantity'],
    seller: json['seller'],
  );

  factory CartItem.fromSupabaseOrderItem(Map<String, dynamic> map) {
    return CartItem(
      id: map['product_id'] as String, // Gunakan 'product_id' dari DB
      name: map['item_name'] as String,
      price: (map['price_at_purchase'] as num).toDouble(), // Gunakan 'price_at_purchase'
      imageUrl: map['image_url'] as String,
      quantity: map['item_quantity'] as int,
      seller: map['seller'] as String,
    );
  }
  String toDatabaseString() => '$name x $quantity';
}
