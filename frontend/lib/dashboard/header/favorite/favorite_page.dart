import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/page_controller.dart';
import '../widgets/product_model.dart';
import 'header_bar.dart';
// import 'package:google_fonts/google_fonts.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final favC = Get.find<FavoriteController>();
    final cartC = Get.find<CartController1>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const HeaderPages(),
          const SizedBox(height: 20),
          Obx(() {
            final favorites = favC.favorites;
            if (favorites.isEmpty) {
              return Center(
                child: Text(
                  'No favorites yet.',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                children: favorites
                    .map((product) => _productCard(product, favC, cartC))
                    .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _productCard(Product product, FavoriteController favC, CartController1 cartC) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 20),
      child: Card(
        elevation: 3,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                product.imagePath,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    product.title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      IconButton(
                        icon: Icon(
                          favC.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          favC.toggleFavorite(product);
                          Get.snackbar("Info", favC.isFavorite(product)
                              ? "${product.title} ditambahkan ke favorit"
                              : "${product.title} dihapus dari favorit");
                        },
                      ),
                    ],
                  ),
                  Text(
                    'Rp ${_rupiah(product.price)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _rupiah(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
