import '../models/growth_record_model.dart';
import '../utils/constants.dart';
import '../utils/logger.dart'; // Ensure this correctly imports your AppLogger
import 'api_client.dart';

class GrowthRecordApiService {
  final _apiClient = ApiClient();
  // REMOVE THIS LINE: You do not need to create an instance of a logger here.
  // final _logger = Logger();

  // 특정 식물의 성장 기록 목록 가져오기
  Future<ApiListResponse<GrowthRecord>> getGrowthRecordsByPlant(
      String plantId, {
        int? page,
        int? size,
        DateTime? startDate,
        DateTime? endDate,
        String? growthStage,
        String? healthStatus,
      }) async {
    try {
      final queryParams = <String, dynamic>{
        'plantId': plantId,
      };
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (growthStage != null && growthStage.isNotEmpty) {
        queryParams['growthStage'] = growthStage;
      }
      if (healthStatus != null && healthStatus.isNotEmpty) {
        queryParams['healthStatus'] = healthStatus;
      }

      return await _apiClient.getList<GrowthRecord>(
        ApiConstants.backendGrowthRecordsPath,
        queryParameters: queryParams,
        fromJson: (json) => GrowthRecord.fromJson(json),
      );
    } catch (e) {
      // FIX: Use AppLogger.error (the static method)
      AppLogger.error('getGrowthRecordsByPlant 오류: $e');
      return ApiListResponse.error('성장 기록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 현재 사용자의 모든 성장 기록 가져오기
  Future<ApiListResponse<GrowthRecord>> getMyGrowthRecords({
    int? page,
    int? size,
    DateTime? startDate,
    DateTime? endDate,
    String? plantId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (plantId != null && plantId.isNotEmpty) {
        queryParams['plantId'] = plantId;
      }

      return await _apiClient.getList<GrowthRecord>(
        '${ApiConstants.backendGrowthRecordsPath}/my',
        queryParameters: queryParams,
        fromJson: (json) => GrowthRecord.fromJson(json),
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('getMyGrowthRecords 오류: $e');
      return ApiListResponse.error('성장 기록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 특정 성장 기록 정보 가져오기
  Future<ApiResponse<GrowthRecord>> getGrowthRecordById(String recordId) async {
    try {
      return await _apiClient.get<GrowthRecord>(
        '${ApiConstants.backendGrowthRecordsPath}/$recordId',
        fromJson: (json) => GrowthRecord.fromJson(json),
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('getGrowthRecordById 오류: $e');
      return ApiResponse.error('성장 기록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 새 성장 기록 생성
  Future<ApiResponse<GrowthRecord>> createGrowthRecord(
      CreateGrowthRecordRequest request,
      ) async {
    try {
      return await _apiClient.post<GrowthRecord>(
        ApiConstants.backendGrowthRecordsPath,
        data: request.toJson(),
        fromJson: (json) => GrowthRecord.fromJson(json),
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('createGrowthRecord 오류: $e');
      return ApiResponse.error('성장 기록 생성 중 오류가 발생했습니다.');
    }
  }

  // 성장 기록 업데이트
  Future<ApiResponse<GrowthRecord>> updateGrowthRecord(
      String recordId,
      UpdateGrowthRecordRequest request,
      ) async {
    try {
      return await _apiClient.put<GrowthRecord>(
        '${ApiConstants.backendGrowthRecordsPath}/$recordId',
        data: request.toJson(),
        fromJson: (json) => GrowthRecord.fromJson(json),
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('updateGrowthRecord 오류: $e');
      return ApiResponse.error('성장 기록 업데이트 중 오류가 발생했습니다.');
    }
  }

  // 성장 기록 삭제
  Future<ApiResponse<void>> deleteGrowthRecord(String recordId) async {
    try {
      return await _apiClient.delete<void>(
        '${ApiConstants.backendGrowthRecordsPath}/$recordId',
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('deleteGrowthRecord 오류: $e');
      return ApiResponse.error('성장 기록 삭제 중 오류가 발생했습니다.');
    }
  }

  // 성장 기록 검색
  Future<ApiListResponse<GrowthRecord>> searchGrowthRecords(
      String keyword, {
        int? page,
        int? size,
        String? plantId,
      }) async {
    try {
      final queryParams = <String, dynamic>{
        'search': keyword,
      };
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;
      if (plantId != null && plantId.isNotEmpty) {
        queryParams['plantId'] = plantId;
      }

      return await _apiClient.getList<GrowthRecord>(
        '${ApiConstants.backendGrowthRecordsPath}/search',
        queryParameters: queryParams,
        fromJson: (json) => GrowthRecord.fromJson(json),
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('searchGrowthRecords 오류: $e');
      return ApiListResponse.error('성장 기록 검색 중 오류가 발생했습니다.');
    }
  }

  // 특정 날짜의 성장 기록 가져오기
  Future<ApiListResponse<GrowthRecord>> getGrowthRecordsByDate(
      DateTime date, {
        String? plantId,
      }) async {
    try {
      final queryParams = <String, dynamic>{
        'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD 형식
      };
      if (plantId != null && plantId.isNotEmpty) {
        queryParams['plantId'] = plantId;
      }

      return await _apiClient.getList<GrowthRecord>(
        '${ApiConstants.backendGrowthRecordsPath}/by-date',
        queryParameters: queryParams,
        fromJson: (json) => GrowthRecord.fromJson(json),
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('getGrowthRecordsByDate 오류: $e');
      return ApiListResponse.error('날짜별 성장 기록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 성장 추이 데이터 가져오기 (차트용)
  Future<ApiResponse<Map<String, dynamic>>> getGrowthTrend(
      String plantId, {
        DateTime? startDate,
        DateTime? endDate,
        String? metric, // height, width 등
      }) async {
    try {
      final queryParams = <String, dynamic>{
        'plantId': plantId,
      };
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (metric != null && metric.isNotEmpty) {
        queryParams['metric'] = metric;
      }

      return await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendGrowthRecordsPath}/trend',
        queryParameters: queryParams,
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('getGrowthTrend 오류: $e');
      return ApiResponse.error('성장 추이 데이터를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 성장 단계별 통계
  Future<ApiResponse<Map<String, dynamic>>> getGrowthStageStats(
      String plantId,
      ) async {
    try {
      return await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendGrowthRecordsPath}/stats/growth-stage',
        queryParameters: {'plantId': plantId},
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('getGrowthStageStats 오류: $e');
      return ApiResponse.error('성장 단계별 통계를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 건강 상태별 통계
  Future<ApiResponse<Map<String, dynamic>>> getHealthStatusStats(
      String plantId,
      ) async {
    try {
      return await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendGrowthRecordsPath}/stats/health-status',
        queryParameters: {'plantId': plantId},
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('getHealthStatusStats 오류: $e');
      return ApiResponse.error('건강 상태별 통계를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 최근 성장 기록 가져오기
  Future<ApiListResponse<GrowthRecord>> getRecentGrowthRecords({
    int limit = 10,
    String? plantId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (plantId != null && plantId.isNotEmpty) {
        queryParams['plantId'] = plantId;
      }

      return await _apiClient.getList<GrowthRecord>(
        '${ApiConstants.backendGrowthRecordsPath}/recent',
        queryParameters: queryParams,
        fromJson: (json) => GrowthRecord.fromJson(json),
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('getRecentGrowthRecords 오류: $e');
      return ApiListResponse.error('최근 성장 기록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 성장 기록 개수 가져오기
  Future<ApiResponse<int>> getGrowthRecordCount({
    String? plantId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (plantId != null && plantId.isNotEmpty) {
        queryParams['plantId'] = plantId;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendGrowthRecordsPath}/count',
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        final count = response.data!['count'] as int? ?? 0;
        return ApiResponse.success(count);
      } else {
        return ApiResponse.error(response.error ?? '성장 기록 개수를 가져오는 중 오류가 발생했습니다.');
      }
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('getGrowthRecordCount 오류: $e');
      return ApiResponse.error('성장 기록 개수를 가져오는 중 오류가 발생했습니다.');
    }
  }
}