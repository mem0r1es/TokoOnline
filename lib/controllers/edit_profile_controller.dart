import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

class EditProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();
  
  final isEditingName = false.obs;
  final isEditingEmail = false.obs;
  final isEditingPhone = false.obs;
  final isChanged = false.obs;
  
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  
  var currentName = ''.obs;
  var currentEmail = ''.obs;
  var currentPhone = ''.obs;
  
  String? phoneError;
  Uint8List? tempImageBytes;
  bool removeImage = false;
  
  @override
  void onInit() {
    super.onInit();
    // Initialize with passed values
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      currentName.value = args['initialName'] ?? '';
      currentEmail.value = args['initialEmail'] ?? '';
      currentPhone.value = args['initialPhone'] ?? '';
    }
  }

  Future<void> pickImageTemporarily() async {
    final imageBytes = await _profileService.pickImage();
    if (imageBytes != null) {
      tempImageBytes = imageBytes;
      removeImage = false;
      isChanged.value = true;
    } else {
      Get.snackbar('Batal', 'Tidak ada gambar yang dipilih', 
          duration: const Duration(seconds: 2));
    }
  }

  void validatePhone(String value) {
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length < 12) {
      phoneError = 'Nomor minimal 12 digit';
    } else if (!_profileService.validatePhoneNumber(cleaned)) {
      phoneError = 'Masukkan angka yang benar';
    } else {
      phoneError = null;
    }
  }

  Future<bool> onWillPop() async {
    if (isChanged.value) {
      bool? result = await Get.dialog(
        AlertDialog(
          title: const Text("Keluar tanpa menyimpan?"),
          content: const Text("Perubahan yang belum disimpan akan hilang."),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false), 
              child: const Text("Lanjut Edit")
            ),
            TextButton(
              onPressed: () => Get.back(result: true), 
              child: const Text("Keluar")
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}