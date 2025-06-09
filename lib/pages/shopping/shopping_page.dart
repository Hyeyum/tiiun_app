import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shopping_item_model.dart';
import '../../services/backend_providers.dart';
import '../../services/shopping_item_api_service.dart';
import '../../services/favorite_api_service.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../../utils/constants.dart';
import 'favorites_page.dart'; // 즐겨찾기 페이지 추가

class ShoppingPage extends ConsumerStatefulWidget {
  const ShoppingPage({super.key});

  @override
  ConsumerState<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends ConsumerState<ShoppingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  List<ShoppingItem> _items = [];
  Set<String> _favoriteItemIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadItems(),
      _loadFavoriteIds(),
    ]);
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);

    try {
      final shoppingService = ref.read(shoppingItemApiServiceProvider);

      final filter = ShoppingItemFilter(
        searchKeyword: _searchQuery.isNotEmpty ? _searchQuery : null,
        category: _selectedCategory,
        isAvailable: true,
        sortBy: 'created_at',
        sortOrder: 'desc',
      );

      final response = await shoppingService.getShoppingItems(filter: filter);

      if (response.isSuccess && response.data != null) {
        setState(() {
          _items = List<ShoppingItem>.from(response.data!);
        });
      } else {
        _showErrorSnackBar('상품을 불러오는데 실패했습니다: ${response.error}');
      }
    } catch (e) {
      _showErrorSnackBar('상품을 불러오는 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFavoriteIds() async {
    try {
      final favoriteService = ref.read(favoriteApiServiceProvider);
      final response = await favoriteService.getFavoriteItemIds();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _favoriteItemIds = response.data!.toSet();
        });
      }
    } catch (e) {
      print('즐겨찾기 목록 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text(
          '쇼핑몰',
          style: AppTypography.h1.copyWith(
            color: AppColors.grey900,
          ),
        ),
        backgroundColor: AppColors.white100,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: AppColors.main600),
            onPressed: () => _navigateToFavorites(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.main900,
          unselectedLabelColor: AppColors.main800,
          indicatorColor: AppColors.main900,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '추천'),
            Tab(text: '신상품'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 검색바
          _buildSearchBar(),

          // 카테고리 필터
          _buildCategoryFilter(),

          // 상품 목록
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildItemList(_items), // 전체
                _buildFeaturedItems(), // 추천
                _buildNewArrivals(), // 신상품
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '상품을 검색해보세요',
          prefixIcon: const Icon(Icons.search, color: AppColors.main800),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: AppColors.main800),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
              _loadItems();
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey600.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey600.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.main600),
          ),
        ),
        onSubmitted: (value) {
          setState(() => _searchQuery = value);
          _loadItems();
        },
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
          _loadItems();
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

  Widget _buildItemList(List<ShoppingItem> items) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.main900),
      );
    }

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      color: AppColors.main900,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildItemCard(item);
        },
      ),
    );
  }

  Widget _buildItemCard(ShoppingItem item) {
    final isFavorite = _favoriteItemIds.contains(item.itemId);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.main500,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.main800.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.main900.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.shopping_bag,
                            color: AppColors.main900,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  )
                      : const Center(
                    child: Icon(
                      Icons.shopping_bag,
                      color: AppColors.main900,
                      size: 32,
                    ),
                  ),
                ),

                // 즐겨찾기 버튼
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(item),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : AppColors.main800,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // 품절 표시
                if (item.isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '품절',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 상품 정보
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.s2.copyWith(
                      color: AppColors.main300,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.brand != null)
                    Text(
                      item.brand!,
                      style: AppTypography.c1.copyWith(
                        color: AppColors.main800,
                      ),
                    ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.formattedPrice,
                          style: AppTypography.s1.copyWith(
                            color: AppColors.main900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (item.rating != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              item.rating!.toStringAsFixed(1),
                              style: AppTypography.c1.copyWith(
                                color: AppColors.main800,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedItems() {
    return Consumer(
      builder: (context, ref, child) {
        final featuredAsync = ref.watch(featuredShoppingItemsProvider);

        return featuredAsync.when(
          data: (items) => _buildItemList(items),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.main600),
          ),
          error: (error, stack) => _buildErrorWidget(error.toString()),
        );
      },
    );
  }

  Widget _buildNewArrivals() {
    return FutureBuilder<List<ShoppingItem>>(
      future: _loadNewArrivals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.main900),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        final items = snapshot.data ?? <ShoppingItem>[];
        return _buildItemList(items);
      },
    );
  }

  Future<List<ShoppingItem>> _loadNewArrivals() async {
    try {
      final shoppingService = ref.read(shoppingItemApiServiceProvider);
      final response = await shoppingService.getNewArrivals(days: 30);

      if (response.isSuccess && response.data != null) {
        return response.data!;
      }
      return <ShoppingItem>[];
    } catch (e) {
      return <ShoppingItem>[];
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppColors.main800.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '상품이 없습니다',
            style: AppTypography.s1.copyWith(
              color: AppColors.main800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 검색어나 카테고리를 시도해보세요',
            style: AppTypography.b2.copyWith(
              color: AppColors.main800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            '오류가 발생했습니다',
            style: AppTypography.s1.copyWith(
              color: AppColors.main300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTypography.b2.copyWith(
              color: AppColors.main800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadInitialData,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.main900,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(ShoppingItem item) async {
    try {
      final favoriteService = ref.read(favoriteApiServiceProvider);
      final response = await favoriteService.toggleFavorite(item.itemId);

      if (response.isSuccess) {
        setState(() {
          if (response.data == true) {
            _favoriteItemIds.add(item.itemId);
            _showSuccessSnackBar('즐겨찾기에 추가되었습니다');
          } else {
            _favoriteItemIds.remove(item.itemId);
            _showSuccessSnackBar('즐겨찾기에서 제거되었습니다');
          }
        });
      } else {
        _showErrorSnackBar('즐겨찾기 처리 실패: ${response.error}');
      }
    } catch (e) {
      _showErrorSnackBar('즐겨찾기 처리 중 오류가 발생했습니다: $e');
    }
  }

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoritesPage(),
      ),
    );
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
