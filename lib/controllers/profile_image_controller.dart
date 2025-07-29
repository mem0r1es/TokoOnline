import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_web/services/profile_image_service.dart';

class ProfileImageController extends GetxController {
  final ProfileImageService _service = ProfileImageService();

  final RxString profileImageUrl = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileImage();
  }

  Future<void> loadProfileImage() async {
    isLoading.value = true;
    try {
      final url = await _service.getProfileImageUrl();
      if (url != null) profileImageUrl.value = url;
    } catch (e) {
      if (Get.isSnackbarOpen) Get.closeAllSnackbars();
      Get.snackbar('Error', 'Gagal memuat foto profil');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfileImage(Uint8List imageBytes) async {
    isLoading.value = true;
    try {
      await _service.uploadProfileImage(imageBytes, 'profile.jpg');
      final newUrl = await _service.getProfileImageUrl();
      if (newUrl != null) {
        profileImageUrl.value = newUrl;
        Get.snackbar('Berhasil', 'Foto profil berhasil diperbarui',
            duration: const Duration(seconds: 2));
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengubah foto profil',
          duration: const Duration(seconds: 2));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImageAndUpload() async {
    Uint8List? imageBytes;

    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
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
      await updateProfileImage(imageBytes);
    } else {
      Get.snackbar('Batal', 'Tidak ada gambar yang dipilih',
          duration: const Duration(seconds: 2));
    }
  }
}
