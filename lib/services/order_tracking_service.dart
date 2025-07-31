import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderTrackingService extends GetxService {
  final _supabase = Supabase.instance.client;

  Future<void> updateOrderStatusesAutomatically(String email) async {
    try {
      final now = DateTime.now();

      final response = await _supabase
          .from('order_history')
          .select()
          .eq('email', email);

      for (final row in response) {
        final timestampStr = row['timestamp'];
        final status = row['status'];
        final id = row['id']; // pastikan kolom ID ada di Supabase

        if (timestampStr == null || id == null) continue;

        final timestamp = DateTime.tryParse(timestampStr);
        if (timestamp == null) continue;

        final diff = now.difference(timestamp).inHours;

        String newStatus = status;

        if (diff >= 72) {
          newStatus = 'sampai';
        } else if (diff >= 48) {
          newStatus = 'dikirim';
        } else if (diff >= 24) {
          newStatus = 'diproses';
        } else {
          newStatus = 'menunggu konfirmasi';
        }

        // Update status jika berubah
        if (newStatus != status) {
          await _supabase.from('order_history').update({
            'status': newStatus,
            'updated_at': now.toIso8601String(),
          }).eq('id', id);

          print('✅ Order $id status updated to "$newStatus"');
        }
      }
    } catch (e) {
      print('❌ Gagal update status order otomatis: $e');
    }
  }
}
