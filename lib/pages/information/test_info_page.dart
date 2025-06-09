import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/pages/information/test_write_post_screen.dart'; // write_post_screen.dart import 추가

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  int _selectedTabIndex = 0; // 인기 탭이 기본 선택

  final List<String> _tabs = ["인기", "재배 팁", "상담", "일상", "인테리어"];

  // 더미 데이터
  final List<InfoItem> infoItems = const [
    InfoItem(
      imagePath: 'assets/icons/functions/info_item1.png',
      title: '집 안 식물들을 키우고 있는 분들에게 도움이 되는 정보를 모아봤어요.',
      description: '혹시 키우고 있는 식물 중에 부족한 것들이나 잘못 관리하고 있다는 느낌이 드는 것들이 있다면 한번 자세히 읽어보세요.',
      date: '2024.12.23',
      likes: 51,
      nickname: '식물러버',
    ),
    InfoItem(
      imagePath: 'assets/icons/functions/info_item2.png',
      title: '저희 식당에서는 고객님의 건강과 안전을 최우선으로 하고 있습니다.',
      description: '흔히 알아야 하는 식당의 청소 및 소독의 개념을 안내해 드립니다. 올바른 관리를 받아보세요.',
      date: '2024.12.29',
      likes: 39,
      nickname: '그린썸',
    ),
    InfoItem(
      imagePath: 'assets/icons/functions/info_item3.png',
      title: '실내에서 키울 때에 사용할 때 통풍이 마지막 이유는 뭔지 물었습니다.',
      description: '주변에서 가장 많이 하는 식물관리의 과정을 잘못 배우는 분들이 많아서 정확한 관리법을 적어보겠습니다.',
      date: '2024.12.25',
      likes: 18,
      nickname: '새싹키우기',
    ),
    InfoItem(
      imagePath: 'assets/icons/functions/info_item4.png',
      title: '모종 및 식물을 키우는 모든 과정들을 잘못 진행하는 경우들을 많이 봤어요.',
      description: '현재 상당한 시기에서 식물관리가 어려울 수도 있으으니 한번 확인해보시기 바랍니다.',
      date: '2024.12.21',
      likes: 24,
      nickname: '초록친구',
    ),
    InfoItem(
      imagePath: 'assets/icons/functions/info_item5.png',
      title: '비료가 주는 것을 맞추어 사서 영향을 주면 다리를 만들어와요 좋아요.',
      description: '그런 비료를 배제하는 것에서 한 번에 사서 추위 등의 시기가 오는 상황에서 나타나지 않도록 눈에 잘됩니다.',
      date: '2024.12.29',
      likes: 14,
      nickname: '꽃내음',
    ),
    InfoItem(
      imagePath: 'assets/icons/functions/info_item6.png',
      title: '바다가 지금의 일열을 얻어 중요한 좋아요 높은 사의 예제.',
      description: '당신 수도는 여러분을 만나고 있기 때문에 내년 정상이 아니더라도 사과하는 여려 곳을 구하는 만나시건 외...',
      date: '2024.12.29',
      likes: 12,
      nickname: '플랜테리어장인',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold를 사용하여 FloatingActionButton을 직접 추가
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              Container(
                width: double.infinity,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '버디 커뮤니티',
                      style: AppTypography.s1.withColor(AppColors.grey900),
                    ),
                    GestureDetector(
                      onTap: () {
                        // 검색 기능 추가 예정
                      },
                      child: SvgPicture.asset(
                        'assets/icons/functions/icon_search.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // 탭 바
              Container(
                height: 32, // 탭바의 높이를 32px로 고정
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabs.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8), // 탭 사이 간격 조정
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // 탭 내부 패딩 조정
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == index
                              ? AppColors.main600 // 선택된 탭 색상
                              : AppColors.grey100, // 비활성 탭 색상
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row( // 텍스트와 아이콘을 가로로 배치하기 위해 Row 추가
                          mainAxisSize: MainAxisSize.min, // Row가 최소한의 공간만 차지하도록
                          children: [
                            if (index == 0) // '인기' 탭 (첫 번째 탭)에만 아이콘 추가
                              Padding(
                                padding: const EdgeInsets.only(right: 4.0), // 아이콘과 텍스트 사이 간격
                                child: SvgPicture.asset(
                                  'assets/icons/functions/icon_trend.svg', // SVG 경로
                                  width: 16, // 아이콘 크기
                                  height: 16, // 아이콘 크기
                                  colorFilter: ColorFilter.mode(
                                    _selectedTabIndex == index ? Colors.white : AppColors.main100,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            Text(
                              _tabs[index],
                              style: AppTypography.b4.withColor(
                                _selectedTabIndex == index ? Colors.white : AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // 컨텐츠 리스트
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: infoItems.length,
                  // Divider를 구분선으로 사용합니다.
                  separatorBuilder: (context, index) => const Divider(
                    height: 20, // 구분선의 높이
                    thickness: 1, // 구분선의 두께
                    color: AppColors.grey100, // 구분선의 색상
                  ),
                  itemBuilder: (context, index) {
                    return _buildInfoCard(infoItems[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새 정보 글 작성 기능: write_post_screen.dart로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WritePostScreen()), // WritePostScreen으로 이동
          );
        },
        shape: const CircleBorder(),
        backgroundColor: AppColors.grey100,
        child: SvgPicture.asset(
          'assets/icons/functions/Edit_Pencil_01.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            AppColors.main600,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(InfoItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 닉네임
                Text(
                  item.nickname,
                  style: AppTypography.c1.withColor(AppColors.grey600),
                ),
                const SizedBox(height: 4), // 닉네임과 제목 사이 간격
                // 제목
                Text(
                  item.title,
                  style: AppTypography.b1.withColor(AppColors.grey900),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // 설명
                Text(
                  item.description,
                  style: AppTypography.b4.withColor(AppColors.grey600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // 날짜 정보
                Text(
                  item.date,
                  style: AppTypography.c2.withColor(AppColors.grey400),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10), // 텍스트와 이미지 사이 간격
          // 이미지와 좋아요
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Add a SizedBox to push the image down
              const SizedBox(height: 20), // **이 값을 10에서 20으로 변경했습니다.**
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    item.imagePath,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.image,
                          color: AppColors.grey400,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/functions/icon_comment.svg', // SVG 경로
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      AppColors.grey600,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.likes}',
                    style: AppTypography.c2.withColor(AppColors.grey400),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 정보 아이템 모델
class InfoItem {
  final String imagePath;
  final String title;
  final String description;
  final String date;
  final int likes;
  final String nickname;

  const InfoItem({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.date,
    required this.likes,
    required this.nickname,
  });
}