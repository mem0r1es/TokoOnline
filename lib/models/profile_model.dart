import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilModel {
  final String id;
  final String name;
  final String email;
  final String? phone;

  ProfilModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  factory ProfilModel.fromMap(Map<String, dynamic> map) {
    return ProfilModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  String get profileImageUrl {
    return Supabase.instance.client
        .storage
        .from('profile-image')
        .getPublicUrl('$id/profile.jpg');
  }
}
