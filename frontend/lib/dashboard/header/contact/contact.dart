import 'package:flutter/material.dart';
import '../header_bar.dart';
// import '../widgets/isi.dart' ;// Pastikan path ini sesuai dengan struktur proyek And
import 'contact_page.dart';
// import 'package:get/get.dart';

class ContactPage1 extends StatelessWidget {
  const ContactPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          const HeaderPages(),
          const ContactPage(),
          

          // Tambahkan bagian lainnya seperti Our Products di sini
          // const SizedBox(height: 40),
          // const SizedBox(height: 500), // Placeholder konten
        ],
      ),
    );
  }
}
