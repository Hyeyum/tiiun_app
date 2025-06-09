import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'buddy_shop_detail_page.dart';
import 'dart:ui';

class BuddyShopPage extends StatefulWidget {
  const BuddyShopPage({super.key});

  @override
  State<BuddyShopPage> createState() => _BuddyShopPageState();
}

class _BuddyShopPageState extends State<BuddyShopPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 상품 카드 위젯을 생성하는 함수
  Widget _buildProductCard({
    required String imagePath,
    required String category,
    required String productName,
  }) {
    // 카테고리에 따른 태그 색상 결정
    Color getTagColor(String category) {
      switch (category) {
        case '화훼류':
          return AppColors.point500;
        case '과채류':
          return AppColors.point900;
        case '허브류':
          return AppColors.main600;
        default:
          return AppColors.grey300; // 기타 카테고리용 색상
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuddyShopDetailPage(),
            settings: RouteSettings(
              arguments: {
                'imagePath': imagePath,
                'productName': productName,
              },
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Colors.white.withOpacity(0.6),
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 16,
                      spreadRadius: -6,
                      color: Color(0xFF131927).withOpacity(0.08),
                    ),
                  ],
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.grey100,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.grey400,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 4,),
          // 상품 정보 (태그 + 이름)
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: getTagColor(category),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6,),
              Text(
                productName,
                style: AppTypography.c1.withColor(AppColors.grey900),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 상품 목록 데이터
  List<Map<String, String>> getProductList() {
    return [
      {'image': 'assets/images/shop/image_pureum.png', 'category': '랜덤', 'name': '랜덤씨앗키트'}, // 기타 카테고리
      {'image': 'assets/images/shop/image_impha_pink.png', 'category': '화훼류', 'name': '임파첸스(분홍색)'},
      {'image': 'assets/images/shop/image_impha_white.png', 'category': '화훼류', 'name': '임파첸스(흰색)'},
      {'image': 'assets/images/shop/image_geumuh_pink.png', 'category': '화훼류', 'name': '금어초(분홍색)'},
      {'image': 'assets/images/shop/image_geumuh_yell.png', 'category': '화훼류', 'name': '금어초(노란색)'},
      {'image': 'assets/images/shop/image_tomato.png', 'category': '과채류', 'name': '방울토마토'},
      {'image': 'assets/images/shop/image_lavandula.png', 'category': '화훼류', 'name': '라벤듈라'},
      {'image': 'assets/images/shop/image_pennel.png', 'category': '화훼류', 'name': '펜넬'},
      {'image': 'assets/images/shop/image_stock_yell.png', 'category': '화훼류', 'name': '스토크(노란색)'},
      {'image': 'assets/images/shop/image_stock_violet.png', 'category': '화훼류', 'name': '스토크(보라색)'},
      {'image': 'assets/images/shop/image_flower_pink.png', 'category': '화훼류', 'name': '로벨리아(분홍색)'},
      {'image': 'assets/images/shop/image_flower_blue.png', 'category': '화훼류', 'name': '로벨리아(파란색)'},
      {'image': 'assets/images/shop/image_diil.png', 'category': '허브류', 'name': '딜'},
      {'image': 'assets/images/shop/image_catnip.png', 'category': '허브류', 'name': '캣닙'},
      {'image': 'assets/images/shop/image_time.png', 'category': '허브류', 'name': '타임'},
      {'image': 'assets/images/shop/image_gaza.png', 'category': '화훼류', 'name': '가자니아'},
      {'image': 'assets/images/shop/image_cheasong_pink.png', 'category': '화훼류', 'name': '채송화(분홍색)'},
      {'image': 'assets/images/shop/image_cheasong_yell.png', 'category': '화훼류', 'name': '채송화(노란색)'},
    ];
  }

  // 검색 결과에 따라 필터링된 상품 목록 반환
  List<Map<String, String>> getFilteredProductList() {
    final allProducts = getProductList();
    if (_searchQuery.isEmpty) {
      return allProducts;
    }
    return allProducts.where((product) {
      final name = product['name']!.toLowerCase();
      final category = product['category']!.toLowerCase();
      return name.contains(_searchQuery) || category.contains(_searchQuery);
    }).toList();
  }

  // 상품 카드 위젯을 생성하는 함수
  Widget _buildNutritionCard({
    required String imagePath,
    required String productName,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuddyShopDetailPage(),
            settings: RouteSettings(
              arguments: {
                'imagePath': imagePath,
                'productName': productName,
              },
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Colors.white.withOpacity(0.6),
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 16,
                      spreadRadius: -6,
                      color: Color(0xFF131927).withOpacity(0.08),
                    ),
                  ],
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.grey100,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.grey400,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 4,),
          // 상품 정보 (태그 + 이름)
          Text(
            productName,
            style: AppTypography.c1.withColor(AppColors.grey900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> getNutritionList() {
    return [
      {'image': 'assets/images/shop/supplement1.png', 'name': '틔운 미니용 영양제'},
      {'image': 'assets/images/shop/supplement2.png', 'name': '틔운용 영양제'},
    ];
  }

  // 검색 결과에 따라 필터링된 영양제 목록 반환
  List<Map<String, String>> getFilteredNutritionList() {
    final allProducts = getNutritionList();
    if (_searchQuery.isEmpty) {
      return allProducts;
    }
    return allProducts.where((product) {
      final name = product['name']!.toLowerCase();
      return name.contains(_searchQuery) || '영양제'.contains(_searchQuery);
    }).toList();
  }

  // 상품 카드 위젯을 생성하는 함수
  Widget _buildDecorationCard({
    required String imagePath,
    required String productName,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuddyShopDetailPage(),
            settings: RouteSettings(
              arguments: {
                'imagePath': imagePath,
                'productName': productName,
              },
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Colors.white.withOpacity(0.6),
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 16,
                      spreadRadius: -6,
                      color: Color(0xFF131927).withOpacity(0.08),
                    ),
                  ],
                ),
                child: Transform.scale(
                  scale: 0.8,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.grey100,
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.grey400,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 4,),
          // 상품 정보 (태그 + 이름)
          Text(
            productName,
            style: AppTypography.c1.withColor(AppColors.grey900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> getDecorationList() {
    return [
      {'image': 'assets/images/shop/image_deco1.png', 'name': '바다표범 장식'},
      {'image': 'assets/images/shop/image_deco2.png', 'name': '바닷속 스티커'},
      {'image': 'assets/images/shop/image_deco3.png', 'name': '하늘정원 스티커'},
      {'image': 'assets/images/shop/image_deco4.png', 'name': '달팽이 장식'},
      {'image': 'assets/images/shop/image_deco5.png', 'name': '달팽이 스티커'},
      {'image': 'assets/images/shop/image_deco6.png', 'name': '숲속 친구들 스티커'},
    ];
  }

  // 검색 결과에 따라 필터링된 장식 목록 반환
  List<Map<String, String>> getFilteredDecorationList() {
    final allProducts = getDecorationList();
    if (_searchQuery.isEmpty) {
      return allProducts;
    }
    return allProducts.where((product) {
      final name = product['name']!.toLowerCase();
      return name.contains(_searchQuery) || '장식'.contains(_searchQuery) || '스티커'.contains(_searchQuery);
    }).toList();
  }

  // 그리드 위젯을 생성하는 함수 (재사용 가능)
  Widget _buildProductGrid({
    required List<Map<String, String>> products,
    required Widget Function({required String imagePath, required String productName}) cardBuilder,
    bool hasCategory = false,
  }) {
    if (products.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            '검색 결과가 없습니다',
            style: AppTypography.b3.withColor(AppColors.grey400),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final int cardsPerRow = 3;
        final double cardWidth = 100;
        final double totalCardWidth = cardWidth * cardsPerRow;
        final double totalSpacing = constraints.maxWidth - totalCardWidth;
        final double spacing = totalSpacing / (cardsPerRow - 1);

        final List<Widget> rows = [];

        for (int i = 0; i < products.length; i += cardsPerRow) {
          List<Widget> rowCards = [];

          for (int j = 0; j < cardsPerRow; j++) {
            int index = i + j;
            if (index >= products.length) {
              // 카드가 부족할 경우 빈 공간 채우기
              rowCards.add(SizedBox(width: cardWidth));
            } else {
              final product = products[index];
              if (hasCategory) {
                rowCards.add(_buildProductCard(
                  imagePath: product['image']!,
                  category: product['category']!,
                  productName: product['name']!,
                ));
              } else {
                rowCards.add(cardBuilder(
                  imagePath: product['image']!,
                  productName: product['name']!,
                ));
              }
            }

            if (j < cardsPerRow - 1) {
              rowCards.add(SizedBox(width: spacing));
            }
          }

          rows.add(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowCards,
          ));

          if (i + cardsPerRow < products.length) {
            rows.add(SizedBox(height: 10));
          }
        }

        return Column(children: rows);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredSeeds = getFilteredProductList();
    final filteredNutrition = getFilteredNutritionList();
    final filteredDecoration = getFilteredDecorationList();
    final hasAnyResults = filteredSeeds.isNotEmpty || filteredNutrition.isNotEmpty || filteredDecoration.isNotEmpty;

    return Scaffold(
      backgroundColor: Color(0xFFE8F6F6),
      appBar: AppBar(
        backgroundColor: Color(0xFFE8F6F6),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SvgPicture.asset(
              'assets/icons/functions/back.svg',
              width: 24,
              height: 24,
              color: AppColors.grey700,
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 0), // 타이틀 위치 조정
          child: Text(
            '구매',
            style: AppTypography.b2.withColor(AppColors.grey900),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 검색창
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.grey100,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // 검색 아이콘
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: SvgPicture.asset(
                          'assets/icons/functions/icon_search.svg',
                          width: 24,
                          height: 24,
                          color: AppColors.grey700,
                        ),
                      ),
                      // 검색 입력 필드
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: AppTypography.b3.withColor(AppColors.grey900),
                          decoration: InputDecoration(
                            hintText: '찾고자 하는 상품명을 검색하세요',
                            hintStyle: AppTypography.b3.withColor(AppColors.grey400),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          onSubmitted: (value) {
                            // 검색 실행 로직 (현재는 실시간 검색으로 처리됨)
                            if (value.trim().isNotEmpty) {
                              print('검색어: $value');
                            }
                          },
                        ),
                      ),
                      // 검색어 클리어 버튼 (검색어가 있을 때만 표시)
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _searchController,
                        builder: (context, value, child) {
                          if (value.text.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                  },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey300,
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/icons/functions/icon_cancel.svg',
                                      width: 8,
                                      height: 8,
                                      color: AppColors.grey50,
                                    ),
                                  )
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 검색 결과가 없을 때 전체 메시지 표시
            if (_searchQuery.isNotEmpty && !hasAnyResults)
              Container(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: AppColors.grey400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '검색 결과가 없습니다',
                        style: AppTypography.s2.withColor(AppColors.grey400),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '다른 검색어를 입력해보세요',
                        style: AppTypography.b3.withColor(AppColors.grey400),
                      ),
                    ],
                  ),
                ),
              ),

            // 씨앗키트
            if (filteredSeeds.isNotEmpty || _searchQuery.isEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '씨앗키트',
                      style: AppTypography.s2.withColor(AppColors.grey900),
                    ),

                    // 씨앗키트 태그 (검색어가 없을 때만 표시)
                    if (_searchQuery.isEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Spacer(),
                            // 화훼류
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: EdgeInsets.only(right: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.point500,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  '화훼류',
                                  style: AppTypography.c1.withColor(AppColors.grey700),
                                ),
                              ],
                            ),
                            SizedBox(width: 12),
                            // 과일류
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: EdgeInsets.only(right: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.point900,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  '과채류',
                                  style: AppTypography.c2.withColor(AppColors.grey700),
                                ),
                              ],
                            ),
                            SizedBox(width: 12),
                            // 허브류
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: EdgeInsets.only(right: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.main600,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  '허브류',
                                  style: AppTypography.c2.withColor(AppColors.grey700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // 씨앗키트 상품 목록
                    _buildProductGrid(
                      products: filteredSeeds,
                      cardBuilder: _buildNutritionCard, // 실제로는 사용되지 않음 (hasCategory가 true이므로)
                      hasCategory: true,
                    ),
                  ],
                ),
              ),

            // 구분선 (검색어가 없거나 여러 카테고리에 결과가 있을 때만 표시)
            if ((_searchQuery.isEmpty || (filteredSeeds.isNotEmpty && (filteredNutrition.isNotEmpty || filteredDecoration.isNotEmpty))) && hasAnyResults)
              Container(
                margin: EdgeInsets.symmetric(vertical: 24),
                width: double.infinity,
                height: 0.5,
                color: AppColors.grey300,
              ),

            // 영양제
            if (filteredNutrition.isNotEmpty || _searchQuery.isEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '영양제',
                        style: AppTypography.s2.withColor(AppColors.grey900),
                      ),
                      SizedBox(height: 16,),

                      // 영양제 상품 목록
                      _buildProductGrid(
                        products: filteredNutrition,
                        cardBuilder: _buildNutritionCard,
                      ),
                    ]
                ),
              ),

            // 구분선
            if ((_searchQuery.isEmpty || (filteredNutrition.isNotEmpty && filteredDecoration.isNotEmpty)) && hasAnyResults)
              Container(
                margin: EdgeInsets.symmetric(vertical: 24),
                width: double.infinity,
                height: 0.5,
                color: AppColors.grey300,
              ),

            // 장식
            if (filteredDecoration.isNotEmpty || _searchQuery.isEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '장식',
                        style: AppTypography.s2.withColor(AppColors.grey900),
                      ),
                      SizedBox(height: 16,),

                      // 장식 상품 목록
                      _buildProductGrid(
                        products: filteredDecoration,
                        cardBuilder: _buildDecorationCard,
                      ),
                    ]
                ),
              ),

            SizedBox(height: 70,),
          ],
        ),
      ),
    );
  }
}