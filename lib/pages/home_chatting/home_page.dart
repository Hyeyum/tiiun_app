import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiiun/pages/home_chatting/chatting_page.dart';
import 'package:tiiun/pages/buddy/buddy_page.dart';
import 'package:tiiun/pages/home_chatting/conversation_list_page.dart';
import 'package:tiiun/pages/information/info_page.dart';
import 'package:tiiun/pages/mypage/my_page.dart';
import 'package:tiiun/pages/plant/plant_management_page.dart'; // 식물 관리 페이지 추가
import 'package:tiiun/pages/shopping/shopping_page.dart'; // 쇼핑 페이지 추가
import 'package:tiiun/pages/shopping/favorites_page.dart'; // 즐겨찾기 페이지 추가
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/services/firebase_service.dart';
import 'package:tiiun/services/ai_service.dart';
import 'package:tiiun/services/backend_providers.dart'; // 백엔드 프로바이더 추가
import 'package:tiiun/models/conversation_model.dart';
import 'package:tiiun/models/message_model.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/utils/error_handler.dart';
import 'package:tiiun/utils/logger.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;
  bool _showLeftGradient = false;
  bool _showRightGradient = false;

  final List<String> _quickActionMessages = [
    '이전 대화',
    '자랑거리',
    '고민거리',
    '위로가 필요할 때',
    '시시콜콜',
    '끝말 잇기',
    '화가 나요',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients && mounted) {
          _onScroll();
        }
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _goToChatScreen() {
    if (_textController.text.trim().isNotEmpty) {
      String message = _textController.text.trim();
      _textController.clear();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            initialMessage: message,
          ),
        ),
      );
    }
  }

  void _handleQuickAction(String actionText) async {
    if (actionText == '이전 대화') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConversationListPage(),
        ),
      );
    } else {
      final firebaseService = ref.read(firebaseServiceProvider);
      final aiService = ref.read(aiServiceProvider);

      try {
        _showLoadingDialog();

        final conversation = await firebaseService.createConversation(
          title: actionText,
          agentId: 'default_agent',
        );

        if (conversation == null) {
          throw Exception('대화 생성 실패');
        }

        final userMessageContent = firebaseService.quickActionMessages[actionText] ?? '안녕하세요!';
        await firebaseService.addMessage(
          conversationId: conversation.id,
          content: userMessageContent,
          sender: MessageSender.user.toString().split('.').last,
        );

        final aiResponse = await aiService.getResponse(
          conversationId: conversation.id,
          userMessage: userMessageContent,
        );

        await firebaseService.addMessage(
          conversationId: conversation.id,
          content: aiResponse.text,
          sender: MessageSender.agent.toString().split('.').last,
          type: MessageType.audio.toString().split('.').last,
        );

        if (mounted) Navigator.of(context).pop();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversation.id,
            ),
          ),
        );
      } on AppError catch (e) {
        if (mounted) Navigator.of(context).pop();
        AppLogger.error('AppError during quick action: ${e.message}', e, e.stackTrace);
        _showSnackBar('AI 응답 생성 중 오류가 발생했습니다: ${e.message}', AppColors.point900);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              initialMessage: firebaseService.quickActionMessages[actionText] ?? actionText,
            ),
          ),
        );
      } catch (e, stackTrace) {
        if (mounted) Navigator.of(context).pop();
        AppLogger.error('Unexpected error during quick action: $e', e, stackTrace);
        _showSnackBar('AI 응답 생성 중 알 수 없는 오류가 발생했습니다.', AppColors.point900);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              initialMessage: firebaseService.quickActionMessages[actionText] ?? actionText,
            ),
          ),
        );
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('틔운이가 생각하고 있어요...'),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    setState(() {
      _showLeftGradient = _scrollController.offset > 0;
      _showRightGradient = _scrollController.offset <
          (_scrollController.position.maxScrollExtent - 1);
    });
  }

  Widget _buildHomeContent() {
    return Container(
      color: const Color(0xFFF3F5F2),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/functions/notification_off.svg',
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 95),
                  SvgPicture.asset(
                    'assets/images/logos/tiiun_logo.svg',
                    width: 80,
                    height: 40,
                  ),
                  const SizedBox(height: 126), // 원래 높이로 되돌림
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(1.5),
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF72ED98), Color(0xFF10BEBE)],
                        stops: [0.4, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10BEBE).withOpacity(0.2),
                          spreadRadius: -4,
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )
                      ],
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 21),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(57),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              onSubmitted: (value) => _goToChatScreen(),
                              decoration: InputDecoration(
                                hintText: '무엇이든 이야기하세요',
                                hintStyle: AppTypography.b4.withColor(AppColors.grey400),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _goToChatScreen,
                            child: SvgPicture.asset(
                              'assets/icons/functions/Paper_Plane.svg',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: Stack(
                      children: [
                        ListView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          children: [
                            _buildQuickActionWithIcon('이전 대화', 'assets/icons/functions/icon_dialog.svg'),
                            const SizedBox(width: 8),
                            _buildQuickActionText('자랑거리'),
                            const SizedBox(width: 8),
                            _buildQuickActionText('고민거리'),
                            const SizedBox(width: 8),
                            _buildQuickActionText('위로가 필요할 때'),
                            const SizedBox(width: 8),
                            _buildQuickActionText('시시콜콜'),
                            const SizedBox(width: 8),
                            _buildQuickActionText('끝말 잇기'),
                            const SizedBox(width: 8),
                            _buildQuickActionText('화가 나요'),
                          ],
                        ),
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
                                      const Color(0xFFF3F5F2),
                                      const Color(0xFFF3F5F2).withOpacity(0.0),
                                    ],
                                    stops: [0.1, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                                      const Color(0xFFF3F5F2).withOpacity(0.0),
                                      const Color(0xFFF3F5F2),
                                    ],
                                    stops: [0.1, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 126), // 원래 높이로 되돌림
                  Container(
                    width: double.infinity,
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey100, width: 1),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/icons/functions/temperature_off.svg', width: 24, height: 24),
                        const SizedBox(width: 2),
                        Text('적정 온도', style: AppTypography.b3.withColor(AppColors.grey700)),
                        const SizedBox(width: 12),
                        Container(width: 1, height: 15, color: AppColors.grey200),
                        const SizedBox(width: 12),
                        SvgPicture.asset('assets/icons/functions/light_on.svg', width: 24, height: 24),
                        const SizedBox(width: 2),
                        Text('조명 밝기 낮음', style: AppTypography.b3.withColor(AppColors.grey700)),
                        const Spacer(),
                        SvgPicture.asset('assets/icons/functions/more.svg', width: 24, height: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 백엔드 기능 바로가기 섹션 추가
                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '겨울철 식물 관리 팁 \u{26C4}',
                            style: AppTypography.s1.withColor(AppColors.grey900),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildPlantTipCard(
                                  '겨울철 물주기, 깍지벌레 관리 팁',
                                  'assets/images/contents/plant_tip1.png'
                              ),
                              _buildPlantTipCard(
                                  '겨울 걱정 NO! 겨울철 식물 이사 고민 줄여요',
                                  'assets/images/contents/plant_tip2.png'
                              ),
                              _buildPlantTipCard(
                                  '실내 공기 정화 식물로 겨울철 건강 지키기',
                                  'assets/images/contents/plant_tip3.png'
                              ),
                              _buildPlantTipCard(
                                  '토분이 관리하기 쉽다고? 누가!',
                                  'assets/images/contents/plant_tip4.png'
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 6.0,
                    child: Image.asset(
                      'assets/images/contents/ad_banner.png',
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(height: 24,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionWithIcon(String text, String iconPath) {
    return GestureDetector(
      onTap: () => _handleQuickAction(text),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: AppTypography.b4.withColor(AppColors.grey700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantTipCard(String title, String imagePath) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48 - 8) / 2;

    return SizedBox(
      width: cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1.0,
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

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const BuddyPage();
      case 2:
        return const InfoPage();
      case 3:
        return const MyPage();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildQuickActionText(String text) {
    return GestureDetector(
      onTap: () => _handleQuickAction(text),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTypography.b4.withColor(AppColors.grey700),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey100, width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.b1.withColor(AppColors.grey900),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.c2.withColor(AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSummaryCard() {
    return Consumer(
      builder: (context, ref, child) {
        final plantCountAsync = ref.watch(plantCountProvider);
        final favoriteCountAsync = ref.watch(favoriteCountProvider);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey100, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey300.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.point600.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: AppColors.point600,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '나의 현황',
                style: AppTypography.b1.withColor(AppColors.grey900),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '식물',
                    style: AppTypography.c2.withColor(AppColors.grey600),
                  ),
                  plantCountAsync.when(
                    data: (count) => Text(
                      '${count}개',
                      style: AppTypography.c1.withColor(AppColors.grey900),
                    ),
                    loading: () => const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 1),
                    ),
                    error: (_, __) => Text(
                      '-',
                      style: AppTypography.c1.withColor(AppColors.grey900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '즐겨찾기',
                    style: AppTypography.c2.withColor(AppColors.grey600),
                  ),
                  favoriteCountAsync.when(
                    data: (count) => Text(
                      '${count}개',
                      style: AppTypography.c1.withColor(AppColors.grey900),
                    ),
                    loading: () => const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 1),
                    ),
                    error: (_, __) => Text(
                      '-',
                      style: AppTypography.c1.withColor(AppColors.grey900),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 네비게이션 메서드들
  void _navigateToPlantManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlantManagementPage(),
      ),
    );
  }

  void _navigateToShopping() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ShoppingPage(),
      ),
    );
  }

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoritesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            width: 360,
            height: 70, // 두 번째 코드와 동일하게 70으로 변경
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(
                  color: AppColors.grey100,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 두 번째 코드와 동일하게 변경
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      label: '홈',
                      activeIcon: 'assets/icons/navbar/home.svg',
                      inactiveIcon: 'assets/icons/navbar/home.svg',
                    ),
                    _buildNavItem(
                      index: 1,
                      label: '버디',
                      activeIcon: 'assets/icons/navbar/leaves.svg',
                      inactiveIcon: 'assets/icons/navbar/leaves.svg',
                    ),
                    _buildNavItem(
                      index: 2,
                      label: '정보',
                      activeIcon: 'assets/icons/navbar/information.svg',
                      inactiveIcon: 'assets/icons/navbar/information.svg',
                    ),
                    _buildNavItem(
                      index: 3,
                      label: 'My',
                      activeIcon: 'assets/icons/navbar/my.svg',
                      inactiveIcon: 'assets/icons/navbar/my.svg',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required String activeIcon,
    required String inactiveIcon,
  }) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container( // 두 번째 코드와 동일하게 Container 유지
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container( // 두 번째 코드와 동일하게 아이콘을 Container로 감쌈
              child: SvgPicture.asset(
                isSelected ? activeIcon : inactiveIcon,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.grey900 : AppColors.grey300,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 2), // 두 번째 코드와 동일하게 2로 변경
            Text(
              label,
              style: AppTypography.c2.withColor(
                  isSelected ? AppColors.grey900 : AppColors.grey300),
            ),
          ],
        ),
      ),
    );
  }
}