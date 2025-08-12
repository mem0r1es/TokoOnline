// File: pages/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/edit_profile_controller.dart';
import 'package:flutter_web/pages/account/EditProfil/edit_profile_page_ui.dart';
import 'package:get/get.dart';

class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final void Function(String) onNameChange;
  final void Function(String) onEmailChange;
  final void Function(String) onPhoneChange;

  const EditProfilePage({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhone,
    required this.onNameChange,
    required this.onEmailChange,
    required this.onPhoneChange,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final controller = Get.put(EditProfileController());

  @override
  void initState() {
    super.initState();
    controller.initialize(
      widget.initialName,
      widget.initialEmail,
      widget.initialPhone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
     appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Edit Profil',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Obx(() => controller.isChanged.value
            ? TextButton(
                onPressed: () async {
                  final changed = await controller.applyChanges(
                    widget.onNameChange,
                    widget.onEmailChange,
                    widget.onPhoneChange,
                  );

                  if (changed.isNotEmpty) {
                    Get.back(); // ✅ Kembali ke profil page
                    Get.snackbar(
                      "Berhasil",
                      "Data berhasil diperbarui: ${changed.join(', ')}",
                      duration: const Duration(seconds: 2),
                    );
                  } else {
                    Get.snackbar(
                      "Tidak ada perubahan",
                      "Tidak ada data yang diubah",
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
                child: const Text(
                  "Selesai",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : const SizedBox.shrink())
      ],
    ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: EditProfilePageUI.buildContent(context, controller, isMobile),
      ),
    );
  }
}
