import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/shops_scroll.dart';
import 'package:get/get.dart';
import '../../widgets/header_bar.dart';
// import '../widgets/isi.dart' ;// Pastikan path ini sesuai dengan struktur proyek And
import 'our_product.dart';
// import 'package:get/get.dart';

class ShopsPage extends GetView<ShopsScrollController> {
  static final String TAG = '/shop';
  const ShopsPage({super.key});
  // final scrollController = Get.find<CustomScrollController>().getController('unique_scroll_key');


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        controller: controller.scrollController,
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
