import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileService {
  Future<Uint8List?> pickImage() async {
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

    return imageBytes;
  }

  bool validatePhoneNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    final regex = RegExp(r'^(?:\+628|08)[0-9]{8,13}$');
    return regex.hasMatch(cleaned);
  }
}