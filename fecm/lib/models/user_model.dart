class User {
  final int id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String fullName;
  final bool isVerified;
  final String createdAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.isVerified,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'is_verified': isVerified,
      'created_at': createdAt,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, username: $username, fullName: $fullName}';
  }
}
