import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';

class BuddyDecoPage extends StatefulWidget {
  const BuddyDecoPage({super.key});

  @override
  State<BuddyDecoPage> createState() => _BuddyDecoPageState();
}

class _BuddyDecoPageState extends State<BuddyDecoPage> {
  int selectedScreenIndex = 1; // 현재 선택된 화면 (중앙이 기본)
  int selectedCategoryIndex = 0; // 선택된 카테고리 (그래픽이 기본)
  PageController _pageController = PageController(initialPage: 1, viewportFraction: 0.4);

  final List<String> categoryNames = ['그래픽', '종이꽃', '봄날'];
  final List<bool> categoryLocked = [false, false, true]; // 봄날은 잠금

  // 화면 프리뷰용 이미지들
  final List<String> previewImages = [
    'assets/images/display/graphic2.png',
    'assets/images/display/animal.png',
    'assets/images/display/paper2.png',
  ];

  // 각 카테고리별 이미지들
  final List<List<String>> categoryImages = [
    [
      'assets/images/display/graphic1.png',
      'assets/images/display/graphic2.png',
      'assets/images/display/graphic3.png',
    ],
    [
      'assets/images/display/paper1.png',
      'assets/images/display/paper2.png',
      'assets/images/display/paper3.png',
    ],
    [
      'assets/images/display/spring1.png',
      'assets/images/display/spring2.png',
      'assets/images/display/spring3.png',
    ],
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          '버디 꾸미기',
          style: AppTypography.b2.withColor(AppColors.grey900),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 화면 프리뷰 섹션 (가로 스크롤)
          Container(
            height: 218,
            padding: EdgeInsets.symmetric(vertical: 20),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  selectedScreenIndex = index;
                });
              },
              itemCount: previewImages.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedScreenIndex == index;

                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: isSelected
                        ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF72ED98),
                            Color(0xFF10BEBE),
                          ],
                          stops: [0.4, 1.0]
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(2), // gradient border 두께
                      child: Container(
                        padding: EdgeInsets.all(8),
                        width: 158,
                        height: 174,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            width: 146,
                            height: 162,
                            previewImages[index],
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.grey300,
                                child: Icon(Icons.image, color: AppColors.grey500),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            width: 112,
                            height: 124,
                            previewImages[index],
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.grey300,
                                child: Icon(Icons.image, color: AppColors.grey500),
                              );
                            },
                          ),
                        ),
                  ),
                );
              },
            ),
          ),

          // 카테고리 섹션
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ListView.separated(
                itemCount: categoryNames.length,
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildCategorySection(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(int categoryIndex) {
    bool isLocked = categoryLocked[categoryIndex];
    String categoryName = categoryNames[categoryIndex];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 헤더
            Row(
              children: [
                if (isLocked) ...[
                  Image.asset(
                    'assets/images/display/lock.png',
                    width: 24,
                    height: 24,
                    filterQuality: FilterQuality.high,
                  ),
                  SizedBox(width: 4),
                ],
                Text(
                  categoryName,
                  style: AppTypography.b2.withColor(AppColors.grey900),
                ),
                if (isLocked) ...[
                  Spacer(),
                  Text(
                    '멤버십 가입 시 사용 가능해요!',
                    style: AppTypography.c1.withColor(AppColors.grey500),
                  ),
                ],
              ],
            ),

            SizedBox(height: 8),

            // 카테고리 이미지들
            Container(
              height: 156,
              child: isLocked
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Opacity(
                  opacity: 0.3,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(0.5),
                      ),
                      child: _buildImageRow(categoryIndex),
                    ),
                  ),
                ),
              )
                  : _buildImageRow(categoryIndex),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageRow(int categoryIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (imageIndex) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          width: 140,
          height: 156,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  categoryImages[categoryIndex][imageIndex],
                  width: 140,
                  height: 156,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image,
                          color: AppColors.grey500,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}