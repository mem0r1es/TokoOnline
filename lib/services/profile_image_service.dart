import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileImageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  final String _bucketName = 'profile-image';
  final String _fileName = 'profile.jpg';

  /// Upload dan replace foto profil ke Supabase Storage
  Future<void> uploadProfileImage(Uint8List imageBytes, String filename) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Pengguna belum login');

    final path = '${user.id}/$_fileName';

    try {
      // Hapus file lama jika ada
      await _supabase.storage.from(_bucketName).remove([path]);

      // Upload file baru
      await _supabase.storage.from(_bucketName).uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(upsert: true),
          );
    } catch (e) {
      if (kDebugMode) print('Error upload gambar: $e');
      rethrow;
    }
  }

  /// Hapus foto profil dari Supabase Storage
  Future<void> deleteProfileImage() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Pengguna belum login");

    final path = '${user.id}/$_fileName';

    try {
      await _supabase.storage.from(_bucketName).remove([path]);
    } catch (e) {
      throw Exception("Gagal menghapus gambar: $e");
    }
  }

  /// Ambil URL publik gambar profil dari Supabase
  Future<String?> getProfileImageUrl() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final path = '${user.id}/$_fileName';

    try {
      final publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(path);

      // Tambahkan timestamp untuk mencegah cache browser
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '$publicUrl?t=$timestamp';
    } catch (e) {
      if (kDebugMode) print('Error mendapatkan URL gambar: $e');
      return null;
    }
  }
}
