import '../models/plant_model.dart';
import '../utils/constants.dart';
import '../utils/logger.dart'; // AppLogger를 정확히 import 하는지 확인하세요.
import 'api_client.dart';

class PlantApiService {
  final _apiClient = ApiClient();
  // 이 줄을 제거하세요: 여기에서 로거의 인스턴스를 만들 필요가 없습니다.
  // final _logger = Logger();

  // 현재 사용자의 모든 식물 목록 가져오기
  Future<ApiListResponse<Plant>> getMyPlants({
    int? page,
    int? size,
    bool? isActive,
    String? speciesName,
    String? growthStage,
    String? healthStatus,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;
      if (isActive != null) queryParams['isActive'] = isActive;
      if (speciesName != null && speciesName.isNotEmpty) {
        queryParams['speciesName'] = speciesName;
      }
      if (growthStage != null && growthStage.isNotEmpty) {
        queryParams['growthStage'] = growthStage;
      }
      if (healthStatus != null && healthStatus.isNotEmpty) {
        queryParams['healthStatus'] = healthStatus;
      }

      return await _apiClient.getList<Plant>(
        ApiConstants.backendPlantsPath,
        queryParameters: queryParams,
        fromJson: (json) => Plant.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error (정적 메서드) 사용
      AppLogger.error('getMyPlants 오류: $e');
      return ApiListResponse.error('식물 목록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 특정 식물 정보 가져오기
  Future<ApiResponse<Plant>> getPlantById(String plantId) async {
    try {
      return await _apiClient.get<Plant>(
        '${ApiConstants.backendPlantsPath}/plantId/$plantId', // 백엔드 경로에 맞춤
        fromJson: (json) => Plant.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getPlantById 오류: $e');
      return ApiResponse.error('식물 정보를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 새 식물 등록
  Future<ApiResponse<Plant>> createPlant(CreatePlantRequest request) async {
    try {
      return await _apiClient.post<Plant>(
        ApiConstants.backendPlantsPath,
        data: request.toJson(),
        fromJson: (json) => Plant.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('createPlant 오류: $e');
      return ApiResponse.error('식물 등록 중 오류가 발생했습니다.');
    }
  }

  // 식물 정보 업데이트
  Future<ApiResponse<Plant>> updatePlant(
      String plantId, // String plantId 사용
      UpdatePlantRequest request,
      ) async {
    try {
      // 백엔드 URL을 /plantId/{plantId}로 호출하도록 수정
      return await _apiClient.put<Plant>(
        '${ApiConstants.backendPlantsPath}/plantId/$plantId', // 수정된 백엔드 엔드포인트
        data: request.toJson(),
        fromJson: (json) => Plant.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('updatePlant 오류: $e');
      return ApiResponse.error('식물 정보 업데이트 중 오류가 발생했습니다.');
    }
  }

  // 식물 삭제 (plantId 사용)
  // plantId (String)를 사용하여 백엔드와 일치시킴
  Future<ApiResponse<void>> deletePlant(String plantId) async {
    try {
      // 백엔드 URL을 /plantId/{plantId}로 호출하도록 수정
      return await _apiClient.delete<void>(
        '${ApiConstants.backendPlantsPath}/plantId/$plantId', // 수정된 백엔드 엔드포인트
      );
    } catch (e) {
      AppLogger.error('deletePlant 오류: $e');
      return ApiResponse.error('식물 삭제 중 오류가 발생했습니다.');
    }
  }

  // 식물 활성화/비활성화 토글
  Future<ApiResponse<Plant>> togglePlantStatus(String plantId) async {
    try {
      return await _apiClient.put<Plant>(
        '${ApiConstants.backendPlantsPath}/$plantId/toggle-status',
        fromJson: (json) => Plant.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('togglePlantStatus 오류: $e');
      return ApiResponse.error('식물 상태 변경 중 오류가 발생했습니다.');
    }
  }

  // 식물 검색
  Future<ApiListResponse<Plant>> searchPlants(
      String keyword, {
        int? page,
        int? size,
      }) async {
    try {
      final queryParams = <String, dynamic>{
        'search': keyword,
      };
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;

      return await _apiClient.getList<Plant>(
        '${ApiConstants.backendPlantsPath}/search',
        queryParameters: queryParams,
        fromJson: (json) => Plant.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('searchPlants 오류: $e');
      return ApiListResponse.error('식물 검색 중 오류가 발생했습니다.');
    }
  }

  // 특정 티이운 모델에 연결된 식물들 가져오기
  Future<ApiListResponse<Plant>> getPlantsByTiiunModel(
      String tiiunModelId, {
        int? page,
        int? size,
      }) async {
    try {
      final queryParams = <String, dynamic>{
        'tiiunModelId': tiiunModelId,
      };
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;

      return await _apiClient.getList<Plant>(
        '${ApiConstants.backendPlantsPath}/by-tiiun-model',
        queryParameters: queryParams,
        fromJson: (json) => Plant.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getPlantsByTiiunModel 오류: $e');
      return ApiListResponse.error('티이운 모델별 식물 목록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 성장 단계별 식물 통계
  Future<ApiResponse<Map<String, dynamic>>> getPlantStatsByGrowthStage() async {
    try {
      return await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendPlantsPath}/stats/growth-stage',
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getPlantStatsByGrowthStage 오류: $e');
      return ApiResponse.error('성장 단계별 통계를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 건강 상태별 식물 통계
  Future<ApiResponse<Map<String, dynamic>>> getPlantStatsByHealthStatus() async {
    try {
      return await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendPlantsPath}/stats/health-status',
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getPlantStatsByHealthStatus 오류: $e');
      return ApiResponse.error('건강 상태별 통계를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 종별 식물 통계
  Future<ApiResponse<Map<String, dynamic>>> getPlantStatsBySpecies() async {
    try {
      return await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendPlantsPath}/stats/species',
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getPlantStatsBySpecies 오류: $e');
      return ApiResponse.error('종별 통계를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 사용자의 식물 개수 가져오기
  Future<ApiResponse<int>> getMyPlantCount({bool? isActive}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isActive != null) queryParams['isActive'] = isActive;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendPlantsPath}/count',
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        final count = response.data!['count'] as int? ?? 0;
        return ApiResponse.success(count);
      } else {
        return ApiResponse.error(response.error ?? '식물 개수를 가져오는 중 오류가 발생했습니다.');
      }
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getMyPlantCount 오류: $e');
      return ApiResponse.error('식물 개수를 가져오는 중 오류가 발생했습니다.');
    }
  }
}