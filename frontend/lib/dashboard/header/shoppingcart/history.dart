import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import '../header_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          const HeaderPages(),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order History",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                // Placeholder for order history items
                Center(
                  child: Text("No order history yet.",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}