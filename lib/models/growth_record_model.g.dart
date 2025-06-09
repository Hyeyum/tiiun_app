// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthRecord _$GrowthRecordFromJson(Map<String, dynamic> json) => GrowthRecord(
  id: (json['id'] as num?)?.toInt(),
  recordId: json['record_id'] as String,
  plantId: json['plant_id'] as String,
  userId: json['user_id'] as String,
  recordDate: DateTime.parse(json['record_date'] as String),
  height: (json['height'] as num?)?.toDouble(),
  width: (json['width'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
  images: json['images'] as String?,
  growthStage: json['growth_stage'] as String?,
  healthStatus: json['health_status'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$GrowthRecordToJson(GrowthRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'record_id': instance.recordId,
      'plant_id': instance.plantId,
      'user_id': instance.userId,
      'record_date': instance.recordDate.toIso8601String(),
      'height': instance.height,
      'width': instance.width,
      'notes': instance.notes,
      'images': instance.images,
      'growth_stage': instance.growthStage,
      'health_status': instance.healthStatus,
      'created_at': instance.createdAt?.toIso8601String(),
    };

CreateGrowthRecordRequest _$CreateGrowthRecordRequestFromJson(
    Map<String, dynamic> json) =>
    CreateGrowthRecordRequest(
      plantId: json['plant_id'] as String,
      recordDate: DateTime.parse(json['record_date'] as String),
      height: (json['height'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      growthStage: json['growth_stage'] as String?,
      healthStatus: json['health_status'] as String?,
    );

Map<String, dynamic> _$CreateGrowthRecordRequestToJson(
    CreateGrowthRecordRequest instance) =>
    <String, dynamic>{
      'plant_id': instance.plantId,
      'record_date': instance.recordDate.toIso8601String(),
      'height': instance.height,
      'width': instance.width,
      'notes': instance.notes,
      'imageUrls': instance.imageUrls,
      'growth_stage': instance.growthStage,
      'health_status': instance.healthStatus,
    };

UpdateGrowthRecordRequest _$UpdateGrowthRecordRequestFromJson(
    Map<String, dynamic> json) =>
    UpdateGrowthRecordRequest(
      recordDate: json['record_date'] == null
          ? null
          : DateTime.parse(json['record_date'] as String),
      height: (json['height'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      growthStage: json['growth_stage'] as String?,
      healthStatus: json['health_status'] as String?,
    );

Map<String, dynamic> _$UpdateGrowthRecordRequestToJson(
    UpdateGrowthRecordRequest instance) =>
    <String, dynamic>{
      'record_date': instance.recordDate?.toIso8601String(),
      'height': instance.height,
      'width': instance.width,
      'notes': instance.notes,
      'imageUrls': instance.imageUrls,
      'growth_stage': instance.growthStage,
      'health_status': instance.healthStatus,
    };
