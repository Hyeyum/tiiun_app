import 'package:json_annotation/json_annotation.dart';

part 'growth_record_model.g.dart';

@JsonSerializable()
class GrowthRecord {
  final int? id;
  @JsonKey(name: 'record_id')
  final String recordId;
  @JsonKey(name: 'plant_id')
  final String plantId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'record_date')
  final DateTime recordDate;
  final double? height;
  final double? width;
  final String? notes;
  final String? images;
  @JsonKey(name: 'growth_stage')
  final String? growthStage;
  @JsonKey(name: 'health_status')
  final String? healthStatus;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  GrowthRecord({
    this.id,
    required this.recordId,
    required this.plantId,
    required this.userId,
    required this.recordDate,
    this.height,
    this.width,
    this.notes,
    this.images,
    this.growthStage,
    this.healthStatus,
    this.createdAt,
  });

  factory GrowthRecord.fromJson(Map<String, dynamic> json) =>
      _$GrowthRecordFromJson(json);
  Map<String, dynamic> toJson() => _$GrowthRecordToJson(this);

  GrowthRecord copyWith({
    int? id,
    String? recordId,
    String? plantId,
    String? userId,
    DateTime? recordDate,
    double? height,
    double? width,
    String? notes,
    String? images,
    String? growthStage,
    String? healthStatus,
    DateTime? createdAt,
  }) {
    return GrowthRecord(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      plantId: plantId ?? this.plantId,
      userId: userId ?? this.userId,
      recordDate: recordDate ?? this.recordDate,
      height: height ?? this.height,
      width: width ?? this.width,
      notes: notes ?? this.notes,
      images: images ?? this.images,
      growthStage: growthStage ?? this.growthStage,
      healthStatus: healthStatus ?? this.healthStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 이미지 URL 리스트로 파싱
  List<String> get imageUrls {
    if (images == null || images!.isEmpty) return [];
    try {
      // JSON 배열 형태인지 확인
      if (images!.startsWith('[') && images!.endsWith(']')) {
        // JSON 파싱 로직
        return images!
            .substring(1, images!.length - 1)
            .split(',')
            .map((e) => e.trim().replaceAll('"', ''))
            .where((e) => e.isNotEmpty)
            .toList();
      } else {
        // 콤마로 구분된 형태
        return images!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    } catch (e) {
      return [];
    }
  }

  @override
  String toString() {
    return 'GrowthRecord(id: $id, recordId: $recordId, plantId: $plantId, recordDate: $recordDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrowthRecord && other.recordId == recordId;
  }

  @override
  int get hashCode => recordId.hashCode;
}

// 성장 기록 생성을 위한 요청 모델
@JsonSerializable()
class CreateGrowthRecordRequest {
  @JsonKey(name: 'plant_id')
  final String plantId;
  @JsonKey(name: 'record_date')
  final DateTime recordDate;
  final double? height;
  final double? width;
  final String? notes;
  final List<String>? imageUrls;
  @JsonKey(name: 'growth_stage')
  final String? growthStage;
  @JsonKey(name: 'health_status')
  final String? healthStatus;

  CreateGrowthRecordRequest({
    required this.plantId,
    required this.recordDate,
    this.height,
    this.width,
    this.notes,
    this.imageUrls,
    this.growthStage,
    this.healthStatus,
  });

  factory CreateGrowthRecordRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGrowthRecordRequestFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$CreateGrowthRecordRequestToJson(this);
    // imageUrls를 images 문자열로 변환
    if (imageUrls != null && imageUrls!.isNotEmpty) {
      json['images'] = imageUrls!.join(',');
    }
    json.remove('imageUrls');
    return json;
  }
}

// 성장 기록 업데이트를 위한 요청 모델
@JsonSerializable()
class UpdateGrowthRecordRequest {
  @JsonKey(name: 'record_date')
  final DateTime? recordDate;
  final double? height;
  final double? width;
  final String? notes;
  final List<String>? imageUrls;
  @JsonKey(name: 'growth_stage')
  final String? growthStage;
  @JsonKey(name: 'health_status')
  final String? healthStatus;

  UpdateGrowthRecordRequest({
    this.recordDate,
    this.height,
    this.width,
    this.notes,
    this.imageUrls,
    this.growthStage,
    this.healthStatus,
  });

  factory UpdateGrowthRecordRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateGrowthRecordRequestFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$UpdateGrowthRecordRequestToJson(this);
    // imageUrls를 images 문자열로 변환
    if (imageUrls != null && imageUrls!.isNotEmpty) {
      json['images'] = imageUrls!.join(',');
    }
    json.remove('imageUrls');
    return json;
  }
}
