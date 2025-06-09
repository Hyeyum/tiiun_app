import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plant_model.dart';
import '../models/growth_record_model.dart';

import '../models/favorite_model.dart';
import '../models/shopping_item_model.dart';
import '../models/tiiun_model_model.dart';
import 'api_client.dart';
import 'user_api_service.dart';
import 'plant_api_service.dart';
import 'growth_record_api_service.dart';
import 'shopping_item_api_service.dart';
import 'favorite_api_service.dart';
import 'tiiun_model_api_service.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// User API Service Provider
final userApiServiceProvider = Provider<UserApiService>((ref) {
  return UserApiService();
});

// Plant API Service Provider
final plantApiServiceProvider = Provider<PlantApiService>((ref) {
  return PlantApiService();
});

// Growth Record API Service Provider
final growthRecordApiServiceProvider = Provider<GrowthRecordApiService>((ref) {
  return GrowthRecordApiService();
});

// Shopping Item API Service Provider
final shoppingItemApiServiceProvider = Provider<ShoppingItemApiService>((ref) {
  return ShoppingItemApiService();
});

// Favorite API Service Provider
final favoriteApiServiceProvider = Provider<FavoriteApiService>((ref) {
  return FavoriteApiService();
});

// Tiiun Model API Service Provider
final tiiunModelApiServiceProvider = Provider<TiiunModelApiService>((ref) {
  return TiiunModelApiService();
});

// === Data Providers ===

// Current user's plants provider
final myPlantsProvider = FutureProvider<List<Plant>>((ref) async {
  final plantService = ref.watch(plantApiServiceProvider);
  final response = await plantService.getMyPlants();
  if (response.isSuccess) {
    return response.data ?? <Plant>[];
  }
  throw Exception(response.error ?? 'Failed to load plants');
});

// Current user's growth records provider
final myGrowthRecordsProvider = FutureProvider<List<GrowthRecord>>((ref) async {
  final growthRecordService = ref.watch(growthRecordApiServiceProvider);
  final response = await growthRecordService.getMyGrowthRecords();
  if (response.isSuccess) {
    return response.data ?? <GrowthRecord>[];
  }
  throw Exception(response.error ?? 'Failed to load growth records');
});

// Current user's favorites provider
final myFavoritesProvider = FutureProvider<List<FavoriteWithItem>>((ref) async {
  final favoriteService = ref.watch(favoriteApiServiceProvider);
  final response = await favoriteService.getMyFavorites();
  if (response.isSuccess) {
    return response.data ?? <FavoriteWithItem>[];
  }
  throw Exception(response.error ?? 'Failed to load favorites');
});

// Current user's tiiun models provider
final myTiiunModelsProvider = FutureProvider<List<TiiunModel>>((ref) async {
  final tiiunModelService = ref.watch(tiiunModelApiServiceProvider);
  final response = await tiiunModelService.getMyTiiunModels();
  if (response.isSuccess) {
    return response.data ?? <TiiunModel>[];
  }
  throw Exception(response.error ?? 'Failed to load tiiun models');
});

// Featured shopping items provider
final featuredShoppingItemsProvider = FutureProvider<List<ShoppingItem>>((ref) async {
  final shoppingItemService = ref.watch(shoppingItemApiServiceProvider);
  final response = await shoppingItemService.getFeaturedItems();
  if (response.isSuccess) {
    return response.data ?? <ShoppingItem>[];
  }
  throw Exception(response.error ?? 'Failed to load featured items');
});

// Recent growth records provider
final recentGrowthRecordsProvider = FutureProvider<List<GrowthRecord>>((ref) async {
  final growthRecordService = ref.watch(growthRecordApiServiceProvider);
  final response = await growthRecordService.getRecentGrowthRecords();
  if (response.isSuccess) {
    return response.data ?? <GrowthRecord>[];
  }
  throw Exception(response.error ?? 'Failed to load recent growth records');
});

// Plant by ID provider
final plantByIdProvider = FutureProvider.family<Plant?, String>((ref, plantId) async {
  final plantService = ref.watch(plantApiServiceProvider);
  final response = await plantService.getPlantById(plantId);
  if (response.isSuccess) {
    return response.data;
  }
  throw Exception(response.error ?? 'Failed to load plant');
});

// Growth records by plant provider
final growthRecordsByPlantProvider = FutureProvider.family<List<GrowthRecord>, String>((ref, plantId) async {
  final growthRecordService = ref.watch(growthRecordApiServiceProvider);
  final response = await growthRecordService.getGrowthRecordsByPlant(plantId);
  if (response.isSuccess) {
    return response.data ?? <GrowthRecord>[];
  }
  throw Exception(response.error ?? 'Failed to load growth records for plant');
});

// Shopping items by category provider
final shoppingItemsByCategoryProvider = FutureProvider.family<List<ShoppingItem>, String>((ref, category) async {
  final shoppingItemService = ref.watch(shoppingItemApiServiceProvider);
  final response = await shoppingItemService.getItemsByCategory(category);
  if (response.isSuccess) {
    return response.data ?? <ShoppingItem>[];
  }
  throw Exception(response.error ?? 'Failed to load items by category');
});

// Favorite item IDs provider (for quick favorite status checks)
final favoriteItemIdsProvider = FutureProvider<List<String>>((ref) async {
  final favoriteService = ref.watch(favoriteApiServiceProvider);
  final response = await favoriteService.getFavoriteItemIds();
  if (response.isSuccess) {
    return response.data ?? <String>[];
  }
  throw Exception(response.error ?? 'Failed to load favorite item IDs');
});

// Online tiiun models provider
final onlineTiiunModelsProvider = FutureProvider<List<TiiunModel>>((ref) async {
  final tiiunModelService = ref.watch(tiiunModelApiServiceProvider);
  final response = await tiiunModelService.getOnlineTiiunModels();
  if (response.isSuccess) {
    return response.data ?? <TiiunModel>[];
  }
  throw Exception(response.error ?? 'Failed to load online tiiun models');
});

// Plant count provider
final plantCountProvider = FutureProvider<int>((ref) async {
  final plantService = ref.watch(plantApiServiceProvider);
  final response = await plantService.getMyPlantCount();
  if (response.isSuccess) {
    return response.data ?? 0;
  }
  throw Exception(response.error ?? 'Failed to load plant count');
});

// Favorite count provider
final favoriteCountProvider = FutureProvider<int>((ref) async {
  final favoriteService = ref.watch(favoriteApiServiceProvider);
  final response = await favoriteService.getFavoriteCount();
  if (response.isSuccess) {
    return response.data ?? 0;
  }
  throw Exception(response.error ?? 'Failed to load favorite count');
});

// Tiiun model count provider
final tiiunModelCountProvider = FutureProvider<int>((ref) async {
  final tiiunModelService = ref.watch(tiiunModelApiServiceProvider);
  final response = await tiiunModelService.getTiiunModelCount();
  if (response.isSuccess) {
    return response.data ?? 0;
  }
  throw Exception(response.error ?? 'Failed to load tiiun model count');
});
