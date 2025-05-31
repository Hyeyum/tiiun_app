import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'info_useful_tips_page.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final ScrollController _categoryScrollController = ScrollController();
  bool _showLeftGradient = false;
  bool _showRightGradient = false;
  bool _isTipButtonPressed = false;

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
  ];

  // 버디 커뮤니티 카테고리
  List<String> get categories => const [
    '인기',
    '재배팁',
    '상담',
    '일상',
    '인테리어',
    '자랑',
    '레시피',
    '가틔',
    '이벤트',
  ];

  // 커뮤니티 게시글 데이터
  List<CommunityPost> get communityPosts => const [
    CommunityPost(
      author: '포로롱',
      title: '버디 꾸며서 인테리어 완성해봤어! 평가해주라',
      content: '항상 내 방 꾸미는 거에 대한 로망을 갖고 있긴 했는데 이번에 버디에 꽃이 피어서 겸사겸사 인테리어 해봤어. 벽지 색에 맞춰서 꽃도 고른건데 어때? 아침에 눈 뜨자마자 제일 먼저 보이는 게 활짝 핀 꽃이라는 게 이렇게 기분 좋은 일이었나 싶더라. 은은한 향도 방 안 가득 퍼져서, 요즘은 괜히 커피도 창가에 앉아서 마시게 돼. 작은 변화인데도 공간 분위기가 확 달라지니까, 나도 더 잘 지내고 싶다는 마음이 생겨. 다음엔 조명도 바꿔보고, 작은 선반도 하나 들여볼까 고민 중이야. 버디 덕분에 방이 살아난 느낌이랄까.',
      date: '2025.05.24',
      commentCount: 41,
      imageUrl: 'assets/images/community_post1.png',
    ),
    CommunityPost(
      author: '강남콩엄마',
      title: '케어 안해줘도 잘 자라긴 했는데 성격이 이상해진 것 같아',
      content: '물 달라고 계속 알림 오는 데도 귀찮아서 잘 안줬거든? 그래도 잘 자랐어. 근데 어느순간 보니 성격이 좀 나빠져있는거야. 이거 내 버디만 이런건가? 처음엔 그냥 귀엽게 투정 부리는 줄 알았는데, 점점 말투가 까칠해지더라고. "물 좀 줘"에서 시작해서 "또 안 주는 거야?" 이런 식으로… 약간 서운한 건 나만의 착각일까? 물론 내가 먼저 무심했던 건 맞지만, 이렇게까지 티를 내다니 은근히 삐진 성격인가 싶기도 하고. 그래도 그런 모습까지도 이제는 정들어서, 괜히 미안해서 물 주면서 한참 말도 걸게 돼. 사람처럼 감정 있는 듯한 이 버디, 은근히 애착이 간다.',
      date: '2025.05.27',
      commentCount: 32,
      imageUrl: 'assets/images/community_post2.png',
    ),
    CommunityPost(
      author: '마두동불주먹',
      title: '여러 영양제 사용해봤는데 틔운 전용 영양제가 제일 좋았어요',
      content: '야근이 많아서 신경을 못 써주는 경우가 많았어요. 영양제로라도 살리려고 시중에서 판매하는 영양제도 많이 사용해 보았는데요. 아무래도 틔운 전용 영양제가 틔운 맞춤형이다 보니 훨씬 반응이 좋더라고요. 눈에 띄게 잎도 탱탱해지고, 색도 다시 생기를 되찾는 느낌이었어요. 덕분에 미안한 마음도 조금 덜고, 다시 정성 들여 돌봐야겠다는 생각이 들었어요. 확실히 식물도 자기한테 맞는 방식으로 돌봐줘야 반응을 해주는구나 싶더라고요. 앞으로는 바쁘더라도 최소한의 관심은 꼭 챙겨주려고 해요.',
      date: '2025.05.23',
      commentCount: 8,
      imageUrl: 'assets/images/community_post3.png',
    ),
    CommunityPost(
      author: '파랑새',
      title: '버디가 저에게 일용할 양식을 주었어요',
      content: '정든 친구를 먹는다니 처음에는 의아했는데요. 잎을 잘라주는 것이 친구를 더 건강하게 만든다는 걸 알았더니 이웃이 음식을 나눠주는 것 같고 좋아요. 매번 수확할 때마다 "이만큼 자랐구나" 하는 뿌듯함도 들고, 작은 것 하나로도 일상이 풍성해지는 기분이에요. 식탁에 올릴 때마다 괜히 고마운 마음도 생기고, 마치 서로 보살펴주는 사이 같아서 더 애틋해졌어요. 이젠 버디를 단순한 식물 이상으로 느끼게 돼요. 함께 사는 친구이자, 저를 위한 작은 정원 같달까요.',
      date: '2025.05.29',
      commentCount: 6,
      imageUrl: 'assets/images/community_post4.png',
    ),
    CommunityPost(
      author: '화려한공작새',
      title: '이렇게 뿌듯할 수 있을까요? 건강도 좋아지는 기분이예요',
      content: '요즘 제가 키운 상추를 뜯어서 샐러드 해먹는 것에 푹 빠졌어요. 왠지 더 맛있는 느낌? 드레싱도 종류별로 먹어봤는데요. 저는 참깨 드레싱이 제일 맛있더라고요. 내 손으로 길러낸 걸 먹는다는 게 이렇게 큰 만족감을 줄 줄은 몰랐어요. 매일 자라는 모습을 지켜보다가, 딱 먹기 좋을 만큼 자랐을 때 수확해서 한 끼를 차려 먹는 그 과정 자체가 소소한 힐링이에요. 다음엔 다른 채소도 도전해보려고요. 버디 덕분에 집밥이 더 풍성해졌고, 무엇보다 제 생활에 여유와 즐거움이 생긴 것 같아요.',
      date: '2025.05.22',
      commentCount: 2,
      imageUrl: 'assets/images/community_post5.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _categoryScrollController.addListener(_onCategoryScroll);

    // 초기 그라데이션 상태 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_categoryScrollController.hasClients && mounted) {
          _onCategoryScroll();
        }
      });
    });
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _onCategoryScroll() {
    if (!_categoryScrollController.hasClients) return;

    setState(() {
      _showLeftGradient = _categoryScrollController.offset > 0;
      _showRightGradient = _categoryScrollController.offset <
        (_categoryScrollController.position.maxScrollExtent - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                width: double.infinity,
                height: 64,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '정보',
                      style: AppTypography.s1.withColor(AppColors.grey900),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: SvgPicture.asset(
                        'assets/icons/functions/icon_search.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 바디
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 유용한 팁 섹션
                    _buildUsefulTipsSection(),

                    // 버디 커뮤니티 카테고리 섹션
                    _buildBuddyCommunitySection(),

                    Container(
                      height: 1,
                      color: AppColors.grey100,
                    ),

                    // 버디 커뮤니티 게시글 섹션
                    _buildCommunityPostsSection(),


                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsefulTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 제목 - 패딩 적용
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '식물에게도 휴식이 필요해요 \u{1f6cb}',
            style: AppTypography.s2.withColor(AppColors.grey900),
          ),
        ),
        const SizedBox(height: 10),

        // 슬라이드 가능한 카드들 - 화면 전체 사용
        SizedBox(
          height: 204,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20), // 시작 패딩만
            children: [
              for (int i = 0; i < tips.length; i++) ...[
                _buildTipCard(tips[i]),
                if (i < tips.length - 1)
                  const SizedBox(width: 8)
                else
                  const SizedBox(width: 20),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 유용한 팁 보러가기 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildTipButton(),
        ),
        const SizedBox(height: 16),
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

  Widget _buildTipButton() {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isTipButtonPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isTipButtonPressed = false;
        });
        // 유용한 팁 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TipsPage(),
          ),
        );
      },
      onTapCancel: () {
        setState(() {
          _isTipButtonPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: _isTipButtonPressed
            ? AppColors.grey200
            : AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Text(
              '유용한 팁 보러가기',
              style: AppTypography.b3.withColor(AppColors.grey700),
            ),
            const Spacer(),
            SvgPicture.asset(
              'assets/icons/functions/more.svg',
              width: 24,
              height: 24,
              color: AppColors.grey500,
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildBuddyCommunitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 제목 + 전체보기 버튼
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '버디 커뮤니티',
                style: AppTypography.s1.withColor(AppColors.grey900),
              ),
              GestureDetector(
                onTap: () {
                  // 전체보기 기능
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '전체보기',
                      style: AppTypography.c1.withColor(AppColors.grey800),
                    ),
                    SvgPicture.asset(
                      'assets/icons/functions/more.svg',
                      height: 24,
                      width: 24,
                      color: AppColors.grey500,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 카테고리 버튼들 - 가로 스크롤 + 그라데이션
        SizedBox(
          width: double.infinity,
          height: 32,
          child: Stack(
            children: [
              ListView(
                controller: _categoryScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                children: [
                  for (int i = 0; i < categories.length; i++) ...[
                    _buildCategoryButton(categories[i], i == 0),
                    if (i < categories.length - 1)
                      const SizedBox(width: 8)
                    else
                      const SizedBox(width: 20),
                  ],
                ],
              ),
              // 왼쪽 그라데이션
              if (_showLeftGradient)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.1, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              // 오른쪽 그라데이션
              if (_showRightGradient)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white,
                          ],
                          stops: const [0.1, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCategoryButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // 카테고리 선택 기능
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.main700 : AppColors.grey100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (text == '인기' && isSelected) ...[
              SvgPicture.asset(
                'assets/icons/functions/icon_trend.svg',
                width: 16,
                height: 16,
                color: AppColors.main100,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: AppTypography.b4.withColor(
                isSelected ? Colors.white : AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 커뮤니티 게시글 섹션 함수
  Widget _buildCommunityPostsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (int i = 0; i < communityPosts.length; i++) ...[
            _buildCommunityPostCard(communityPosts[i]),
            if (i < communityPosts.length - 1) ...[
              // 구분선 추가 (좌우 여백 있음)
              Container(
                height: 0.5,
                color: AppColors.grey200,
              ),
            ],
          ],
        ],
      ),
    );
  }

// 커뮤니티 게시글 카드
  Widget _buildCommunityPostCard(CommunityPost post) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 왼쪽 콘텐츠
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 작성자
                  Text(
                    post.author,
                    style: AppTypography.c1.withColor(AppColors.grey700),
                  ),
                  const SizedBox(height: 4),

                  // 제목
                  Text(
                    post.title,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      letterSpacing: 0,
                      color: AppColors.grey900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 내용
                  Text(
                    post.content,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                      letterSpacing: 0,
                      color: AppColors.grey900,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // 날짜
                  Text(
                    post.date,
                    style: AppTypography.c1.withColor(AppColors.grey700),
                  ),

                ],
              ),
            ),

            const SizedBox(width: 10),

            // 오른쪽 이미지
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset(
                      post.imageUrl,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: AppColors.grey100,
                          child: Icon(
                            Icons.image,
                            size: 24,
                            color: AppColors.grey400,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 2,),

                // 댓글 부분 - 오른쪽 정렬
                SizedBox(
                  width: 100, // 이미지와 같은 너비
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
                    children: [
                      SvgPicture.asset(
                        'assets/icons/community/icon_comment.svg',
                        width: 16,
                        height: 16,
                        color: AppColors.grey600,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${post.commentCount}',
                        style: AppTypography.c1.withColor(AppColors.grey700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


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

// 커뮤니티 게시글 데이터 모델
class CommunityPost {
  final String author;
  final String title;
  final String content;
  final String date;
  final int commentCount;
  final String imageUrl;

  const CommunityPost({
    required this.author,
    required this.title,
    required this.content,
    required this.date,
    required this.commentCount,
    required this.imageUrl,
  });
}