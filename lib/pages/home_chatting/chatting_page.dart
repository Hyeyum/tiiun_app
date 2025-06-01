import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/services/firebase_service.dart';
import 'package:tiiun/services/openai_service.dart';
import 'package:tiiun/models/conversation_model.dart';
import 'package:tiiun/models/message_model.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'dart:ui';

class ChatScreen extends StatefulWidget {
  final String? initialMessage;
  final String? conversationId;

  const ChatScreen({
    super.key,
    this.initialMessage,
    this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final FirebaseService _firebaseService = FirebaseService();

  // ValueNotifier로 텍스트 상태 관리 (깜빡임 방지)
  final ValueNotifier<bool> _hasTextNotifier = ValueNotifier<bool>(false);

  String? _currentConversationId;
  bool _isLoading = false;
  bool _isTyping = false;
  ConversationModel? _conversation;

  @override
  void initState() {
    super.initState();
    _currentConversationId = widget.conversationId;

    // 텍스트 변경 리스너
    _messageController.addListener(_onTextChanged);

    // 초기 메시지가 있으면 자동으로 전송
    if (widget.initialMessage != null && widget.conversationId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialMessage!);
      });
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _textFieldFocusNode.dispose();
    _hasTextNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // 스크롤해도 색상 변하지 않게
        leading: IconButton(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 12),
          icon: SvgPicture.asset(
            'assets/icons/functions/back.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 20, 20, 12),
            child: SvgPicture.asset('assets/icons/functions/record.svg', width: 24, height: 24,),
          )
        ],
      ),
      body: Stack(
        children: [
          // 메인 콘텐츠 (입력창과 겹치도록)
          GestureDetector(
            onTap: _focusTextField,
            child: Column(
              children: [
                Expanded(
                  child: _currentConversationId != null
                      ? _buildMessageList()
                      : _buildEmptyState(),
                ),
                if (_isTyping) _buildTypingIndicator(),
                // 여백 제거 - 메시지들이 입력창 뒤까지 올라오도록
              ],
            ),
          ),

          // 하단 고정 블러 입력창 (주변은 투명, 입력칸만 블러)
          Positioned(
            left: 12,
            right: 12,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // 입력칸만 반투명
                    borderRadius: BorderRadius.circular(48),
                    border: Border.all(
                      color: AppColors.grey200.withOpacity(0.8),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 카메라 버튼
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: GestureDetector(
                          onTap: () {
                            print('카메라 버튼 클릭');
                          },
                          child: SvgPicture.asset(
                            'assets/icons/functions/camera.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 텍스트 입력 필드
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _textFieldFocusNode,
                          decoration: InputDecoration(
                            hintText: '무엇이든 이야기하세요',
                            hintStyle: AppTypography.b4.withColor(AppColors.grey400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (_) => _sendCurrentMessage(),
                          maxLines: null,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 동적 버튼 (음성/전송)
                      _buildDynamicButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<MessageModel>>(
      stream: _firebaseService.getMessages(_currentConversationId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        // 메시지 순서를 뒤집어서 최신 메시지가 아래에 오도록
        final reversedMessages = messages.reversed.toList();

        return ListView.builder(
          controller: _scrollController,
          reverse: true, // ListView를 뒤집어서 아래부터 시작
          padding: EdgeInsets.fromLTRB(12, 82, 12, 96), // 패딩도 뒤집음
          itemCount: reversedMessages.length,
          itemBuilder: (context, index) {
            final message = reversedMessages[index];

            // AI의 마지막 메시지인지 확인
            final isLastAiMessage = index == 0 && !message.isUser;

            return _buildMessageBubble(message, isLastAiMessage);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(MessageModel message, [bool isLastAiMessage = false]) {
    final isUser = message.isUser;

    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // AI의 마지막 메시지일 때만 아이콘 표시
        if (isLastAiMessage)
          Container(
            // padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/logos/tiiun_logo.svg', // 원하는 아이콘으로 변경
                  width: 20,
                  height: 20,
                ),
              ],
            ),
          ),

        // 메시지 버블
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            decoration: BoxDecoration(
              color: isUser ? AppColors.main100 : AppColors.grey50,
              borderRadius: isUser
                  ? BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.zero,
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              )
                  : BorderRadius.only(
                topLeft: Radius.zero,
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: AppTypography.b3.withColor(
                    isUser ? AppColors.grey800 : AppColors.grey900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.only(
              topLeft: Radius.zero,
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '입력 중',
                style: AppTypography.b3.withColor(AppColors.grey900),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.grey900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.grey300,
          ),
          SizedBox(height: 16),
          Text(
            '새로운 대화를 시작해보세요!',
            style: AppTypography.b2.withColor(AppColors.grey600),
          ),
        ],
      ),
    );
  }

  // 메시지 입력 부분에서 동적 버튼만 ValueListenableBuilder로 감싸기
  Widget _buildDynamicButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _hasTextNotifier,
      builder: (context, hasText, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () {
              if (hasText) {
                _sendCurrentMessage();
              } else {
                print("음성 버튼 클릭");
              }
            },
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 150),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: hasText
                  ? SvgPicture.asset(
                'assets/icons/functions/Paper_Plane.svg',
                width: 28,
                height: 28,
                key: ValueKey('send'),
              )
                  : SvgPicture.asset(
                'assets/icons/functions/voice.svg',
                width: 28,
                height: 28,
                key: ValueKey('voice'),
              ),
            ),
          ),
        );
      },
    );
  }

  void _sendCurrentMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      // 메시지 전송 전에 먼저 스크롤 위치 유지
      final currentScrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;

      _sendMessage(message);
      _messageController.clear();

      // 텍스트 클리어 후 스크롤 위치 복원
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(currentScrollOffset);
      }
    }
  }

  Future<void> _sendMessage(String message) async {
    if (_isLoading || _isTyping) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 새 대화인 경우 생성
      if (_currentConversationId == null) {
        final conversation = await _firebaseService.createConversation();

        if (conversation == null) {
          throw Exception('대화 생성 실패');
        }

        _currentConversationId = conversation.conversationId;
        _conversation = conversation;
      }

      // 사용자 메시지 추가
      await _firebaseService.addMessage(
        conversationId: _currentConversationId!,
        content: message,
        sender: 'user',
      );

      // 타이핑 인디케이터 표시
      setState(() {
        _isTyping = true;
        _isLoading = false;
      });

      // 약간의 지연 후 AI 응답 생성
      await Future.delayed(Duration(milliseconds: 500));

      // 🔍 API 키 검증 디버깅 (메서드명 수정)
      print('🔍 디버깅 시작...');
      print('🔑 API 키 시작 부분: ${OpenAIService.getApiKeyPrefix()}');
      print('🔍 API 키 유효성: ${OpenAIService.isApiKeyValid()}');
      print('🔍 API 키 길이: ${OpenAIService.getApiKeyLength()}');

      String aiResponse;
      if (OpenAIService.isApiKeyValid()) {
        print('✅ API 키 유효 - OpenAI 호출 시작');

        try {
          aiResponse = await OpenAIService.getChatResponse(
            message: message,
            conversationType: 'normal',
          );
          print('✅ OpenAI API 응답 받음: ${aiResponse.substring(0, aiResponse.length > 50 ? 50 : aiResponse.length)}...');
        } catch (e) {
          print('❌ OpenAI API 에러: $e');
          aiResponse = '죄송해요, AI 응답 생성 중 오류가 발생했어요. 다시 시도해주세요! 🤖';
        }
      } else {
        print('❌ API 키 무효 - 폴백 응답 사용');
        aiResponse = _generateFallbackResponse(message);
      }

      // AI 응답 저장
      await _firebaseService.addMessage(
        conversationId: _currentConversationId!,
        content: aiResponse,
        sender: 'ai',
      );

      // 스크롤을 맨 아래로 (지연 시간 늘림)
      _scrollToBottom();

    } catch (e) {
      print('메시지 전송 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('메시지 전송 중 오류가 발생했습니다'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isTyping = false;
      });
    }
  }

  void _scrollToBottom() {
    // reverse ListView에서는 0이 맨 아래
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          0.0, // reverse ListView에서는 0이 맨 아래
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 텍스트 변경 감지
  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    _hasTextNotifier.value = hasText;
  }

  // 키보드 포커스 주기
  void _focusTextField() {
    FocusScope.of(context).requestFocus(_textFieldFocusNode);
  }

  // OpenAI API 실패 시 대체 응답
  String _generateFallbackResponse(String message) {
    // 간단한 키워드 기반 응답
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('안녕') || lowerMessage.contains('hi') || lowerMessage.contains('hello')) {
      return '안녕하세요! 😊 오늘 하루는 어떠셨나요?';
    } else if (lowerMessage.contains('고마') || lowerMessage.contains('감사')) {
      return '천만에요! 언제든지 도와드릴게요 😄';
    } else if (lowerMessage.contains('힘들') || lowerMessage.contains('우울') || lowerMessage.contains('슬프')) {
      return '힘든 시간을 보내고 계시는군요. 괜찮아요, 저가 여기 있어요 🤗';
    } else if (lowerMessage.contains('좋') || lowerMessage.contains('기쁘') || lowerMessage.contains('행복')) {
      return '정말 좋은 소식이네요! 😄 더 자세히 얘기해주세요!';
    } else if (lowerMessage.contains('?') || lowerMessage.contains('궁금')) {
      return '궁금한 게 있으시군요! 🤔 제가 아는 선에서 도움을 드릴게요.';
    } else {
      return '흥미로운 이야기네요! 😊 더 자세히 들려주세요.';
    }
  }
}