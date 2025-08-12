class InfoUser {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? address;
  final String? provinsi;
  final String? provinsiId; // Tambahkan field ini
  final String? kota;
  final String? kotaId; // Tambahkan field ini
  final String? kecamatan;
  final String? kecamatanId; // Tambahkan field ini
  final String? kodepos;
  final String? detail;
  final DateTime? timestamp;
  final bool? isDefault;

  InfoUser({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.address,
    this.provinsi,
    this.provinsiId,
    this.kota,
    this.kotaId,
    this.kecamatan,
    this.kecamatanId,
    this.kodepos,
    this.detail,
    this.timestamp,
    this.isDefault,
  });

  factory InfoUser.fromJson(Map<String, dynamic> json) => InfoUser(
        id: json['id']?.toString(),
        fullName: json['full_name'],
        email: json['email'],
        phone: json['phone'],
        address: json['address'],
        provinsi: json['provinsi'],
        provinsiId: json['provinsi_id'],
        kota: json['kota'],
        kotaId: json['kota_id'],
        kecamatan: json['kecamatan'],
        kecamatanId: json['kecamatan_id'],
        kodepos: json['kode_pos'],
        detail: json['detail'],
        timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp']) : null,
        isDefault: json['is_default'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'address': address,
        'provinsi': provinsi,
        'provinsi_id': provinsiId,
        'kota': kota,
        'kota_id': kotaId,
        'kecamatan': kecamatan,
        'kecamatan_id': kecamatanId,
        'kode_pos': kodepos,
        'detail': detail,
        'timestamp': timestamp?.toIso8601String(),
        'is_default': isDefault ?? false,
      };

  factory InfoUser.fromDatabase(Map<String, dynamic> data) => InfoUser(
        id: data['id']?.toString(),
        fullName: data['full_name'],
        email: data['email'],
        phone: data['phone'],
        address: data['address'],
        provinsi: data['provinsi'],
        provinsiId: data['provinsi_id'],
        kota: data['kota'],
        kotaId: data['kota_id'],
        kecamatan: data['kecamatan'],
        kecamatanId: data['kecamatan_id'],
        kodepos: data['kode_pos'],
        detail: data['detail'],
        timestamp: data['timestamp'] != null ? DateTime.tryParse(data['timestamp']) : null,
        isDefault: data['is_default'] ?? false,
      );

  Map<String, dynamic> toDatabase() => {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'address': address,
        'provinsi': provinsi,
        'provinsi_id': provinsiId,
        'kota': kota,
        'kota_id': kotaId,
        'kecamatan': kecamatan,
        'kecamatan_id': kecamatanId,
        'kode_pos': kodepos,
        'detail': detail,
        'timestamp': timestamp?.toIso8601String(),
        'is_active': true,
        'is_default': isDefault ?? false,
      };

  InfoUser copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? provinsi,
    String? provinsiId,
    String? kota,
    String? kotaId,
    String? kecamatan,
    String? kecamatanId,
    String? kodepos,
    String? detail,
    DateTime? timestamp,
    bool? isDefault,
  }) {
    return InfoUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      provinsi: provinsi ?? this.provinsi,
      provinsiId: provinsiId ?? this.provinsiId,
      kota: kota ?? this.kota,
      kotaId: kotaId ?? this.kotaId,
      kecamatan: kecamatan ?? this.kecamatan,
      kecamatanId: kecamatanId ?? this.kecamatanId,
      kodepos: kodepos ?? this.kodepos,
      detail: detail ?? this.detail,
      timestamp: timestamp ?? this.timestamp,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}