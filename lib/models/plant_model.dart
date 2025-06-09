import 'package:json_annotation/json_annotation.dart';

part 'plant_model.g.dart';

@JsonSerializable()
class Plant {
  final int? id;
  @JsonKey(name: 'plant_id')
  final String plantId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'tiiun_model_id')
  final String? tiiunModelId;
  @JsonKey(name: 'species_name')
  final String speciesName;
  final String? nickname;
  @JsonKey(name: 'planted_date')
  final DateTime? plantedDate;
  @JsonKey(name: 'growth_stage')
  final String? growthStage;
  @JsonKey(name: 'health_status')
  final String? healthStatus;
  final String? location;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'care_schedule')
  final String? careSchedule;
  final String? notes;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Plant({
    this.id,
    required this.plantId,
    required this.userId,
    this.tiiunModelId,
    required this.speciesName,
    this.nickname,
    this.plantedDate,
    this.growthStage,
    this.healthStatus,
    this.location,
    this.imageUrl,
    this.careSchedule,
    this.notes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);
  Map<String, dynamic> toJson() => _$PlantToJson(this);

  Plant copyWith({
    int? id,
    String? plantId,
    String? userId,
    String? tiiunModelId,
    String? speciesName,
    String? nickname,
    DateTime? plantedDate,
    String? growthStage,
    String? healthStatus,
    String? location,
    String? imageUrl,
    String? careSchedule,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Plant(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      userId: userId ?? this.userId,
      tiiunModelId: tiiunModelId ?? this.tiiunModelId,
      speciesName: speciesName ?? this.speciesName,
      nickname: nickname ?? this.nickname,
      plantedDate: plantedDate ?? this.plantedDate,
      growthStage: growthStage ?? this.growthStage,
      healthStatus: healthStatus ?? this.healthStatus,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      careSchedule: careSchedule ?? this.careSchedule,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Plant(id: $id, plantId: $plantId, userId: $userId, speciesName: $speciesName, nickname: $nickname)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plant && other.plantId == plantId;
  }

  @override
  int get hashCode => plantId.hashCode;
}

// 식물 생성을 위한 요청 모델
@JsonSerializable()
class CreatePlantRequest {
  @JsonKey(name: 'tiiun_model_id')
  final String? tiiunModelId;
  @JsonKey(name: 'species_name')
  final String speciesName;
  final String? nickname;
  @JsonKey(name: 'planted_date')
  final DateTime? plantedDate;
  @JsonKey(name: 'growth_stage')
  final String? growthStage;
  @JsonKey(name: 'health_status')
  final String? healthStatus;
  final String? location;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'care_schedule')
  final String? careSchedule;
  final String? notes;

  CreatePlantRequest({
    this.tiiunModelId,
    required this.speciesName,
    this.nickname,
    this.plantedDate,
    this.growthStage,
    this.healthStatus,
    this.location,
    this.imageUrl,
    this.careSchedule,
    this.notes,
  });

  factory CreatePlantRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePlantRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePlantRequestToJson(this);
}

// 식물 업데이트를 위한 요청 모델
@JsonSerializable()
class UpdatePlantRequest {
  @JsonKey(name: 'tiiun_model_id')
  final String? tiiunModelId;
  @JsonKey(name: 'species_name')
  final String? speciesName;
  final String? nickname;
  @JsonKey(name: 'planted_date')
  final DateTime? plantedDate;
  @JsonKey(name: 'growth_stage')
  final String? growthStage;
  @JsonKey(name: 'health_status')
  final String? healthStatus;
  final String? location;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'care_schedule')
  final String? careSchedule;
  final String? notes;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  UpdatePlantRequest({
    this.tiiunModelId,
    this.speciesName,
    this.nickname,
    this.plantedDate,
    this.growthStage,
    this.healthStatus,
    this.location,
    this.imageUrl,
    this.careSchedule,
    this.notes,
    this.isActive,
  });

  factory UpdatePlantRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePlantRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePlantRequestToJson(this);
}
