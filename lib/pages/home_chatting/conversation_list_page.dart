// conversation_list_page.dart
import 'package:flutter/material.dart';
import 'package:tiiun/services/firebase_service.dart';
import 'package:tiiun/models/conversation_model.dart';
import 'package:tiiun/models/message_model.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/pages/home_chatting/chatting_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConversationListPage extends StatefulWidget {
  const ConversationListPage({super.key});

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder<List<ConversationModel>>(
        stream: _firebaseService.getConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '오류가 발생했습니다',
                    style: AppTypography.b2.withColor(AppColors.grey600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: AppTypography.c2.withColor(AppColors.grey400),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // 새로고침
                    },
                    child: Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final conversations = snapshot.data ?? [];

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
      ),
    );
  }

  Widget _buildConversationItem(ConversationModel conversation) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversation.conversationId!,
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
                  // 대화 제목 (없으면 기본 제목)
                  Text(
                    _getConversationTitle(conversation),
                    style: AppTypography.b2.withColor(AppColors.grey900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // 마지막 메시지 가져오기
                  _buildLastMessage(conversation),
                ],
              ),
            ),
            Text(
              conversation.formattedTime,
              style: AppTypography.c2.withColor(AppColors.grey400),
            ),
          ],
        ),
      ),
    );
  }

  // 대화 제목 생성
  String _getConversationTitle(ConversationModel conversation) {
    // 기본 제목이 있으면 사용, 없으면 시간 기반 제목
    if (conversation.conversationId != null) {
      final date = conversation.createdAt;
      final month = date.month;
      final day = date.day;
      final hour = date.hour;
      final minute = date.minute;
      return '$month월 ${day}일 ${hour}:${minute.toString().padLeft(2, '0')} 대화';
    }
    return '틔운이와의 대화';
  }

  // 마지막 메시지 표시 위젯
  Widget _buildLastMessage(ConversationModel conversation) {
    if (conversation.lastMessageId == null) {
      return Text(
        '새로운 대화',
        style: AppTypography.b4.withColor(AppColors.grey600),
      );
    }

    // 마지막 메시지 내용 가져오기
    return FutureBuilder<MessageModel?>(
      future: _firebaseService.getMessage(conversation.lastMessageId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            '로딩 중...',
            style: AppTypography.b4.withColor(AppColors.grey400),
          );
        }

        final message = snapshot.data;
        if (message == null) {
          return Text(
            '메시지를 불러올 수 없습니다',
            style: AppTypography.b4.withColor(AppColors.grey400),
          );
        }

        return Text(
          message.content,
          style: AppTypography.b4.withColor(AppColors.grey600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}