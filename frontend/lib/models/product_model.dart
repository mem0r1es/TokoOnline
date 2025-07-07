class Product {
  final String? id; // Database ID
  final String title;
  final String imagePath;
  final String description;
  final int price;
  final String? category;
  int? stock;
  final bool? isActive;
  final DateTime? createdAt;

  // For backward compatibility with old cart system
  int quantity;
  int get subtotal => price * quantity;

  Product({
    this.id,
    required this.title,
    required this.imagePath,
    required this.description,
    required this.price,
    this.category,
    this.stock,
    this.isActive,
    this.createdAt,
    this.quantity = 1, // Default quantity
  });

  // Factory constructor untuk data dari database
  factory Product.fromDatabase(Map<String, dynamic> data) {
    return Product(
      id: data['id'],
      title: data['name'] ?? '',
      imagePath: data['image_url'] ?? 'assets/placeholder.png',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toInt() ?? 0,
      category: data['category'],
      stock: data['stock'],
      isActive: data['is_active'],
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : null,
      quantity: 1,
    );
  }

  // Convert to JSON for database
  Map<String, dynamic> toDatabase() {
    return {
      'name': title,
      'image_url': imagePath,
      'description': description,
      'price': price,
      'category': category,
      'stock': stock,
      'is_active': isActive ?? true,
    };
  }

  // For backward compatibility
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imagePath': imagePath,
      'description': description,
      'price': price,
      'category': category,
      'stock': stock,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  // Create copy with updated fields
  Product copyWith({
    String? id,
    String? title,
    String? imagePath,
    String? description,
    int? price,
    String? category,
    int? stock,
    bool? isActive,
    int? quantity,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      quantity: quantity ?? this.quantity,
    );
  }
}
