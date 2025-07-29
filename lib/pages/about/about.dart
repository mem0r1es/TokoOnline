import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/scroll_controller.dart';
import 'package:get/get.dart';
import '../../widgets/header_bar.dart';
// import '../widgets/isi.dart' ;// Pastikan path ini sesuai dengan struktur proyek And
import 'about_page.dart';
// import 'package:get/get.dart';

class AboutPage1 extends GetView<CustomScrollController> {
  static final String TAG = '/about';
  const AboutPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        controller: controller.scrollController,
        // key: PageStorageKey<String>('aboutpage'),
        children: [
          const HeaderPages(),
          const AboutPage(),
          

          // Tambahkan bagian lainnya seperti Our Products di sini
          // const SizedBox(height: 40),
          // const SizedBox(height: 500), // Placeholder konten
        ],
      ),
    );
  }
}
