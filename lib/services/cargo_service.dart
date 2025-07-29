
import 'package:flutter_web/models/cargo_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CargoService {
  final supabase = Supabase.instance.client;

  Future<List<CargoModel>> fetchCargo() async {
    final response = await supabase
        .from('cargo_options')
        .select('id, name, kategori_id(id, kategori)');

    return (response as List)
        .map((data) => CargoModel.fromDatabase(data))
        .toList();
  }
}
