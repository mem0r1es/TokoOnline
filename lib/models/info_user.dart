class InfoUser {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? address;
  final String? provinsi;
  final String? kota;
  final String? kecamatan;
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
    this.kota,
    this.kodepos,
    this.kecamatan,
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
        kota: json['kota'],
        kodepos: json['kode_pos'],
        kecamatan: json['kecamatan'],
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
        'kota': kota,
        'kode_pos': kodepos,
        'kecamatan': kecamatan,
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
        kota: data['kota'],
        kodepos: data['kode_pos'],
        kecamatan: data['kecamatan'],
        detail: data['detail'],
        timestamp: data['timestamp'] != null ? DateTime.tryParse(data['timestamp']) : null,
      );

  Map<String, dynamic> toDatabase() => {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'address': address,
        'provinsi': provinsi,
        'kota': kota,
        'kode_pos': kodepos,
        'kecamatan': kecamatan,
        'detail': detail,
        'timestamp': timestamp?.toIso8601String(),
        'is_active': true,
      };

  InfoUser copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? provinsi,
    String? kota,
    String? kecamatan,
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
      kota: kota ?? this.kota,
      kecamatan: kecamatan ?? this.kecamatan,
      kodepos: kodepos ?? this.kodepos,
      detail: detail ?? this.detail,
      timestamp: timestamp ?? this.timestamp,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
