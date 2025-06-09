import 'package:json_annotation/json_annotation.dart';

part 'tiiun_model_model.g.dart';

@JsonSerializable()
class TiiunModel {
  final int? id;
  @JsonKey(name: 'tiiun_model_id')
  final String tiiunModelId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'model_name')
  final String modelName;
  @JsonKey(name: 'serial_number')
  final String serialNumber;
  @JsonKey(name: 'firmware_version')
  final String? firmwareVersion;
  @JsonKey(name: 'register_mode')
  final String? registerMode;
  @JsonKey(name: 'tiiun_location')
  final String? tiiunLocation;
  final String? status;
  @JsonKey(name: 'last_sync_at')
  final DateTime? lastSyncAt;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  TiiunModel({
    this.id,
    required this.tiiunModelId,
    required this.userId,
    required this.modelName,
    required this.serialNumber,
    this.firmwareVersion,
    this.registerMode,
    this.tiiunLocation,
    this.status,
    this.lastSyncAt,
    this.createdAt,
  });

  factory TiiunModel.fromJson(Map<String, dynamic> json) =>
      _$TiiunModelFromJson(json);
  Map<String, dynamic> toJson() => _$TiiunModelToJson(this);

  TiiunModel copyWith({
    int? id,
    String? tiiunModelId,
    String? userId,
    String? modelName,
    String? serialNumber,
    String? firmwareVersion,
    String? registerMode,
    String? tiiunLocation,
    String? status,
    DateTime? lastSyncAt,
    DateTime? createdAt,
  }) {
    return TiiunModel(
      id: id ?? this.id,
      tiiunModelId: tiiunModelId ?? this.tiiunModelId,
      userId: userId ?? this.userId,
      modelName: modelName ?? this.modelName,
      serialNumber: serialNumber ?? this.serialNumber,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      registerMode: registerMode ?? this.registerMode,
      tiiunLocation: tiiunLocation ?? this.tiiunLocation,
      status: status ?? this.status,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 기기 상태에 따른 색상 반환
  String get statusColor {
    switch (status?.toLowerCase()) {
      case 'online':
      case 'active':
        return '#4CAF50'; // 녹색
      case 'offline':
      case 'inactive':
        return '#F44336'; // 빨간색
      case 'standby':
      case 'idle':
        return '#FF9800'; // 오렌지색
      case 'maintenance':
        return '#9E9E9E'; // 회색
      default:
        return '#607D8B'; // 기본 회색
    }
  }

  // 기기 상태 한글 텍스트
  String get statusText {
    switch (status?.toLowerCase()) {
      case 'online':
        return '온라인';
      case 'offline':
        return '오프라인';
      case 'active':
        return '활성';
      case 'inactive':
        return '비활성';
      case 'standby':
        return '대기';
      case 'idle':
        return '유휴';
      case 'maintenance':
        return '점검중';
      default:
        return '알 수 없음';
    }
  }

  // 마지막 동기화 시간이 최근인지 확인 (1시간 이내)
  bool get isRecentlySync {
    if (lastSyncAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastSyncAt!);
    return difference.inHours < 1;
  }

  // 기기가 온라인 상태인지 확인
  bool get isOnline {
    return status?.toLowerCase() == 'online' || status?.toLowerCase() == 'active';
  }

  @override
  String toString() {
    return 'TiiunModel(id: $id, tiiunModelId: $tiiunModelId, modelName: $modelName, serialNumber: $serialNumber, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TiiunModel && other.tiiunModelId == tiiunModelId;
  }

  @override
  int get hashCode => tiiunModelId.hashCode;
}

// 티이운 모델 등록을 위한 요청 모델
@JsonSerializable()
class RegisterTiiunModelRequest {
  @JsonKey(name: 'model_name')
  final String modelName;
  @JsonKey(name: 'serial_number')
  final String serialNumber;
  @JsonKey(name: 'firmware_version')
  final String? firmwareVersion;
  @JsonKey(name: 'register_mode')
  final String? registerMode;
  @JsonKey(name: 'tiiun_location')
  final String? tiiunLocation;

  RegisterTiiunModelRequest({
    required this.modelName,
    required this.serialNumber,
    this.firmwareVersion,
    this.registerMode,
    this.tiiunLocation,
  });

  factory RegisterTiiunModelRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterTiiunModelRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterTiiunModelRequestToJson(this);
}

// 티이운 모델 업데이트를 위한 요청 모델
@JsonSerializable()
class UpdateTiiunModelRequest {
  @JsonKey(name: 'model_name')
  final String? modelName;
  @JsonKey(name: 'firmware_version')
  final String? firmwareVersion;
  @JsonKey(name: 'register_mode')
  final String? registerMode;
  @JsonKey(name: 'tiiun_location')
  final String? tiiunLocation;
  final String? status;

  UpdateTiiunModelRequest({
    this.modelName,
    this.firmwareVersion,
    this.registerMode,
    this.tiiunLocation,
    this.status,
  });

  factory UpdateTiiunModelRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTiiunModelRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateTiiunModelRequestToJson(this);
}

// 티이운 모델 동기화를 위한 요청 모델
@JsonSerializable()
class SyncTiiunModelRequest {
  @JsonKey(name: 'tiiun_model_id')
  final String tiiunModelId;
  @JsonKey(name: 'sync_data')
  final Map<String, dynamic>? syncData;

  SyncTiiunModelRequest({
    required this.tiiunModelId,
    this.syncData,
  });

  factory SyncTiiunModelRequest.fromJson(Map<String, dynamic> json) =>
      _$SyncTiiunModelRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SyncTiiunModelRequestToJson(this);
}
