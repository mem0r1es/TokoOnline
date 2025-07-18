// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      contactNumber: json['contact_number'] as String?,
      userType: json['user_type'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'contact_number': instance.contactNumber,
      'user_type': instance.userType,
      'created_at': instance.createdAt,
    };

AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => AuthTokens(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );

Map<String, dynamic> _$AuthTokensToJson(AuthTokens instance) =>
    <String, dynamic>{
      'access': instance.access,
      'refresh': instance.refresh,
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      message: json['message'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'user': instance.user,
      'tokens': instance.tokens,
    };

RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
    RegisterResponse(
      message: json['message'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegisterResponseToJson(RegisterResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'user': instance.user,
    };
