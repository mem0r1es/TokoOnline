import 'package:flutter/material.dart';
import '../header_bar.dart';
// import '../widgets/isi.dart' ;// Pastikan path ini sesuai dengan struktur proyek And
import 'about_page.dart';
// import 'package:get/get.dart';

class AboutPage1 extends StatelessWidget {
  const AboutPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
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
