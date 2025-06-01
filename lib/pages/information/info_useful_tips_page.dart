import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:tiiun/pages/toast_helper.dart';

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
      imageUrl: 'assets/images/contents/big_tip0.png',
      title: '봄을 담은 침실',
      scrapCount: 62,
      titlePosition: TextPosition(top: 148, left: 20),
      scrapPosition: TextPosition(bottom: 18, left: 20),
      textColor: Colors.white, // 흰색 텍스트
    ),
    BigTipData(
      imageUrl: 'assets/images/contents/big_tip2.png',
      title: '방울토마토,\n인기 씨앗이 된 이유',
      scrapCount: 48,
      titlePosition: TextPosition(top: 18, left: 20),
      scrapPosition: TextPosition(bottom: 18, left: 20),
      textColor: AppColors.grey900, // 검정색 텍스트
    ),
    BigTipData(
      imageUrl: 'assets/images/contents/big_tip4.png',
      title: '고양이에게서 식물 지키기',
      scrapCount: 92,
      titlePosition: TextPosition(top: 148, left: 20),
      scrapPosition: TextPosition(bottom: 18, left: 20),
      textColor: Colors.white, // 흰색 텍스트
    ),
    BigTipData(
      imageUrl: 'assets/images/contents/big_tip3.png',
      title: '반려 식물을 산책시키는 여자',
      scrapCount: 60,
      titlePosition: TextPosition(top: 18, left: 20),
      scrapPosition: TextPosition(bottom: 18, right: 20),
      textColor: Colors.white, // 흰색 텍스트
    ),
    BigTipData(
      imageUrl: 'assets/images/contents/big_tip5.png',
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
      imageUrl: 'assets/images/contents/info_image1.png',
      title: '하루종일 직사광선 NO! 광량 조절 꿀팁',
    ),
    TipData(
      imageUrl: 'assets/images/contents/info_image2.png',
      title: '산책을 좋아하는 식물도 있답니다',
    ),
    TipData(
      imageUrl: 'assets/images/contents/info_image3.png',
      title: '오전에 일어나는 식물이 더 건강하다',
    ),
    TipData(
      imageUrl: 'assets/images/contents/info_image4.png',
      title: '간접광의 중요성',
    ),
    TipData(
      imageUrl: 'assets/images/contents/plant_tip1.png',
      title: '겨울철 물주기, 깍지벌레 관리 팁',
    ),
    TipData(
      imageUrl: 'assets/images/contents/plant_tip2.png',
      title: '겨울 걱정 NO! 겨울철 식물 이사 고민 줄여요',
    ),
    TipData(
      imageUrl: 'assets/images/contents/plant_tip3.png',
      title: '실내 공기 정화 식물로 겨울철 건강 지키기',
    ),
    TipData(
      imageUrl: 'assets/images/contents/plant_tip4.png',
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
                            child: _buildBigTipCard(bigTips[index], index),
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

  Widget _buildBigTipCard(BigTipData tip, int index) {
    return GestureDetector(
      onTap: () {
        // "봄을 담은 침실"만 상세 페이지로 이동
        if (tip.title == '봄을 담은 침실') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpringBedroomDetailPage(),
            ),
          );
        } else {
          // 나머지는 준비중 메시지
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${tip.title} 상세 페이지 준비중입니다!'),
              duration: Duration(seconds: 2),
              backgroundColor: AppColors.main600,
            ),
          );
        }
      },
      child: Container(
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
                  filterQuality: FilterQuality.high,
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
            Text(
              tip.title,
              style: AppTypography.b4.withColor(AppColors.grey800),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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

// "봄을 담은 침실" 전용 상세 페이지
class SpringBedroomDetailPage extends StatefulWidget {
  const SpringBedroomDetailPage({super.key});

  @override
  State<SpringBedroomDetailPage> createState() => _SpringBedroomDetailPageState();
}

class _SpringBedroomDetailPageState extends State<SpringBedroomDetailPage> {
  bool isBookmarked = false;

  // 유용한 팁 데이터
  List<TipData> get tips => const [
    TipData(
      imageUrl: 'assets/images/contents/info_image2.png',
      title: '산책을 좋아하는 식물도 있답니다',
    ),
    TipData(
      imageUrl: 'assets/images/contents/info_image3.png',
      title: '오전에 일어나는 식물이 더 건강하다',
    ),
    TipData(
      imageUrl: 'assets/images/contents/big_tip5.png',
      title: '쓰다듬으면 더 잘 자라나요?',
    ),
    TipData(
      imageUrl: 'assets/images/contents/plant_tip4.png',
      title: '토분이 관리하기 쉽다고? 누가!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xFF131927).withOpacity(0.08),
                blurRadius: 16,
                offset: Offset(0, 8),
                spreadRadius: -6
              ),
            ],
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: AppBar(
                backgroundColor: Colors.white.withOpacity(0.7),
                elevation: 0,
                scrolledUnderElevation: 0,
                toolbarHeight: 56,
                leadingWidth: 56,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 20),
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
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isBookmarked = !isBookmarked;
                        });
                        ToastHelper.showTopToast(
                          context: context,
                          message: isBookmarked ? '스크랩에 저장되었습니다.' : '스크랩을 취소했습니다.',
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.black.withOpacity(0.5),
                        );
                      },
                      child: SvgPicture.asset(
                        isBookmarked ? 'assets/icons/functions/Bookmark_on.svg' : 'assets/icons/functions/Bookmark.svg',
                        height: 24,
                        width: 24,
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메인 이미지
            Container(
              width: double.infinity,
              height: 240,
              child: Image.asset(
                'assets/images/contents/big_tip0.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.grey100,
                    child: Icon(
                      Icons.image,
                      size: 64,
                      color: AppColors.grey400,
                    ),
                  );
                },
              ),
            ),

            // 콘텐츠 영역
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Container(
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    child: Text(
                      '봄을 담은 침실',
                      style: AppTypography.h4.withColor(AppColors.grey900),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 본문 내용
                  Container(
                    padding: const EdgeInsets.all(0),
                    margin: const EdgeInsets.all(0),
                    child: Text(
                      '창밖의 벚꽃이 지고 나면, 봄은 방 안으로 들어와야 할지도 몰라요. 틔운 버디 하나를 들여놓고 나서부터, 제 침실은 조금 달라졌습니다.',
                      style: AppTypography.b1.withColor(AppColors.grey900),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.zero,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/images/contents/content_image1.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(0),
                    margin: const EdgeInsets.all(0),
                    child: Text('햇살이 천천히 스며드는 오후, 침대 머리맡엔 연두빛 채소들이 자라고 있어요.\n초록도 그냥 초록이 아니라, 루꼴라의 뽀얀 연두, 크리스피 채소의 생기 가득한 청록, 그리고 바질의 짙은 녹색이 층을 이룹니다. 틔운 버디의 조명이 이 색들을 은은하게 비추면, 그 자체로 하나의 풍경이 되죠.\n식물의 색감은 공간의 온도를 바꿉니다.',
                      style: AppTypography.b1.withColor(AppColors.grey900),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.zero,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/images/contents/content_image2.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(0),
                    margin: const EdgeInsets.all(0),
                    child: Text('만약 침실 톤이 아이보리나 화이트 위주라면, 잎이 도드라지는 짙은 바질이나 스위스차드처럼 대비감 있는 채소가 추천이에요.\n반대로 우드 톤이나 베이지 컬러 가구가 많은 방이라면, 잎사귀가 풍성한 청경채나 적당한 광택감이 있는 적겨자채가 따뜻한 분위기를 더해줍니다.\n색감은 단순히 보기 좋기 위한 것만이 아니에요.\n시각적으로 안정된 색을 자주 마주하면 감정의 기복도 완화된다는 연구처럼, 매일 초록이의 성장과 변화를 관찰하는 건 일종의 심리적 안정 루틴이 되곤 하죠.',
                      style: AppTypography.b1.withColor(AppColors.grey900),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(0),
                    margin: const EdgeInsets.all(0),
                    child: Text('작은 장치 하나로 계절을 들이고, 하루를 다정하게 마무리할 수 있다면,\n그건 꽤 괜찮은 침실의 조건이 아닐까요?',
                      style: AppTypography.b1.withColor(AppColors.grey900),
                    ),
                  ),
                  // const SizedBox(height: 16),

                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/images/contents/content_image3.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),

                  Text("무엇보다 '틔운 버디'의 부드러운 조명은 밤이 깊을수록 침실을 포근하게 감싸줍니다.\n잠들기 전, 바질의 은은한 향과 함께 약한 불빛만 남겨두면 자연스러운 수면 유도로 이어집니다.\n형광등을 끈 채로 틔운 버디의 조명만 남겨보세요.\n그 빛은 식물에게는 성장을, 사람에게는 평온함을 선물해줍니다.",
                    style: AppTypography.b1.withColor(AppColors.grey900),
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 16, bottom: 36),
                    child: Text("틔운 버디는 침실을 단순한 '쉼터'가 아닌, 작은 계절의 정원으로 바꿔주는 역할을 해요. 계절에 따라 식물을 바꿔보는 것도 또 하나의 재미입니다. 봄엔 파릇한 새싹, 여름엔 청량한 향을 품은 허브, 가을엔 무화과나 무드감 있는 컬러의 채소들로.",
                      style: AppTypography.b1.withColor(AppColors.grey900),
                    ),
                  ),
                  const SizedBox(height: 16),


                ],
              ),
            ),

            _buildTipSliderSection(
              title: '이런 글은 어떠세요?',
              tipDataList: tips,
            ),
            const SizedBox(height: 8,),
            const SizedBox(height: 21,),
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
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

  Widget _buildTipCard(TipData tip) {
    return SizedBox(
      width: 156,
      height: 204,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
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
            Text(
              tip.title,
              style: AppTypography.b4.withColor(AppColors.grey800),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          ],
        ),
      ),
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

// 큰 팁 데이터 모델 (기존 유지)
class BigTipData {
  final String imageUrl;
  final String title;
  final int scrapCount;
  final TextPosition titlePosition;
  final TextPosition scrapPosition;
  final Color textColor;

  const BigTipData({
    required this.imageUrl,
    required this.title,
    required this.scrapCount,
    required this.titlePosition,
    required this.scrapPosition,
    required this.textColor,
  });
}

// 팁 데이터 모델 (기존 유지)
class TipData {
  final String imageUrl;
  final String title;

  const TipData({
    required this.imageUrl,
    required this.title,
  });
}