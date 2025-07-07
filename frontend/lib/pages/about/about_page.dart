import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(24.0),
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.storefront, size: 60, color: Color.fromARGB(255, 176, 140, 92)),
            SizedBox(height: 20),
            Text(
              "Tentang Toko Online Kami",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              "Kami adalah toko online terpercaya yang menyediakan berbagai produk berkualitas dengan harga terjangkau. "
              "Didirikan sejak 2025, kami berkomitmen untuk memberikan layanan terbaik kepada pelanggan di seluruh Indonesia.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
  }
}
