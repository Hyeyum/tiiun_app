import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/services/firebase_service.dart';
import 'package:tiiun/services/openai_service.dart';
import 'package:tiiun/models/conversation_model.dart';
import 'package:tiiun/models/message_model.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiiun/services/conversation_service.dart';
import 'package:tiiun/services/ai_service.dart';
import 'package:tiiun/utils/error_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

// Import the new Modal AnalysisScreen
import 'package:tiiun/pages/home_chatting/analysis_page.dart';
import 'package:tiiun/services/voice_assistant_service.dart';
import 'package:tiiun/services/speech_to_text_service.dart';
import 'package:tiiun/services/voice_service.dart';
import 'package:tiiun/services/image_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? initialMessage;
  final String? conversationId;

  const ChatScreen({
    super.key,
    this.initialMessage,
    this.conversationId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final FirebaseService _firebaseService = FirebaseService();

  // ValueNotifier로 텍스트 상태 관리 (깜빡임 방지)
  final ValueNotifier<bool> _hasTextNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isRecordingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _currentTranscriptionNotifier = ValueNotifier<String>('');
  final ValueNotifier<bool> _isUploadingImageNotifier = ValueNotifier<bool>(false);

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
    _isRecordingNotifier.dispose();
    _currentTranscriptionNotifier.dispose();
    _isUploadingImageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
          icon: SvgPicture.asset(
            'assets/icons/functions/back.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 20, 20, 12),
            child: GestureDetector(
              onTap: _showAnalysisModal,
              child: SvgPicture.asset(
                'assets/icons/functions/record.svg',
                width: 24,
                height: 24,
              ),
            ),
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
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(48),
                    border: Border.all(
                      color: AppColors.grey200.withOpacity(0.8),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 카메라 버튼
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: GestureDetector(
                          onTap: _handleCameraButton,
                          child: Image.asset(
                            'assets/icons/functions/camera.png',
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
          padding: const EdgeInsets.fromLTRB(12, 82, 12, 82), // 패딩도 뒤집음
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
                  'assets/images/logos/tiiun_logo.svg',
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
                  ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.zero,
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              )
                  : const BorderRadius.only(
                topLeft: Radius.zero,
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isImage && message.imageUrl != null) ...[
                    _buildImageMessage(message.imageUrl!),
                    if (message.content.trim().isNotEmpty)
                      const SizedBox(height: 8),
                  ],

                  if (message.content.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Text(
                        message.content,
                        style: AppTypography.b3.withColor(
                          isUser ? AppColors.grey800 : AppColors.grey900,
                        ),
                      ),
                    ),

                  if (message.audioUrl != null && message.audioUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _buildAudioPlayer(message.audioUrl!),
                    ),
                ]

            ),
          ),
        ),
      ],
    );
  }

  // 오디오 플레이어 위젯 추가
  Widget _buildAudioPlayer(String audioUrl) {
    // 임시로 provider 없이 작동하도록 수정
    return GestureDetector(
      onTap: () async {
        // 임시로 스낵바로 대체
        _showSnackBar('음성 메시지 재생 기능이 곧 추가될 예정입니다.', AppColors.main600);
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_fill,
            color: AppColors.main700,
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            '음성 메시지',
            style: TextStyle(color: AppColors.main700, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
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
              const SizedBox(width: 8),
              const SizedBox(
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
    return const Center(
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
            style: TextStyle(color: AppColors.grey600, fontSize: 16),
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
                _toggleVoiceInput();
              }
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
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
                colorFilter: const ColorFilter.mode(AppColors.main600, BlendMode.srcIn),
                key: const ValueKey('send'),
              )
                  : ValueListenableBuilder<bool>(
                valueListenable: _isRecordingNotifier,
                builder: (context, isRecording, child) {
                  return SvgPicture.asset(
                    'assets/icons/functions/voice.svg',
                    width: 28,
                    height: 28,
                    key: ValueKey(isRecording ? 'voice_recording' : 'voice'),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // 음성 입력 (녹음) 토글 메서드 추가
  Future<void> _toggleVoiceInput() async {
    // 임시로 스낵바로 대체
    _showSnackBar('음성 입력 기능이 곧 추가될 예정입니다.', AppColors.main600);
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
      // 새 대화인 경우 Firestore에 생성
      if (_currentConversationId == null) {
        final conversation = await _firebaseService.createConversation();

        if (conversation == null) {
          throw Exception('대화 생성 실패');
        }

        _currentConversationId = conversation.conversationId;
        _conversation = conversation;
      }

      // 사용자 메시지 저장
      await _firebaseService.addMessage(
        conversationId: _currentConversationId!,
        content: message,
        sender: 'user',
      );

      setState(() {
        _isTyping = true;
        _isLoading = false;
      });

      // 약간의 딜레이 후 AI 응답 생성
      await Future.delayed(const Duration(milliseconds: 500));

      String aiResponse;
      if (OpenAIService.isApiKeyValid()) {
        try {
          aiResponse = await OpenAIService.getChatResponse(
            message: message,
            conversationType: 'normal',
          );
        } catch (e) {
          aiResponse = 'AI 응답 생성 중 오류가 발생했습니다. 다시 시도해주세요!';
        }
      } else {
        aiResponse = _generateFallbackResponse(message);
      }

      // AI 메시지 저장
      await _firebaseService.addMessage(
        conversationId: _currentConversationId!,
        content: aiResponse,
        sender: 'ai',
      );

      _scrollToBottom();

    } catch (e) {
      _showSnackBar('메시지 전송 중 오류가 발생했습니다.', AppColors.point900);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isTyping = false;
        });
      }
    }
  }


  void _scrollToBottom() {
    // reverse ListView에서는 0이 맨 아래
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          0.0, // reverse ListView에서는 0이 맨 아래
          duration: const Duration(milliseconds: 300),
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

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // 이미지 메시지 위젯
  Widget _buildImageMessage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: AppColors.grey100,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.main600),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: AppColors.grey100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.grey400, size: 32),
              const SizedBox(height: 8),
              Text(
                '이미지를 불러올 수 없습니다',
                style: AppTypography.c2.withColor(AppColors.grey400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 카메라 버튼 핸들러
  Future<void> _handleCameraButton() async {
    // 임시로 스낵바로 대체
    _showSnackBar('이미지 전송 기능이 곧 추가될 예정입니다.', AppColors.main600);
  }

  // 이미지 메시지 전송
  Future<void> _sendImageMessage(String imageUrl) async {
    // 임시로 구현
    _showSnackBar('이미지가 전송되었습니다.', AppColors.main600);
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

  // Modal Bottom Sheet로 분석 화면 띄우기
  void _showAnalysisModal() {
    if (_currentConversationId != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => ModalAnalysisScreen(
          conversationId: _currentConversationId!,
        ),
      );
    } else {
      _showSnackBar('대화가 시작된 후에 분석을 시작할 수 있습니다.', AppColors.main600);
    }
  }
}