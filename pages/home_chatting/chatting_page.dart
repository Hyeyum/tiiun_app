import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:tiiun/services/conversation_service.dart'; // Corrected import for ConversationService
import 'package:tiiun/models/conversation_model.dart'; // Import Conversation model
import 'package:tiiun/models/message_model.dart'; // Import Message model
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/services/ai_service.dart'; // Import AiService
import 'package:tiiun/utils/error_handler.dart'; // Import ErrorHandler for consistent error handling
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg
import 'package:cached_network_image/cached_network_image.dart'; // 이미지 표시용
import 'package:image_picker/image_picker.dart'; // 이미지 선택용

// Import the new Modal AnalysisScreen
import 'package:tiiun/pages/home_chatting/analysis_page.dart'; // 새로운 Modal Analysis Screen import
import 'package:tiiun/services/voice_assistant_service.dart'; // VoiceAssistantService 임포트
import 'package:tiiun/services/speech_to_text_service.dart'; // SpeechToTextService 임포트 (SimpleSpeechRecognizer 상태를 받기 위함)
import 'package:tiiun/services/voice_service.dart'; // VoiceService for audio playback
import 'package:tiiun/services/image_service.dart'; // 이미지 서비스 임포트

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

  final ValueNotifier<bool> _hasTextNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isRecordingNotifier = ValueNotifier<bool>(false); // 녹음 상태를 위한 ValueNotifier 추가
  final ValueNotifier<String> _currentTranscriptionNotifier = ValueNotifier<String>(''); // 실시간 음성 인식을 위한 ValueNotifier 추가
  final ValueNotifier<bool> _isUploadingImageNotifier = ValueNotifier<bool>(false); // 이미지 업로드 상태 추가


  String? _currentConversationId;
  bool _isLoading = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _currentConversationId = widget.conversationId;

    _messageController.addListener(_onTextChanged);

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
    _isRecordingNotifier.dispose(); // ValueNotifier dispose 추가
    _currentTranscriptionNotifier.dispose(); // ValueNotifier dispose 추가
    _isUploadingImageNotifier.dispose(); // 이미지 업로드 상태 dispose 추가
    super.dispose();
  }

  // Modal Bottom Sheet로 분석 화면 띄우기
  void _showAnalysisModal() {
    if (_currentConversationId != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // 전체 화면 제어 가능하도록 설정
        backgroundColor: Colors.transparent, // 배경 투명하게 설정
        barrierColor: Colors.black.withOpacity(0.5), // 배경 어둡게 설정
        builder: (context) => ModalAnalysisScreen(
          conversationId: _currentConversationId!,
        ),
      );
    } else {
      _showSnackBar('대화가 시작된 후에 분석을 시작할 수 있습니다.', AppColors.main600);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 키보드가 올라와도 화면이 리사이즈되도록 설정
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
          icon: SvgPicture.asset( // Changed to SvgPicture
            'assets/icons/functions/back.svg', // Assuming an arrow_back SVG exists
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(AppColors.grey800, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // conv.svg 아이콘을 가장 오른쪽에 정렬
          Container(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 12), // right 패딩을 0으로 변경
            child: SvgPicture.asset(
              'assets/icons/nv.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(AppColors.grey800, BlendMode.srcIn),
            ),
          ),
          // analytics.svg 아이콘 (conv.svg의 왼쪽에 배치됨)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 20, 12), // 기존 right 패딩 유지
            child: GestureDetector(
              onTap: _showAnalysisModal, // Modal Bottom Sheet 호출
              child: SvgPicture.asset( // Changed to SvgPicture
                'assets/icons/functions/record.svg', // Assuming an analytics SVG exists
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(AppColors.grey800, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _focusTextField,
        child: Column(
          children: [
            // 메시지 리스트를 Expanded로 감싸서 남은 공간 모두 사용
            Expanded(
              child: _currentConversationId != null
                  ? _buildMessageList()
                  : _buildEmptyState(),
            ),
            // 타이핑 인디케이터
            if (_isTyping) _buildTypingIndicator(),
            // 입력창을 별도의 위젯으로 분리
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // 안전한 입력창 (BackdropFilter 제거)
  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        MediaQuery.of(context).padding.bottom + 16
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white, // 불투명한 배경
          borderRadius: BorderRadius.circular(48),
          border: Border.all(
            color: AppColors.grey200,
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
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: ValueListenableBuilder<bool>(
                valueListenable: _isUploadingImageNotifier,
                builder: (context, isUploading, child) {
                  return GestureDetector(
                    onTap: isUploading ? null : _handleCameraButton, // 업로드 중이면 비활성화
                    child: isUploading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.main600),
                            ),
                          )
                        : SvgPicture.asset( // Changed to SvgPicture
                            'assets/icons/functions/camera.svg', // Assuming a camera_alt SVG exists
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(AppColors.grey800, BlendMode.srcIn),
                          ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
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
            _buildDynamicButton(),
          ],
        ),
      ),
    );
  }

  // 수정된 메시지 리스트 - 더 간단한 padding
  Widget _buildMessageList() {
    // null 체크 및 유효성 검사 추가
    if (_currentConversationId == null || _currentConversationId!.isEmpty) {
      print('Invalid conversation ID: $_currentConversationId');
      return _buildEmptyState();
    }

    final conversationService = ref.watch(conversationServiceProvider);
    return StreamBuilder<List<Message>>(
      stream: conversationService.getConversationMessages(_currentConversationId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 더 상세한 에러 처리 추가
        if (snapshot.hasError) {
          print('Error loading messages: ${snapshot.error}');
          final error = ErrorHandler.handleException(snapshot.error!);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset( // Changed to SvgPicture
                  'assets/icons/functions/icon_info.svg', // Assuming an error_outline SVG exists
                  width: 48,
                  height: 48,
                  colorFilter: ColorFilter.mode(AppColors.grey400, BlendMode.srcIn),
                ),
                const SizedBox(height: 16),
                Text(
                  '메시지를 불러올 수 없습니다',
                  style: AppTypography.b2.withColor(AppColors.grey600),
                ),
                const SizedBox(height: 8),
                Text(
                  error.message,
                  style: AppTypography.c2.withColor(AppColors.grey400),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grey200,
                        foregroundColor: AppColors.grey600,
                      ),
                      child: Text('돌아가기'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {}); // 스트림 재시도
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.main600,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('다시 시도'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        final reversedMessages = messages.reversed.toList();

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          // 간단한 padding - Column 구조에서는 겹칠 일이 없음
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          itemCount: reversedMessages.length,
          itemBuilder: (context, index) {
            final message = reversedMessages[index];
            return _buildMessageBubble(message);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.isUser;

    return Align(
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
            // 이미지 메시지 처리
            if (message.type == MessageType.image && message.attachments.isNotEmpty)
              _buildImageMessage(message.attachments.first.url),
            // 텍스트 메시지 처리 (이미지가 없거나 텍스트가 있는 경우)
            if (message.content.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  top: (message.type == MessageType.image && message.attachments.isNotEmpty) ? 8 : 0,
                ),
                child: Text(
                  message.content,
                  style: AppTypography.b3.withColor(
                    isUser ? AppColors.grey800 : AppColors.grey900,
                  ),
                ),
              ),
            if (message.audioUrl != null && message.audioUrl!.isNotEmpty) // 오디오 URL이 있으면 재생 버튼 추가
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildAudioPlayer(message.audioUrl!), // 오디오 플레이어 빌드 메서드 호출
              ),
          ],
        ),
      ),
    );
  }

  // 오디오 플레이어 위젯 추가
  Widget _buildAudioPlayer(String audioUrl) {
    final voiceService = ref.read(voiceServiceProvider); // VoiceService 인스턴스 가져오기
    return StreamBuilder<bool>(
      stream: Stream.periodic(const Duration(milliseconds: 100), (_) => voiceService.isPlaying && voiceService.currentPlayingUrl == audioUrl), // 재생 상태 스트림
      builder: (context, snapshot) {
        final isPlayingThisAudio = snapshot.data ?? false;
        return GestureDetector(
          onTap: () async {
            if (isPlayingThisAudio) {
              await voiceService.stopSpeaking(); // 재생 중이면 중지
            } else {
              await voiceService.playAudio(audioUrl, isLocalFile: audioUrl.startsWith('/data')); // 재생 시작
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPlayingThisAudio ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: AppColors.main700,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isPlayingThisAudio ? '재생 중' : '음성 메시지',
                style: AppTypography.b4.withColor(AppColors.main700),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: const BorderRadius.only(
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset( // Changed to SvgPicture
            'assets/icons/functions/icon_chat.svg', // Assuming a chat_bubble_outline SVG exists
            width: 64,
            height: 64,
            colorFilter: ColorFilter.mode(AppColors.grey300, BlendMode.srcIn),
          ),
          const SizedBox(height: 16),
          Text(
            '새로운 대화를 시작해보세요!',
            style: AppTypography.b2.withColor(AppColors.grey600),
          ),
        ],
      ),
    );
  }

  // 안전한 동적 버튼 (SVG 사용)
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
                _toggleVoiceInput(); // 텍스트 없으면 음성 입력 토글
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
                  ? SvgPicture.asset( // Changed to SvgPicture
                      'assets/icons/functions/Paper_Plane.svg', // Assuming a send SVG exists
                      width: 28,
                      height: 28,
                      colorFilter: ColorFilter.mode(AppColors.main600, BlendMode.srcIn),
                      key: const ValueKey('send'),
                    )
                  : ValueListenableBuilder<bool>( // 녹음 중일 때 빨간색 마이크 아이콘으로 변경
                      valueListenable: _isRecordingNotifier,
                      builder: (context, isRecording, child) {
                        return SvgPicture.asset(
                          'assets/icons/functions/voice.svg', // Assuming a keyboard_voice SVG exists
                          width: 28,
                          height: 28,
                          colorFilter: ColorFilter.mode(
                            isRecording ? AppColors.point900 : AppColors.grey600, // 녹음 중일 때 빨간색
                            BlendMode.srcIn,
                          ),
                          key: ValueKey(isRecording ? 'voice_recording' : 'voice'), // 키 변경
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
    final voiceAssistantService = ref.read(voiceAssistantServiceProvider); // VoiceAssistantService 인스턴스 가져오기

    if (voiceAssistantService.isListening) { // 녹음 중이면 중지
      await voiceAssistantService.stopListening();
      _isRecordingNotifier.value = false;
      final recognizedText = _currentTranscriptionNotifier.value.trim();
      _currentTranscriptionNotifier.value = ''; // 초기화

      if (recognizedText.isNotEmpty && recognizedText != '[interim]음성을 인식하는 중입니다...') { // 임시 메시지 제외
        _sendMessage(recognizedText); // 인식된 텍스트 전송
      } else {
        _showSnackBar('인식된 음성이 없습니다.', AppColors.grey600); // 인식된 텍스트 없을 때 스낵바
      }
    } else { // 녹음 중이 아니면 시작
      _isRecordingNotifier.value = true;
      _currentTranscriptionNotifier.value = ''; // 초기화
      _messageController.text = ''; // 입력 필드 초기화
      _hasTextNotifier.value = false; // 입력 필드 상태 초기화
      _textFieldFocusNode.unfocus(); // 키보드 숨기기

      // 음성 인식 초기화 시도
      try {
        await voiceAssistantService.initSpeech();
      } catch (e) {
        debugPrint('음성 인식 초기화 오류: $e');
      }

      voiceAssistantService.startConversation(_currentConversationId ?? ''); // 대화 시작/계속

      voiceAssistantService.startListening().listen((result) { // 음성 인식 스트림 구독
        if (result.startsWith('[interim]')) {
          _currentTranscriptionNotifier.value = result.substring(9); // 중간 결과 업데이트
        } else if (result.startsWith('[error]')) {
          _isRecordingNotifier.value = false;
          _currentTranscriptionNotifier.value = '';
          
          // 에러 메시지에 따라 다른 안내 표시
          String errorMessage = result.substring(7);
          if (errorMessage.contains('Whisper 서비스가 초기화되지 않았습니다')) {
            _showSnackBar('음성 인식을 기기 내장 기능으로 사용합니다.', AppColors.main600);
          } else if (errorMessage.contains('기기 내장 음성 인식으로 전환')) {
            _showSnackBar('기기 내장 음성 인식으로 전환되었습니다.', AppColors.main600);
          } else {
            _showSnackBar(errorMessage, AppColors.point900); // 기타 오류 스낵바
          }
        } else if (result == '[listening_stopped]') {
          _isRecordingNotifier.value = false;
          // 최종 결과는 이미 _currentTranscriptionNotifier에 반영되므로 여기서 추가 처리 불필요
        } else {
          _currentTranscriptionNotifier.value = result; // 최종 결과 업데이트
        }
        
        // 실시간으로 입력창에 인식된 텍스트 반영
        if (_currentTranscriptionNotifier.value.isNotEmpty && 
            !_currentTranscriptionNotifier.value.startsWith('[interim]') &&
            !_currentTranscriptionNotifier.value.startsWith('[error]')) {
          _messageController.text = _currentTranscriptionNotifier.value;
          _messageController.selection = TextSelection.fromPosition(TextPosition(offset: _messageController.text.length)); // 커서 맨 뒤로
        }
      }, onError: (e) {
        _isRecordingNotifier.value = false;
        _currentTranscriptionNotifier.value = '';
        _showSnackBar('음성 인식 중 오류가 발생했습니다: ${e.toString()}', AppColors.point900);
      });
    }
  }


  void _sendCurrentMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _sendMessage(message);
      _messageController.clear();
      _hasTextNotifier.value = false; // Manually update after clearing
    }
  }

  Future<void> _sendMessage(String message) async {
    if (_isLoading || _isTyping) return;

    setState(() {
      _isLoading = true;
    });

    final conversationService = ref.read(conversationServiceProvider);
    final aiService = ref.read(aiServiceProvider);

    try {
      if (_currentConversationId == null) {
        final newConversation = await conversationService.createConversation(
          title: message.length > 20 ? message.substring(0, 20) + '...' : message,
          agentId: 'default_agent',
        );
        _currentConversationId = newConversation.id;
      }

      await conversationService.addMessage(
        conversationId: _currentConversationId!,
        content: message,
        sender: MessageSender.user,
      );

      setState(() {
        _isTyping = true;
        _isLoading = false;
      });

      // Give some visual feedback before AI starts processing
      await Future.delayed(const Duration(milliseconds: 500));

      final aiResponse = await aiService.getResponse(
        conversationId: _currentConversationId!,
        userMessage: message,
      );

      await conversationService.addMessage(
        conversationId: _currentConversationId!,
        content: aiResponse.text,
        sender: MessageSender.agent,
        audioUrl: aiResponse.voiceFileUrl,
        audioDuration: aiResponse.voiceDuration?.toInt(),
        type: MessageType.audio, // Agent's message might be audio
      );

      _scrollToBottom();
    } on AppError catch (e) {
      print('AppError during message sending: ${e.message}');
      _showSnackBar('메시지 전송 중 오류가 발생했습니다: ${e.message}', AppColors.point900);
    } catch (e, stackTrace) {
      print('Unexpected error during message sending: $e');
      _showSnackBar('메시지 전송 중 알 수 없는 오류가 발생했습니다.', AppColors.point900);
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
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTextChanged() {
    _hasTextNotifier.value = _messageController.text.trim().isNotEmpty;
  }

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
          child: Center(
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
              Icon(Icons.error_outline, color: AppColors.grey400, size: 32),
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
    try {
      if (_currentConversationId == null) {
        _showSnackBar('대화를 시작한 후에 이미지를 보낼 수 있습니다.', AppColors.grey600);
        return;
      }

      final imageService = ref.read(imageServiceProvider);
      
      // 이미지 소스 선택 다이얼로그 표시
      ImageSource? source = await imageService.showImageSourceDialog(context);
      if (source == null) return; // 사용자가 취소함

      _isUploadingImageNotifier.value = true;

      // 이미지 선택 및 업로드
      String? imageUrl = await imageService.pickAndUploadImage(
        source: source,
        conversationId: _currentConversationId!,
        context: context,
      );

      if (imageUrl != null) {
        await _sendImageMessage(imageUrl);
        _showSnackBar('이미지가 전송되었습니다.', AppColors.main600);
      }
    } catch (e) {
      _showSnackBar('이미지 전송 중 오류가 발생했습니다: ${e.toString()}', AppColors.point900);
    } finally {
      _isUploadingImageNotifier.value = false;
    }
  }

  // 이미지 메시지 전송
  Future<void> _sendImageMessage(String imageUrl) async {
    if (_isLoading || _isTyping) return;

    setState(() {
      _isLoading = true;
    });

    final conversationService = ref.read(conversationServiceProvider);

    try {
      if (_currentConversationId == null) {
        final newConversation = await conversationService.createConversation(
          title: '이미지 대화',
          agentId: 'default_agent',
        );
        _currentConversationId = newConversation.id;
      }

      // 이미지 메시지 추가
      await conversationService.addMessage(
        conversationId: _currentConversationId!,
        content: '이미지를 보냈습니다.',
        sender: MessageSender.user,
        type: MessageType.image,
        attachments: [
          MessageAttachment(
            url: imageUrl,
            type: 'image',
            fileName: 'image.jpg',
          ),
        ],
      );

      _scrollToBottom();
    } on AppError catch (e) {
      print('AppError during image message sending: ${e.message}');
      _showSnackBar('이미지 전송 중 오류가 발생했습니다: ${e.message}', AppColors.point900);
    } catch (e, stackTrace) {
      print('Unexpected error during image message sending: $e');
      _showSnackBar('이미지 전송 중 알 수 없는 오류가 발생했습니다.', AppColors.point900);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}