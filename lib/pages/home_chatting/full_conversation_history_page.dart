import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/models/conversation_model.dart';
import 'package:tiiun/pages/home_chatting/chatting_page.dart';
import 'package:tiiun/utils/date_formatter.dart';
import 'package:tiiun/utils/error_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FullConversationHistoryPage extends ConsumerStatefulWidget {
  const FullConversationHistoryPage({super.key});

  @override
  ConsumerState<FullConversationHistoryPage> createState() => _FullConversationHistoryPageState();
}

class _FullConversationHistoryPageState extends ConsumerState<FullConversationHistoryPage> {
  final List<Conversation> _conversations = [
    Conversation(
      id: 'dummy_1',
      userId: 'dummy_user_id',
      title: '이태희 팀장',
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      lastMessage: '히스테릭하다. 나이가 많다. 태진님을 지속적으로 괴롭히고 있다.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      plantId: 'default_plant',
      summary: '이태희 팀장: 히스테릭하다.\n나이가 많다.\n태진님을 지속적으로 괴롭히고 있다.',
      messageCount: 5,
      agentId: 'default_agent',
    ),
    Conversation(
      id: 'dummy_2',
      userId: 'dummy_user_id',
      title: '김지윤 대리',
      createdAt: DateTime.now().subtract(const Duration(days: 5, hours: 11)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5, hours: 10)),
      lastMessage: '시은님에게 종종 잘해준다. 딸기 라떼를 좋아한다.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 5, hours: 10)),
      plantId: 'default_plant',
      summary: '김지윤 대리: 시은님에게 종종 잘해준다.\n딸기 라떼를 좋아한다.',
      messageCount: 8,
      agentId: 'default_agent',
    ),
    Conversation(
      id: 'dummy_3',
      userId: 'dummy_user_id',
      title: '일로일로 프로젝트',
      createdAt: DateTime.now().subtract(const Duration(days: 10, hours: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10, hours: 3)),
      lastMessage: '시은님은 기획을 담당하고 있다. 5월 29일이 마감일이다.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 10, hours: 3)),
      plantId: 'default_plant',
      summary: '일로일로 프로젝트: 시은님은 기획을 담당하고 있다.\n5월 29일이 마감일이다.',
      messageCount: 12,
      agentId: 'default_agent',
    ),
    Conversation(
      id: 'dummy_4',
      userId: 'dummy_user_id',
      title: 'A 기업 이직 준비',
      createdAt: DateTime.now().subtract(const Duration(days: 15, hours: 9)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15, hours: 8)),
      lastMessage: '5월 29일에 서류 마감이었다. 회사 업무로 인해 이직 준비에 소홀해 아쉽다.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 15, hours: 8)),
      plantId: 'default_plant',
      summary: 'A 기업 이직 준비: 5월 29일에 서류 마감이었다.\n회사 업무로 인해 이직 준비에 소홀해 아쉽다.\n면접 준비는 AI와 함께 진행하고 있다.',
      messageCount: 7,
      agentId: 'default_agent',
    ),
    Conversation(
      id: 'dummy_5',
      userId: 'dummy_user_id',
      title: '버거킹 명동점',
      createdAt: DateTime.now().subtract(const Duration(days: 15, hours: 9)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15, hours: 8)),
      lastMessage: '시은님은 불고기 버거를 좋아한다. 해당 매장이 깨끗해서 자주 방문한다.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 15, hours: 8)),
      plantId: 'default_plant',
      summary: '버거킹 명동점: 시은님은 불고기 버거를 좋아한다.\n해당 매장이 깨끗해서 자주 방문한다.',
      messageCount: 7,
      agentId: 'default_agent',
    ),
    Conversation(
      id: 'dummy_6',
      userId: 'dummy_user_id',
      title: '맥도날드 명동점',
      createdAt: DateTime.now().subtract(const Duration(days: 15, hours: 9)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15, hours: 8)),
      lastMessage: '해당 매장은 직원이 불친절하다. 음식은 맛있으나 왠지 가기 싫어한다.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 15, hours: 8)),
      plantId: 'default_plant',
      summary: '맥도날드 명동점: 해당 매장은 직원이 불친절하다.\n음식은 맛있으나 왠지 가기 싫어한다.',
      messageCount: 7,
      agentId: 'default_agent',
    ),
  ];

  static const String _addNewItemId = 'add_new_conversation_placeholder';

  bool _showPopup = true; // State to control popup visibility

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  toolbarHeight: 56,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  floating: false,
                  pinned: false, // true로 하면 완전히 사라지지 않고 일부만 남음
                  snap: false,
                  leading: Container(
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/functions/back.svg',
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/functions/icon_dialog.svg',
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(AppColors.grey600, BlendMode.srcIn),
                        ),
                        onPressed: () {
                          setState(() {
                            _conversations.removeWhere((item) => item.id == _addNewItemId);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12),
                        Text(
                          '대화 리포트',
                          style: AppTypography.h5.withColor(AppColors.grey900),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '틔운이 기억한 대화 주제들이에요!\n틔운이 잘못 알고 있는 부분은 수정해주세요.',
                          style: AppTypography.b1.withColor(AppColors.grey700),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                _conversations.isEmpty && !_conversations.any((item) => item.id == _addNewItemId)
                    ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/functions/icon_dialog.svg',
                          width: 48,
                          height: 48,
                          colorFilter: const ColorFilter.mode(
                            AppColors.grey300,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '아직 대화 기록이 없습니다',
                          style: AppTypography.b2.withColor(AppColors.grey600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '대화를 시작하여 기록을 남겨보세요!',
                          style: AppTypography.c2.withColor(AppColors.grey400),
                        ),
                      ],
                    ),
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final conversation = _conversations[index];
                      if (conversation.id == _addNewItemId) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: _buildAddConversationButton(),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: _buildConversationItem(conversation),
                      );
                    },
                    childCount: _conversations.length,
                  ),
                ),
              ],
            ),
          ),
          if (_showPopup) _buildOverlayPopup(),
        ],
      ),
    );
  }

  Widget _buildAddConversationButton({EdgeInsetsGeometry? margin}) {
    return GestureDetector(
      onTap: () {
        _showSnackBar('새로운 대화 주제를 추가합니다.');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/functions/icon_plus.svg',
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    // summary에서 제목과 내용 분리 (': '를 기준으로)
    String title = '대화 주제';
    String content = conversation.summary ?? '새로운 대화';

    if (conversation.summary != null && conversation.summary!.contains(': ')) {
      final parts = conversation.summary!.split(': ');
      title = parts[0];
      content = parts.length > 1 ? parts[1] : conversation.summary!;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTypography.s1.withColor(AppColors.grey900),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/functions/Edit_Pencil_01.svg',
                        width: 20,
                        height: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          bool isAddButtonPresent = _conversations.any((item) => item.id == _addNewItemId);

                          if (isAddButtonPresent) {
                            _conversations.removeWhere((item) => item.id == _addNewItemId);
                          } else {
                            _conversations.insert(0, Conversation(
                              id: _addNewItemId,
                              userId: '',
                              title: '새 대화',
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                              lastMessage: '',
                              lastMessageAt: DateTime.now(),
                              messageCount: 0,
                              agentId: 'default',
                            ));
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  content.isEmpty ? '새로운 대화' : content,
                  style: AppTypography.b1.withColor(AppColors.grey700),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildOverlayPopup() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '틔운에게 알려주세요!',
                    style: AppTypography.h5.withColor(AppColors.grey900),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPopup = false;
                      });
                    },
                    child: SvgPicture.asset(
                      'assets/icons/community/Close_MD.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '이태희 팀장님과 A가 동일 인물인가요?',
                style: AppTypography.b2.withColor(AppColors.grey900),
              ),
              const SizedBox(height: 8),
              Text(
                '이태희 팀장님은 히스테릭하고 나이가 많아요.\nA는 히스테릭하고, 태진님을 지속적으로 괴롭히고 있어요.',
                style: AppTypography.b3.withColor(AppColors.grey900),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: 136,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showPopup = false;
                            });
                            _showSnackBar('동일 인물이 아니라고 응답하셨습니다.');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.grey100,
                            foregroundColor: AppColors.grey700,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            '아니에요',
                            style: AppTypography.b1.withColor(AppColors.grey900),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        width: 136,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showPopup = false;
                            });
                            _showSnackBar('동일 인물이라고 응답하셨습니다.');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.main700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            '맞아요',
                            style: AppTypography.b2.withColor(Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.point900,
        ),
      );
    }
  }
}