import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/product_model.dart';
import '../controllers/page_controller.dart';
import 'package:get/get.dart';

class SearchResultPage extends StatelessWidget {
  final String query;

  SearchResultPage({super.key, required this.query});

  final cartC = Get.put(CartController1());
  final favC = Get.put(FavoriteController());

  final List<Product> allProducts = [
    Product(
      title: 'Syltherine',
      imagePath: 'assets/product1.png',
      description: 'Stylish cafe chair',
      price: 2500000,
    ),
    Product(
      title: 'Product 2',
      imagePath: 'assets/product2.png',
      description: 'Elegant dining table',
      price: 3000000,
    ),
    Product(
      title: 'Product 3',
      imagePath: 'assets/product3.png',
      description: 'Comfortable sofa',
      price: 4500000,
    ),
    Product(
      title: 'Product 4',
      imagePath: 'assets/product4.png',
      description: 'Modern bookshelf',
      price: 1800000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final results = allProducts.where((p) =>
      p.title.toLowerCase().contains(query.toLowerCase()) ||
      p.description.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results', style: GoogleFonts.poppins()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: results.isEmpty
            ? Center(
                child: Text(
                  'No products found for "$query"',
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
              )
            : Wrap(
                spacing: 20,
                runSpacing: 20,
                children: results.map((product) => _productCard(product)).toList(),
              ),
      ),
    );
  }

  Widget _productCard(Product product) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 4,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(product.imagePath, width: 150, height: 150, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(product.title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(product.description, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        onPressed: () {
                          cartC.addToCart(product);
                          Get.snackbar("Berhasil", "${product.title} ditambahkan ke keranjang");
                        },
                      ),
                      Obx(() => IconButton(
                        icon: Icon(
                          favC.isFavorite(product)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          favC.toggleFavorite(product);
                          Get.snackbar("Info", favC.isFavorite(product)
                              ? "${product.title} ditambahkan ke favorit"
                              : "${product.title} dihapus dari favorit");
                        },
                      )),
                    ],
                  ),
                  Text('Rp ${_rupiah(product.price)}', style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _rupiah(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
