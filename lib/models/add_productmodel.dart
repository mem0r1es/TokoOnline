class AddProductmodel {
  final String id; // Assuming you have an ID field for the product
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

  factory AddProductmodel.fromDatabase(Map<String, dynamic> data) {
    print('RAW PRODUCT DATA: $data');
    return AddProductmodel(
      id: data['id'] ?? '', // Ensure ID is handled
      sellerId: data['seller_id'] ?? '', // Ensure sellerId is handled
      name: data['name'],
      filePath: data['image_url'] ?? 'assets/placeholder.png',
      description: data['description'],
      price: data['price'],
      category: data['category'],
      stock: data['stock'],
      isActive: data['is_active'] ?? true,
      // sellerId: data['seller_id'],
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id, // Include ID for updates
      'seller_id': sellerId, // Include sellerId for updates
      'name': name,
      'image_url': filePath,
      'description': description,
      'price': price,
      'category': category,
      'stock': stock,
      'is_active': isActive ?? true, // Default to true if not provided
      // 'seller_id': sellerId,
    };
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
      'stock': stock,
      'is_active': isActive ?? false, // Default to true if not provided
      // 'seller_id': sellerId,
    };
  }
}