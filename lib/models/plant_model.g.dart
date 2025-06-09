// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plant _$PlantFromJson(Map<String, dynamic> json) => Plant(
  id: (json['id'] as num?)?.toInt(),
  plantId: json['plant_id'] as String,
  userId: json['user_id'] as String,
  tiiunModelId: json['tiiun_model_id'] as String?,
  speciesName: json['species_name'] as String,
  nickname: json['nickname'] as String?,
  plantedDate: json['planted_date'] == null
      ? null
      : DateTime.parse(json['planted_date'] as String),
  growthStage: json['growth_stage'] as String?,
  healthStatus: json['health_status'] as String?,
  location: json['location'] as String?,
  imageUrl: json['image_url'] as String?,
  careSchedule: json['care_schedule'] as String?,
  notes: json['notes'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PlantToJson(Plant instance) => <String, dynamic>{
  'id': instance.id,
  'plant_id': instance.plantId,
  'user_id': instance.userId,
  'tiiun_model_id': instance.tiiunModelId,
  'species_name': instance.speciesName,
  'nickname': instance.nickname,
  'planted_date': instance.plantedDate?.toIso8601String(),
  'growth_stage': instance.growthStage,
  'health_status': instance.healthStatus,
  'location': instance.location,
  'image_url': instance.imageUrl,
  'care_schedule': instance.careSchedule,
  'notes': instance.notes,
  'is_active': instance.isActive,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

CreatePlantRequest _$CreatePlantRequestFromJson(Map<String, dynamic> json) =>
    CreatePlantRequest(
      tiiunModelId: json['tiiun_model_id'] as String?,
      speciesName: json['species_name'] as String,
      nickname: json['nickname'] as String?,
      plantedDate: json['planted_date'] == null
          ? null
          : DateTime.parse(json['planted_date'] as String),
      growthStage: json['growth_stage'] as String?,
      healthStatus: json['health_status'] as String?,
      location: json['location'] as String?,
      imageUrl: json['image_url'] as String?,
      careSchedule: json['care_schedule'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$CreatePlantRequestToJson(CreatePlantRequest instance) =>
    <String, dynamic>{
      'tiiun_model_id': instance.tiiunModelId,
      'species_name': instance.speciesName,
      'nickname': instance.nickname,
      'planted_date': instance.plantedDate?.toIso8601String(),
      'growth_stage': instance.growthStage,
      'health_status': instance.healthStatus,
      'location': instance.location,
      'image_url': instance.imageUrl,
      'care_schedule': instance.careSchedule,
      'notes': instance.notes,
    };

UpdatePlantRequest _$UpdatePlantRequestFromJson(Map<String, dynamic> json) =>
    UpdatePlantRequest(
      tiiunModelId: json['tiiun_model_id'] as String?,
      speciesName: json['species_name'] as String?,
      nickname: json['nickname'] as String?,
      plantedDate: json['planted_date'] == null
          ? null
          : DateTime.parse(json['planted_date'] as String),
      growthStage: json['growth_stage'] as String?,
      healthStatus: json['health_status'] as String?,
      location: json['location'] as String?,
      imageUrl: json['image_url'] as String?,
      careSchedule: json['care_schedule'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool?,
    );

Map<String, dynamic> _$UpdatePlantRequestToJson(UpdatePlantRequest instance) =>
    <String, dynamic>{
      'tiiun_model_id': instance.tiiunModelId,
      'species_name': instance.speciesName,
      'nickname': instance.nickname,
      'planted_date': instance.plantedDate?.toIso8601String(),
      'growth_stage': instance.growthStage,
      'health_status': instance.healthStatus,
      'location': instance.location,
      'image_url': instance.imageUrl,
      'care_schedule': instance.careSchedule,
      'notes': instance.notes,
      'is_active': instance.isActive,
    };
