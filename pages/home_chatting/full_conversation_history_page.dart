import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/services/conversation_service.dart'; // Keep for future real data
import 'package:tiiun/models/conversation_model.dart';
import 'package:tiiun/pages/home_chatting/chatting_page.dart'; // Still needed if ChatScreen is used elsewhere
import 'package:tiiun/utils/date_formatter.dart'; // Keep if used elsewhere
import 'package:tiiun/utils/error_handler.dart';
import 'package:flutter_svg/flutter_svg.dart'; // flutter_svg 패키지 import

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
      lastMessage: '히스테릭하다. 나이가 많다. 태진님을 지속적으로 괴롭히고 있다.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
      agentId: 'default_agent',
      messageCount: 5,
    ),
    Conversation(
      id: 'dummy_2',
      userId: 'dummy_user_id',
      title: '김지윤 대리',
      lastMessage: '시은님에게 종종 잘해준다. 딸기 라떼를 좋아한다.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 5, hours: 10)),
      createdAt: DateTime.now().subtract(const Duration(days: 5, hours: 11)),
      agentId: 'default_agent',
      messageCount: 8,
    ),
    Conversation(
      id: 'dummy_3',
      userId: 'dummy_user_id',
      title: '일로일로 프로젝트',
      lastMessage: '시은님은 기획을 담당하고 있다. 5월 29일이 마감일이다.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 10, hours: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 10, hours: 4)),
      agentId: 'default_agent',
      messageCount: 12,
    ),
    Conversation(
      id: 'dummy_4',
      userId: 'dummy_user_id',
      title: 'A 기업 이직 준비',
      lastMessage: '5월 29일에 서류 마감이었다. 외사 업무로 인해 이직 준비에 소홀 아쉽다. 면접 준비는 AI와 함께 진행하고 있다.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 15, hours: 8)),
      createdAt: DateTime.now().subtract(const Duration(days: 15, hours: 9)),
      agentId: 'default_agent',
      messageCount: 7,
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/functions/back.svg', // 예시 경로
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(AppColors.grey900, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/functions/icon_dialog.svg', // 예시 경로
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(AppColors.grey900, BlendMode.srcIn),
            ),
            onPressed: () {
              setState(() {
                _conversations.removeWhere((item) => item.id == _addNewItemId);
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  '대화 리포트',
                  style: AppTypography.s1.withColor(AppColors.grey900),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  '티운이 기억한 대화 주제들이에요!',
                  style: AppTypography.b4.withColor(AppColors.grey600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Text(
                  '티운이 잘못 알고 있는 부분은 수정해주세요.',
                  style: AppTypography.b4.withColor(AppColors.grey600),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _conversations.isEmpty && !_conversations.any((item) => item.id == _addNewItemId)
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/functions/icon_dialog.svg',
                              width: 48,
                              height: 48,
                              colorFilter: ColorFilter.mode(
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
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = _conversations[index];
                          if (conversation.id == _addNewItemId) {
                            return _buildAddConversationButton(margin: const EdgeInsets.only(bottom: 12));
                          }
                          return _buildConversationItem(conversation);
                        },
                      ),
              ),
            ],
          ),
          if (_showPopup) _buildOverlayPopup(), // Overlay popup when _showPopup is true
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
        margin: margin,
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey100),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/functions/icon_plus.svg', // 예시 경로
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(AppColors.grey600, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.title,
                  style: AppTypography.b2.withColor(AppColors.grey900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  conversation.lastMessage.isEmpty ? '새로운 대화' : conversation.lastMessage,
                  style: AppTypography.b4.withColor(AppColors.grey600),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/functions/Edit_Pencil_01.svg', // 예시 경로
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(AppColors.grey400, BlendMode.srcIn),
            ),
            onPressed: () {
              setState(() {
                bool isAddButtonPresent = _conversations.any((item) => item.id == _addNewItemId);

                if (isAddButtonPresent) {
                  _conversations.removeWhere((item) => item.id == _addNewItemId);
                } else {
                  _conversations.insert(0,
                    Conversation(
                      id: _addNewItemId,
                      userId: '', title: '', lastMessage: '',
                      lastMessageAt: DateTime.now(), createdAt: DateTime.now(),
                      agentId: '', messageCount: 0,
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayPopup() {
    return Container(
      color: Colors.black.withOpacity(0.5), // Semi-transparent black background
      alignment: Alignment.center,
      child: Material( // Wrap with Material to avoid text display issues
        color: Colors.transparent,
        child: Container(
          width: 320, // Approximate width based on image
          margin: const EdgeInsets.symmetric(horizontal: 24), // Center the popup with horizontal margin
          padding: const EdgeInsets.all(20), // Uniform padding, will adjust inner elements
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row( // Use a Row to place title and close button on the same line
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center, // Vertically align title and icon
                children: [
                  Text(
                    '티운에게 알려주세요!',
                    style: AppTypography.s1.withColor(AppColors.grey900), // Changed to s1
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPopup = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8), // Add left padding to keep it from the edge
                      child: Icon(Icons.close, color: AppColors.grey500, size: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Spacing below title
              Text(
                '이태희 팀장님과 A가 동일 인물인가요?',
                style: AppTypography.b2.withColor(AppColors.grey900),
              ),
              const SizedBox(height: 10),
              Text(
                '이태희 팀장님은 히스테릭하고 나이가 많아요. A는 히스테릭하고, 태진님을 지속적으로 괴롭히고 있어요.',
                style: AppTypography.b4.withColor(AppColors.grey600),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showPopup = false;
                        });
                        _showSnackBar('동일 인물이 아니라고 응답하셨습니다.');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grey100,
                        foregroundColor: AppColors.grey900,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppColors.grey100),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '아니에요',
                        style: AppTypography.b2.withColor(AppColors.grey900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showPopup = false;
                        });
                        _showSnackBar('동일 인물이라고 응답하셨습니다.');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.main400, // Changed to point500
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '맞아요',
                        style: AppTypography.b2.withColor(Colors.white),
                      ),
                    ),
                  ),
                ],
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