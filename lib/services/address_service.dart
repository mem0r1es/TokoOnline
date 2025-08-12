import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/info_user.dart';

class AddressService {
  final SupabaseClient _supabase;

  // Dependency injection untuk memudahkan testing
  AddressService({SupabaseClient? client}) 
    : _supabase = client ?? Supabase.instance.client;

  /// Menyimpan atau memperbarui alamat
  Future<void> saveAddress(InfoUser address) async {
    try {
      final userEmail = _getCurrentUserEmail();

      final addressData = _buildAddressData(address, userEmail);

      if (address.id != null) {
        await _updateAddress(address.id!, addressData);
      } else {
        await _createAddress(addressData);
      }
    } catch (e) {
      throw Exception('Failed to save address: ${e.toString()}');
    }
  }

  /// Mengambil daftar alamat user
  Future<List<InfoUser>> fetchAddresses() async {
    try {
      final userEmail = _getCurrentUserEmail();
      final response = await _supabase
          .from('addresses')
          .select('*')
          .eq('email', userEmail)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return response.map<InfoUser>((data) => InfoUser.fromDatabase(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch addresses: ${e.toString()}');
    }
  }

  /// Menonaktifkan alamat (soft delete)
  Future<void> deactivateAddress(String id) async {
    try {
      await _supabase
          .from('addresses')
          .update({'is_active': false})
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to deactivate address: ${e.toString()}');
    }
  }

  /// Mengambil data provinsi
  Future<List<Map<String, dynamic>>> fetchProvinces() async {
    try {
      final response = await _supabase
          .from('provinces')
          .select('*')
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch provinces: ${e.toString()}');
    }
  }

  /// Mengambil data kabupaten/kota berdasarkan provinsi
  Future<List<Map<String, dynamic>>> fetchRegencies(String provinceId) async {
    try {
      final response = await _supabase
          .from('regencies')
          .select('*')
          .eq('province_id', provinceId)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch regencies: ${e.toString()}');
    }
  }

  /// Mengambil data kecamatan berdasarkan kabupaten/kota
  Future<List<Map<String, dynamic>>> fetchDistricts(String regencyId) async {
    try {
      final response = await _supabase
          .from('districts')
          .select('*')
          .eq('regency_id', regencyId)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch districts: ${e.toString()}');
    }
  }

  // ============ PRIVATE HELPER METHODS ============ //

  /// Mendapatkan email user yang sedang login
  String _getCurrentUserEmail() {
    final email = _supabase.auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      throw Exception('User not authenticated');
    }
    return email.trim().toLowerCase();
  }

  /// Membuat payload data alamat
  Map<String, dynamic> _buildAddressData(InfoUser address, String userEmail) {
    return {
      'full_name': address.fullName,
      'email': userEmail,
      'phone': address.phone,
      'address': address.address,
      'provinsi': address.provinsi,
      'provinsi_id': address.provinsi,
      'kota': address.kota,
      'kota_id': address.kota,
      'kecamatan': address.kecamatan,
      'kecamatan_id': address.kecamatan,
      'kode_pos': address.kodepos,
      'detail': address.detail,
      'is_active': true,
      'is_default': address.isDefault ?? false,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Membuat alamat baru
  Future<void> _createAddress(Map<String, dynamic> addressData) async {
    await _supabase.from('addresses').insert(addressData);
  }

  /// Memperbarui alamat yang sudah ada
  Future<void> _updateAddress(String id, Map<String, dynamic> addressData) async {
    await _supabase
        .from('addresses')
        .update(addressData)
        .eq('id', id);
  }
}