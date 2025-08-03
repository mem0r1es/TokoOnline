import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web/controllers/profile_image_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static const String route = '/edit-profile';

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final isEditingName = false.obs;
  final isEditingEmail = false.obs;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final isChanged = false.obs;

  late RxString currentName;
  late RxString currentEmail;
  late RxString currentPhone;

  final imageController = Get.find<ProfileImageController>();
  Uint8List? _tempImageBytes;
  bool _removeImage = false;

  @override
  void initState() {
    super.initState();
    currentName = widget.initialName.obs;
    currentEmail = widget.initialEmail.obs;
    currentPhone = widget.initialPhone.obs;
  }

  Future<bool> _onWillPop() async {
    if (isChanged.value) {
      bool? result = await Get.dialog(
        AlertDialog(
          title: const Text("Keluar tanpa menyimpan?"),
          content: const Text("Perubahan yang belum disimpan akan hilang."),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: const Text("Lanjut Edit")),
            TextButton(onPressed: () => Get.back(result: true), child: const Text("Keluar")),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  Future<void> pickImageTemporarily() async {
    Uint8List? imageBytes;

    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result != null && result.files.first.bytes != null) {
        imageBytes = result.files.first.bytes!;
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        imageBytes = await pickedFile.readAsBytes();
      }
    }

    if (imageBytes != null) {
      setState(() {
        _tempImageBytes = imageBytes;
        _removeImage = false;
        isChanged.value = true;
      });
    } else {
      Get.snackbar('Batal', 'Tidak ada gambar yang dipilih', duration: const Duration(seconds: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () async {
              if (await _onWillPop()) Get.back();
            },
          ),
          title: Text("Edit Profil", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.black87)),
          centerTitle: true,
          actions: [
            Obx(() => isChanged.value
                ? TextButton(
                    onPressed: () async {
                      final result = await Get.dialog<bool>(
                        AlertDialog(
                          title: const Text("Simpan Perubahan?"),
                          content: const Text("Perubahan profil akan disimpan."),
                          actions: [
                            TextButton(onPressed: () => Get.back(result: false), child: const Text("Batal")),
                            TextButton(onPressed: () => Get.back(result: true), child: const Text("OK")),
                          ],
                        ),
                      );

                      if (result == true) {
                        final changes = <String>[];

                        if (currentName.value != widget.initialName) {
                          widget.onNameChange(currentName.value);
                          changes.add("nama");
                        }
                        if (currentEmail.value != widget.initialEmail) {
                          widget.onEmailChange(currentEmail.value);
                          changes.add("email");
                        }
                        if (currentPhone.value != widget.initialPhone) {
                          widget.onPhoneChange(currentPhone.value);
                          changes.add("nomor HP");
                        }

                        if (_tempImageBytes != null) {
                          await imageController.updateProfileImage(_tempImageBytes!);
                          changes.add("foto profil");
                        } else if (_removeImage) {
                          await imageController.removeImage();
                          changes.add("foto profil");
                        }

                        if (changes.isNotEmpty) {
                          Get.snackbar("Berhasil", "Berhasil mengubah ${changes.join(', ')}",
                              backgroundColor: Colors.green, colorText: Colors.white);
                        }

                        await Future.delayed(const Duration(milliseconds: 500));
                        Get.offNamed('/profile');
                      }
                    },
                    child: Text("Selesai", style: GoogleFonts.montserrat(color: Colors.green, fontWeight: FontWeight.bold)),
                  )
                : const SizedBox.shrink())
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Obx(() => _buildContent(context, isMobile)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isMobile) {
    final hasTempImage = _tempImageBytes != null;
    final hasNetworkImage = imageController.profileImageUrl.value.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Foto profil
        GestureDetector(
          onTap: () {
            if (!hasTempImage && !hasNetworkImage) {
              pickImageTemporarily();
            } else {
              Get.bottomSheet(
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_camera),
                        title: const Text('Ubah Foto'),
                        onTap: () {
                          Get.back();
                          pickImageTemporarily();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete),
                        title: const Text('Hapus Foto'),
                        onTap: () {
                          Get.back();
                          setState(() {
                            _tempImageBytes = null;
                            _removeImage = true;
                            imageController.profileImageUrl.value = '';
                            isChanged.value = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          },
          child: Column(
            children: [
              imageController.isLoading.value
                  ? const CircularProgressIndicator()
                  : CircleAvatar(
                      radius: isMobile ? 50 : 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: hasTempImage
                          ? MemoryImage(_tempImageBytes!)
                          : (hasNetworkImage ? NetworkImage(imageController.profileImageUrl.value) : null),
                      child: (!hasTempImage && !hasNetworkImage)
                          ? const Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                    ),
              const SizedBox(height: 8),
              Text(
                (!hasTempImage && !hasNetworkImage) ? "Tambah Foto Profil" : "Ubah / Hapus Foto",
                style: GoogleFonts.montserrat(
                  color: Colors.blueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Ubah Nama
        _buildListTile(
          icon: Icons.person,
          label: "Ubah Nama",
          value: currentName.value,
          onTap: () {
            isEditingName.value = true;
            nameController.text = currentName.value;
          },
          isMobile: isMobile,
        ),

        if (isEditingName.value)
          _buildEditField("Nama Baru", nameController, () {
            final value = nameController.text.trim();
            if (value.isNotEmpty) {
              currentName.value = value;
              isEditingName.value = false;
              nameController.clear();
              isChanged.value = true;
            } else {
              Get.snackbar("Error", "Nama tidak boleh kosong");
            }
          }, () {
            isEditingName.value = false;
            nameController.clear();
          }),

        // Ubah Email
        _buildListTile(
          icon: Icons.email,
          label: "Ubah Email",
          value: currentEmail.value,
          onTap: () {
            isEditingEmail.value = true;
            emailController.text = currentEmail.value;
          },
          isMobile: isMobile,
        ),

        if (isEditingEmail.value)
          _buildEditField("Email Baru", emailController, () {
            final value = emailController.text.trim();
            if (value.isNotEmpty) {
              currentEmail.value = value;
              isEditingEmail.value = false;
              emailController.clear();
              isChanged.value = true;
            } else {
              Get.snackbar("Error", "Email tidak boleh kosong");
            }
          }, () {
            isEditingEmail.value = false;
            emailController.clear();
          }),

        // Nomor HP
        _buildListTile(
          icon: Icons.phone,
          label: "Ubah Nomor HP",
          value: currentPhone.value,
          onTap: () {
            Get.snackbar('Coming Soon', 'Fitur ganti nomor HP akan tersedia di versi selanjutnya');
            isChanged.value = true;
          },
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
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

  Widget _buildEditField(String label, TextEditingController controller, VoidCallback onSave, VoidCallback onCancel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(controller: controller, decoration: const InputDecoration(border: OutlineInputBorder())),
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
