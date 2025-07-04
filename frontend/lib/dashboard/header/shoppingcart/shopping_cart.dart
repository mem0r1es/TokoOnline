import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import '../controllers/page_controller.dart';
import '../header_bar.dart';
import 'cart.dart';

class ShoppingCart extends StatelessWidget {
  const ShoppingCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(title: Text('shopping cart')),
      body: ListView(
        children: [
          const HeaderPages(),
          CartPages(), // Ganti dengan widget Cart yang sesuai
          // const OurProduct(),
          

          // Tambahkan bagian lainnya seperti Our Products di sini
          // const SizedBox(height: 40),
          const SizedBox(height: 500), // Placeholder konten
        ],
      ),
    );
  }
}
