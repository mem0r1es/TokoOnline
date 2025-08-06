import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/edit_profile_controller.dart';
import 'package:flutter_web/controllers/profile_image_controller.dart';
import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePageUI {
  static Widget buildContent(BuildContext context, EditProfileController controller, bool isMobile) {
    final imageController = Get.find<ProfileImageController>();

    return Obx(() {
      final hasTempImage = controller.tempImageBytes != null;
      final hasNetworkImage = imageController.profileImageUrl.value.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileImageSection(
            controller: controller,
            imageController: imageController,
            hasTempImage: hasTempImage,
            hasNetworkImage: hasNetworkImage,
            isMobile: isMobile,
          ),
          const SizedBox(height: 24),

          _EditTile(
            icon: Icons.person,
            label: "Ubah Nama",
            value: controller.currentName.value,
            onTap: controller.startEditingName,
            isMobile: isMobile,
          ),
          if (controller.isEditingName.value)
            _EditField(
              label: "Nama Baru",
              controller: controller.nameController,
              onSave: controller.saveEditedName,
              onCancel: controller.cancelEditingName,
            ),

          _EditTile(
            icon: Icons.email,
            label: "Ubah Email",
            value: controller.currentEmail.value,
            onTap: controller.startEditingEmail,
            isMobile: isMobile,
          ),
          if (controller.isEditingEmail.value)
            _EditField(
              label: "Email Baru",
              controller: controller.emailController,
              onSave: controller.saveEditedEmail,
              onCancel: controller.cancelEditingEmail,
            ),

          _EditTile(
            icon: Icons.phone,
            label: "Ubah Nomor HP",
            value: controller.currentPhone.value,
            onTap: controller.startEditingPhone,
            isMobile: isMobile,
          ),
          if (controller.isEditingPhone.value)
            _EditField(
              label: "Nomor HP Baru",
              controller: controller.phoneController,
              onSave: controller.saveEditedPhone,
              onCancel: controller.cancelEditingPhone,
              errorText: controller.phoneError.value,
            ),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: TextButton.icon(
              onPressed: () => _showPasswordChangeDialog(context),
              icon: const Icon(Icons.lock_reset, size: 18),
              label: Text(
                "Ganti Kata Sandi",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      );
    });
  }

  static void _showPasswordChangeDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final obscureOld = true.obs;
    final obscureNew = true.obs;
    final obscureConfirm = true.obs;

    Get.dialog(
      AlertDialog(
        title: const Text("Ganti Kata Sandi"),
        content: Obx(() => SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: obscureOld.value,
                    decoration: InputDecoration(
                      labelText: "Kata sandi lama",
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureOld.value ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => obscureOld.toggle(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNew.value,
                    decoration: InputDecoration(
                      labelText: "Kata sandi baru",
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew.value ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => obscureNew.toggle(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm.value,
                    decoration: InputDecoration(
                      labelText: "Konfirmasi kata sandi",
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm.value ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => obscureConfirm.toggle(),
                      ),
                    ),
                  ),
                ],
              ),
            )),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final oldPass = oldPasswordController.text.trim();
              final newPass = newPasswordController.text.trim();
              final confirmPass = confirmPasswordController.text.trim();

              if (newPass != confirmPass) {
                Get.snackbar("Error", "Konfirmasi kata sandi tidak cocok");
                return;
              }

              if (newPass.length < 6) {
                Get.snackbar("Error", "Kata sandi minimal 6 karakter");
                return;
              }

              try {
                await Get.find<AuthController>().changePassword(oldPass, newPass);
                Get.back();
                Get.snackbar("Berhasil", "Kata sandi berhasil diubah");
              } catch (e) {
                Get.snackbar("Error", "Gagal mengubah kata sandi");
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}

class _ProfileImageSection extends StatelessWidget {
  final EditProfileController controller;
  final ProfileImageController imageController;
  final bool hasTempImage;
  final bool hasNetworkImage;
  final bool isMobile;

  const _ProfileImageSection({
    required this.controller,
    required this.imageController,
    required this.hasTempImage,
    required this.hasNetworkImage,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageController.isLoading.value
                ? const CircularProgressIndicator()
                : CircleAvatar(
                    radius: isMobile ? 50 : 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: hasTempImage
                        ? MemoryImage(controller.tempImageBytes!)
                        : (hasNetworkImage
                            ? NetworkImage(imageController.profileImageUrl.value)
                            : null) as ImageProvider?,
                    child: (!hasTempImage && !hasNetworkImage)
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: controller.pickImageTemporarily,
              icon: const Icon(Icons.edit, size: 18, color: Colors.green),
              label: Text(
                (!hasTempImage && !hasNetworkImage) ? "Tambah Foto" : "Ubah Foto",
                style: GoogleFonts.montserrat(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(width: 8),
            if (hasTempImage || hasNetworkImage)
              OutlinedButton.icon(
                onPressed: () => _showDeleteConfirmation(context, controller),
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                label: Text(
                  "Hapus Foto",
                  style: GoogleFonts.montserrat(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, EditProfileController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Hapus Foto"),
        content: const Text("Apakah Anda yakin ingin menghapus foto profil?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.removeImage();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}

class _EditTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isMobile;

  const _EditTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.montserrat(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 16),
              Expanded(
                child: Text(label, style: GoogleFonts.montserrat(fontSize: 16)),
              ),
              const SizedBox(width: 16),
              Flexible(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String? errorText;

  const _EditField({
    required this.label,
    required this.controller,
    required this.onSave,
    required this.onCancel,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            errorText: errorText,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            TextButton(onPressed: onCancel, child: const Text("Batal")),
            ElevatedButton(onPressed: onSave, child: const Text("Simpan")),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
