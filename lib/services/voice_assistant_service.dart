// lib/services/voice_assistant_service.dart (renamed from voice_assisant_service.dart)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart' as flutter_tts; // Assign a prefix to flutter_tts to avoid conflict
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

import 'langchain_service.dart';
import 'conversation_memory_service.dart';
import 'voice_service.dart'; // Primary voice operations (STT/TTS)
import 'whisper_service.dart'; // No longer directly used here, VoiceService handles it
import 'openai_tts_service.dart'; // No longer directly used here, VoiceService handles it
import '../utils/simple_speech_recognizer.dart'; // Used by VoiceService for on-device STT
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiiun/services/remote_config_service.dart';
import 'package:tiiun/utils/error_handler.dart'; // The intended ErrorHandler class
import 'package:tiiun/utils/logger.dart'; // Import AppLogger
import 'package:tiiun/services/voice_assistant_service.dart'; // Import SpeechRecognitionMode

// 음성 인식 모드 열거형
enum SpeechRecognitionMode {
  whisper,   // OpenAI Whisper API 사용 (handled by VoiceService)
  native,    // 기기 내장 음성 인식 사용 (handled by VoiceService)
}

// 음성 비서 서비스 Provider
final voiceAssistantServiceProvider = Provider<VoiceAssistantService>((ref) {
  try {
    final langchainService = ref.watch(langchainServiceProvider);
    final conversationMemoryService = ref.watch(conversationMemoryServiceProvider);
    final voiceService = ref.watch(voiceServiceProvider);
    // API key is now passed to VoiceService and LangchainService directly from their providers,
    // so VoiceAssistantService doesn't need to know the raw key.
    return VoiceAssistantService(langchainService, conversationMemoryService, voiceService);
  } catch (e, stackTrace) {
    AppLogger.error('VoiceAssistantService: Failed to initialize.', e, stackTrace);
    // Return a dummy/empty service for robustness in case of initialization failure
    return VoiceAssistantService.empty();
  }
});

class VoiceAssistantService {
  // Empty service for robustness
  factory VoiceAssistantService.empty() {
    return VoiceAssistantService._empty();
  }

  VoiceAssistantService._empty()
      : _langchainService = null,
        _memoryService = null,
        _voiceService = null,
        _whisperService = null, // Ensure these are null in empty constructor
        _openAiTtsService = null;


  // General constructor
  VoiceAssistantService(
      this._langchainService,
      this._memoryService,
      this._voiceService,
      ) : _whisperService = _voiceService?.whisperService, // Get reference from VoiceService
        _openAiTtsService = _voiceService?.openAiTtsService { // Get reference from VoiceService
    _loadSettings(); // Load settings, including recognition mode
    // LLM ConversationChain is now managed by LangchainService
  }

  final LangchainService? _langchainService;
  final ConversationMemoryService? _memoryService;
  final VoiceService? _voiceService;
  // Direct access to sub-services via VoiceService
  final WhisperService? _whisperService;
  final OpenAiTtsService? _openAiTtsService;


  bool _isListening = false;
  bool _isProcessing = false;

  SpeechRecognitionMode _recognitionMode = SpeechRecognitionMode.whisper; // Default to Whisper

  // LLM Chain (now handled by LangchainService, this can be removed from here)
  // ConversationChain? _conversationChain;
  final Uuid _uuid = const Uuid();

  // State
  String _currentConversationId = '';
  StreamController<String>? _transcriptionStreamController;
  StreamController<Map<String, dynamic>>? _responseStreamController;
  StreamSubscription? _recognizerSubscription;
  StreamSubscription? _whisperStreamSubscription;

  // Connectivity (already handled by VoiceService or ConnectivityService)
  final Connectivity _connectivity = Connectivity();

  // Settings Load
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final useWhisper = prefs.getBool('use_whisper_api') ?? true;
      _recognitionMode = useWhisper
          ? SpeechRecognitionMode.whisper
          : SpeechRecognitionMode.native;
      AppLogger.info('VoiceAssistantService: Loaded recognition mode: $_recognitionMode (useWhisper: $useWhisper)');
    } catch (e, stackTrace) {
      AppLogger.error('VoiceAssistantService: Failed to load settings.', e, stackTrace);
    }
  }

  // Settings Save
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        'use_whisper_api',
        _recognitionMode == SpeechRecognitionMode.whisper,
      );
      AppLogger.info('VoiceAssistantService: Saved recognition mode: $_recognitionMode');
    } catch (e, stackTrace) {
      AppLogger.error('VoiceAssistantService: Failed to save settings.', e, stackTrace);
    }
  }

  // Initialize on-device speech (can be handled by VoiceService internally)
  Future<void> initSpeech() async {
    // VoiceService should handle its own initialization now
    // This method can call VoiceService.initializeSTT() if needed
    AppLogger.info('VoiceAssistantService: Initializing speech components via VoiceService.');
    try {
      await _voiceService?.initializeSTT();
      // Use flutter_tts.FlutterTts with the prefix
      await (flutter_tts.FlutterTts()).setLanguage('ko-KR');
      await (flutter_tts.FlutterTts()).setSpeechRate(0.5);
      await (flutter_tts.FlutterTts()).setVolume(1.0);
      await (flutter_tts.FlutterTts()).setPitch(1.0);
    } catch (e, stackTrace) {
      AppLogger.error('VoiceAssistantService: Error initializing STT via VoiceService.', e, stackTrace);
    }
  }

  // Set speech recognition mode
  Future<void> setRecognitionMode(SpeechRecognitionMode mode) async {
    _recognitionMode = mode;
    await _saveSettings();
    AppLogger.debug('VoiceAssistantService: Recognition mode set to: $mode');
  }

  // Convenience method for setting Whisper usage
  void setUseWhisper(bool useWhisper) {
    setRecognitionMode(useWhisper ? SpeechRecognitionMode.whisper : SpeechRecognitionMode.native);
  }

  // Check internet connection (delegated to VoiceService or ConnectivityService)
  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  // Start Voice Recognition
  Stream<String> startListening() {
    _transcriptionStreamController = StreamController<String>.broadcast(); // Changed to broadcast

    if (_isListening) {
      _transcriptionStreamController?.add('[error]이미 음성 인식 중입니다');
      return _transcriptionStreamController!.stream;
    }

    if (_isProcessing) {
      _transcriptionStreamController?.add('[error]현재 응답을 처리 중입니다');
      return _transcriptionStreamController!.stream;
    }

    _isListening = true;
    AppLogger.debug('VoiceAssistantService: Starting listening in mode: $_recognitionMode');

    try {
      if (_recognitionMode == SpeechRecognitionMode.whisper) {
        _startWhisperRecognition();
      } else {
        _startNativeSpeechRecognition();
      }

      return _transcriptionStreamController!.stream;
    } catch (e, stackTrace) {
      _isListening = false;
      AppLogger.error('VoiceAssistantService: Error starting listening.', e, stackTrace);
      _transcriptionStreamController?.add('[error]음성 인식 시작 실패: ${e.toString()}');
      return _transcriptionStreamController!.stream;
    }
  }

  // Start Whisper Recognition
  Future<void> _startWhisperRecognition() async {
    if (_whisperService == null) {
      _transcriptionStreamController?.add('[error]Whisper 서비스가 초기화되지 않았습니다');
      _isListening = false;
      return;
    }

    if (!await _checkInternetConnection()) {
      _transcriptionStreamController?.add('[error]인터넷 연결이 필요합니다. 기기 내장 음성 인식으로 전환합니다.');
      _isListening = false;
      _recognitionMode = SpeechRecognitionMode.native; // Fallback
      _startNativeSpeechRecognition();
      return;
    }

    AppLogger.debug("VoiceAssistantService: Starting Whisper speech recognition.");

    try {
      final whisperStream = _whisperService!.streamRecordAndTranscribe(
        recordingDuration: 10,
        language: 'ko',
      );

      _whisperStreamSubscription = whisperStream.listen(
            (result) {
          if (result.startsWith('[error]')) {
            AppLogger.error("VoiceAssistantService: Whisper recognition error: ${result.substring(7)}");
            _transcriptionStreamController?.add(result);
            if (result.contains('인터넷 연결') || result.contains('API 오류') || result.contains('OpenAI API 키')) {
              _recognitionMode = SpeechRecognitionMode.native; // Dynamic fallback
            }
          } else if (result.startsWith('[listening_stopped]')) {
            if (_isListening) {
              _isListening = false;
              _transcriptionStreamController?.add('[listening_stopped]');
            }
          } else if (result.startsWith('[interim]')) {
            _transcriptionStreamController?.add(result);
          } else {
            _transcriptionStreamController?.add(result);
            _isListening = false;
            _transcriptionStreamController?.add('[listening_stopped]');
          }
        },
        onError: (error, stackTrace) {
          AppLogger.error("VoiceAssistantService: Whisper stream error: $error", error, stackTrace);
          _transcriptionStreamController?.add('[error]음성 인식 중 오류가 발생했습니다');
          _isListening = false;
          _transcriptionStreamController?.add('[listening_stopped]');
        },
        onDone: () {
          if (_isListening) {
            _isListening = false;
            _transcriptionStreamController?.add('[listening_stopped]');
          }
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error("VoiceAssistantService: Error starting Whisper recognition: $e", e, stackTrace);
      _transcriptionStreamController?.add('[error]음성 인식 시작 실패: ${e.toString()}');
      _isListening = false;
    }
  }

  // Start Native Speech Recognition
  void _startNativeSpeechRecognition() {
    AppLogger.debug("VoiceAssistantService: Starting native speech recognition.");
    try {
      _voiceService?.startOnDeviceListening(); // VoiceService wraps SimpleSpeechRecognizer

      _recognizerSubscription = _voiceService?.onDeviceTranscriptionStream.listen(
            (result) {
          if (result.startsWith('[error]')) {
            AppLogger.error("VoiceAssistantService: Native recognition error: ${result.substring(7)}");
            _transcriptionStreamController?.add(result);
          } else if (result.startsWith('[listening_stopped]')) {
            if (_isListening) {
              _isListening = false;
              _transcriptionStreamController?.add('[listening_stopped]');
            }
          } else if (result.startsWith('[interim]')) {
            _transcriptionStreamController?.add(result);
          } else {
            _transcriptionStreamController?.add(result);
            _isListening = false;
            _transcriptionStreamController?.add('[listening_stopped]');
          }
        },
        onError: (error, stackTrace) {
          AppLogger.error("VoiceAssistantService: Native stream error: $error", error, stackTrace);
          _transcriptionStreamController?.add('[error]음성 인식 중 오류가 발생했습니다');
          _isListening = false;
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error("VoiceAssistantService: Error starting native speech recognition: $e", e, stackTrace);
      _transcriptionStreamController?.add('[error]음성 인식 시작 실패: ${e.toString()}');
      _isListening = false;
    }
  }

  // Stop Voice Recognition
  Future<void> stopListening() async {
    if (!_isListening) {
      AppLogger.debug('VoiceAssistantService: Not currently listening.');
      return;
    }

    _isListening = false;
    AppLogger.debug('VoiceAssistantService: Stopping listening.');

    try {
      await _whisperStreamSubscription?.cancel();
      await _voiceService?.stopOnDeviceListening(); // VoiceService handles on-device stop
      await _recognizerSubscription?.cancel();
      _transcriptionStreamController?.add('[listening_stopped]');
    } catch (e, stackTrace) {
      AppLogger.error('VoiceAssistantService: Error stopping listening: $e', e, stackTrace);
    }
  }

  // Start or continue conversation
  Future<void> startConversation(String conversationId) async {
    _currentConversationId = conversationId.isNotEmpty ? conversationId : _uuid.v4();
    AppLogger.info('VoiceAssistantService: Conversation started/continued with ID: $_currentConversationId');
  }

  // Process voice input
  Stream<Map<String, dynamic>> processVoiceInput(
      String text,
      String voiceId,
      ) {
    _responseStreamController = StreamController<Map<String, dynamic>>.broadcast();

    if (_isProcessing) {
      _responseStreamController?.add({
        'status': 'error',
        'message': '이미 응답 처리 중입니다',
      });
      _responseStreamController?.close();
      return _responseStreamController!.stream;
    }

    if (_langchainService == null) {
      _responseStreamController?.add({
        'status': 'error',
        'message': 'AI 서비스가 초기화되지 않았습니다',
      });
      _responseStreamController?.close();
      return _responseStreamController!.stream;
    }

    if (_voiceService == null) {
      _responseStreamController?.add({
        'status': 'error',
        'message': '음성 서비스가 초기화되지 않았습니다',
      });
      _responseStreamController?.close();
      return _responseStreamController!.stream;
    }

    if (text.isEmpty) {
      _responseStreamController?.add({
        'status': 'error',
        'message': '음성 입력이 비어 있습니다',
      });
      _responseStreamController?.close();
      return _responseStreamController!.stream;
    }

    _isProcessing = true;
    AppLogger.debug('VoiceAssistantService: Processing voice input: "$text"');

    _responseStreamController?.add({
      'status': 'processing',
      'message': '응답을 생성하는 중...',
    });

    ErrorHandler.safeFuture(() async { // Use safeFuture for consistent error handling
      final response = await _getAIResponse(text, voiceId);
      _responseStreamController?.add({
        'status': 'completed',
        'response': response,
      });
      _responseStreamController?.close();
    }).catchError((error, stackTrace) {
      _isProcessing = false;
      AppLogger.error('VoiceAssistantService: Error during AI response generation: $error', error, stackTrace);
      _responseStreamController?.add({
        'status': 'error',
        'message': '응답 생성 중 오류: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(error))}',
      });
      _responseStreamController?.close();
    });

    return _responseStreamController!.stream;
  }

  // AI response generation (delegated to LangchainService)
  Future<Map<String, dynamic>> _getAIResponse(
      String userMessage,
      String voiceId,
      ) async {
    if (_langchainService == null) {
      throw AppError(type: AppErrorType.system, message: 'AI 서비스가 초기화되지 않았습니다.');
    }
    if (_voiceService == null) {
      throw AppError(type: AppErrorType.system, message: '음성 서비스가 초기화되지 않았습니다.');
    }

    // LangChain service generates response and possibly TTS URL
    final langchainResponse = await _langchainService!.getResponse(
      conversationId: _currentConversationId,
      userMessage: userMessage,
    );

    final textResponse = langchainResponse.text;
    String? audioFilePath = langchainResponse.voiceFileUrl;

    if (audioFilePath == null || audioFilePath.isEmpty) {
      AppLogger.warning('VoiceAssistantService: LangChain did not return voice URL. Generating TTS locally.');
      // If LangChain didn't provide an audio URL, generate it using VoiceService
      final ttsResult = await _voiceService!.textToSpeechFile(textResponse, voiceId);
      audioFilePath = ttsResult['url'];
    }

    return {
      'text': textResponse,
      'audioPath': audioFilePath,
      'voiceId': voiceId,
    };
  }

  // Play audio (delegated to VoiceService)
  Future<void> speak(String text, String voiceId) async {
    if (_voiceService == null) {
      AppLogger.warning('VoiceAssistantService: VoiceService is null, cannot speak.');
      return;
    }
    return ErrorHandler.safeFuture(() async {
      await _voiceService!.speak(text, voiceId: voiceId);
    });
  }

  // Stop speaking (delegated to VoiceService)
  Future<void> stopSpeaking() async {
    if (_voiceService == null) {
      AppLogger.warning('VoiceAssistantService: VoiceService is null, cannot stop speaking.');
      return;
    }
    return ErrorHandler.safeFuture(() async {
      await _voiceService!.stopSpeaking();
    });
  }

  // End conversation (cleanup)
  Future<void> endConversation() async {
    AppLogger.info('VoiceAssistantService: Ending conversation and cleaning up resources.');
    await stopListening();
    await stopSpeaking();
    // Controllers should be closed here as they are managed by VoiceAssistantService
    await _transcriptionStreamController?.close();
    await _responseStreamController?.close();
  }

  // Dispose resources
  Future<void> dispose() async {
    AppLogger.info('VoiceAssistantService: Disposing VoiceAssistantService.');
    await endConversation(); // Ensure all active operations are stopped
    // VoiceService, LangchainService, etc., are managed by Riverpod and will be disposed when no longer watched.
  }

  // Check listening status
  bool get isListening => _isListening;

  // Check processing status
  bool get isProcessing => _isProcessing;

  // Check Whisper usage
  bool get isUsingWhisper => _recognitionMode == SpeechRecognitionMode.whisper;

  // Get current recognition mode
  SpeechRecognitionMode get recognitionMode => _recognitionMode;
}