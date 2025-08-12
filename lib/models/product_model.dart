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
  final String? sellerId;
  final String? storeName;

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
    required this.sellerId,
    this.storeName,
    this.quantity = 1, // Default quantity
  });

  // Factory constructor untuk data dari database
  // factory Product.fromDatabase(Map<String, dynamic> data) {
  //   print('RAW PRODUCT DATA: $data');

  //   print('DEBUG seller_id: ${data['seller_id']} (${data['seller_id'].runtimeType})');
  //   return Product(
  //     id: data['id']?.toString(),
  //     title: data['name'] ?? '',
  //     imagePath: data['image_url'] ?? 'assets/placeholder.png',
  //     description: data['description'] ?? '',
  //     price: (data['price'] as num?)?.toInt() ?? 0,
  //     category: data['category'],
  //     stock: data['stock_quantity'],
  //     isActive: data['is_active'],
  //     createdAt: data['created_at'] != null
  //         ? DateTime.parse(data['created_at'])
  //         : null,
  //     sellerId: data['seller_id'] is Map
  //         ? data['seller_id']['id']?.toString()
  //         : data['seller_id']?.toString(),
  //     storeName: data['seller_id'] is Map
  //         ? data['seller_id']['store_name']
  //         : null,
  //     quantity: 1,
      
  //   );
    
  // }

  factory Product.fromDatabase(Map<String, dynamic> data) {
  print('RAW PRODUCT DATA: $data');

  return Product(
    id: data['id']?.toString(),
    title: data['name'] ?? '',
    imagePath: data['image_url'] ?? 'assets/placeholder.png',
    description: data['description'] ?? '',
    price: (data['price'] as num?)?.toInt() ?? 0,
    category: data['category'],
    stock: data['stock_quantity'],
    isActive: data['is_active'],
    createdAt: data['created_at'] != null
        ? DateTime.parse(data['created_at'])
        : null,
    sellerId: data['seller_id']?.toString(),
    storeName: data['seller_store_name'], // ini ambil dari VIEW
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
      'stock_quantity': stock,
      'is_active': isActive ?? true,
      'seller_id': sellerId,
      'storeName' : storeName,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    title: json['title'],
    price: json['price'],
    imagePath: json['imagePath'],
    storeName: json['storeName'],
    category: json['category'],
    stock: json['stock_quantity'], description: '', sellerId: '',
  );

  // For backward compatibility
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imagePath': imagePath,
      'description': description,
      'price': price,
      'category': category,
      'stock_quantity': stock,
      'quantity': quantity,
      'subtotal': subtotal,
      'seller_id': sellerId,
      'storeName' : storeName,
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
      sellerId: sellerId ?? sellerId,
      storeName: storeName ?? storeName,
      quantity: quantity ?? this.quantity,
    );
  }
}
