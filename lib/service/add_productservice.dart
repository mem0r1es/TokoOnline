// Contoh di dalam fungsi untuk menambahkan produk ke database
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toko_online_getx/models/add_productmodel.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

final supabase = Supabase.instance.client;

class AddProductService extends GetxService {
  Future<String?> uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      print('❌ Tidak ada gambar yang dipilih');
      return null;
    }

    final String uuid = Uuid().v4();
    String fileExtension = extension(image.name);
    if (fileExtension.isEmpty) {
      fileExtension = '.jpg';
    }

    final String uploadPath = '$uuid$fileExtension';

    // Tentukan contentType
    String contentType = 'image/jpeg';
    if (fileExtension.toLowerCase() == '.png') {
      contentType = 'image/png';
    }

    try {
      final bytes = await image.readAsBytes();
      print('📤 Mengunggah gambar ke path: $uploadPath');
      print('📦 Content-Type: $contentType');
      print('📏 Ukuran file: ${bytes.lengthInBytes} bytes');

      final result = await supabase.storage
          .from('product-images')
          .uploadBinary(
            uploadPath,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      print('✅ Upload berhasil: $result');

      final String imageUrl =
          supabase.storage.from('product-images').getPublicUrl(uploadPath);
      print('🌐 Public URL: $imageUrl');
      return imageUrl;
    } catch (e, stacktrace) {
      print('❌ Error uploading image: $e');
      print('📚 Stacktrace:\n$stacktrace');
      print('📤 Path: $uploadPath');
      return null;
    }
  }

  Future<void> addProductToDatabase(AddProductmodel newProduct, {String? filePath}) async {
    print('🚀 Memulai proses tambah produk');

    if (newProduct.filePath == null || newProduct.filePath!.isEmpty) {
    print('❌ URL gambar tidak ditemukan, proses dibatalkan.');
    // Tampilkan pesan error ke pengguna
    Get.snackbar('Error', 'Please upload an image first.');
    return;
  }

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      print('❌ User belum login');
      return;
    }

    final Map<String, dynamic> data = {
      'name': newProduct.name,
      'image_url': newProduct.filePath,
      'description': newProduct.description,
      'price': newProduct.price,
      'category': newProduct.category,
      'stock_quantity': newProduct.stock,
      'is_active': newProduct.isActive,
      'seller_id': userId,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    print('📦 Data produk yang akan dikirim: $data');

    try {
      final response = await supabase.from('products').insert(data);
      print('✅ Produk berhasil ditambahkan');
    } catch (e, stacktrace) {
      print('❌ Gagal menambahkan produk: $e');
      print('📚 Stacktrace:\n$stacktrace');
    }
  }
}
