import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showEditProfileOptions({
  required BuildContext context,
  required Function(String) onNameChange,
  required Function(String) onEmailChange,
  required Function(String) onPhoneChange,
}) {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            Text("Edit Profil",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'No. Telepon'),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                onNameChange(nameController.text.trim());
                onEmailChange(emailController.text.trim());
                onPhoneChange(phoneController.text.trim());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text("Simpan"),
            ),
          ],
        ),
      );
    },
  );
}
