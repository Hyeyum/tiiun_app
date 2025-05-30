import 'package:flutter/material.dart';
import 'package:tiiun/pages/home_chatting/chatting_page.dart';
import 'package:tiiun/pages/buddy/buddy_page.dart';
import 'package:tiiun/pages/home_chatting/conversation_list_page.dart';
import 'package:tiiun/pages/information/info_page.dart';
import 'package:tiiun/pages/mypage/my_page.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/services/firebase_service.dart';
import 'package:tiiun/services/openai_service.dart';
import 'package:tiiun/models/conversation_model.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseService _firebaseService = FirebaseService();
  int _selectedIndex = 0;
  bool _showLeftGradient = false;
  bool _showRightGradient = false;

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
      // 이전 대화 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConversationListPage(),
        ),
      );
    } else {
      // 퀵액션으로 새 대화 생성
      try {
        // 로딩 표시
        _showLoadingDialog();

        // 1. 퀵액션으로 대화 시작 (자동으로 첫 메시지 추가됨)
        final conversation = await _firebaseService.startQuickActionConversation(actionText);

        if (conversation == null) {
          throw Exception('대화 생성 실패');
        }

        // 2. AI 응답 생성
        final userMessage = _firebaseService.quickActionMessages[actionText] ?? '안녕하세요!';
        String aiResponse;

        if (OpenAIService.isApiKeyValid()) {
          aiResponse = await OpenAIService.getChatResponse(
            message: userMessage,
            conversationType: actionText,
          );
        } else {
          // API 키가 없으면 기본 응답 사용
          aiResponse = _generateFallbackResponse(actionText);
        }

        // 3. AI 응답 저장
        await _firebaseService.addMessage(
          conversationId: conversation.conversationId!,
          content: aiResponse,
          sender: 'ai',
        );

        // 로딩 다이얼로그 닫기
        if (mounted) Navigator.of(context).pop();

        // 4. 채팅 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversation.conversationId!,
            ),
          ),
        );
      } catch (e) {
        // 로딩 다이얼로그 닫기
        if (mounted) Navigator.of(context).pop();

        print('퀵액션 처리 오류: $e');

        // 에러 발생 시 기본 채팅 화면으로 이동
        final message = _firebaseService.quickActionMessages[actionText] ?? actionText;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              initialMessage: message,
            ),
          ),
        );

        // 에러 스낵바 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI 응답 생성 중 오류가 발생했습니다'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // 로딩 다이얼로그 표시
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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

  // OpenAI API 실패 시 대체 응답
  String _generateFallbackResponse(String actionType) {
    switch (actionType) {
      case '자랑거리':
        return '와! 정말 자랑스러운 일이네요! 🎉 더 자세히 얘기해주세요!';
      case '고민거리':
        return '고민이 있으시는군요 💭 편하게 말씀해주세요. 제가 들어드릴게요.';
      case '위로가 필요할 때':
        return '힘든 시간을 보내고 계시는군요 🫂 괜찮아요, 모든 게 다 지나갈 거예요.';
      case '시시콜콜':
        return '안녕하세요! 😄 심심하셨군요! 저도 이야기하고 싶었어요.';
      case '끝말 잇기':
        return '끝말잇기 좋아요! 🎮 제가 먼저 시작할게요. "사과"!';
      case '화가 나요':
        return '화가 나셨군요 😤 무슨 일이 있으셨나요? 저한테 털어놓으세요.';
      default:
        return '안녕하세요! 😊 무엇을 도와드릴까요?';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // 초기 그라데이션 상태 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients && mounted) {
          _onScroll();
        }
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    setState(() {
      _showLeftGradient = _scrollController.offset > 0;
      _showRightGradient = _scrollController.offset <
          (_scrollController.position.maxScrollExtent - 1);
    });
  }

  // 홈 탭
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
                    'assets/images/tiiun_logo.svg',
                    width: 80,
                    height: 40,
                  ),
                  const SizedBox(height: 126),
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
                                width: 24,
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
                                width: 24,
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
                  const SizedBox(height: 126),
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

                  // 겨울철 식물 관리 팁
                  Container(
                    width: double.infinity,
                    // height: 700,
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

                          // Wrap으로 식물 관리 팁 카드들 배치
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildPlantTipCard(
                                  '겨울철 물주기, 깍지벌레 관리 팁',
                                  'assets/images/plant_tip1.png'
                              ),
                              _buildPlantTipCard(
                                  '겨울 걱정 NO! 겨울철 식물 이사 고민 줄여요',
                                  'assets/images/plant_tip2.png'
                              ),
                              _buildPlantTipCard(
                                  '실내 공기 정화 식물로 겨울철 건강 지키기',
                                  'assets/images/plant_tip3.png'
                              ),
                              _buildPlantTipCard(
                                  '토분이 관리하기 쉽다고? 누가!',
                                  'assets/images/plant_tip4.png'
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
                      'assets/images/ad_banner.png',
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

  // 아이콘 + 텍스트가 있는 퀵 액션 버튼 (이전 대화용)
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

  // 2열 그리드용 식물 관리 팁 카드 위젯 (세로형)
  Widget _buildPlantTipCard(String title, String imagePath) {
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




  // 각 탭 내용 선택
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

  // 텍스트만 있는 퀵 액션 버튼
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
            height: 70,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(5),
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
            const SizedBox(height: 2),
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