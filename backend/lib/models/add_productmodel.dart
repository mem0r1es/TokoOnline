class AddProductmodel {
  final String? id; // Assuming you have an ID field for the product
  final String sellerId; // Assuming you have a sellerId field for the product
  final String name;
  final String filePath;
  final String description;
  final int price;
  final String? category;
  final int? stock;
  final bool? isActive;
  // final String? sellerId;

  AddProductmodel({
    this.id = '', // Default to empty string if not provided
    this.sellerId = '', // Default to empty string if not provided
    required this.name,
    required this.filePath,
    required this.description,
    required this.price,
    this.category,
    this.stock,
    this.isActive = true,
    // this.sellerId,
  });

  AddProductmodel copyWith({
    String? id,
    String? sellerId,
    String? name,
    String? filePath,
    String? description,
    int? price,
    String? category,
    int? stock,
    bool? isActive,
  }) {
    return AddProductmodel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
    );
  }


  factory AddProductmodel.fromDatabase(Map<String, dynamic> data) {
    print('RAW PRODUCT DATA: $data');
    return AddProductmodel(
      id: data['id'] ?? '', // Ensure ID is handled
      sellerId: data['seller_id'] ?? '', // Ensure sellerId is handled
      name: data['name'],
      filePath: data['image_url'] ?? 'assets/placeholder.png',
      description: data['description'],
      price: (data['price']as num?)?.toInt() ?? 0, // Convert to double safel
      category: data['category'],
      stock: data['stock_quantity'],
      isActive: data['is_active'] ?? true,
      // sellerId: data['seller_id'],
    );
  }

  Map<String, dynamic> toDatabase({bool includeSellerId = false}) {
    final map = {
      // 'id': id, // Include ID for updates
      // 'seller_id': sellerId, // Include sellerId for updates
      'name': name,
      'image_url': filePath,
      'description': description,
      'price': price,
      'category': category,
      'stock_quantity': stock,
      'is_active': isActive ?? true, // Default to true if not provided
      // 'seller_id': sellerId,
    };
      if (includeSellerId && sellerId.trim().isNotEmpty) {
    map['seller_id'] = sellerId;
  }

    return map;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include ID for updates
      'seller_id': sellerId, // Include sellerId for updates
      'name': name,
      'image_url': filePath,
      'description': description,
      'price': price,
      'category': category,
      'stock_quantity': stock,
      'is_active': isActive ?? false, // Default to true if not provided
      // 'seller_id': sellerId,
    };
  }
}