import '../models/favorite_model.dart';
import '../utils/constants.dart';
import '../utils/logger.dart'; // Make sure this path is correct for AppLogger
import 'api_client.dart';

class FavoriteApiService {
  final _apiClient = ApiClient();
  // REMOVE THIS LINE: You don't need a local instance of Logger or AppLogger here
  // final _logger = Logger();

  // 현재 사용자의 즐겨찾기 목록 가져오기
  Future<ApiListResponse<FavoriteWithItem>> getMyFavorites({
    int? page,
    int? size,
    String? category,
    bool? isAvailable,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (isAvailable != null) queryParams['isAvailable'] = isAvailable;

      return await _apiClient.getList<FavoriteWithItem>(
        ApiConstants.backendFavoritesPath,
        queryParameters: queryParams,
        fromJson: (json) => FavoriteWithItem.fromJson(json),
      );
    } catch (e) {
      // FIX: Use AppLogger.error (the static method)
      AppLogger.error('getMyFavorites 오류: $e');
      return ApiListResponse.error('즐겨찾기 목록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 즐겨찾기 추가
  Future<ApiResponse<Favorite>> addToFavorites(String itemId) async {
    try {
      final request = CreateFavoriteRequest(itemId: itemId);
      return await _apiClient.post<Favorite>(
        ApiConstants.backendFavoritesPath,
        data: request.toJson(),
        fromJson: (json) => Favorite.fromJson(json),
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('addToFavorites 오류: $e');
      return ApiResponse.error('즐겨찾기 추가 중 오류가 발생했습니다.');
    }
  }

  // 즐겨찾기 제거
  Future<ApiResponse<void>> removeFromFavorites(String itemId) async {
    try {
      return await _apiClient.delete<void>(
        '${ApiConstants.backendFavoritesPath}/$itemId',
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('removeFromFavorites 오류: $e');
      return ApiResponse.error('즐겨찾기 제거 중 오류가 발생했습니다.');
    }
  }

  // 특정 아이템이 즐겨찾기에 있는지 확인
  Future<ApiResponse<bool>> isFavorite(String itemId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendFavoritesPath}/$itemId/check',
      );

      if (response.isSuccess && response.data != null) {
        final isFavorite = response.data!['isFavorite'] as bool? ?? false;
        return ApiResponse.success(isFavorite);
      } else {
        return ApiResponse.error(response.error ?? '즐겨찾기 확인 중 오류가 발생했습니다.');
      }
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('isFavorite 오류: $e');
      return ApiResponse.error('즐겨찾기 확인 중 오류가 발생했습니다.');
    }
  }

  // 여러 아이템의 즐겨찾기 상태를 한번에 확인
  Future<ApiResponse<Map<String, bool>>> checkMultipleFavorites(
      List<String> itemIds,
      ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.backendFavoritesPath}/check-multiple',
        data: {'itemIds': itemIds},
      );

      if (response.isSuccess && response.data != null) {
        final favorites = Map<String, bool>.from(
          response.data!['favorites'] as Map<String, dynamic>? ?? {},
        );
        return ApiResponse.success(favorites);
      } else {
        return ApiResponse.error(response.error ?? '즐겨찾기 상태 확인 중 오류가 발생했습니다.');
      }
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('checkMultipleFavorites 오류: $e');
      return ApiResponse.error('즐겨찾기 상태 확인 중 오류가 발생했습니다.');
    }
  }

  // 즐겨찾기 토글 (있으면 제거, 없으면 추가)
  Future<ApiResponse<bool>> toggleFavorite(String itemId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.backendFavoritesPath}/$itemId/toggle',
      );

      if (response.isSuccess && response.data != null) {
        final isFavorite = response.data!['isFavorite'] as bool? ?? false;
        return ApiResponse.success(isFavorite);
      } else {
        return ApiResponse.error(response.error ?? '즐겨찾기 토글 중 오류가 발생했습니다.');
      }
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('toggleFavorite 오류: $e');
      return ApiResponse.error('즐겨찾기 토글 중 오류가 발생했습니다.');
    }
  }

  // 즐겨찾기 개수 가져오기
  Future<ApiResponse<int>> getFavoriteCount() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendFavoritesPath}/count',
      );

      if (response.isSuccess && response.data != null) {
        final count = response.data!['count'] as int? ?? 0;
        return ApiResponse.success(count);
      } else {
        return ApiResponse.error(response.error ?? '즐겨찾기 개수를 가져오는 중 오류가 발생했습니다.');
      }
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('getFavoriteCount 오류: $e');
      return ApiResponse.error('즐겨찾기 개수를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 카테고리별 즐겨찾기 목록 가져오기
  Future<ApiListResponse<FavoriteWithItem>> getFavoritesByCategory(
      String category, {
        int? page,
        int? size,
      }) async {
    try {
      final queryParams = <String, dynamic>{
        'category': category,
      };
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;

      return await _apiClient.getList<FavoriteWithItem>(
        '${ApiConstants.backendFavoritesPath}/category',
        queryParameters: queryParams,
        fromJson: (json) => FavoriteWithItem.fromJson(json),
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('getFavoritesByCategory 오류: $e');
      return ApiListResponse.error('카테고리별 즐겨찾기를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 즐겨찾기 검색
  Future<ApiListResponse<FavoriteWithItem>> searchFavorites(
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

      return await _apiClient.getList<FavoriteWithItem>(
        '${ApiConstants.backendFavoritesPath}/search',
        queryParameters: queryParams,
        fromJson: (json) => FavoriteWithItem.fromJson(json),
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('searchFavorites 오류: $e');
      return ApiListResponse.error('즐겨찾기 검색 중 오류가 발생했습니다.');
    }
  }

  // 최근 즐겨찾기한 아이템들 가져오기
  Future<ApiListResponse<FavoriteWithItem>> getRecentFavorites({
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };

      return await _apiClient.getList<FavoriteWithItem>(
        '${ApiConstants.backendFavoritesPath}/recent',
        queryParameters: queryParams,
        fromJson: (json) => FavoriteWithItem.fromJson(json),
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('getRecentFavorites 오류: $e');
      return ApiListResponse.error('최근 즐겨찾기를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 즐겨찾기 전체 삭제
  Future<ApiResponse<void>> clearAllFavorites() async {
    try {
      return await _apiClient.delete<void>(
        '${ApiConstants.backendFavoritesPath}/clear',
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('clearAllFavorites 오류: $e');
      return ApiResponse.error('즐겨찾기 전체 삭제 중 오류가 발생했습니다.');
    }
  }

  // 즐겨찾기 카테고리별 통계
  Future<ApiResponse<Map<String, dynamic>>> getFavoriteCategoryStats() async {
    try {
      return await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.backendFavoritesPath}/stats/category',
      );
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('getFavoriteCategoryStats 오류: $e');
      return ApiResponse.error('즐겨찾기 카테고리 통계를 가져오는 중 오류가 발생했습니다.');
    }
  }

  // 즐겨찾기 목록 ID만 가져오기 (가벼운 요청용)
  Future<ApiListResponse<String>> getFavoriteItemIds() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        '${ApiConstants.backendFavoritesPath}/item-ids',
      );

      if (response.isSuccess && response.data != null) {
        final itemIds = (response.data as List<dynamic>)
            .map((id) => id.toString())
            .toList();
        return ApiListResponse.success(itemIds);
      } else {
        return ApiListResponse.error(response.error ?? '즐겨찾기 아이템 ID를 가져오는 중 오류가 발생했습니다.');
      }
    } catch (e) {
      // FIX: Use AppLogger.error
      AppLogger.error('getFavoriteItemIds 오류: $e');
      return ApiListResponse.error('즐겨찾기 아이템 ID를 가져오는 중 오류가 발생했습니다.');
    }
  }
}