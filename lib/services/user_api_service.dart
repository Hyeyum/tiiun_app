// 새 폴더/lib/services/user_api_service.dart
import '../models/backend_user_model.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';
import 'api_client.dart';

class UserApiService {
  final _apiClient = ApiClient();
  // 제거됨: final _logger = Logger();

  // 현재 인증된 사용자 정보 가져오기
  Future<ApiResponse<BackendUser>> getCurrentUser() async {
    try {
      return await _apiClient.get<BackendUser>(
        '${ApiConstants.backendUsersPath}/me',
        fromJson: (json) => BackendUser.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('getCurrentUser 오류: $e');
      return ApiResponse.error('사용자 정보를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // Firebase 인증 후 사용자 정보 생성 또는 업데이트
  Future<ApiResponse<BackendUser>> createOrUpdateUser(
      CreateUserRequest request,
      ) async {
    try {
      return await _apiClient.post<BackendUser>(
        '${ApiConstants.backendAuthPath}/login-or-register',
        data: request.toJson(),
        fromJson: (json) => BackendUser.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('createOrUpdateUser 오류: $e');
      return ApiResponse.error('사용자 생성/업데이트 중 오류가 발생했습니다.');
    }
  }

  // 사용자 정보 업데이트
  Future<ApiResponse<BackendUser>> updateUser(
      UpdateUserRequest request,
      ) async {
    try {
      return await _apiClient.put<BackendUser>(
        '${ApiConstants.backendUsersPath}/me',
        data: request.toJson(),
        fromJson: (json) => BackendUser.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('updateUser 오류: $e');
      return ApiResponse.error('사용자 정보 업데이트 중 오류가 발생했습니다.');
    }
  }

  // 사용자 삭제 (계정 비활성화)
  Future<ApiResponse<void>> deleteUser() async {
    try {
      return await _apiClient.delete<void>(
        '${ApiConstants.backendUsersPath}/me',
      );
    } catch (e) {
      AppLogger.error('deleteUser 오류: $e');
      return ApiResponse.error('계정 삭제 중 오류가 발생했습니다.');
    }
  }

  // 사용자 활성 상태 업데이트 (마지막 활동 시간 갱신)
  Future<ApiResponse<void>> updateLastActiveTime() async {
    try {
      return await _apiClient.put<void>(
        '${ApiConstants.backendUsersPath}/last-active',
      );
    } catch (e) {
      AppLogger.error('updateLastActiveTime 오류: $e');
      return ApiResponse.error('활동 시간 업데이트 중 오류가 발생했습니다.');
    }
  }

  // 특정 사용자 정보 가져오기 (관리자용)
  Future<ApiResponse<BackendUser>> getUserById(String userId) async {
    try {
      return await _apiClient.get<BackendUser>(
        '${ApiConstants.backendUsersPath}/$userId',
        fromJson: (json) => BackendUser.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('getUserById 오류: $e');
      return ApiResponse.error('사용자 정보를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 모든 사용자 목록 가져오기 (관리자용)
  Future<ApiListResponse<BackendUser>> getAllUsers({
    int? page,
    int? size,
    String? search,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (isActive != null) queryParams['isActive'] = isActive;

      return await _apiClient.getList<BackendUser>(
        ApiConstants.backendUsersPath,
        queryParameters: queryParams,
        fromJson: (json) => BackendUser.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('getAllUsers 오류: $e');
      return ApiListResponse.error('사용자 목록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 사용자 검색
  Future<ApiListResponse<BackendUser>> searchUsers(
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

      return await _apiClient.getList<BackendUser>(
        '${ApiConstants.backendUsersPath}/search',
        queryParameters: queryParams,
        fromJson: (json) => BackendUser.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('searchUsers 오류: $e');
      return ApiListResponse.error('사용자 검색 중 오류가 발생했습니다.');
    }
  }

  // 사용자 통계 정보 가져오기 (관리자용)
  Future<ApiResponse<Map<String, dynamic>>> getUserStats() async {
    try {
      return await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendUsersPath}/stats',
      );
    } catch (e) {
      AppLogger.error('getUserStats 오류: $e');
      return ApiResponse.error('사용자 통계를 가져오는 중 오류가 발생했습니다.');
    }
  }
}