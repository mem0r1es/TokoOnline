class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        name: json['name'],
        price: json['price'].toDouble(),
        imageUrl: json['imageUrl'],
        quantity: json['quantity'],
      );

  factory CartItem.fromDatabase(String name, int quantity) {
  return CartItem(
    id: '',            // Kalau tidak ada ID-nya, diisi kosong
    name: name.trim(),
    price: 0.0,        // Harga belum diketahui
    imageUrl: '',      // Kosong juga
    quantity: quantity,
  );
}


  String toDatabaseString() => '$name x $quantity';
}
