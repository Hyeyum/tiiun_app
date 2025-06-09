import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiiun/services/conversation_service.dart';
import 'package:tiiun/models/conversation_model.dart';
import 'package:tiiun/models/message_model.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:tiiun/services/ai_service.dart';
import 'package:tiiun/utils/error_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'dart:async';

// Import the new Modal AnalysisScreen
import 'package:tiiun/pages/home_chatting/analysis_page.dart';
import 'package:tiiun/services/voice_assistant_service.dart';
import 'package:tiiun/services/speech_to_text_service.dart';
import 'package:tiiun/services/voice_service.dart';
import 'package:tiiun/services/image_service.dart';
import 'package:tiiun/services/gpt4o_audio_service.dart';
import 'package:record/record.dart' as record_pkg;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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

class _ChatScreenState extends ConsumerState<ChatScreen> with WidgetsBindingObserver {
  // ✅ 컨트롤러들 - 메모리 누수 방지를 위한 명시적 관리
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocusNode = FocusNode();

  // ✅ ValueNotifier들 - dispose 보장
  final ValueNotifier<bool> _hasTextNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isRecordingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _currentTranscriptionNotifier = ValueNotifier<String>('');
  final ValueNotifier<bool> _isUploadingImageNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isProcessingAudioNotifier = ValueNotifier<bool>(false);

  // ✅ 녹음 관련 변수들
  final record_pkg.AudioRecorder _audioRecorder = record_pkg.AudioRecorder();
  final Uuid _uuid = const Uuid();
  String? _currentRecordingPath;

  // ✅ 스트림 구독 관리 - 메모리 누수 방지
  StreamSubscription<List<Message>>? _messagesSubscription;
  StreamSubscription<bool>? _voicePlaybackSubscription;
  StreamSubscription<SpeechRecognitionState>? _speechSubscription;
  Timer? _autoScrollTimer;

  // 상태 변수들
  String? _currentConversationId;
  bool _isLoading = false;
  bool _isTyping = false;
  bool _isDisposed = false; // dispose 상태 추적

  // ✅ 성능 최적화: 메시지 페이지네이션
  static const int _messagesPerPage = 50;
  bool _hasMoreMessages = true;
  bool _isLoadingMoreMessages = false;

  @override
  void initState() {
    super.initState();

    // ✅ 앱 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);

    _currentConversationId = widget.conversationId;

    // 텍스트 컨트롤러 리스너 등록
    _messageController.addListener(_onTextChanged);

    // 스크롤 컨트롤러 리스너 등록
    _scrollController.addListener(_onScrollChanged);

    // 음성 서비스 초기화
    _initializeVoiceServices();

    // 초기 메시지 처리
    if (widget.initialMessage != null && widget.conversationId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          _sendMessage(widget.initialMessage!);
        }
      });
    }

    // ✅ 메시지 스트림 구독 (메모리 관리 포함)
    _subscribeToMessages();
  }

  /// ✅ 음성 서비스 초기화
  Future<void> _initializeVoiceServices() async {
    try {
      // Speech-to-Text 서비스 초기화
      final speechService = SpeechToTextService();
      await speechService.initialize();

      // Voice Assistant 서비스 초기화
      final voiceAssistant = ref.read(voiceAssistantServiceProvider);
      await voiceAssistant.initSpeech();

      debugPrint('🎤 음성 서비스 초기화 완료');
    } catch (e) {
      debugPrint('❌ 음성 서비스 초기화 실패: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      // ✅ 앱이 백그라운드로 갈 때 리소스 정리
        _pauseActiveOperations();
        break;
      case AppLifecycleState.resumed:
      // ✅ 앱이 포그라운드로 돌아올 때 리소스 복구
        _resumeActiveOperations();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    // ✅ 앱 생명주기 관찰자 해제
    WidgetsBinding.instance.removeObserver(this);

    // ✅ 모든 활성 작업 중단
    _pauseActiveOperations();

    // ✅ 컨트롤러들 dispose
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();

    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();

    _textFieldFocusNode.dispose();

    // ✅ ValueNotifier들 dispose
    _hasTextNotifier.dispose();
    _isRecordingNotifier.dispose();
    _currentTranscriptionNotifier.dispose();
    _isUploadingImageNotifier.dispose();
    _isProcessingAudioNotifier.dispose();

    // ✅ 스트림 구독 해제
    _messagesSubscription?.cancel();
    _voicePlaybackSubscription?.cancel();
    _speechSubscription?.cancel();

    // ✅ 타이머 정리
    _autoScrollTimer?.cancel();

    // ✅ 녹음기 dispose
    _audioRecorder.dispose();

    // ✅ 임시 파일 정리
    _cleanupTempFiles();

    super.dispose();
  }

  /// ✅ 메시지 스트림 구독 관리
  void _subscribeToMessages() {
    if (_currentConversationId == null || _isDisposed) return;

    _messagesSubscription?.cancel(); // 기존 구독 해제

    final conversationService = ref.read(conversationServiceProvider);
    _messagesSubscription = conversationService
        .getConversationMessages(_currentConversationId!, limit: _messagesPerPage)
        .listen(
          (messages) {
        if (!_isDisposed && mounted) {
          // 메시지 업데이트 처리
          setState(() {
            _hasMoreMessages = messages.length >= _messagesPerPage;
          });
        }
      },
      onError: (error) {
        if (!_isDisposed && mounted) {
          debugPrint('메시지 스트림 오류: $error');
          _showSnackBar('메시지를 불러오는 중 오류가 발생했습니다.', AppColors.point900);
        }
      },
    );
  }

  /// ✅ 백그라운드 시 활성 작업 일시정지
  void _pauseActiveOperations() {

    // dispose 체크 추가
    if (_isDisposed) return;

    // 녹음 중단
    if (_isRecordingNotifier.value) {
      _stopRecordingAndProcess().catchError((e) {
        debugPrint('녹음 중단 오류: $e');
      });
    }

    // 음성 재생 중단 (dispose된 경우 안전하게 처리)
    try {
      if (mounted) {
        final voiceService = ref.read(voiceServiceProvider);
        voiceService.stopSpeaking();
      }
    } catch (e) {
      debugPrint('음성 서비스 중단 오류: $e');
    }

    // 타이머 일시정지
    _autoScrollTimer?.cancel();
  }

  /// ✅ 포그라운드 복귀 시 리소스 복구
  void _resumeActiveOperations() {
    if (_isDisposed) return;

    // 필요한 경우 스트림 재구독
    if (_messagesSubscription == null || _messagesSubscription!.isPaused) {
      _subscribeToMessages();
    }
  }

  /// ✅ 스크롤 변화 감지 (페이지네이션 트리거)
  void _onScrollChanged() {
    if (_isDisposed || !_scrollController.hasClients) return;

    // 스크롤이 맨 위에 도달했을 때 추가 메시지 로드
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreMessages();
    }
  }

  /// ✅ 추가 메시지 로드 (페이지네이션)
  Future<void> _loadMoreMessages() async {
    if (_isLoadingMoreMessages || !_hasMoreMessages || _currentConversationId == null) {
      return;
    }

    setState(() {
      _isLoadingMoreMessages = true;
    });

    try {
      // 추가 메시지 로드 로직 구현
      await Future.delayed(const Duration(milliseconds: 500)); // 시뮬레이션

      setState(() {
        _isLoadingMoreMessages = false;
      });
    } catch (e) {
      debugPrint('추가 메시지 로드 오류: $e');
      if (mounted) {
        setState(() {
          _isLoadingMoreMessages = false;
        });
      }
    }
  }

  /// ✅ 임시 파일 정리
  Future<void> _cleanupTempFiles() async {
    if (_currentRecordingPath != null) {
      try {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('임시 파일 정리 실패: $e');
      }
      _currentRecordingPath = null;
    }
  }

  /// 🎤 ===== 음성 기능 구현 =====

  /// ✅ 음성 입력 토글 (완전 구현)
  Future<void> _toggleVoiceInput() async {
    if (_isDisposed) return;

    try {
      if (_isRecordingNotifier.value) {
        // 녹음 중지 및 처리
        await _stopRecordingAndProcess();
      } else {
        // 새로운 녹음 시작
        await _startVoiceRecording();
      }
    } catch (e) {
      debugPrint('음성 입력 토글 오류: $e');
      _showSnackBar('음성 입력 중 오류가 발생했습니다: ${e.toString()}', AppColors.point900);

      // 오류 시 상태 초기화
      if (!_isDisposed) {
        _isRecordingNotifier.value = false;
        _isProcessingAudioNotifier.value = false;
        _currentTranscriptionNotifier.value = '';
      }
    }
  }

  /// ✅ 음성 녹음 시작
  Future<void> _startVoiceRecording() async {
    if (_isDisposed) return;

    try {
      _isProcessingAudioNotifier.value = true;
      _currentTranscriptionNotifier.value = '음성 인식 준비 중...';

      // Speech-to-Text 서비스 사용
      final speechService = SpeechToTextService();

      // 음성 인식 상태 스트림 구독
      _speechSubscription?.cancel();
      _speechSubscription = speechService.stateStream.listen(
            (state) => _handleSpeechRecognitionState(state),
        onError: (error) {
          debugPrint('음성 인식 스트림 오류: $error');
          _showSnackBar('음성 인식 중 오류가 발생했습니다.', AppColors.point900);
          _resetVoiceState();
        },
      );

      // 음성 인식 시작
      final success = await speechService.startListening();

      if (success) {
        _isRecordingNotifier.value = true;
        _currentTranscriptionNotifier.value = '듣고 있습니다... 말씀해 주세요';
        _showSnackBar('음성 인식이 시작되었습니다. 말씀해 주세요.', AppColors.main600);
      } else {
        throw Exception('음성 인식을 시작할 수 없습니다.');
      }
    } catch (e) {
      debugPrint('음성 녹음 시작 오류: $e');
      _showSnackBar('음성 인식을 시작할 수 없습니다: ${e.toString()}', AppColors.point900);
      _resetVoiceState();
    }
  }

  /// ✅ 음성 인식 상태 처리
  void _handleSpeechRecognitionState(SpeechRecognitionState state) {
    if (_isDisposed) return;

    switch (state.status) {
      case SpeechStatus.listening:
        _currentTranscriptionNotifier.value = state.isInterim
            ? '인식 중: ${state.text}'
            : '듣고 있습니다...';
        break;

      case SpeechStatus.result:
        _currentTranscriptionNotifier.value = '인식 완료: ${state.text}';
        if (state.text.isNotEmpty) {
          // 인식된 텍스트를 메시지로 전송
          _sendRecognizedText(state.text);
        }
        _resetVoiceState();
        break;

      case SpeechStatus.error:
        _currentTranscriptionNotifier.value = '오류: ${state.error ?? "알 수 없는 오류"}';
        _showSnackBar('음성 인식 오류: ${state.error}', AppColors.point900);
        _resetVoiceState();
        break;

      case SpeechStatus.notListening:
        if (_isRecordingNotifier.value) {
          _currentTranscriptionNotifier.value = '음성 인식이 중지되었습니다.';
          _resetVoiceState();
        }
        break;
    }
  }

  /// ✅ 녹음 중지 및 처리
  Future<void> _stopRecordingAndProcess() async {
    if (_isDisposed) return;

    try {
      _currentTranscriptionNotifier.value = '음성 처리 중...';

      // Speech-to-Text 서비스 중지
      final speechService = SpeechToTextService();
      final recognizedText = await speechService.stopListening();

      _speechSubscription?.cancel();

      if (recognizedText.isNotEmpty) {
        _currentTranscriptionNotifier.value = '인식 완료: $recognizedText';
        await _sendRecognizedText(recognizedText);
      } else {
        _currentTranscriptionNotifier.value = '음성이 인식되지 않았습니다.';
        _showSnackBar('음성이 인식되지 않았습니다. 다시 시도해 주세요.', AppColors.grey600);
      }
    } catch (e) {
      debugPrint('녹음 처리 오류: $e');
      _showSnackBar('음성 처리 중 오류가 발생했습니다.', AppColors.point900);
    } finally {
      _resetVoiceState();
    }
  }

  /// ✅ 인식된 텍스트 전송
  Future<void> _sendRecognizedText(String text) async {
    if (_isDisposed || text.trim().isEmpty) return;

    try {
      // 텍스트 필드에 입력
      _messageController.text = text.trim();
      _hasTextNotifier.value = true;

      // 잠시 대기 후 자동 전송 (사용자가 수정할 시간 제공)
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!_isDisposed && _messageController.text.trim() == text.trim()) {
        // 사용자가 수정하지 않았다면 자동 전송
        _sendCurrentMessage();
        _showSnackBar('음성 메시지가 전송되었습니다.', AppColors.main600);
      }
    } catch (e) {
      debugPrint('인식된 텍스트 처리 오류: $e');
    }
  }

  /// ✅ 음성 상태 초기화
  void _resetVoiceState() {
    if (_isDisposed) return;

    _isRecordingNotifier.value = false;
    _isProcessingAudioNotifier.value = false;

    // 잠시 후 transcription 메시지 클리어
    Timer(const Duration(seconds: 3), () {
      if (!_isDisposed) {
        _currentTranscriptionNotifier.value = '';
      }
    });
  }

  /// 🎵 ===== 음성 어시스턴트 기능 =====

  /// ✅ 고급 음성 어시스턴트 모드
  Future<void> _startVoiceAssistantMode() async {
    if (_isDisposed) return;

    try {
      final voiceAssistant = ref.read(voiceAssistantServiceProvider);

      if (_currentConversationId != null) {
        await voiceAssistant.startConversation(_currentConversationId!);
      }

      _isProcessingAudioNotifier.value = true;
      _showSnackBar('🤖 음성 어시스턴트 모드 시작', AppColors.main600);

      // 음성 어시스턴트 리스닝 시작
      final transcriptionStream = voiceAssistant.startListening();

      transcriptionStream.listen(
            (result) => _handleVoiceAssistantResult(result),
        onError: (error) {
          debugPrint('음성 어시스턴트 오류: $error');
          _showSnackBar('음성 어시스턴트 오류가 발생했습니다.', AppColors.point900);
          _isProcessingAudioNotifier.value = false;
        },
      );
    } catch (e) {
      debugPrint('음성 어시스턴트 시작 오류: $e');
      _showSnackBar('음성 어시스턴트를 시작할 수 없습니다.', AppColors.point900);
      _isProcessingAudioNotifier.value = false;
    }
  }

  /// ✅ 음성 어시스턴트 결과 처리
  void _handleVoiceAssistantResult(String result) {
    if (_isDisposed) return;

    if (result.startsWith('[error]')) {
      final error = result.substring(7);
      _showSnackBar('오류: $error', AppColors.point900);
      _isProcessingAudioNotifier.value = false;
    } else if (result.startsWith('[interim]')) {
      final text = result.substring(9);
      _currentTranscriptionNotifier.value = '인식 중: $text';
    } else if (result == '[listening_stopped]') {
      _isProcessingAudioNotifier.value = false;
      _currentTranscriptionNotifier.value = '';
    } else if (result.isNotEmpty) {
      // 최종 인식 결과 처리
      _processVoiceAssistantInput(result);
    }
  }

  /// ✅ 음성 어시스턴트 입력 처리
  Future<void> _processVoiceAssistantInput(String text) async {
    if (_isDisposed) return;

    try {
      final voiceAssistant = ref.read(voiceAssistantServiceProvider);

      // AI 응답 생성 및 음성 재생
      final responseStream = voiceAssistant.processVoiceInput(text, 'alloy');

      responseStream.listen(
            (response) => _handleVoiceAssistantResponse(response),
        onError: (error) {
          debugPrint('음성 어시스턴트 응답 오류: $error');
          _showSnackBar('응답 생성 중 오류가 발생했습니다.', AppColors.point900);
          _isProcessingAudioNotifier.value = false;
        },
      );
    } catch (e) {
      debugPrint('음성 어시스턴트 입력 처리 오류: $e');
      _isProcessingAudioNotifier.value = false;
    }
  }

  /// ✅ 음성 어시스턴트 응답 처리
  void _handleVoiceAssistantResponse(Map<String, dynamic> response) {
    if (_isDisposed) return;

    final status = response['status'];

    switch (status) {
      case 'processing':
        _currentTranscriptionNotifier.value = response['message'] ?? '응답 생성 중...';
        break;

      case 'completed':
        final responseData = response['response'];
        final text = responseData['text'];
        final audioPath = responseData['audioPath'];

        // 텍스트 메시지 전송
        if (text != null && text.isNotEmpty) {
          _sendMessage(text);
        }

        // 음성 재생
        if (audioPath != null && audioPath.isNotEmpty) {
          _playVoiceResponse(audioPath);
        }

        _isProcessingAudioNotifier.value = false;
        _currentTranscriptionNotifier.value = '';
        break;

      case 'error':
        final errorMessage = response['message'] ?? '알 수 없는 오류';
        _showSnackBar('오류: $errorMessage', AppColors.point900);
        _isProcessingAudioNotifier.value = false;
        _currentTranscriptionNotifier.value = '';
        break;
    }
  }

  /// ✅ 음성 응답 재생
  Future<void> _playVoiceResponse(String audioPath) async {
    try {
      final voiceService = ref.read(voiceServiceProvider);
      await voiceService.playAudio(audioPath, isLocalFile: true);
    } catch (e) {
      debugPrint('음성 응답 재생 오류: $e');
    }
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
          // 메인 콘텐츠
          GestureDetector(
            onTap: _focusTextField,
            child: Column(
              children: [
                Expanded(
                  child: _currentConversationId != null
                      ? _buildOptimizedMessageList()
                      : _buildEmptyState(),
                ),
                if (_isTyping) _buildTypingIndicator(),

                // ✅ 음성 인식 상태 표시
                ValueListenableBuilder<String>(
                  valueListenable: _currentTranscriptionNotifier,
                  builder: (context, transcription, child) {
                    if (transcription.isEmpty) return const SizedBox.shrink();
                    return _buildTranscriptionIndicator(transcription);
                  },
                ),

                // 오디오 처리 인디케이터
                ValueListenableBuilder<bool>(
                  valueListenable: _isProcessingAudioNotifier,
                  builder: (context, isProcessing, child) {
                    if (!isProcessing) return const SizedBox.shrink();
                    return _buildAudioProcessingIndicator();
                  },
                ),

                // ✅ 추가 메시지 로딩 인디케이터
                if (_isLoadingMoreMessages)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: const CircularProgressIndicator(),
                  ),
              ],
            ),
          ),

          // 하단 고정 블러 입력창
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

  /// ✅ 음성 인식 상태 표시 위젯
  Widget _buildTranscriptionIndicator(String transcription) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.main500,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.zero,
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(color: AppColors.main200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mic,
                color: AppColors.main700,
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  transcription,
                  style: AppTypography.b4.withColor(AppColors.main700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ 최적화된 메시지 리스트
  Widget _buildOptimizedMessageList() {
    if (_currentConversationId == null || _currentConversationId!.isEmpty) {
      debugPrint('Invalid conversation ID: $_currentConversationId');
      return _buildEmptyState();
    }

    final conversationService = ref.watch(conversationServiceProvider);
    return StreamBuilder<List<Message>>(
      stream: conversationService.getConversationMessages(_currentConversationId!, limit: _messagesPerPage),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('Error loading messages: ${snapshot.error}');
          final error = ErrorHandler.handleException(snapshot.error!);
          return _buildErrorState(error.message);
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        // ✅ ListView.builder 최적화 설정
        return ListView.builder(
          controller: _scrollController,
          reverse: true, // 최신 메시지가 아래
          cacheExtent: 1000, // 캐시 확장으로 스크롤 성능 향상
          physics: const BouncingScrollPhysics(), // 부드러운 스크롤
          padding: const EdgeInsets.fromLTRB(12, 82, 12, 82),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isLastAiMessage = index == 0 && !message.isUser;

            // ✅ 메시지 빌더 최적화
            return _buildOptimizedMessageBubble(message, isLastAiMessage);
          },
        );
      },
    );
  }

  /// ✅ 최적화된 메시지 버블 (메모리 효율적)
  Widget _buildOptimizedMessageBubble(Message message, [bool isLastAiMessage = false]) {
    final isUser = message.isUser;

    return Column(
      key: ValueKey(message.id), // ✅ 키 추가로 위젯 재사용 최적화
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // AI의 마지막 메시지일 때만 아이콘 표시
        if (isLastAiMessage)
          Container(
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
                // 이미지 메시지 처리 (지연 로딩)
                if (message.type == MessageType.image && message.attachments.isNotEmpty)
                  _buildOptimizedImageMessage(message.attachments.first.url),

                // 텍스트 메시지 처리
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

                // 오디오 플레이어 (최적화됨)
                if (message.audioUrl != null && message.audioUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildOptimizedAudioPlayer(message.audioUrl!),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ✅ 최적화된 이미지 메시지 (메모리 효율적)
  Widget _buildOptimizedImageMessage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        memCacheWidth: 800, // ✅ 메모리 캐시 크기 제한
        memCacheHeight: 600, // ✅ 메모리 캐시 크기 제한
        maxWidthDiskCache: 1200, // ✅ 디스크 캐시 크기 제한
        maxHeightDiskCache: 900, // ✅ 디스크 캐시 크기 제한
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

  /// ✅ 최적화된 오디오 플레이어
  Widget _buildOptimizedAudioPlayer(String audioUrl) {
    final voiceService = ref.read(voiceServiceProvider);

    return StreamBuilder<bool>(
      stream: Stream.periodic(
        const Duration(milliseconds: 200), // ✅ 폴링 주기 최적화 (100ms → 200ms)
            (_) => voiceService.isPlaying && voiceService.currentPlayingUrl == audioUrl,
      ),
      builder: (context, snapshot) {
        final isPlayingThisAudio = snapshot.data ?? false;

        return GestureDetector(
          onTap: () async {
            try {
              if (isPlayingThisAudio) {
                await voiceService.stopSpeaking();
              } else {
                await voiceService.playAudio(audioUrl, isLocalFile: audioUrl.startsWith('/data'));
              }
            } catch (e) {
              debugPrint('오디오 재생 오류: $e');
              _showSnackBar('오디오를 재생할 수 없습니다.', AppColors.point900);
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

  // 나머지 메서드들 (기존과 동일)
  Widget _buildAudioProcessingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.main100,
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
                '🧠 스마트 음성 분석 중',
                style: AppTypography.b3.withColor(AppColors.main700),
              ),
              const SizedBox(width: 8),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.main700),
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/functions/icon_info.svg',
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
            errorMessage,
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
                  // setState(() {}); // 스트림 재시도
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
            onLongPress: hasText ? null : _startVoiceAssistantMode, // 🤖 롱프레스로 음성 어시스턴트 모드
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
                  return Container(
                    decoration: isRecording ? BoxDecoration(
                      color: AppColors.main100,
                      shape: BoxShape.circle,
                    ) : null,
                    padding: isRecording ? const EdgeInsets.all(4) : null,
                    child: SvgPicture.asset(
                      'assets/icons/functions/voice.svg',
                      width: 28,
                      height: 28,
                      // colorFilter: ColorFilter.mode(
                      //   isRecording ? AppColors.point700 : AppColors.grey600,
                      //   BlendMode.srcIn,
                      // ),
                      key: ValueKey(isRecording ? 'voice_recording' : 'voice'),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _sendCurrentMessage() {
    if (_isDisposed) return;

    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      final currentScrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;

      _sendMessage(message);
      _messageController.clear();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(currentScrollOffset);
      }
    }
  }

  Future<void> _sendMessage(String message) async {
    if (_isLoading || _isTyping || _isDisposed) return;

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
        _subscribeToMessages(); // 새 대화에 대한 스트림 구독
      }

      await conversationService.addMessage(
        conversationId: _currentConversationId!,
        content: message,
        sender: MessageSender.user,
      );

      if (!_isDisposed) {
        setState(() {
          _isTyping = true;
          _isLoading = false;
        });

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
          type: MessageType.audio,
        );

        _scrollToBottom();
      }
    } on AppError catch (e) {
      debugPrint('AppError during message sending: ${e.message}');
      _showSnackBar('메시지 전송 중 오류가 발생했습니다: ${e.message}', AppColors.point900);
    } catch (e, stackTrace) {
      debugPrint('Unexpected error during message sending: $e');
      _showSnackBar('메시지 전송 중 알 수 없는 오류가 발생했습니다.', AppColors.point900);
    } finally {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
          _isTyping = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_isDisposed) return;

    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients && mounted && !_isDisposed) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTextChanged() {
    if (_isDisposed) return;

    final hasText = _messageController.text.trim().isNotEmpty;
    _hasTextNotifier.value = hasText;
  }

  void _focusTextField() {
    if (_isDisposed) return;

    FocusScope.of(context).requestFocus(_textFieldFocusNode);
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted || _isDisposed) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _handleCameraButton() async {
    if (_isDisposed) return;

    try {
      if (_currentConversationId == null) {
        _showSnackBar('대화를 시작한 후에 이미지를 보낼 수 있습니다.', AppColors.grey600);
        return;
      }

      final imageService = ref.read(imageServiceProvider);

      ImageSource? source = await imageService.showImageSourceDialog(context);
      if (source == null) return;

      _isUploadingImageNotifier.value = true;

      String? imageUrl = await imageService.pickAndUploadImage(
        source: source,
        conversationId: _currentConversationId!,
        context: context,
      );

      if (imageUrl != null && !_isDisposed) {
        await _sendImageMessage(imageUrl);
        _showSnackBar('이미지가 전송되었습니다.', AppColors.main600);
      }
    } catch (e) {
      _showSnackBar('이미지 전송 중 오류가 발생했습니다: ${e.toString()}', AppColors.point900);
    } finally {
      if (!_isDisposed) {
        _isUploadingImageNotifier.value = false;
      }
    }
  }

  Future<void> _sendImageMessage(String imageUrl) async {
    if (_isLoading || _isTyping || _isDisposed) return;

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
        _subscribeToMessages();
      }

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
    } catch (e) {
      debugPrint('Unexpected error during image message sending: $e');
      _showSnackBar('이미지 전송 중 알 수 없는 오류가 발생했습니다.', AppColors.point900);
    } finally {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAnalysisModal() {
    if (_isDisposed) return;

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