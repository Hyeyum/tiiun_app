// 디자인 수정됨
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:tiiun/services/conversation_service.dart';
import 'package:tiiun/models/conversation_model.dart'; // Ensure correct Conversation and Message models
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/pages/home_chatting/chatting_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/utils/error_handler.dart'; // Import ErrorHandler
import 'package:tiiun/utils/date_formatter.dart'; // Import DateFormatter

class ConversationListPage extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const ConversationListPage({super.key});

  @override
  ConsumerState<ConversationListPage> createState() => _ConversationListPageState(); // Changed to ConsumerState
}

class _ConversationListPageState extends ConsumerState<ConversationListPage> {
  // No need for direct instantiation of FirebaseService here, use ref.read

  @override
  Widget build(BuildContext context) {
    // Watch the userConversationsProvider to get real-time updates
    final conversationsAsyncValue = ref.watch(userConversationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            'assets/icons/functions/back.svg',
            width: 24,
            height: 24,
            color: AppColors.grey700,
          ),
        ),
        title: Text(
          '대화 목록',
          style: AppTypography.b2.withColor(AppColors.grey900),
        ),
        centerTitle: true,
      ),
      body: conversationsAsyncValue.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/functions/icon_chat.svg',
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
                    '버디와 새로운 대화를 시작해보세요!',
                    style: AppTypography.c2.withColor(AppColors.grey400),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return _buildConversationItem(conversation);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          final appError = ErrorHandler.handleException(error, stack);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '오류가 발생했습니다', // 두 번째 코드와 동일한 간단한 텍스트
                  style: AppTypography.b2.withColor(AppColors.grey600),
                ),
                const SizedBox(height: 8), // 두 번째 코드와 동일한 간격
                Text(
                  '${appError.message}', // 두 번째 코드와 동일하게 에러 메시지 형태 변경
                  style: AppTypography.c2.withColor(AppColors.grey400),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(userConversationsProvider); // Invalidate the provider to retry
                  },
                  child: Text('다시 시도'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversation.id,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: AppColors.grey600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 대화 제목 (두 번째 코드와 동일한 방식으로 생성)
                  Text(
                    _getConversationTitle(conversation),
                    style: AppTypography.b2.withColor(AppColors.grey900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // 마지막 메시지 가져오기 (두 번째 코드와 동일한 방식)
                  _buildLastMessage(conversation),
                ],
              ),
            ),
            Text(
              _getFormattedTime(conversation), // 두 번째 코드와 동일한 방식으로 시간 포맷
              style: AppTypography.c2.withColor(AppColors.grey400),
            ),
          ],
        ),
      ),
    );
  }

  // 대화 제목 생성 (두 번째 코드와 동일한 방식)
  String _getConversationTitle(Conversation conversation) {
    // 기본 제목이 있으면 사용, 없으면 시간 기반 제목
    if (conversation.id.isNotEmpty) {
      final date = conversation.createdAt ?? DateTime.now();
      final month = date.month;
      final day = date.day;
      final hour = date.hour;
      final minute = date.minute;
      return '$month월 ${day}일 ${hour}:${minute.toString().padLeft(2, '0')}';
    }
    return '틔운이와의 대화';
  }

// 마지막 메시지 표시 위젯 (기존 방식 유지)
  Widget _buildLastMessage(Conversation conversation) {
    if (conversation.lastMessage.isNotEmpty) {
      return Text(
        conversation.lastMessage,
        style: AppTypography.b4.withColor(AppColors.grey600),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text(
      '새로운 대화',
      style: AppTypography.b4.withColor(AppColors.grey600),
    );
  }

  // 시간 포맷 (두 번째 코드와 동일한 방식)
  String _getFormattedTime(Conversation conversation) {
    final date = conversation.lastMessageAt ?? conversation.createdAt ?? DateTime.now();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  // ✅ 스낵바 메서드 추가
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