import 'package:flutter_web/models/cargo_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CargoService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<CargoModel>> fetchCargo() async {
    try {
      final response = await supabase
          .from('cargo_options') // Pastikan nama tabel benar
          .select('id, name, harga, kategori_id (id, kategori)');
      // Debug: Print data mentah dari Supabase
      print('Data dari Supabase: $response');

      return (response as List)
          .map((item) => CargoModel.fromDatabase(item))
          .toList();
    } catch (e) {
      print('Error saat fetch cargo: $e');
      throw Exception('Gagal mengambil data cargo: $e');
    }
  }
}

