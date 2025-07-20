import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  static Map<String, String> headersWithAuth(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Get seller's products with pagination and filters
  static Future<ProductListResponse> getSellerProducts({
    required String token,
    int page = 1,
    String search = '',
    String status = '',
    String categoryId = '',
    String ordering = '-created_at',
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      if (search.isNotEmpty) 'search': search,
      if (status.isNotEmpty) 'status': status,
      if (categoryId.isNotEmpty) 'category_id': categoryId,
      'ordering': ordering,
    };

    final uri = Uri.parse('$baseUrl/products/').replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: headersWithAuth(token),
    );

    if (response.statusCode == 200) {
      return ProductListResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load products: ${response.body}');
    }
  }

  // Get product details
  static Future<Product> getProduct({
    required String token,
    required String productId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId/'),
      headers: headersWithAuth(token),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product: ${response.body}');
    }
  }

  // Create new product
  static Future<Product> createProduct({
    required String token,
    required CreateProductRequest productData,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/'),
      headers: headersWithAuth(token),
      body: json.encode(productData.toJson()),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create product: ${response.body}');
    }
  }

  // Update product
  static Future<Product> updateProduct({
    required String token,
    required String productId,
    required CreateProductRequest productData,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$productId/'),
      headers: headersWithAuth(token),
      body: json.encode(productData.toJson()),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update product: ${response.body}');
    }
  }

  // Delete product
  static Future<void> deleteProduct({
    required String token,
    required String productId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$productId/'),
      headers: headersWithAuth(token),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete product: ${response.body}');
    }
  }

  // Toggle product status
  static Future<Product> toggleProductStatus({
    required String token,
    required String productId,
    required String newStatus,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/$productId/toggle-status/'),
      headers: headersWithAuth(token),
      body: json.encode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to toggle product status: ${response.body}');
    }
  }

  // Get categories
  static Future<List<Category>> getCategories({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/categories/'),
      headers: headersWithAuth(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.body}');
    }
  }

  // Get seller dashboard stats
  static Future<SellerStats> getSellerStats({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/seller/stats/'),
      headers: headersWithAuth(token),
    );

    if (response.statusCode == 200) {
      return SellerStats.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load seller stats: ${response.body}');
    }
  }
}