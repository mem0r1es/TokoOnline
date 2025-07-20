// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };

ProductImage _$ProductImageFromJson(Map<String, dynamic> json) => ProductImage(
      id: (json['id'] as num?)?.toInt(),
      imageUrl: json['image_url'] as String,
      altText: json['alt_text'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProductImageToJson(ProductImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image_url': instance.imageUrl,
      'alt_text': instance.altText,
      'is_primary': instance.isPrimary,
      'order': instance.order,
    };

ProductAttribute _$ProductAttributeFromJson(Map<String, dynamic> json) =>
    ProductAttribute(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$ProductAttributeToJson(ProductAttribute instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'value': instance.value,
    };

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
      condition: json['condition'] as String,
      status: json['status'] as String,
      stockQuantity: (json['stock_quantity'] as num).toInt(),
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      color: json['color'] as String?,
      size: json['size'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      isFeatured: json['is_featured'] as bool? ?? false,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      sellerName: json['seller_name'] as String?,
      sellerUsername: json['seller_username'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      attributes: (json['attributes'] as List<dynamic>?)
          ?.map((e) => ProductAttribute.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'category': instance.category,
      'condition': instance.condition,
      'status': instance.status,
      'stock_quantity': instance.stockQuantity,
      'brand': instance.brand,
      'model': instance.model,
      'color': instance.color,
      'size': instance.size,
      'weight': instance.weight,
      'is_featured': instance.isFeatured,
      'views_count': instance.viewsCount,
      'seller_name': instance.sellerName,
      'seller_username': instance.sellerUsername,
      'images': instance.images,
      'attributes': instance.attributes,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

ProductListResponse _$ProductListResponseFromJson(Map<String, dynamic> json) =>
    ProductListResponse(
      count: (json['count'] as num).toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProductListResponseToJson(
        ProductListResponse instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results,
    };

CreateProductRequest _$CreateProductRequestFromJson(
        Map<String, dynamic> json) =>
    CreateProductRequest(
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      condition: json['condition'] as String,
      stockQuantity: (json['stock_quantity'] as num).toInt(),
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      color: json['color'] as String?,
      size: json['size'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      attributes: (json['attributes'] as List<dynamic>?)
          ?.map((e) => ProductAttribute.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreateProductRequestToJson(
        CreateProductRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'category_id': instance.categoryId,
      'condition': instance.condition,
      'stock_quantity': instance.stockQuantity,
      'brand': instance.brand,
      'model': instance.model,
      'color': instance.color,
      'size': instance.size,
      'weight': instance.weight,
      'images': instance.images,
      'attributes': instance.attributes,
    };

SellerStats _$SellerStatsFromJson(Map<String, dynamic> json) => SellerStats(
      totalProducts: (json['total_products'] as num).toInt(),
      activeProducts: (json['active_products'] as num).toInt(),
      inactiveProducts: (json['inactive_products'] as num).toInt(),
      soldProducts: (json['sold_products'] as num).toInt(),
      totalViews: (json['total_views'] as num).toInt(),
      outOfStock: (json['out_of_stock'] as num).toInt(),
    );

Map<String, dynamic> _$SellerStatsToJson(SellerStats instance) =>
    <String, dynamic>{
      'total_products': instance.totalProducts,
      'active_products': instance.activeProducts,
      'inactive_products': instance.inactiveProducts,
      'sold_products': instance.soldProducts,
      'total_views': instance.totalViews,
      'out_of_stock': instance.outOfStock,
    };
