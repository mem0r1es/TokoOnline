import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


void showEditProfileOptions({
  required BuildContext context,
  required void Function(String) onNameChange,
  required void Function(String) onEmailChange,
  required void Function(String) onPhoneChange,
}) {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Edit Profil", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(height: 20),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Ubah Nama"),
            onTap: () {
              Get.back();
              _editFieldDialog(
                title: "Ubah Nama",
                hint: "Nama Baru",
                onConfirm: onNameChange,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text("Ubah Email"),
            onTap: () {
              Get.back();
              _editFieldDialog(
                title: "Ubah Email",
                hint: "Email Baru",
                onConfirm: onEmailChange,
              );
            },
          ),
        ListTile(
          leading: const Icon(Icons.phone),
          title: const Text("Ubah Nomor HP"),
          onTap: () {
            Get.back(); // Tutup bottom sheet
            Get.snackbar('Coming Soon', 'Fitur ganti nomor HP akan tersedia di versi selanjutnya');
          },
        ),

        ],
      ),
    ),
  );
}

void _editFieldDialog({
  required String title,
  required String hint,
  required void Function(String) onConfirm,
}) {
  final TextEditingController inputController = TextEditingController();

  Get.dialog(
    AlertDialog(
      title: Text(title),
      content: TextField(
        controller: inputController,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
        ElevatedButton(
          onPressed: () {
            final value = inputController.text.trim();
            if (value.isNotEmpty) {
              onConfirm(value);
              Get.back();
            } else {
              Get.snackbar("Error", "Input tidak boleh kosong");
            }
          },
          child: const Text("Simpan"),
        )
      ],
    ),
  );
}
