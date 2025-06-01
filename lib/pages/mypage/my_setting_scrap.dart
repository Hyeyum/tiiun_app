import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';

class MySettingScrapPage extends StatelessWidget {
  const MySettingScrapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            '스크랩',
            style: AppTypography.b2.withColor(AppColors.grey900),
          ),
        ),
        centerTitle: true,
      ),

      // child를 body로 변경
      body: Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 36, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wrap으로 식물 관리 팁 카드들 배치
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPlantTipCard(
                    context, // context 전달
                    '겨울철 물주기, 깍지벌레 관리 팁',
                    'assets/images/contents/plant_tip1.png'
                ),
                _buildPlantTipCard(
                    context, // context 전달
                    '겨울 걱정 NO! 겨울철 식물 이사 고민 줄여요',
                    'assets/images/contents/plant_tip2.png'
                ),
                _buildPlantTipCard(
                    context, // context 전달
                    '실내 공기 정화 식물로 겨울철 건강 지키기',
                    'assets/images/contents/plant_tip3.png'
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 2열 그리드용 식물 관리 팁 카드 위젯 (세로형) - context 파라미터 추가
  Widget _buildPlantTipCard(BuildContext context, String title, String imagePath) {
    // 화면 너비에 따라 카드 너비 계산 (2열 그리드)
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48 - 8) / 2; // 패딩 40 + 간격 8을 고려

    return SizedBox(
      width: cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1.0, // 정사각형 비율
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    color: AppColors.grey100,
                    child: const Icon(Icons.eco, size: 48, color: Colors.green),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.b2.withColor(AppColors.grey800),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}