import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Hubungi Kami",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            contactItem(Icons.email, "contact@tokoonline.com"),
            const SizedBox(height: 12),
            contactItem(Icons.phone, "0812 3456 789"),
            const SizedBox(height: 12),
            contactItem(Icons.location_on, "Jl. Toko Online No. 123"),
          ],
        ),
      );
  }

  Widget contactItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Color.fromARGB(255, 176, 140, 92)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
