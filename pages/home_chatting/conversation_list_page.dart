// conversation_list_page.dart
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
          icon: Icon(Icons.arrow_back, color: AppColors.grey900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '이전 대화',
          style: AppTypography.s1.withColor(AppColors.grey900),
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
                    '홈에서 새로운 대화를 시작해보세요!',
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
                  '오류가 발생했습니다: ${appError.message}',
                  style: AppTypography.b2.withColor(AppColors.grey600),
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
        // ✅ conversation ID 유효성 검사
        if (conversation.id.isEmpty) {
          _showSnackBar('잘못된 대화입니다.');
          return;
        }
        
        try {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                conversationId: conversation.id,
              ),
            ),
          );
        } catch (e) {
          print('대화 화면 이동 오류: $e');
          _showSnackBar('대화를 열 수 없습니다.');
        }
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
                  Text(
                    conversation.title, // Use conversation.title directly
                    style: AppTypography.b2.withColor(AppColors.grey900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage.isEmpty ? '새로운 대화' : conversation.lastMessage,
                    style: AppTypography.b4.withColor(AppColors.grey600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              DateFormatter.formatRelativeTime(conversation.lastMessageAt), // Use DateFormatter
              style: AppTypography.c2.withColor(AppColors.grey400),
            ),
          ],
        ),
      ),
    );
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