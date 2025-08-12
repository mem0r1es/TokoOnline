import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_web/controllers/profile_image_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_web/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileController extends GetxController {
  final isChanged = false.obs;
  final isEditingName = false.obs;
  final isEditingEmail = false.obs;
  final isEditingPhone = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordLamaController = TextEditingController(); // 🔒 Password lama


  late RxString currentName;
  late RxString currentEmail;
  late RxString currentPhone;

  late String initialName;
  late String initialEmail;
  late String initialPhone;

  final RxnString phoneError = RxnString();

  Uint8List? tempImageBytes;
  bool removeImageFlag = false;

  // 🔒 Tambahan untuk ubah password
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxnString passwordError = RxnString();

  void initialize(String name, String email, String phone) {
    initialName = name;
    initialEmail = email;
    initialPhone = phone;

    currentName = name.obs;
    currentEmail = email.obs;
    currentPhone = phone.obs;
  }

  void startEditingName() {
    isEditingName.value = true;
    nameController.text = currentName.value;
  }

  void cancelEditingName() {
    isEditingName.value = false;
    nameController.clear();
  }

  void saveEditedName() {
    final value = nameController.text.trim();
    if (value.isNotEmpty) {
      currentName.value = value;
      isEditingName.value = false;
      nameController.clear();
      isChanged.value = true;
    } else {
      Get.snackbar("Error", "Nama tidak boleh kosong");
    }
  }

  void startEditingEmail() {
    isEditingEmail.value = true;
    emailController.text = currentEmail.value;
  }

  void cancelEditingEmail() {
    isEditingEmail.value = false;
    emailController.clear();
  }

  void saveEditedEmail() {
    final value = emailController.text.trim();
    if (value.isNotEmpty) {
      currentEmail.value = value;
      isEditingEmail.value = false;
      emailController.clear();
      isChanged.value = true;
    } else {
      Get.snackbar("Error", "Email tidak boleh kosong");
    }
  }

  void startEditingPhone() {
    isEditingPhone.value = true;
    phoneController.text = currentPhone.value;
  }

  void cancelEditingPhone() {
    isEditingPhone.value = false;
    phoneController.clear();
    phoneError.value = null;
  }

  bool validatePhoneNumber(String value) {
    final trimmed = value.trim();
    final pattern = r'^(\+62|08)[0-9]{9,13}$';
    final regex = RegExp(pattern);
    return regex.hasMatch(trimmed);
  }

  void saveEditedPhone() async {
    final value = phoneController.text.trim();

    if (!validatePhoneNumber(value)) {
      phoneError.value = "Nomor HP tidak valid. Gunakan format 08 atau +62, 12–15 digit.";
      return;
    }

    try {
      phoneError.value = null;
      final authController = Get.find<AuthController>();
      await authController.updatePhone(value);

      currentPhone.value = value;
      isEditingPhone.value = false;
      phoneController.clear();
      isChanged.value = true;
    } catch (e) {
      Get.snackbar("Error", "Gagal memperbarui nomor HP");
    }
  }

  Future<void> pickImageTemporarily() async {
    Uint8List? imageBytes;

    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.first.bytes != null) {
        imageBytes = result.files.first.bytes;
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        imageBytes = await pickedFile.readAsBytes();
      }
    }

    if (imageBytes != null) {
      tempImageBytes = imageBytes;
      removeImageFlag = false;
      isChanged.value = true;
    } else {
      Get.snackbar(
        'Batal',
        'Tidak ada gambar yang dipilih',
        duration: const Duration(seconds: 2),
      );
    }
  }

  void removeImage() {
    tempImageBytes = null;
    removeImageFlag = true;
    final imageController = Get.find<ProfileImageController>();
    imageController.profileImageUrl.value = '';
    isChanged.value = true;
  }

  Future<List<String>> applyChanges(
    void Function(String) onNameChange,
    void Function(String) onEmailChange,
    void Function(String) onPhoneChange,
  ) async {
    final imageController = Get.find<ProfileImageController>();
    final changes = <String>[];

    if (currentName.value != initialName) {
      onNameChange(currentName.value);
      changes.add("nama");
    }

    if (currentEmail.value != initialEmail) {
      onEmailChange(currentEmail.value);
      changes.add("email");
    }

    if (currentPhone.value != initialPhone) {
      onPhoneChange(currentPhone.value);
      changes.add("nomor HP");
    }

    if (tempImageBytes != null) {
      await imageController.updateProfileImage(tempImageBytes!);
      changes.add("foto profil");
    } else if (removeImageFlag) {
      await imageController.removeImage();
      changes.add("foto profil");
    }

    // ✅ Reset flag
    initialName = currentName.value;
    initialEmail = currentEmail.value;
    initialPhone = currentPhone.value;
    tempImageBytes = null;
    removeImageFlag = false;
    isChanged.value = false;

    return changes;
  }

  // 🔒 Fungsi untuk mengganti kata sandi
Future<bool> changePassword() async {
  final oldPassword = passwordLamaController.text.trim();
  final newPassword = passwordController.text.trim();
  final confirm = confirmPasswordController.text.trim();

  passwordError.value = null;

  if (oldPassword.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
    passwordError.value = "Semua kolom harus diisi.";
    return false;
  }

  if (newPassword == oldPassword) {
    passwordError.value = "Password baru tidak boleh sama dengan yang lama.";
    return false;
  }

  if (newPassword.length < 6) {
    passwordError.value = "Password baru minimal 6 karakter.";
    return false;
  }

  if (newPassword != confirm) {
    passwordError.value = "Konfirmasi password tidak cocok.";
    return false;
  }

  try {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    if (user == null || user.email == null) {
      passwordError.value = "Sesi pengguna tidak ditemukan.";
      return false;
    }

    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: user.email!,
      password: oldPassword,
    );

    if (response.user == null) {
      passwordError.value = "Password lama salah.";
      return false;
    }

    await authController.updatePassword(newPassword);

    passwordLamaController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    Get.snackbar("Berhasil", "Kata sandi berhasil diperbarui");

    return true;
  } catch (e) {
    passwordError.value = "Gagal mengganti kata sandi.";
    Get.snackbar("Error", e.toString().replaceFirst("Exception: ", ""));
    return false;
  }
}
}
