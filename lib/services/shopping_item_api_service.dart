import '../models/shopping_item_model.dart';
import '../utils/constants.dart';
import '../utils/logger.dart'; // AppLogger를 정확히 import 하는지 확인하세요.
import 'api_client.dart';

class ShoppingItemApiService {
  final _apiClient = ApiClient();

  Future<ApiListResponse<ShoppingItem>> getShoppingItems({
    int? page,
    int? size,
    ShoppingItemFilter? filter,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;
      if (filter != null) {
        queryParams.addAll(filter.toQueryParameters());
      }

      return await _apiClient.getList<ShoppingItem>(
        ApiConstants.backendShoppingItemsPath,
        queryParameters: queryParams,
        fromJson: (json) => ShoppingItem.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('getShoppingItems 오류: $e');
      return ApiListResponse.error('쇼핑 아이템 목록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  Future<ApiResponse<ShoppingItem>> getShoppingItemById(String itemId) async {
    try {
      return await _apiClient.get<ShoppingItem>(
        '${ApiConstants.backendShoppingItemsPath}/$itemId',
        fromJson: (json) => ShoppingItem.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('getShoppingItemById 오류: $e');
      return ApiResponse.error('쇼핑 아이템 정보를 가져오는 중 오류가 발생했습니다.');
    }
  }

  Future<ApiListResponse<ShoppingItem>> getFeaturedItems({
    int? page,
    int? size,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'isFeatured': true,
      };
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      return await _apiClient.getList<ShoppingItem>(
        '${ApiConstants.backendShoppingItemsPath}/featured',
        queryParameters: queryParams,
        fromJson: (json) => ShoppingItem.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('getFeaturedItems 오류: $e');
      return ApiListResponse.error('추천 상품을 가져오는 중 오류가 발생했습니다.');
    }
  }

  Future<ApiListResponse<ShoppingItem>> getItemsByCategory(
      String category, {
        int? page,
        int? size,
        String? sortBy,
        String? sortOrder,
      }) async {
    try {
      final queryParams = <String, dynamic>{
        'category': category,
      };
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      return await _apiClient.getList<ShoppingItem>(
        '${ApiConstants.backendShoppingItemsPath}/category',
        queryParameters: queryParams,
        fromJson: (json) => ShoppingItem.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('getItemsByCategory 오류: $e');
      return ApiListResponse.error('카테고리별 상품을 가져오는 중 오류가 발생했습니다.');
    }
  }

  Future<ApiListResponse<ShoppingItem>> searchShoppingItems(
      String keyword, {
        int? page,
        int? size,
        ShoppingItemFilter? filter,
      }) async {
    try {
      final queryParams = <String, dynamic>{
        'search': keyword,
      };
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;
      if (filter != null) {
        queryParams.addAll(filter.toQueryParameters());
      }

      return await _apiClient.getList<ShoppingItem>(
        '${ApiConstants.backendShoppingItemsPath}/search',
        queryParameters: queryParams,
        fromJson: (json) => ShoppingItem.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('searchShoppingItems 오류: $e');
      return ApiListResponse.error('상품 검색 중 오류가 발생했습니다.');
    }
  }

  Future<ApiListResponse<ShoppingItem>> getItemsByBrand(
      String brand, {
        int? page,
        int? size,
      }) async {
    try {
      final queryParams = <String, dynamic>{
        'brand': brand,
      };
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;

      return await _apiClient.getList<ShoppingItem>(
        '${ApiConstants.backendShoppingItemsPath}/brand',
        queryParameters: queryParams,
        fromJson: (json) => ShoppingItem.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('getItemsByBrand 오류: $e');
      return ApiListResponse.error('브랜드별 상품을 가져오는 중 오류가 발생했습니다.');
    }
  }

  Future<ApiListResponse<ShoppingItem>> getItemsByPriceRange(
      double minPrice,
      double maxPrice, {
        int? page,
        int? size,
      }) async {
    try {
      final queryParams = <String, dynamic>{
        'minPrice': minPrice,
        'maxPrice': maxPrice,
      };
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;

      return await _apiClient.getList<ShoppingItem>(
        '${ApiConstants.backendShoppingItemsPath}/price-range',
        queryParameters: queryParams,
        fromJson: (json) => ShoppingItem.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('getItemsByPriceRange 오류: $e');
      return ApiListResponse.error('가격대별 상품을 가져오는 중 오류가 발생했습니다.');
    }
  }

  Future<ApiListResponse<ShoppingItem>> getTopRatedItems({
    int? page,
    int? size,
    double? minRating,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'sortBy': 'rating',
        'sortOrder': 'desc',
      };
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;
      if (minRating != null) queryParams['minRating'] = minRating;

      return await _apiClient.getList<ShoppingItem>(
        '${ApiConstants.backendShoppingItemsPath}/top-rated',
        queryParameters: queryParams,
        fromJson: (json) => ShoppingItem.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('getTopRatedItems 오류: $e');
      return ApiListResponse.error('평점 높은 상품을 가져오는 중 오류가 발생했습니다.');
    }
  }

  Future<ApiListResponse<ShoppingItem>> getNewArrivals({
    int? page,
    int? size,
    int? days,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'sortBy': 'created_at',
        'sortOrder': 'desc',
      };
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;
      if (days != null) queryParams['days'] = days;

      return await _apiClient.getList<ShoppingItem>(
        '${ApiConstants.backendShoppingItemsPath}/new-arrivals',
        queryParameters: queryParams,
        fromJson: (json) => ShoppingItem.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('getNewArrivals 오류: $e');
      return ApiListResponse.error('신상품을 가져오는 중 오류가 발생했습니다.');
    }
  }

  Future<ApiListResponse<String>> getCategories() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        '${ApiConstants.backendShoppingItemsPath}/categories',
      );

      if (response.isSuccess && response.data != null) {
        final categories = (response.data as List<dynamic>)
            .map((category) => category.toString())
            .toList();
        return ApiListResponse.success(categories);
      } else {
        return ApiListResponse.error(response.error ?? '카테고리 목록을 가져오는 중 오류가 발생했습니다.');
      }
    } catch (e) {
      AppLogger.error('getCategories 오류: $e');
      return ApiListResponse.error('카테고리 목록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  Future<ApiListResponse<String>> getBrands() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        '${ApiConstants.backendShoppingItemsPath}/brands',
      );

      if (response.isSuccess && response.data != null) {
        final brands = (response.data as List<dynamic>)
            .map((brand) => brand.toString())
            .toList();
        return ApiListResponse.success(brands);
      } else {
        return ApiListResponse.error(response.error ?? '브랜드 목록을 가져오는 중 오류가 발생했습니다.');
      }
    } catch (e) {
      AppLogger.error('getBrands 오류: $e');
      return ApiListResponse.error('브랜드 목록을 가져오는 중 오류가 발생했습니다.');
    }
  }

  Future<ApiResponse<ShoppingItem>> createShoppingItem(
      CreateShoppingItemRequest request,
      ) async {
    try {
      return await _apiClient.post<ShoppingItem>(
        '${ApiConstants.backendShoppingItemsPath}/admin',
        data: request.toJson(),
        fromJson: (json) => ShoppingItem.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('createShoppingItem 오류: $e');
      return ApiResponse.error('쇼핑 아이템 생성 중 오류가 발생했습니다.');
    }
  }
}
