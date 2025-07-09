import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/info_user.dart';

class AddressService {
  final supabase = Supabase.instance.client;
  

  // Menyimpan alamat baru
  Future<void> saveAddress(InfoUser address) async {
    final user = supabase.auth.currentUser;
    final userEmail = user?.email ?? '';

    final addressData = {
      'full_name': address.fullName,
      'email': userEmail,  // biar pasti nyambung ke akun yang login
      'phone': address.phone,
      'address': address.address,
      'is_active': true,
      // 'created_at': DateTime.now().toIso8601String(),
    };

    try {
    if (address.id != null) {
      // UPDATE
      await supabase
          .from('addresses')
          .update(addressData)
          .eq('id', address.id!);  // pastikan 'id' adalah UUID dan tidak null
        print('Address updated: ${address.id}');
      } else {
        // INSERT
        await supabase.from('addresses').insert(addressData);
        print('Address inserted for $userEmail');
      }
    } catch (e) {
      print('Failed to save or update address: $e');
    }
  }

  // Mengambil alamat yang aktif (berdasarkan email user yang login)
  Future<List<InfoUser>> fetchAddresses() async {
  final user = supabase.auth.currentUser;
  final userEmail = user?.email?.trim().toLowerCase() ?? '';
  print('Logged in user email: $userEmail');

  try {
    // 1️⃣ Ambil semua data addresses tanpa filter ➔ untuk cek apakah data nyampe
    final response = await supabase
        .from('addresses')
        .select('*');

    print('ALL ADDRESSES: $response');  // 🔍 Tambahin ini

    // 2️⃣ Coba filter biasa (seperti sebelumnya)
    final filteredResponse = await supabase
        .from('addresses')
        .select('*')
        .eq('email', userEmail)
        .eq('is_active', true);

    print('FILTERED ADDRESSES: $filteredResponse');  // 🔍 Tambahin ini juga

    return filteredResponse.map<InfoUser>((data) => InfoUser.fromDatabase(data)).toList();
  } catch (e) {
    print('Failed to fetch addresses: $e');
    return [];
  }
}


  // Optional: Menonaktifkan alamat lama (soft delete)
  Future<void> deactivateAddress(String id) async {  // ← harus String bukan int
    try {
      await supabase
          .from('addresses')
          .update({'is_active': false})
          .eq('id', id);  // ← pastikan 'id' adalah UUID
      print('Address $id deactivated');
    } catch (e) {
      print('Failed to deactivate address: $e');
    }
  }

}
