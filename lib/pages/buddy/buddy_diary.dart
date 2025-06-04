import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'dart:ui';

class BuddyDiaryPage extends StatelessWidget {
  final String plantName;
  final String plantVariety;
  final String plantedDate;
  final String plantImage;
  final int daysPlanted;

  const BuddyDiaryPage({
    super.key,
    required this.plantName,
    required this.plantVariety,
    required this.plantedDate,
    required this.plantImage,
    required this.daysPlanted,
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
            // 식물 정보 카드 (기본 정보만)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 식물 이름
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          child: Text(
                            plantName,
                            style: AppTypography.h5.withColor(AppColors.grey900),
                          ),
                        ),

                        // 함께한 지 & 품종
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '함께한 지',
                                  style: AppTypography.c2.withColor(AppColors.grey400),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '${daysPlanted}일째',
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
                                  plantVariety,
                                  style: AppTypography.b1.withColor(AppColors.grey700),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 8),

                        // 키운 날짜
                        Text(
                          '$plantedDate ~',
                          style: AppTypography.c3.withColor(AppColors.grey500),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 20),

                  // 식물 이미지
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        width: 100,
                        height: 100,
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 20),
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
                          child: Transform.scale(
                            scale: 0.9,
                            child: Image.asset(
                              plantImage,
                              fit: BoxFit.cover,
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
                  ),
                ],
              ),
            ),

            // 성장 정보 전체를 감싸는 Container
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '개화 예상 시기 : 08.03 - 08.15',
                      style: AppTypography.c1.withColor(AppColors.grey400),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '버디가 잘 자라고 있어요. 어떤 꽃이 필까요?',
                        style: AppTypography.b3.withColor(AppColors.grey900),
                      ),
                    ),
                    // 상태 탭
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Column(
                        children: [
                          // 발아기, 성장기, 수확기
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '수확기',
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
                          SizedBox(height: 16),
                          // 프로그레스 바
                          Container(
                            height: 8,
                            child: Stack(
                              children: [
                                // 회색 배경 (전체)
                                Container(
                                  width: double.infinity,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.grey100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                // 그라데이션 (진행률만큼)
                                FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 0.2,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF72ED98), Color(0xFF10BEBE)],
                                        stops: [0.4, 1.0],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
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
            ),

            // 일지 섹션
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '일지',
                        style: AppTypography.h4.withColor(AppColors.grey900),
                      ),
                      Spacer(),
                      Icon(
                        Icons.calendar_month,
                        color: AppColors.grey600,
                        size: 20,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // 일지 아이템들
                  _buildDiaryItem(
                    date: '2025.05.28',
                    dayNumber: 1,
                    imageUrl: 'assets/images/plant1.jpg', // 실제 이미지 경로로 변경
                    content: '어쩌구저쩌구',
                    hasImage: true,
                  ),

                  _buildDiaryItem(
                    date: '2025.05.27',
                    dayNumber: 2,
                    content: '어쩌구저쩌구',
                    hasImage: false,
                  ),

                  _buildDiaryItem(
                    date: '2025.05.25',
                    dayNumber: 3,
                    content: '어쩌구저쩌구',
                    hasImage: false,
                    hasEditIcon: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: 100), // 하단 여백
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab(String text, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green : AppColors.grey300,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.b4.withColor(
          isActive ? Colors.white : AppColors.grey600,
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
    bool hasEditIcon = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              SizedBox(width: 8),
              Text(
                date,
                style: AppTypography.b3.withColor(AppColors.grey800),
              ),
              Spacer(),
              if (hasEditIcon)
                Icon(
                  Icons.edit,
                  color: Colors.green,
                  size: 16,
                ),
            ],
          ),
          SizedBox(height: 12),

          if (hasImage && imageUrl != null) ...[
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.grey100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
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
            SizedBox(height: 12),
          ],

          Text(
            content,
            style: AppTypography.b3.withColor(AppColors.grey700),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}