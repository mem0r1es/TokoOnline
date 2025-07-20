import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String? description;

  Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class ProductImage {
  final int? id;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @JsonKey(name: 'alt_text')
  final String? altText;
  @JsonKey(name: 'is_primary')
  final bool isPrimary;
  final int order;

  ProductImage({
    this.id,
    required this.imageUrl,
    this.altText,
    this.isPrimary = false,
    this.order = 0,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) => _$ProductImageFromJson(json);
  Map<String, dynamic> toJson() => _$ProductImageToJson(this);
}

@JsonSerializable()
class ProductAttribute {
  final int? id;
  final String name;
  final String value;

  ProductAttribute({
    this.id,
    required this.name,
    required this.value,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) => _$ProductAttributeFromJson(json);
  Map<String, dynamic> toJson() => _$ProductAttributeToJson(this);
}

@JsonSerializable()
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final Category? category;
  final String condition;
  final String status;
  @JsonKey(name: 'stock_quantity')
  final int stockQuantity;
  final String? brand;
  final String? model;
  final String? color;
  final String? size;
  final double? weight;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'views_count')
  final int viewsCount;
  @JsonKey(name: 'seller_name')
  final String? sellerName;
  @JsonKey(name: 'seller_username')
  final String? sellerUsername;
  final List<ProductImage>? images;
  final List<ProductAttribute>? attributes;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.category,
    required this.condition,
    required this.status,
    required this.stockQuantity,
    this.brand,
    this.model,
    this.color,
    this.size,
    this.weight,
    this.isFeatured = false,
    this.viewsCount = 0,
    this.sellerName,
    this.sellerUsername,
    this.images,
    this.attributes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  bool get isAvailable => status == 'active' && stockQuantity > 0;

  String get primaryImageUrl {
    if (images != null && images!.isNotEmpty) {
      final primaryImage = images!.firstWhere(
        (img) => img.isPrimary,
        orElse: () => images!.first,
      );
      return primaryImage.imageUrl;
    }
    return '';
  }

  String get statusDisplayName {
    switch (status) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'sold':
        return 'Sold';
      case 'pending':
        return 'Pending Review';
      default:
        return status;
    }
  }

  String get conditionDisplayName {
    switch (condition) {
      case 'new':
        return 'New';
      case 'like_new':
        return 'Like New';
      case 'good':
        return 'Good';
      case 'fair':
        return 'Fair';
      case 'poor':
        return 'Poor';
      default:
        return condition;
    }
  }
}

@JsonSerializable()
class ProductListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Product> results;

  ProductListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) => _$ProductListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProductListResponseToJson(this);
}

@JsonSerializable()
class CreateProductRequest {
  final String name;
  final String description;
  final double price;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  final String condition;
  @JsonKey(name: 'stock_quantity')
  final int stockQuantity;
  final String? brand;
  final String? model;
  final String? color;
  final String? size;
  final double? weight;
  final List<ProductImage>? images;
  final List<ProductAttribute>? attributes;

  CreateProductRequest({
    required this.name,
    required this.description,
    required this.price,
    this.categoryId,
    required this.condition,
    required this.stockQuantity,
    this.brand,
    this.model,
    this.color,
    this.size,
    this.weight,
    this.images,
    this.attributes,
  });

  factory CreateProductRequest.fromJson(Map<String, dynamic> json) => _$CreateProductRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateProductRequestToJson(this);
}

@JsonSerializable()
class SellerStats {
  @JsonKey(name: 'total_products')
  final int totalProducts;
  @JsonKey(name: 'active_products')
  final int activeProducts;
  @JsonKey(name: 'inactive_products')
  final int inactiveProducts;
  @JsonKey(name: 'sold_products')
  final int soldProducts;
  @JsonKey(name: 'total_views')
  final int totalViews;
  @JsonKey(name: 'out_of_stock')
  final int outOfStock;

  SellerStats({
    required this.totalProducts,
    required this.activeProducts,
    required this.inactiveProducts,
    required this.soldProducts,
    required this.totalViews,
    required this.outOfStock,
  });

  factory SellerStats.fromJson(Map<String, dynamic> json) => _$SellerStatsFromJson(json);
  Map<String, dynamic> toJson() => _$SellerStatsToJson(this);
}