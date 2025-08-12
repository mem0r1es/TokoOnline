import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/info_user.dart';

class AddressService {
  final supabase = Supabase.instance.client;
  
  Future<void> saveAddress(InfoUser address) async {
    final user = supabase.auth.currentUser;
    final userEmail = user?.email ?? '';

    final addressData = {
      'full_name': address.fullName,
      'email': userEmail,
      'phone': address.phone,
      'address': address.address,
      'provinsi': address.provinsi,
      'kota': address.kota,
      'kecamatan': address.kecamatan,
      'kode_pos': address.kodepos,
      'detail': address.detail,
      'is_active': true,
      // Anda bisa tambahkan 'provinsi_id', 'kota_id', 'kecamatan_id' di sini
      // untuk mempermudah saat edit
    };

    try {
      if (address.id != null) {
        await supabase
            .from('addresses')
            .update(addressData)
            .eq('id', address.id!);
        print('Address updated: ${address.id}');
      } else {
        await supabase.from('addresses').insert(addressData);
        print('Address inserted for $userEmail');
      }
    } catch (e) {
      print('Failed to save or update address: $e');
    }
  }

  Future<List<InfoUser>> fetchAddresses() async {
    final user = supabase.auth.currentUser;
    final userEmail = user?.email?.trim().toLowerCase() ?? '';

    try {
      final response = await supabase
          .from('addresses')
          .select('*')
          .eq('email', userEmail)
          .eq('is_active', true);

      return response.map<InfoUser>((data) => InfoUser.fromDatabase(data)).toList();
    } catch (e) {
      print('Failed to fetch addresses: $e');
      return [];
    }
  }

  Future<void> deactivateAddress(String id) async {
    try {
      await supabase
          .from('addresses')
          .update({'is_active': false})
          .eq('id', id);
      print('Address $id deactivated');
    } catch (e) {
      print('Failed to deactivate address: $e');
    }
  }
}