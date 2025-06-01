import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'info_community_write_page.dart';
import 'info_useful_tips_page.dart';
import 'package:tiiun/pages/dropdown.dart';

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
  bool _showCommunityAll = false; // 전체보기 상태
  int _selectedCategoryIndex = 0; // 선택된 카테고리 인덱스
  String _selectedSortOption = '추천순'; // 선택된 정렬 옵션
  OverlayEntry? _sortOverlayEntry;
  final LayerLink _sortLayerLink = LayerLink();

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
  ];

  // 버디 커뮤니티 카테고리
  List<String> get categories => const [
    '인기',
    '재배 팁',
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
      imageUrl: 'assets/images/contents/community_post1.png',
    ),
    CommunityPost(
      author: '강남콩엄마',
      title: '케어 안해줘도 잘 자라긴 했는데 성격이 이상해진 것 같아',
      content: '물 달라고 계속 알림 오는 데도 귀찮아서 잘 안줬거든? 그래도 잘 자랐어. 근데 어느순간 보니 성격이 좀 나빠져있는거야. 이거 내 버디만 이런건가? 처음엔 그냥 귀엽게 투정 부리는 줄 알았는데, 점점 말투가 까칠해지더라고. "물 좀 줘"에서 시작해서 "또 안 주는 거야?" 이런 식으로… 약간 서운한 건 나만의 착각일까? 물론 내가 먼저 무심했던 건 맞지만, 이렇게까지 티를 내다니 은근히 삐진 성격인가 싶기도 하고. 그래도 그런 모습까지도 이제는 정들어서, 괜히 미안해서 물 주면서 한참 말도 걸게 돼. 사람처럼 감정 있는 듯한 이 버디, 은근히 애착이 간다.',
      date: '2025.05.27',
      commentCount: 32,
      imageUrl: 'assets/images/contents/community_post2.png',
    ),
    CommunityPost(
      author: '마두동불주먹',
      title: '여러 영양제 사용해봤는데 틔운 전용 영양제가 제일 좋았어요',
      content: '야근이 많아서 신경을 못 써주는 경우가 많았어요. 영양제로라도 살리려고 시중에서 판매하는 영양제도 많이 사용해 보았는데요. 아무래도 틔운 전용 영양제가 틔운 맞춤형이다 보니 훨씬 반응이 좋더라고요. 눈에 띄게 잎도 탱탱해지고, 색도 다시 생기를 되찾는 느낌이었어요. 덕분에 미안한 마음도 조금 덜고, 다시 정성 들여 돌봐야겠다는 생각이 들었어요. 확실히 식물도 자기한테 맞는 방식으로 돌봐줘야 반응을 해주는구나 싶더라고요. 앞으로는 바쁘더라도 최소한의 관심은 꼭 챙겨주려고 해요.',
      date: '2025.05.23',
      commentCount: 8,
      imageUrl: 'assets/images/contents/community_post3.png',
    ),
    CommunityPost(
      author: '파랑새',
      title: '버디가 저에게 일용할 양식을 주었어요',
      content: '정든 친구를 먹는다니 처음에는 의아했는데요. 잎을 잘라주는 것이 친구를 더 건강하게 만든다는 걸 알았더니 이웃이 음식을 나눠주는 것 같고 좋아요. 매번 수확할 때마다 "이만큼 자랐구나" 하는 뿌듯함도 들고, 작은 것 하나로도 일상이 풍성해지는 기분이에요. 식탁에 올릴 때마다 괜히 고마운 마음도 생기고, 마치 서로 보살펴주는 사이 같아서 더 애틋해졌어요. 이젠 버디를 단순한 식물 이상으로 느끼게 돼요. 함께 사는 친구이자, 저를 위한 작은 정원 같달까요.',
      date: '2025.05.29',
      commentCount: 6,
      imageUrl: 'assets/images/contents/community_post4.png',
    ),
    CommunityPost(
      author: '화려한공작새',
      title: '이렇게 뿌듯할 수 있을까요? 건강도 좋아지는 기분이예요',
      content: '요즘 제가 키운 상추를 뜯어서 샐러드 해먹는 것에 푹 빠졌어요. 왠지 더 맛있는 느낌? 드레싱도 종류별로 먹어봤는데요. 저는 참깨 드레싱이 제일 맛있더라고요. 내 손으로 길러낸 걸 먹는다는 게 이렇게 큰 만족감을 줄 줄은 몰랐어요. 매일 자라는 모습을 지켜보다가, 딱 먹기 좋을 만큼 자랐을 때 수확해서 한 끼를 차려 먹는 그 과정 자체가 소소한 힐링이에요. 다음엔 다른 채소도 도전해보려고요. 버디 덕분에 집밥이 더 풍성해졌고, 무엇보다 제 생활에 여유와 즐거움이 생긴 것 같아요.',
      date: '2025.05.22',
      commentCount: 2,
      imageUrl: 'assets/images/contents/community_post5.png',
    ),
  ];

  // 전체 커뮤니티 게시글 데이터 (더 많은 게시글)
  List<CommunityPost> get allCommunityPosts => [
    ...communityPosts,
    const CommunityPost(
      author: '초록이사랑',
      title: '드디어 첫 꽃 피었어요\u{1F979}',
      content: '오늘 아침에 물 주려다가 깜짝 놀랐잖아요. 우리 버디, 첫 꽃 폈어요!! 처음엔 진짜 이렇게 예쁘게 피울 줄은 몰랐는데, 꽃이 생각보다 크고 향도 너무 좋네요. 약간 라벤더 느낌도 나고, 방 안이 향기로 가득해졌어요. 하루하루 기다린 보람이 있는 것 같아서 너무 뿌듯해요. 버디 키우는 분들 다들 곧 꽃 피울 거예요 :)',
      date: '2025.05.21',
      commentCount: 15,
      imageUrl: 'assets/images/contents/community_post1.png',
    ),
    const CommunityPost(
      author: '식집사초보',
      title: '이거 물 달라고 할 때마다 줘도 되는거임?',
      content: '우리 버디만 이런건지 몰겟는데 키운 지 일주일 정도 됐는데 물 달라고 하는 텀이 완전 짧아서 긴가민가 해... 너무 자주 주면 안 좋다고 한 사람도 있어서 괜히 불안하네... 근데 또 흙 겉이 말라 보여서 안 주기도 그렇고 걍 하란 대로 하면 되는 거 맞지?흙 겉은 말라 보이는데 속은 안 말랐을까 싶고ㅠㅠ 다들 어떻게 하고 있어?',
      date: '2025.05.20',
      commentCount: 24,
      imageUrl: 'assets/images/contents/community_post2.png',
    ),
    const CommunityPost(
      author: '틔운마스터',
      title: '(스압) 틔운 4년차가 계절별 관리 팁 딱 알려준다',
      content: '참고로 본인은 틔운 오브제 출시 때부터 키워온 자칭 고인물임. 중간에 보내본 적도 있는데, 이번에 틔운 버디 출시했다길래 하나 사봄. 식물 키우는 게 거기서 거기라 뉴비들 참고하라고 글 써봄. 봄 : 새순 올라오는 시기. 물 좀 자주 줘야됨 근데 과습 조심\n여름:직광 맞으면 잎 탐. 반그늘 아니면 커튼 필수. 물 자주',
      date: '2025.05.19',
      commentCount: 67,
      imageUrl: 'assets/images/contents/community_post3.png',
    ),
    const CommunityPost(
      author: '천성농부',
      title: '드디어 첫 수확!',
      content: '이게 진짜 되네...? 처음엔 그냥 심어보자~ 하고 시작했는데, 오늘 첫 수확했어요. 이게 뭔가 싶을 정도로 감격적이더라구요.. 손으로 직접 키운 잎을 잘라낼 때 그 뿌듯함이란... 매일 체크하면서 잘 자라라고 말도 걸어줬는데, 그게 통했나봐요. 처음 키우는 분들, 진짜 끝까지 해보세요. 수확의 순간은 생각보다 더 벅참!',
      date: '2025.05.18',
      commentCount: 13,
      imageUrl: 'assets/images/contents/community_post4.png',
    ),
    const CommunityPost(
      author: '그린라이프',
      title: '나 오늘 진짜 감동 먹엇잖아 ㅠㅠㅜ',
      content: '한 달 전까지만 회사일 때문에 스트레스받아서 회사-집 무한반복에 진짜 어디다 한풀이할 데도 없어서 속는셈 치고 버디 요즘 유행하길래 사봤어... 식물 각 잡고 키워본 것도 처음이라 엄청 서투르고 나랑은 안 맞다고 생각했는데 하다 보니 재밌더라? 한 달 내내 매일 물주면서 재잘재잘 이야기하니까 친밀감도 생기고 그랬는데 내가 얼마 전에',
      date: '2025.05.17',
      commentCount: 28,
      imageUrl: 'assets/images/contents/community_post5.png',
    ),
  ];

  // 광고 데이터
  AdData get adData => const AdData(
    title: '임파첸스와 함께 새로운 봄을 맞이하는 것은 어떨까요?',
    content: '향기로운 임파첸스와 함께라면 벚꽃 구경을 가지 않아도 봄을 만끽할 수 있어요!\n키우기도 쉽고 개화까지 얼마 안 걸린답니다.',
    imageUrl: 'assets/images/contents/ad_comm.png', // 광고 이미지 경로
  );

  // 전체 커뮤니티 게시글과 광고를 포함한 데이터 (더 많은 게시글)
  List<dynamic> get allCommunityPostsWithAd {
    List<dynamic> items = [];

    // 처음 두 게시글 추가
    items.addAll(allCommunityPosts.take(2));

    // 두 번째 글 다음에 광고 추가
    items.add(adData);

    // 나머지 게시글 추가
    items.addAll(allCommunityPosts.skip(2));

    return items;
  }

  // 정렬 옵션 목록
  List<String> get sortOptions => const [
    '추천순',
    '최신순',
    '댓글수순',
    '조회수순',
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
        child: _showCommunityAll
            ? _buildCommunityAllView()  // 전체보기 화면
            : _buildMainView(),         // 메인 화면
      ),
    );
  }

  // 메인 화면
  Widget _buildMainView() {
    return Column(
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
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '버디 커뮤니티',
                style: AppTypography.s1.withColor(AppColors.grey900),
              ),
              GestureDetector(
                onTap: () {
                  // 전체보기 상태로 변경
                  setState(() {
                    _showCommunityAll = true;
                  });
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

        const SizedBox(height: 12),

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
                    _buildCategoryButton(categories[i], i == _selectedCategoryIndex, i),  // index 매개변수 있음
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

  Widget _buildCategoryButton(String text, bool isSelected, [int? index]) {
    return GestureDetector(
      onTap: () {
        if (index != null) {
          setState(() {
            _selectedCategoryIndex = index;
          });
        }
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
            if (text == '인기') ...[
              SvgPicture.asset(
                'assets/icons/functions/icon_trend.svg',
                width: 16,
                height: 16,
                color: isSelected ? AppColors.main100 : null,
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
            _buildCommunityPostCard(communityPosts[i], isFirstPost: false),
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

  // 커뮤니티 게시글 카드 (padding 조건부 적용)
  Widget _buildCommunityPostCard(CommunityPost post, {bool isFirstPost = false}) {
    return Container(
      padding: EdgeInsets.only(
        top: isFirstPost ? 0 : 16,  // 첫 번째 글은 위쪽 padding 0
        bottom: 16,
        left: 0,
        right: 0,
      ),
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
              const SizedBox(height: 22),
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
              const SizedBox(height: 2),

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
    );
  }

  // 커뮤니티 전체보기 화면
  Widget _buildCommunityAllView() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 헤더
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showCommunityAll = false;
                    });
                  },
                  child: SvgPicture.asset(
                    'assets/icons/functions/back.svg',
                    width: 24,
                    height: 24,
                  )
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '버디 커뮤니티',
                      style: AppTypography.s1.withColor(AppColors.grey900),
                    ),
                  ),
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

          // 카테고리 버튼들
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
                      _buildCategoryButton(categories[i], i == _selectedCategoryIndex, i),
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

          // 구분선
          Container(
            height: 1,
            color: AppColors.grey100,
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
          ),

          // 게시글 목록 (정렬버튼 포함하여 모두 스크롤)
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero, // 패딩 제거
              itemCount: allCommunityPostsWithAd.length + 1, // +1은 정렬버튼을 위한 공간
              itemBuilder: (context, index) {
                // 첫 번째 아이템은 정렬 버튼
                if (index == 0) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      children: [
                        const Spacer(),
                        _buildSortButton(),
                      ],
                    ),
                  );
                }

                // 나머지는 게시글 (index를 1 빼서 조정)
                final actualIndex = index - 1;
                final item = allCommunityPostsWithAd[actualIndex];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // 아이템이 광고인지 게시글인지 구분하여 렌더링
                      if (item is AdData)
                        _buildAdCard(item, isFirstPost: actualIndex == 0)
                      else if (item is CommunityPost)
                        _buildCommunityPostCard(item, isFirstPost: actualIndex == 0),

                      // 마지막 아이템이 아닌 경우 구분선 추가
                      if (actualIndex < allCommunityPostsWithAd.length - 1)
                        Container(
                          height: 0.5,
                          color: AppColors.grey200,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),


        ],
      ),
      // 플로팅 액션 버튼 (글쓰기 버튼)
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: AppColors.grey100,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF131927).withOpacity(0.08),
                  offset: const Offset(2, 8),
                  blurRadius: 8,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                  borderRadius: BorderRadius.circular(60),
                  onTap: () {
                  // 글쓰기 페이지로 이동
                  _navigateToWritePage();
                },
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      'assets/icons/community/Edit_Pencil_02.svg',
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // 정렬 옵션 드롭다운 버튼
  Widget _buildSortButton() {
    return CustomSortButton(
      sortOptions: sortOptions,
      selected: _selectedSortOption,
      onSelected: (value) {
        setState(() {
          _selectedSortOption = value;
        });
      },
    );
  }

  // 광고 카드 위젯
  Widget _buildAdCard(AdData ad, {bool isFirstPost = false}) {
    return Container(
      padding: EdgeInsets.only(
        top: isFirstPost ? 0 : 16,
        bottom: 16,
        left: 0,
        right: 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽 콘텐츠
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 광고 라벨
                Text(
                  '광고',
                  style: AppTypography.c1.withColor(AppColors.grey700),
                ),
                const SizedBox(height: 4),

                // 제목
                Text(
                  ad.title,
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
                  ad.content,
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
              ],
            ),
          ),

          const SizedBox(width: 10),

          // 오른쪽 이미지
          Column(
            children: [
              const SizedBox(height: 22),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    ad.imageUrl,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: AppColors.main100,
                        child: Icon(
                          Icons.campaign,
                          size: 24,
                          color: AppColors.main700,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 글쓰기 페이지로 이동하는 메서드
  void _navigateToWritePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CommunityWritePage(), // 글쓰기 페이지
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

// 광고 데이터 모델
class AdData {
  final String title;
  final String content;
  final String imageUrl;
  final bool isAd; // 광고인지 구분하는 플래그

  const AdData({
    required this.title,
    required this.content,
    required this.imageUrl,
    this.isAd = true,
  });
}