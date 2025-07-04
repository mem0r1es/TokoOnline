import 'package:flutter/material.dart';
import '../header_bar.dart';
// import '../widgets/isi.dart' ;// Pastikan path ini sesuai dengan struktur proyek And
import 'our_product.dart';
// import 'package:get/get.dart';

class ShopsPage extends StatelessWidget {
  const ShopsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          const HeaderPages(),
          OurProduct(),
          

          // Tambahkan bagian lainnya seperti Our Products di sini
          // const SizedBox(height: 40),
          const SizedBox(height: 500), // Placeholder konten
        ],
      ),
    );
  }
}
