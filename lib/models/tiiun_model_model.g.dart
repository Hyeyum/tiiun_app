// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tiiun_model_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TiiunModel _$TiiunModelFromJson(Map<String, dynamic> json) => TiiunModel(
  id: (json['id'] as num?)?.toInt(),
  tiiunModelId: json['tiiun_model_id'] as String,
  userId: json['user_id'] as String,
  modelName: json['model_name'] as String,
  serialNumber: json['serial_number'] as String,
  firmwareVersion: json['firmware_version'] as String?,
  registerMode: json['register_mode'] as String?,
  tiiunLocation: json['tiiun_location'] as String?,
  status: json['status'] as String?,
  lastSyncAt: json['last_sync_at'] == null
      ? null
      : DateTime.parse(json['last_sync_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$TiiunModelToJson(TiiunModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tiiun_model_id': instance.tiiunModelId,
      'user_id': instance.userId,
      'model_name': instance.modelName,
      'serial_number': instance.serialNumber,
      'firmware_version': instance.firmwareVersion,
      'register_mode': instance.registerMode,
      'tiiun_location': instance.tiiunLocation,
      'status': instance.status,
      'last_sync_at': instance.lastSyncAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
    };

RegisterTiiunModelRequest _$RegisterTiiunModelRequestFromJson(
    Map<String, dynamic> json) =>
    RegisterTiiunModelRequest(
      modelName: json['model_name'] as String,
      serialNumber: json['serial_number'] as String,
      firmwareVersion: json['firmware_version'] as String?,
      registerMode: json['register_mode'] as String?,
      tiiunLocation: json['tiiun_location'] as String?,
    );

Map<String, dynamic> _$RegisterTiiunModelRequestToJson(
    RegisterTiiunModelRequest instance) =>
    <String, dynamic>{
      'model_name': instance.modelName,
      'serial_number': instance.serialNumber,
      'firmware_version': instance.firmwareVersion,
      'register_mode': instance.registerMode,
      'tiiun_location': instance.tiiunLocation,
    };

UpdateTiiunModelRequest _$UpdateTiiunModelRequestFromJson(
    Map<String, dynamic> json) =>
    UpdateTiiunModelRequest(
      modelName: json['model_name'] as String?,
      firmwareVersion: json['firmware_version'] as String?,
      registerMode: json['register_mode'] as String?,
      tiiunLocation: json['tiiun_location'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$UpdateTiiunModelRequestToJson(
    UpdateTiiunModelRequest instance) =>
    <String, dynamic>{
      'model_name': instance.modelName,
      'firmware_version': instance.firmwareVersion,
      'register_mode': instance.registerMode,
      'tiiun_location': instance.tiiunLocation,
      'status': instance.status,
    };

SyncTiiunModelRequest _$SyncTiiunModelRequestFromJson(
    Map<String, dynamic> json) =>
    SyncTiiunModelRequest(
      tiiunModelId: json['tiiun_model_id'] as String,
      syncData: json['sync_data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SyncTiiunModelRequestToJson(
    SyncTiiunModelRequest instance) =>
    <String, dynamic>{
      'tiiun_model_id': instance.tiiunModelId,
      'sync_data': instance.syncData,
    };
