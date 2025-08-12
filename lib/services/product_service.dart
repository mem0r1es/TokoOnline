import '../models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  Future<List<Product>> fetchProducts() async {

    final response = await supabase
    .from('product_with_seller')
    .select()
    .eq('is_active', true)
    .order('created_at', ascending: false);

    return response.map((data) => Product.fromDatabase(data)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await supabase
        .from('products')
        .select('*, seller_id (id, store_name)')
        .eq('is_active', true)
        .or(
          'name.ilike.%$query%,description.ilike.%$query%',
        )
        .order('name');

    return response.map((data) => Product.fromDatabase(data)).toList();
  }

  Future<void> testConnection() async {
    await supabase.from('products').select('count').limit(1);
  }

  Future<void> updateProductStock(String productId, int newStock) async {
    try {
      await supabase
          .from('products')
          .update({'stock_quantity': newStock})
          .eq('id', productId);

      print('Stock updated in Supabase for product $productId to $newStock');
    } catch (e) {
      print('Failed to update stock: $e');
    }
  }

}