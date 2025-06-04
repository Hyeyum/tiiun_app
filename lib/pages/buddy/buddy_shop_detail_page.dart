import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'dart:ui';

class BuddyShopDetailPage extends StatefulWidget {
  const BuddyShopDetailPage({super.key});

  @override
  State<BuddyShopDetailPage> createState() => _BuddyShopDetailPageState();
}

class _BuddyShopDetailPageState extends State<BuddyShopDetailPage> {
  int _quantity = 1;
  bool _isFavorite = false;

  void _increaseQuantity() {
    setState(() {
      if (_quantity < 99) {
        _quantity++;
      }
    });
  }

  void _decreaseQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 전달받은 상품 정보
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String imagePath = args['imagePath'];
    final String productName = args['productName'];

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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8,),
            // 상품 이미지
            Center(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: 140,
                    height: 140,
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
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.grey100,
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.grey400,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // 상품 이름
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  productName,
                  style: AppTypography.s2.withColor(AppColors.grey900),
                ),
              ),
            ),
            
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 첫 번째 박스
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        // 발아기, 성장기, 수확기
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '발아기',
                                    style: AppTypography.b4.withColor(AppColors.grey900),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    '약 11일',
                                    style: AppTypography.c1.withColor(AppColors.grey400),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '성장기',
                                    style: AppTypography.b4.withColor(AppColors.grey900),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    '약 16일',
                                    style: AppTypography.c1.withColor(AppColors.grey400),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '개화기',
                                    style: AppTypography.b4.withColor(AppColors.grey900),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    '약 6일',
                                    style: AppTypography.c1.withColor(AppColors.grey400),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        // 프로그레스 바
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF72ED98),
                                Color(0xFF10BEBE)
                              ],
                              stops: [0.4, 1.0],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16,),

                  // 두 번째 박스
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '적정 환경',
                            style: AppTypography.b2.withColor(AppColors.grey900),
                          ),
                        ),
                        SizedBox(height: 8,),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/functions/temperature_off.svg',
                              width: 24,
                              height: 24,
                              color: AppColors.main600,
                            ),
                            SizedBox(width: 2,),
                            Text(
                              '적정 온도 : 38도',
                              style: AppTypography.b3.withColor(AppColors.grey700),
                            ),

                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 12),
                              width: 1,
                              height: 15,
                              decoration: BoxDecoration(
                                color: AppColors.grey200,
                                borderRadius: BorderRadius.circular(0.5),
                              ),
                            ),

                            SvgPicture.asset(
                              'assets/icons/buddy/icon_water.svg',
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 2,),
                            Text(
                              '습도 : 75%',
                              style: AppTypography.b3.withColor(AppColors.grey700),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16,),

                  // 세 번째 박스
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child:
                            Text(
                              '급수 기간',
                              style: AppTypography.b2.withColor(AppColors.grey900),
                            )
                        ),
                        SizedBox(height: 8,),
                        Align(
                          alignment: Alignment.centerLeft,
                          child:
                          Text(
                            '일주일에 한 번',
                            style: AppTypography.b3.withColor(AppColors.grey700),
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
      // 하단 구매 버튼
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 48,
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.main700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '구매하러 가기',
          style: AppTypography.s2.withColor(Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}