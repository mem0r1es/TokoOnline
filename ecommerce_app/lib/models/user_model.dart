import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String email;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'contact_number')
  final String? contactNumber;
  @JsonKey(name: 'user_type')
  final String userType;
  @JsonKey(name: 'created_at')
  final String createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.contactNumber,
    required this.userType,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool get isAdmin => userType == 'admin';
  bool get isSeller => userType == 'seller';
  
  String get fullName => '$firstName $lastName';
}

@JsonSerializable()
class AuthTokens {
  final String access;
  final String refresh;

  AuthTokens({required this.access, required this.refresh});

  factory AuthTokens.fromJson(Map<String, dynamic> json) => _$AuthTokensFromJson(json);
  Map<String, dynamic> toJson() => _$AuthTokensToJson(this);
}

@JsonSerializable()
class LoginResponse {
  final String message;
  final User user;
  final AuthTokens tokens;

  LoginResponse({
    required this.message,
    required this.user,
    required this.tokens,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class RegisterResponse {
  final String message;
  final User user;

  RegisterResponse({required this.message, required this.user});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => _$RegisterResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
}