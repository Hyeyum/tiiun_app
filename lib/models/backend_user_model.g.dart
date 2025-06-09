// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backend_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackendUser _$BackendUserFromJson(Map<String, dynamic> json) => BackendUser(
  id: (json['id'] as num?)?.toInt(),
  userId: json['user_id'] as String? ?? '',
  email: json['email'] as String? ?? '',
  username: json['username'] as String?,
  passwordHash: json['password_hash'] as String?,
  displayName: json['display_name'] as String?,
  photoUrl: json['photo_url'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  lastActiveAt: json['last_active_at'] == null
      ? null
      : DateTime.parse(json['last_active_at'] as String),
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$BackendUserToJson(BackendUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'email': instance.email,
      'password_hash': instance.passwordHash,
      'username': instance.username,
      'display_name': instance.displayName,
      'photo_url': instance.photoUrl,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'last_active_at': instance.lastActiveAt?.toIso8601String(),
      'is_active': instance.isActive,
    };

CreateUserRequest _$CreateUserRequestFromJson(Map<String, dynamic> json) =>
    CreateUserRequest(
      email: json['email'] as String,
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
    );

Map<String, dynamic> _$CreateUserRequestToJson(CreateUserRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'username': instance.username,
      'display_name': instance.displayName,
      'photo_url': instance.photoUrl,
    };

UpdateUserRequest _$UpdateUserRequestFromJson(Map<String, dynamic> json) =>
    UpdateUserRequest(
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      isActive: json['is_active'] as bool?,
    );

Map<String, dynamic> _$UpdateUserRequestToJson(UpdateUserRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'display_name': instance.displayName,
      'photo_url': instance.photoUrl,
      'is_active': instance.isActive,
    };
