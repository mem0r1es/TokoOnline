import '../models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// final List<Product> staticProducts = [
//     Product(
//       id: 'static-1',
//       title: 'Syltherine',
//       imagePath: 'assets/product1.png',
//       description: 'Stylish cafe chair',
//       price: 2500000,
//       category: 'furniture',
//       stock: 50,
//       storeName: 'Toko Perabot', 
//       sellerId: '00000'
//     ),
//     Product(
//       id: 'static-2',
//       title: 'Product 2',
//       imagePath: 'assets/product2.png',
//       description: 'Elegant dining table',
//       price: 3000000,
//       category: 'furniture',
//       stock: 25,
//       storeName: 'Toko Perabot', 
//       sellerId: '00000'
//     ),
//     Product(
//       id: 'static-3',
//       title: 'Product 3',
//       imagePath: 'assets/product3.png',
//       description: 'Comfortable sofa',
//       price: 4500000,
//       category: 'furniture',
//       stock: 15,
//       storeName: 'Toko Perabot', 
//       sellerId: '00000'
//     ),
//     Product(
//       id: 'static-4',
//       title: 'Product 4',
//       imagePath: 'assets/product4.png',
//       description: 'Modern bookshelf',
//       price: 1800000,
//       category: 'furniture',
//       stock: 30,
//       storeName: 'Toko Perabot', 
//       sellerId: '00000'
//     ),
//   ];

class ProductService {
  final supabase = Supabase.instance.client;

  Future<List<Product>> fetchProducts() async {
    // final response = await supabase
    //     .from('products')
    //     .select('*, seller_id (id, store_name)')
    //     .eq('is_active', true)
    //     .order('created_at', ascending: false);

    // return response.map((data) => Product.fromDatabase(data)).toList();
    final response = await supabase
    .from('product_with_seller')
    .select()
    .eq('is_active', true)
    .order('created_at', ascending: false);

return response.map((data) => Product.fromDatabase(data)).toList();
// return products

  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await supabase
        .from('product_with_seller')
        .select('*, seller_id (id, store_name)')
        .eq('is_active', true)
        .or(
          'name.ilike.%$query%,description.ilike.%$query%',
        )
        .order('name');

    return response.map((data) => Product.fromDatabase(data)).toList();
  }

  // Future<void> migrateStaticProductsToDatabase() async {
  //   final existingProducts = await supabase
  //       .from('products')
  //       .select('name')
  //       .eq('is_active', true);

  //   if (existingProducts.isEmpty) {
  //     final productsToInsert = staticProducts.map((p) => p.toDatabase()).toList();
  //     await supabase.from('products').insert(productsToInsert);
  //   }
  // }

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