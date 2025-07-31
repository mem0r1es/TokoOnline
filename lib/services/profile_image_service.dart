import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileImageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> uploadProfileImage(Uint8List imageBytes, String filename) async {
    final String? userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Pengguna belum login');

    try {
      await _supabase.storage
          .from('profile-image')
          .remove(['$userId/$filename']);

      await _supabase.storage
          .from('profile-image')
          .uploadBinary(
            '$userId/$filename',
            imageBytes,
            fileOptions: const FileOptions(upsert: true),
          );
    } catch (e) {
      if (kDebugMode) print('Error upload gambar: $e');
      rethrow;
    }
  }

  Future<String?> getProfileImageUrl() async {
    final String? userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final String publicUrl = _supabase.storage
          .from('profile-image')
          .getPublicUrl('$userId/profile.jpg');

      // Tambahkan timestamp agar tidak cache
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      return '$publicUrl?t=$timestamp';
    } catch (e) {
      if (kDebugMode) print('Error mendapatkan URL gambar: $e');
      return null;
    }
  }
}
