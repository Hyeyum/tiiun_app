import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 큰 팁 데이터 (위치 정보와 텍스트 색상 추가)
  final List<BigTipData> bigTips = const [
    BigTipData(
      imageUrl: 'assets/images/big_tip0.png',
      title: '봄을 담은 침실',
      scrapCount: 62,
      titlePosition: TextPosition(top: 148, left: 20),
      scrapPosition: TextPosition(bottom: 18, left: 20),
      textColor: Colors.white, // 흰색 텍스트
    ),
    BigTipData(
      imageUrl: 'assets/images/big_tip2.png',
      title: '방울토마토,\n인기 씨앗이 된 이유',
      scrapCount: 48,
      titlePosition: TextPosition(top: 18, left: 20),
      scrapPosition: TextPosition(bottom: 18, left: 20),
      textColor: AppColors.grey900, // 검정색 텍스트
    ),
    BigTipData(
      imageUrl: 'assets/images/big_tip4.png',
      title: '고양이에게서 식물 지키기',
      scrapCount: 92,
      titlePosition: TextPosition(top: 148, left: 20),
      scrapPosition: TextPosition(bottom: 18, left: 20),
      textColor: Colors.white, // 흰색 텍스트
    ),
    BigTipData(
      imageUrl: 'assets/images/big_tip3.png',
      title: '반려 식물을 산책시키는 여자',
      scrapCount: 60,
      titlePosition: TextPosition(top: 18, left: 20),
      scrapPosition: TextPosition(bottom: 18, right: 20),
      textColor: Colors.white, // 흰색 텍스트
    ),
    BigTipData(
      imageUrl: 'assets/images/big_tip5.png',
      title: '쓰다듬으면 더 잘 자라나요?',
      scrapCount: 49,
      titlePosition: TextPosition(top: 148, left: 20),
      scrapPosition: TextPosition(bottom: 18, left: 20),
      textColor: AppColors.grey900, // 흰색 텍스트
    ),
  ];

  // 유용한 팁 데이터
  List<TipData> get tips => const [
    TipData(
      imageUrl: 'assets/images/info_image1.png',
      title: '하루종일 직사광선 NO! 광량 조절 꿀팁',
    ),
    TipData(
      imageUrl: 'assets/images/info_image2.png',
      title: '산책을 좋아하는 식물도 있답니다',
    ),
    TipData(
      imageUrl: 'assets/images/info_image3.png',
      title: '오전에 일어나는 식물이 더 건강하다',
    ),
    TipData(
      imageUrl: 'assets/images/info_image4.png',
      title: '간접광의 중요성',
    ),
    TipData(
      imageUrl: 'assets/images/plant_tip1.png',
      title: '겨울철 물주기, 깍지벌레 관리 팁',
    ),
    TipData(
      imageUrl: 'assets/images/plant_tip2.png',
      title: '겨울 걱정 NO! 겨울철 식물 이사 고민 줄여요',
    ),
    TipData(
      imageUrl: 'assets/images/plant_tip3.png',
      title: '실내 공기 정화 식물로 겨울철 건강 지키기',
    ),
    TipData(
      imageUrl: 'assets/images/plant_tip4.png',
      title: '토분이 관리하기 쉽다고? 누가!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text(
          '유용한 팁',
          style: AppTypography.b2.withColor(AppColors.grey900),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {},
              child: SvgPicture.asset(
                'assets/icons/functions/icon_search.svg',
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child:
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    // 큰 팁 카드 슬라이더 - 중앙 정렬
                    SizedBox(
                      height: 220,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: bigTips.length,
                        itemBuilder: (context, index) {
                          return Center( // 카드를 화면 중앙에 배치
                            child: _buildBigTipCard(bigTips[index]),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 페이지 인디케이터
                    _buildPageIndicator(),

                  ],
                ),
              ),

            _buildTipSliderSection(
              title: '식물에게도 휴식이 필요해요 \u{1f6cb}',
              tipDataList: tips.sublist(0, 4),
            ),

            const SizedBox(height: 12,),

            _buildTipSliderSection(
              title: '겨울철 식물 관리 팁 \u{26C4}',
              tipDataList: tips.sublist(4, 8),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildBigTipCard(BigTipData tip) {
    return Container(
      width: 320, // 고정 너비
      height: 220, // 고정 높이
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // 배경 이미지
            Container(
              width: double.infinity,
              height: double.infinity,
              margin: EdgeInsets.all(0),
              child: Image.asset(
                tip.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.grey100,
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: AppColors.grey400,
                    ),
                  );
                },
              ),
            ),

        // 제목 텍스트
        Positioned(
          top: tip.titlePosition.top,
          bottom: tip.titlePosition.bottom,
          left: tip.titlePosition.left,
          right: tip.titlePosition.right,
          child: Text(
            tip.title,
            style: AppTypography.h4.withColor(tip.textColor),
            textAlign: tip.titlePosition.right != null
                ? TextAlign.end
                : TextAlign.start,
          ),
        ),

        // 스크랩 수 텍스트
        Positioned(
          top: tip.scrapPosition.top,
          bottom: tip.scrapPosition.bottom,
          left: tip.scrapPosition.left,
          right: tip.scrapPosition.right,
          child: Text(
            '스크랩 수 ${tip.scrapCount}',
            style: AppTypography.b4.withColor(tip.textColor),
            textAlign: tip.scrapPosition.right != null
                ? TextAlign.end
                : TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < bigTips.length; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == _currentPage
                  ? AppColors.main800 // 현재 페이지
                  : AppColors.grey200, // 다른 페이지
            ),
          ),
      ],
    );
  }

  Widget _buildTipCard(TipData tip) {
    return SizedBox(
      width: 156,
      height: 204,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 부분
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 156,
                height: 156,
                child: Image.asset(
                  tip.imageUrl,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      color: AppColors.grey100,
                      child: const Icon(
                        Icons.eco,
                        size: 48,
                        color: Colors.green,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 텍스트 부분
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                tip.title,
                style: AppTypography.b4.withColor(AppColors.grey800),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipSliderSection({
    required String title,
    required List<TipData> tipDataList,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            title,
            style: AppTypography.s2.withColor(AppColors.grey900),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 204,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            children: [
              for (int i = 0; i < tipDataList.length; i++) ...[
                _buildTipCard(tipDataList[i]),
                if (i < tipDataList.length - 1)
                  const SizedBox(width: 8)
                else
                  const SizedBox(width: 20),
              ],
            ],
          ),
        ),
      ],
    );
  }


}

// 텍스트 위치 클래스
class TextPosition {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const TextPosition({
    this.top,
    this.bottom,
    this.left,
    this.right,
  });
}

// 큰 팁 데이터 모델 (텍스트 색상 필드 추가)
class BigTipData {
  final String imageUrl;
  final String title;
  final int scrapCount;
  final TextPosition titlePosition; // 제목 위치
  final TextPosition scrapPosition;
  final Color textColor; // 텍스트 색상 필드 추가

  const BigTipData({
    required this.imageUrl,
    required this.title,
    required this.scrapCount,
    required this.titlePosition, // 제목 위치 필수
    required this.scrapPosition, // 스크랩 수 위치 필수
    required this.textColor, // 필수 매개변수로 추가
  });
}

// 팁 데이터 모델
class TipData {
  final String imageUrl;
  final String title;

  const TipData({
    required this.imageUrl,
    required this.title,
  });
}