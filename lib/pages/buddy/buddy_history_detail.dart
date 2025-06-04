import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'dart:ui';

class BuddyHistoryDetailPage extends StatelessWidget {

  const BuddyHistoryDetailPage({
    super.key,
  });

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
        title: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Text(
            '성장일지',
            style: AppTypography.b2.withColor(AppColors.grey900),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 푸름이 기본 정보 Container
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 3, bottom: 13,),
                          child: Text(
                            '푸름이',
                            style: AppTypography.h5.withColor(AppColors.grey900),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '함께한 기간',
                                  style: AppTypography.c2.withColor(AppColors.grey400),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '113일',
                                  style: AppTypography.b1.withColor(AppColors.grey700),
                                ),
                              ],
                            ),
                            SizedBox(width: 54),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '품종',
                                  style: AppTypography.c2.withColor(AppColors.grey400),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '스토크',
                                  style: AppTypography.b1.withColor(AppColors.grey700),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '2024.12.22 ~ 2025.03.28',
                          style: AppTypography.c3.withColor(AppColors.grey500),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF131927).withOpacity(0.08),
                              offset: Offset(0, 8),
                              blurRadius: 16,
                              spreadRadius: -6,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          child: Image.asset(
                            'assets/images/shop/image_stock_yell.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: SvgPicture.asset(
                                  'assets/icons/plants/sprout.svg',
                                  width: 40,
                                  height: 40,
                                  color: Colors.green,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 위쪽 둥근 Container (개화 예상 시기 + 일기 섹션)
            Container(
              padding: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 개화 예상 시기 섹션
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '버디에 예쁜 꽃이 피었어요. 추억을 되새겨보세요.',
                          style: AppTypography.b3.withColor(AppColors.grey900),
                        ),
                        SizedBox(height: 8,),
                        Container(
                            padding: EdgeInsets.fromLTRB(12, 20, 12, 0),
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
                                            '약 32일',
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
                                            '약 60일',
                                            style: AppTypography.c1.withColor(AppColors.grey400),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
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
                            )
                        ),
                      ],
                    ),
                  ),

                  // 2. 구분선 섹션
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    color: AppColors.grey200,
                    height: 0.5,
                  ),

                  // 3. 일기 섹션
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              Text(
                                '일기',
                                style: AppTypography.h5.withColor(AppColors.grey900),
                              ),
                              Spacer(),
                              SvgPicture.asset(
                                'assets/icons/buddy/Calendar.svg',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ),

                        // 일기 아이템들
                        _buildDiaryItem(
                          date: '2025.03.22',
                          dayNumber: 1,
                          imageUrl: 'assets/images/diary/diary1.png',
                          content: '정말 예쁘다. 근데 이제 시들시들해 보여서 보내줄 때가 오고 있는 것 같아. 푸름이도 새로운 모습을 하고 싶어하는 것 같기도 하고.',
                          hasImage: true,
                        ),

                        _buildDiaryItem(
                          date: '2025.03.14',
                          dayNumber: 2,
                          imageUrl: 'assets/images/diary/diary2.png',
                          content: '거실에 배치하니 지나갈 때마다 향기로운 냄새가 나서 기분이 좋다.',
                          hasImage: true,
                        ),

                        _buildDiaryItem(
                          date: '2025.05.25',
                          dayNumber: 3,
                          imageUrl: 'assets/images/diary/diary3.png',
                          content: '보일때마다 기분 좋다~~',
                          hasImage: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiaryItem({
    required String date,
    required int dayNumber,
    required String content,
    String? imageUrl,
    bool hasImage = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타임라인 부분
          Container(
            // width: 10,
            child: Column(
              children: [
                // 원형 점
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.main700,
                    shape: BoxShape.circle,
                  ),
                ),
                // 세로 라인 (마지막 아이템이 아닌 경우에만)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: AppColors.main700,
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: 15),

          // 콘텐츠 부분
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      date,
                      style: AppTypography.b1.withColor(AppColors.grey900),
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(height: 10),

                if (hasImage && imageUrl != null) ...[
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.grey100,
                            child: Center(
                              child: Icon(
                                Icons.image,
                                color: AppColors.grey400,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],

                Text(
                  content,
                  style: AppTypography.b1.withColor(AppColors.grey900),
                ),

                SizedBox(height: 16), // 다음 아이템과의 간격
              ],
            ),
          ),
        ],
      ),
    );
  }
}