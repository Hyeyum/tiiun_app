import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'buddy_shop_page.dart';
import 'buddy_history.dart';

class BuddyPage extends StatefulWidget {
  const BuddyPage({super.key});

  @override
  State<BuddyPage> createState() => _BuddyPageState();
}

class _BuddyPageState extends State<BuddyPage> {
  late final PageController _pageController;
  int _currentPlantIndex = 1;

  final List<Map<String, dynamic>> _plants = [
    {
      'id': '1',
      'name': '누렁이',
      'icon': 'assets/images/shop/image_geumuh_yell.png',
      'kit': '금어초(노랑)',
      'days': 121,
      'temperature': '22°C',
      'water': '충분',
      'lightHours': 12,
      'lightLevel': 4,
      'lightStart': '오전 8:00',
      'lightEnd': '오후 8:00',
    },
    {
      'id': '2',
      'name': '푸름이',
      'icon': 'assets/images/shop/image_pureum.png',
      'kit': '랜덤씨앗 키트',
      'days': 32,
      'temperature': '24°C',
      'water': '보통',
      'lightHours': 13,
      'lightLevel': 3,
      'lightStart': '오전 9:00',
      'lightEnd': '오후 10:00',
    },
    {
      'id': '3',
      'name': '멋쟁이',
      'icon': 'assets/images/shop/image_tomato.png',
      'kit': '방울토마토',
      'days': 68,
      'temperature': '20°C',
      'water': '부족',
      'lightHours': 10,
      'lightLevel': 2,
      'lightStart': '오전 10:00',
      'lightEnd': '오후 8:00',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPlantIndex,
      viewportFraction: 0.325,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD4F5F5), Color(0xFFE8F6F6)],
            stops: [0.6, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 고정 헤더
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('버디', style: AppTypography.s1.withColor(AppColors.grey900)),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuddyShopPage())),
                            child: SvgPicture.asset('assets/icons/buddy/Handbag.svg', width: 24, height: 24),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuddyHistoryPage())),
                            child: SvgPicture.asset('assets/icons/functions/icon_buddy.svg', width: 24, height: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 스크롤 가능한 영역
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // 이미지 카드 영역
                      SizedBox(
                        height: 140,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _plants.length,
                          onPageChanged: (index) => setState(() => _currentPlantIndex = index),
                          itemBuilder: (context, index) {
                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double scale = 1.0;
                                if (_pageController.position.haveDimensions) {
                                  double diff = (_pageController.page! - index).abs();
                                  scale = 1.0 - (diff * 0.429).clamp(0.0, 0.429);
                                }
                                return Center(
                                  child: Transform.scale(
                                    scale: scale,
                                    child: _buildBuddyImageCard(_plants[index], index == _currentPlantIndex),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildPlantInfo(_plants[_currentPlantIndex]),

                      const SizedBox(height: 24),

                      // 버디 화면 꾸미러가기 버튼
                      _buildDecoButton(),

                      const SizedBox(height: 12),

                      // 상태 카드들
                      _buildStatusCards(_plants[_currentPlantIndex]),

                      const SizedBox(height: 12),

                      // 조명 정보 카드
                      _buildLightInfoCard(_plants[_currentPlantIndex]),

                      const SizedBox(height: 10),

                      // 씨앗 키트 제거 버튼
                      _buildSeedKitRemoveButton(),

                      // 하단 여백
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuddyImageCard(Map<String, dynamic> plant, bool isActive) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: isActive ? Colors.white : AppColors.grey200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF131927).withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Center(
          child: Transform.scale(
            scale: 0.85,
            child: Image.asset(
              plant['icon'],
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantInfo(Map<String, dynamic> plant) {
    return Column(
      children: [
        Text('${plant['days']}일차', style: AppTypography.b4.withColor(AppColors.main900)),
        Stack(
          alignment: Alignment.center,
          children: [
            Text(plant['name'], style: AppTypography.h5.withColor(AppColors.grey900)),
            Positioned(
              right: 0,
              child: Transform.translate(
                offset: const Offset(24, 0),
                child: SvgPicture.asset(
                  'assets/icons/functions/more.svg',
                  width: 24,
                  height: 24,
                  color: AppColors.grey400
                ),
              ),
            ),
          ],
        ),
        Text(plant['kit'], style: AppTypography.b3.withColor(AppColors.grey500)),
      ],
    );
  }

  // 버디 화면 꾸미러가기 버튼
  Widget _buildDecoButton() {
    return GestureDetector(
      onTap: () {
        // 버디 화면 꾸미기 기능
      },
      child: Container(
        width: double.infinity,
        height: 44,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '버디 화면 꾸미러가기',
              style: AppTypography.b3.withColor(AppColors.grey800),
            ),
            SvgPicture.asset(
              'assets/icons/functions/more.svg',
              width: 24,
              height: 24,
              color: AppColors.grey500,
            )
          ],
        ),
      ),
    );
  }

  // 상태 카드들 (선택된 식물에 따라 데이터 변경)
  Widget _buildStatusCards(Map<String, dynamic> plant) {
    return Column(
      children: [
        // 작물 온도
        _buildStatusCard(
          icon: 'assets/icons/buddy/temperature_off_gradient.svg',
          title: '적정 온도',
          description: '식물 재배에 알맞은 온도예요',
          backgroundColor: Colors.white,
        ),

        const SizedBox(height: 10),

        // 물통 종부
        _buildStatusCard(
          icon: 'assets/icons/buddy/half_bottle.svg',
          title: '물통 충분',
          description: '버디가 먹을 물이 충분히 있어요',
          backgroundColor: Colors.white,
        ),
      ],
    );
  }

  // 개별 상태 카드
  Widget _buildStatusCard({
    required String icon,
    required String title,
    required String description,
    required Color backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘과 타이틀을 같은 선상에
          Row(
            children: [
              SvgPicture.asset(
                icon,
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 2),
              Text(
                title,
                style: AppTypography.b2.withColor(AppColors.grey900),
              ),
            ],
          ),
          // description은 아래에
          if (description.isNotEmpty) ...[
            Text(
              description,
              style: AppTypography.c1.withColor(AppColors.grey700),
            ),
          ],
        ],
      ),
    );
  }

  // 조명 정보 카드 (선택된 식물에 따라 데이터 변경)
  Widget _buildLightInfoCard(Map<String, dynamic> plant) {
    // 10~18시간 범위로 계산하고, 범위를 벗어나면 제한
    double progressValue = ((plant['lightHours'] - 10) / (18 - 10)).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/functions/light_on.svg',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 2),
                Text(
                  '조명 밝기 낮음',
                  style: AppTypography.b2.withColor(AppColors.grey900),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 조명 시간
          Text(
            '조명 시간',
            style: AppTypography.b4.withColor(AppColors.grey900),
          ),
          const SizedBox(height: 2,),
          Text(
            '${plant['lightStart']} - ${plant['lightEnd']}',
            style: AppTypography.c1.withColor(AppColors.grey700),
          ),

          Container(
            height: 0.5,
            color: AppColors.grey200,
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),

          // 조명 지속시간
          Text(
            '조명 지속시간',
            style: AppTypography.b4.withColor(AppColors.grey900),
          ),
          const SizedBox(height: 2,),
          Text(
            '${plant['lightHours']}시간',
            style: AppTypography.c2.withColor(AppColors.main900),
          ),

          const SizedBox(height: 2),

          // 프로그레스 바
          // 프로그레스 바
          Container(
            margin: const EdgeInsets.fromLTRB(0, 12, 0, 4),
            height: 12,
            child: Stack(
              children: [
                // 회색 배경 (전체)
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                // 그라데이션 (진행률만큼)
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressValue,
                  child: Container(
                    height: 12,
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
          // 프로그레스 바 아래 시간 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10시간',
                style: AppTypography.c1.withColor(AppColors.grey700),
              ),
              Text(
                '18시간',
                style: AppTypography.c1.withColor(AppColors.grey700),
              ),
            ],
          ),
          const SizedBox(height: 4),

          const SizedBox(height: 2),

          Text(
            '조명 시간이 적당하여 버디가 잘 자랄 거예요',
            style: AppTypography.c1.withColor(AppColors.grey700),
          ),

          Container(
            height: 0.5,
            color: AppColors.grey200,
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),

          // 조명 밝기
          Text(
            '조명 밝기',
            style: AppTypography.b4.withColor(AppColors.grey900),
          ),
          const SizedBox(height: 2),
          Text(
            '${plant['lightLevel']}단계',
            style: AppTypography.c2.withColor(AppColors.main900),
          ),
          const SizedBox(height: 2),

          // 조명 레벨 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1단계',
                style: AppTypography.c1.withColor(AppColors.grey700),
              ),
              ...List.generate(5, (index) {
                return Container(
                  child:
                  SvgPicture.asset(
                    index < plant['lightLevel']
                      ? 'assets/icons/buddy/light_on.svg'
                      : 'assets/icons/buddy/light_off.svg',
                    width: 24,
                    height: 24,
                  ),
                );
              }),
              Text(
                '5단계',
                style: AppTypography.c1.withColor(AppColors.grey700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 씨앗 키트 제거 버튼
  Widget _buildSeedKitRemoveButton() {
    return GestureDetector(
      onTap: () {
        // 씨앗 키트 제거 기능
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.main600,
            width: 1.5
          ),
        ),
        child: Center(
          child: Text(
            '씨앗 키트 제거',
            style: AppTypography.s2.withColor(AppColors.main800),
          ),
        ),
      ),
    );
  }
}