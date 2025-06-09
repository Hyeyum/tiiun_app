import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/favorite_model.dart';
import '../../services/backend_providers.dart';
import '../../services/favorite_api_service.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../utils/constants.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  List<FavoriteWithItem> _favorites = [];
  bool _isLoading = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      final favoriteService = ref.read(favoriteApiServiceProvider);
      final response = await favoriteService.getMyFavorites(
        category: _selectedCategory,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _favorites = response.data!;
        });
      } else {
        _showErrorSnackBar('즐겨찾기를 불러오는데 실패했습니다: ${response.error}');
      }
    } catch (e) {
      _showErrorSnackBar('즐겨찾기를 불러오는 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteCountAsync = ref.watch(favoriteCountProvider);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text(
          '즐겨찾기',
          style: AppTypography.h1.copyWith(
            color: AppColors.grey900,
          ),
        ),
        backgroundColor: AppColors.white100,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_favorites.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.main800),
              onSelected: (value) {
                switch (value) {
                  case 'clear_all':
                    _showClearAllConfirmation();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('전체 삭제'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // 통계 카드
          _buildStatsCard(favoriteCountAsync),

          // 카테고리 필터
          _buildCategoryFilter(),

          // 즐겨찾기 목록
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(color: AppColors.main600),
            )
                : _favorites.isEmpty
                ? _buildEmptyState()
                : _buildFavoritesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(AsyncValue<int> favoriteCountAsync) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.main500,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.main800.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '즐겨찾기한 상품',
                  style: AppTypography.b2.copyWith(
                    color: AppColors.main800,
                  ),
                ),
                const SizedBox(height: 4),
                favoriteCountAsync.when(
                  data: (count) => Text(
                    '$count개',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.main300,
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.main900,
                    ),
                  ),
                  error: (_, __) => Text(
                    '-',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.main300,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _refreshData(),
            icon: const Icon(Icons.refresh, color: AppColors.main900),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip('전체', null),
          _buildCategoryChip('식물관리', '식물관리'),
          _buildCategoryChip('화분', '화분'),
          _buildCategoryChip('도구', '도구'),
          _buildCategoryChip('영양제', '영양제'),
          _buildCategoryChip('장식품', '장식품'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
          _loadFavorites();
        },
        backgroundColor: AppColors.main500,
        selectedColor: AppColors.main900.withOpacity(0.1),
        labelStyle: AppTypography.b2.copyWith(
          color: isSelected ? AppColors.main900 : AppColors.main800,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.main900 : AppColors.main800.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.main600,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final favorite = _favorites[index];
          return _buildFavoriteCard(favorite);
        },
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriteWithItem favorite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.main500,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.main800.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // 상품 이미지
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.main900.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: favorite.itemImageUrl != null && favorite.itemImageUrl!.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                favorite.itemImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.shopping_bag,
                    color: AppColors.main900,
                  );
                },
              ),
            )
                : const Icon(
              Icons.shopping_bag,
              color: AppColors.main900,
            ),
          ),
          const SizedBox(width: 16),

          // 상품 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  favorite.itemName ?? '상품명 없음',
                  style: AppTypography.s1.copyWith(
                    color: AppColors.main300,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (favorite.itemCategory != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.main800.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      favorite.itemCategory!,
                      style: AppTypography.c1.copyWith(
                        color: AppColors.main800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (favorite.itemPrice != null)
                      Text(
                        '₩${favorite.itemPrice!.toStringAsFixed(0).replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                        )}',
                        style: AppTypography.s1.copyWith(
                          color: AppColors.main900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const Spacer(),
                    if (favorite.itemRating != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            favorite.itemRating!.toStringAsFixed(1),
                            style: AppTypography.b2.copyWith(
                              color: AppColors.main800,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '즐겨찾기 추가: ${_formatDate(favorite.createdAt)}',
                  style: AppTypography.c1.copyWith(
                    color: AppColors.main800,
                  ),
                ),
                if (!favorite.itemIsAvailable)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '품절',
                        style: AppTypography.c1.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 액션 버튼
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.main800),
            onSelected: (value) {
              switch (value) {
                case 'remove':
                  _showRemoveConfirmation(favorite);
                  break;
                case 'view':
                  _viewItemDetails(favorite);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility, color: AppColors.main900),
                    SizedBox(width: 8),
                    Text('상품 보기'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.favorite_border, color: Colors.red),
                    SizedBox(width: 8),
                    Text('즐겨찾기 해제'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: AppColors.main800.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '즐겨찾기한 상품이 없어요',
            style: AppTypography.s1.copyWith(
              color: AppColors.main800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '마음에 드는 상품을 즐겨찾기에 추가해보세요!',
            style: AppTypography.b2.copyWith(
              color: AppColors.main800,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('쇼핑하러 가기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.main600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '알 수 없음';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  Future<void> _refreshData() async {
    await _loadFavorites();
    ref.invalidate(favoriteCountProvider);
  }

  void _showRemoveConfirmation(FavoriteWithItem favorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('즐겨찾기 해제'),
        content: Text('${favorite.itemName}을(를) 즐겨찾기에서 제거하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFavorite(favorite);
            },
            child: const Text('제거', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 삭제'),
        content: const Text('모든 즐겨찾기를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllFavorites();
            },
            child: const Text('전체 삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _viewItemDetails(FavoriteWithItem favorite) {
    // TODO: 상품 상세 페이지로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${favorite.itemName} 상세 페이지로 이동합니다.'),
        backgroundColor: AppColors.main900,
      ),
    );
  }

  void _removeFavorite(FavoriteWithItem favorite) async {
    try {
      final favoriteService = ref.read(favoriteApiServiceProvider);
      final response = await favoriteService.removeFromFavorites(favorite.itemId);

      if (response.isSuccess) {
        setState(() {
          _favorites.removeWhere((f) => f.itemId == favorite.itemId);
        });
        _showSuccessSnackBar('즐겨찾기에서 제거되었습니다.');
        ref.invalidate(favoriteCountProvider);
      } else {
        _showErrorSnackBar('제거 실패: ${response.error}');
      }
    } catch (e) {
      _showErrorSnackBar('제거 중 오류가 발생했습니다: $e');
    }
  }

  void _clearAllFavorites() async {
    try {
      final favoriteService = ref.read(favoriteApiServiceProvider);
      final response = await favoriteService.clearAllFavorites();

      if (response.isSuccess) {
        setState(() {
          _favorites.clear();
        });
        _showSuccessSnackBar('모든 즐겨찾기가 삭제되었습니다.');
        ref.invalidate(favoriteCountProvider);
      } else {
        _showErrorSnackBar('삭제 실패: ${response.error}');
      }
    } catch (e) {
      _showErrorSnackBar('삭제 중 오류가 발생했습니다: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
