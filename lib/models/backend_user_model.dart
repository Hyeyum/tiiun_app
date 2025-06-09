import 'package:json_annotation/json_annotation.dart';

part 'backend_user_model.g.dart';

@JsonSerializable()
class BackendUser {
  final int? id;
  @JsonKey(name: 'user_id', defaultValue: '') // 여기에 defaultValue 추가
  final String userId;
  @JsonKey(defaultValue: '') // 여기에 defaultValue 추가
  final String email;
  @JsonKey(name: 'password_hash')
  final String? passwordHash;
  final String? username;
  @JsonKey(name: 'display_name')
  final String? displayName;
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'last_active_at')
  final DateTime? lastActiveAt;
  @JsonKey(name: 'is_active')
  final bool isActive;

  BackendUser({
    this.id,
    required this.userId,
    required this.email,
    this.username,
    this.passwordHash,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.lastActiveAt,
    this.isActive = true,
  });

  factory BackendUser.fromJson(Map<String, dynamic> json) =>
      _$BackendUserFromJson(json);

  Map<String, dynamic> toJson() => _$BackendUserToJson(this);
  BackendUser copyWith({
    int? id,
    String? userId,
    String? email,
    String? username,
    String? passwordHash,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
    bool? isActive,
  }) {
    return BackendUser(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // 표시할 이름 반환 (우선순위: displayName > username > email)
  String get displayTitle {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (username != null && username!.isNotEmpty) {
      return username!;
    }
    return email;
  }

  // 프로필 이미지가 있는지 확인
  bool get hasProfileImage {
    return photoUrl != null && photoUrl!.isNotEmpty;
  }

  // 활성 사용자인지 확인
  bool get isActiveUser {
    return isActive;
  }

  // 최근 활동 여부 확인 (24시간 이내)
  bool get isRecentlyActive {
    if (lastActiveAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastActiveAt!);
    return difference.inHours < 24;
  }

  @override
  String toString() {
    return 'BackendUser(id: $id, userId: $userId, email: $email, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BackendUser && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

// 사용자 생성을 위한 요청 모델 (Firebase Auth 후 DB 저장용)
@JsonSerializable()
class CreateUserRequest {
  final String email;
  final String? username;
  @JsonKey(name: 'display_name')
  final String? displayName;
  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  CreateUserRequest({
    required this.email,
    this.username,
    this.displayName,
    this.photoUrl,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);
}

// 사용자 업데이트를 위한 요청 모델
@JsonSerializable()
class UpdateUserRequest {
  final String? username;
  @JsonKey(name: 'display_name')
  final String? displayName;
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  UpdateUserRequest({
    this.username,
    this.displayName,
    this.photoUrl,
    this.isActive,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
}

// Firebase 사용자 정보를 백엔드 요청으로 변환
extension FirebaseUserExtension on BackendUser {
  CreateUserRequest toCreateRequest() {
    return CreateUserRequest(
      email: email,
      username: username,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  UpdateUserRequest toUpdateRequest() {
    return UpdateUserRequest(
      username: username,
      displayName: displayName,
      photoUrl: photoUrl,
      isActive: isActive,
    );
  }
}
