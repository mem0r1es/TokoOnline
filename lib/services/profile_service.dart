// File: services/profile_service.dart
import 'package:flutter_web/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_web/controllers/auth_controller.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<void> updateUserProfile({String? name, String? email, String? phone}) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User belum login");

    final updates = <String, dynamic>{};
    if (name != null) updates['full_name'] = name; // gunakan full_name
    if (email != null) updates['email'] = email;
    if (phone != null) updates['phone'] = phone;

    if (updates.isNotEmpty) {
      await supabase.from('profiles').update(updates).eq('id', user.id);
      await _refreshProfile();
    }
  }

  Future<void> _refreshProfile() async {
    final authController = Get.find<AuthController>();
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final result = await supabase.from('profiles').select().eq('id', user.id).single();
    authController.userProfile.value = ProfilModel.fromMap(result);
  }
}
