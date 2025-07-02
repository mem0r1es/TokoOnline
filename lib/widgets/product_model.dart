class Product {
  final String title;
  final String imagePath;
  final String description;
  final int price;
  int quantity;

  Product({
    required this.title,
    required this.imagePath,
    required this.description,
    required this.price,
    this.quantity = 1
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          imagePath == other.imagePath &&
          description == other.description &&
          price == other.price;

  @override
  int get hashCode =>
      title.hashCode ^ imagePath.hashCode ^ description.hashCode ^ price.hashCode;

  int get subtotal => price * quantity;
  // int get totalPrice => subtotal;
}
