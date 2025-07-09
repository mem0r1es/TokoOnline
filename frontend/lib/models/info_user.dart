class InfoUser {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? address;
  final DateTime? timestamp; // Uncomment if you want to track when the address was added

  InfoUser({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.address,
    this.timestamp,
  });

  factory InfoUser.fromDatabase(Map<String, dynamic> data) {
    return InfoUser(
      id: data['id']?.toString(),
      fullName: data['full_name'] as String?,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      timestamp: data['timestamp'] != null ? DateTime.tryParse(data['timestamp']) : null,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'timestamp': timestamp?.toIso8601String(), // Uncomment if you want to save timestamp
      'is_active': true,
      // 'created_at': DateTime.now().toIso8601String(),
    };
  }
}
