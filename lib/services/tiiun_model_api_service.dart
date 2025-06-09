import '../models/tiiun_model_model.dart';
import '../utils/constants.dart';
import '../utils/logger.dart'; // AppLogger를 정확히 import 하는지 확인하세요.
import 'api_client.dart';

class TiiunModelApiService {
  final _apiClient = ApiClient();
  // 이 줄을 제거하세요: 여기에서 로거의 인스턴스를 만들 필요가 없습니다.
  // final _logger = Logger();

  // 현재 사용자의 모든 티이운 모델 목록 가져오기
  Future<ApiListResponse<TiiunModel>> getMyTiiunModels({
    int? page,
    int? size,
    String? status,
    String? location,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }

      return await _apiClient.getList<TiiunModel>(
        ApiConstants.backendTiiunModelsPath,
        queryParameters: queryParams,
        fromJson: (json) => TiiunModel.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error (정적 메서드) 사용
      AppLogger.error('getMyTiiunModels 오류: $e');
      return ApiListResponse.error('티이운 모델 목록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 특정 티이운 모델 정보 가져오기
  Future<ApiResponse<TiiunModel>> getTiiunModelById(String tiiunModelId) async {
    try {
      return await _apiClient.get<TiiunModel>(
        '${ApiConstants.backendTiiunModelsPath}/$tiiunModelId',
        fromJson: (json) => TiiunModel.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getTiiunModelById 오류: $e');
      return ApiResponse.error('티이운 모델 정보를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 새 티이운 모델 등록
  Future<ApiResponse<TiiunModel>> registerTiiunModel(
      RegisterTiiunModelRequest request,
      ) async {
    try {
      return await _apiClient.post<TiiunModel>(
        ApiConstants.backendTiiunModelsPath,
        data: request.toJson(),
        fromJson: (json) => TiiunModel.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('registerTiiunModel 오류: $e');
      return ApiResponse.error('티이운 모델 등록 중 오류가 발생했습니다.');
    }
  }

  // 티이운 모델 정보 업데이트
  Future<ApiResponse<TiiunModel>> updateTiiunModel(
      String tiiunModelId,
      UpdateTiiunModelRequest request,
      ) async {
    try {
      return await _apiClient.put<TiiunModel>(
        '${ApiConstants.backendTiiunModelsPath}/$tiiunModelId',
        data: request.toJson(),
        fromJson: (json) => TiiunModel.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('updateTiiunModel 오류: $e');
      return ApiResponse.error('티이운 모델 업데이트 중 오류가 발생했습니다.');
    }
  }

  // 티이운 모델 삭제
  Future<ApiResponse<void>> deleteTiiunModel(String tiiunModelId) async {
    try {
      return await _apiClient.delete<void>(
        '${ApiConstants.backendTiiunModelsPath}/$tiiunModelId',
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('deleteTiiunModel 오류: $e');
      return ApiResponse.error('티이운 모델 삭제 중 오류가 발생했습니다.');
    }
  }

  // 티이운 모델 동기화
  Future<ApiResponse<TiiunModel>> syncTiiunModel(
      String tiiunModelId, {
        Map<String, dynamic>? syncData,
      }) async {
    try {
      final request = SyncTiiunModelRequest(
        tiiunModelId: tiiunModelId,
        syncData: syncData,
      );

      return await _apiClient.post<TiiunModel>(
        '${ApiConstants.backendTiiunModelsPath}/$tiiunModelId/sync',
        data: request.toJson(),
        fromJson: (json) => TiiunModel.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('syncTiiunModel 오류: $e');
      return ApiResponse.error('티이운 모델 동기화 중 오류가 발생했습니다.');
    }
  }

  // 티이운 모델 상태 업데이트
  Future<ApiResponse<TiiunModel>> updateTiiunModelStatus(
      String tiiunModelId,
      String status,
      ) async {
    try {
      final request = UpdateTiiunModelRequest(status: status);
      return await _apiClient.put<TiiunModel>(
        '${ApiConstants.backendTiiunModelsPath}/$tiiunModelId/status',
        data: request.toJson(),
        fromJson: (json) => TiiunModel.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('updateTiiunModelStatus 오류: $e');
      return ApiResponse.error('티이운 모델 상태 업데이트 중 오류가 발생했습니다.');
    }
  }

  // 시리얼 번호로 티이운 모델 검색
  Future<ApiResponse<TiiunModel>> findBySerialNumber(String serialNumber) async {
    try {
      return await _apiClient.get<TiiunModel>(
        '${ApiConstants.backendTiiunModelsPath}/serial/$serialNumber',
        fromJson: (json) => TiiunModel.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('findBySerialNumber 오류: $e');
      return ApiResponse.error('시리얼 번호로 티이운 모델을 찾는 중 오류가 발생했습니다.');
    }
  }

  // 온라인 상태인 티이운 모델들 가져오기
  Future<ApiListResponse<TiiunModel>> getOnlineTiiunModels({
    int? page,
    int? size,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'status': 'online',
      };
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;

      return await _apiClient.getList<TiiunModel>(
        '${ApiConstants.backendTiiunModelsPath}/online',
        queryParameters: queryParams,
        fromJson: (json) => TiiunModel.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getOnlineTiiunModels 오류: $e');
      return ApiListResponse.error('온라인 티이운 모델을 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 특정 위치의 티이운 모델들 가져오기
  Future<ApiListResponse<TiiunModel>> getTiiunModelsByLocation(
      String location, {
        int? page,
        int? size,
      }) async {
    try {
      final queryParams = <String, dynamic>{
        'location': location,
      };
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;

      return await _apiClient.getList<TiiunModel>(
        '${ApiConstants.backendTiiunModelsPath}/location',
        queryParameters: queryParams,
        fromJson: (json) => TiiunModel.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getTiiunModelsByLocation 오류: $e');
      return ApiListResponse.error('위치별 티이운 모델을 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 티이운 모델 검색
  Future<ApiListResponse<TiiunModel>> searchTiiunModels(
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

      return await _apiClient.getList<TiiunModel>(
        '${ApiConstants.backendTiiunModelsPath}/search',
        queryParameters: queryParams,
        fromJson: (json) => TiiunModel.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('searchTiiunModels 오류: $e');
      return ApiListResponse.error('티이운 모델 검색 중 오류가 발생했습니다.');
    }
  }

  // 펌웨어 업데이트 가능한 티이운 모델들 가져오기
  Future<ApiListResponse<TiiunModel>> getUpdatableTiiunModels({
    int? page,
    int? size,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;

      return await _apiClient.getList<TiiunModel>(
        '${ApiConstants.backendTiiunModelsPath}/updatable',
        queryParameters: queryParams,
        fromJson: (json) => TiiunModel.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getUpdatableTiiunModels 오류: $e');
      return ApiListResponse.error('업데이트 가능한 티이운 모델을 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 티이운 모델 상태별 통계
  Future<ApiResponse<Map<String, dynamic>>> getTiiunModelStatsByStatus() async {
    try {
      return await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendTiiunModelsPath}/stats/status',
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getTiiunModelStatsByStatus 오류: $e');
      return ApiResponse.error('상태별 티이운 모델 통계를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 위치별 티이운 모델 통계
  Future<ApiResponse<Map<String, dynamic>>> getTiiunModelStatsByLocation() async {
    try {
      return await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendTiiunModelsPath}/stats/location',
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getTiiunModelStatsByLocation 오류: $e');
      return ApiResponse.error('위치별 티이운 모델 통계를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 펌웨어 버전별 티이운 모델 통계
  Future<ApiResponse<Map<String, dynamic>>> getTiiunModelStatsByFirmware() async {
    try {
      return await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendTiiunModelsPath}/stats/firmware',
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getTiiunModelStatsByFirmware 오류: $e');
      return ApiResponse.error('펌웨어별 티이운 모델 통계를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 티이운 모델 개수 가져오기
  Future<ApiResponse<int>> getTiiunModelCount({
    String? status,
    String? location,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (location != null) queryParams['location'] = location;

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendTiiunModelsPath}/count',
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        final count = response.data!['count'] as int? ?? 0;
        return ApiResponse.success(count);
      } else {
        return ApiResponse.error(response.error ?? '티이운 모델 개수를 가져오는 중 오류가 발생했습니다.');
      }
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getTiiunModelCount 오류: $e');
      return ApiResponse.error('티이운 모델 개수를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 최근 동기화된 티이운 모델들 가져오기
  Future<ApiListResponse<TiiunModel>> getRecentlySyncedModels({
    int limit = 10,
    int? hours, // 몇 시간 이내
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (hours != null) queryParams['hours'] = hours;

      return await _apiClient.getList<TiiunModel>(
        '${ApiConstants.backendTiiunModelsPath}/recently-synced',
        queryParameters: queryParams,
        fromJson: (json) => TiiunModel.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getRecentlySyncedModels 오류: $e');
      return ApiListResponse.error('최근 동기화된 티이운 모델을 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 오프라인 상태인 티이운 모델들 가져오기
  Future<ApiListResponse<TiiunModel>> getOfflineTiiunModels({
    int? page,
    int? size,
    int? hours, // 몇 시간 이상 오프라인
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'status': 'offline',
      };
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;
      if (hours != null) queryParams['hours'] = hours;

      return await _apiClient.getList<TiiunModel>(
        '${ApiConstants.backendTiiunModelsPath}/offline',
        queryParameters: queryParams,
        fromJson: (json) => TiiunModel.fromJson(json),
      );
    } catch (e) {
      // 수정: AppLogger.error 사용
      AppLogger.error('getOfflineTiiunModels 오류: $e');
      return ApiListResponse.error('오프라인 티이운 모델을 가져오는 중 오류가 발생했습니다.');
    }
  }
}