// lib/services/gpt4o_audio_service.dart (개선된 버전)
// 🚀 NEW: GPT-4o-audio-preview 전용 서비스
// 실시간 음성 대화 및 네이티브 오디오 처리를 위한 서비스
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiiun/services/remote_config_service.dart';
import 'package:tiiun/services/openai_tts_service.dart'; // 🆕 TTS 서비스 추가
import 'package:tiiun/utils/error_handler.dart';
import 'package:tiiun/utils/logger.dart';

// GPT-4o Audio 서비스 Provider (TTS 서비스 주입)
final gpt4oAudioServiceProvider = Provider<Gpt4oAudioService>((ref) {
  final remoteConfigService = ref.watch(remoteConfigServiceProvider);
  final openAiTtsService = ref.watch(openAiTtsServiceProvider); // 🆕 TTS 서비스 주입
  final apiKey = remoteConfigService.getOpenAIApiKey();
  return Gpt4oAudioService(
    apiKey: apiKey,
    ttsService: openAiTtsService, // 🆕 TTS 서비스 전달
  );
});

/// GPT-4o-audio-preview를 활용한 실시간 음성 대화 서비스
///
/// 특징:
/// - 실시간 음성 입출력 처리
/// - 자연스러운 음성 톤과 감정 표현
/// - 끊김 없는 대화 지원
/// - 멀티모달 처리 (텍스트 + 오디오)
class Gpt4oAudioService {
  final String _apiKey;
  final OpenAiTtsService _ttsService; // 🆕 TTS 서비스 의존성
  final Uuid _uuid = const Uuid();
  final Connectivity _connectivity = Connectivity();

  // API Endpoints
  final String _chatCompletionsUrl = 'https://api.openai.com/v1/chat/completions';
  final String _audioTranscriptionsUrl = 'https://api.openai.com/v1/audio/transcriptions';

  // GPT-4o Audio 모델 설정
  static const String _audioModel = 'gpt-4o-audio-preview';
  static const String _whisperModel = 'whisper-1';

  // Retry constants
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  // 🆕 생성자에 TTS 서비스 주입
  Gpt4oAudioService({
    required String apiKey,
    required OpenAiTtsService ttsService,
  }) : _apiKey = apiKey, _ttsService = ttsService;

  /// 인터넷 연결 확인
  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  /// 🚀 실시간 음성 대화 - GPT-4o-audio-preview 활용
  ///
  /// 음성 입력을 받아 즉시 음성으로 응답하는 실시간 대화 시스템
  /// [audioFilePath]: 사용자 음성 녹음 파일 경로
  /// [systemPrompt]: 시스템 프롬프트 (상담사 성격 등)
  /// [conversationHistory]: 이전 대화 기록
  /// [voiceStyle]: 응답 음성 스타일 ('alloy', 'echo', 'fable', 'onyx', 'nova', 'shimmer')
  Future<Map<String, dynamic>> processAudioConversation({
    required String audioFilePath,
    String? systemPrompt,
    List<Map<String, dynamic>>? conversationHistory,
    String voiceStyle = 'nova',
  }) async {
    return ErrorHandler.safeApiCall(() async {
      if (!await _checkInternetConnection()) {
        throw AppError(
          type: AppErrorType.network,
          message: '인터넷 연결이 필요합니다. GPT-4o Audio는 온라인 연결이 필수입니다.',
        );
      }

      if (_apiKey.isEmpty) {
        throw AppError(
          type: AppErrorType.authentication,
          message: 'OpenAI API 키가 설정되지 않았습니다.',
        );
      }

      AppLogger.info('Gpt4oAudioService: Starting audio conversation processing');

      // 1️⃣ 음성을 텍스트로 변환 (Whisper)
      final transcription = await _transcribeAudio(audioFilePath);
      if (transcription.isEmpty) {
        throw AppError(
          type: AppErrorType.data,
          message: '음성을 인식할 수 없습니다. 다시 말씀해주세요.',
        );
      }

      AppLogger.debug('Gpt4oAudioService: Transcription: $transcription');

      // 2️⃣ GPT-4o Audio로 응답 생성
      final responseText = await _generateAudioResponse(
        userMessage: transcription,
        systemPrompt: systemPrompt,
        conversationHistory: conversationHistory,
      );

      // 3️⃣ 🆕 개선된 TTS 서비스 사용
      final audioPath = await _generateHighQualityAudioWithService(
        text: responseText,
        voice: voiceStyle,
      );

      return {
        'userTranscription': transcription,
        'responseText': responseText,
        'responseAudioPath': audioPath,
        'voiceStyle': voiceStyle,
        'processingTime': DateTime.now().millisecondsSinceEpoch,
        'source': 'gpt-4o-audio-preview',
      };
    });
  }

  /// 🎙️ 음성 전용 대화 모드
  Stream<Map<String, dynamic>> streamAudioConversation({
    required Stream<String> audioPathStream,
    String? systemPrompt,
    String voiceStyle = 'nova',
  }) async* {
    List<Map<String, dynamic>> conversationHistory = [];

    await for (final audioPath in audioPathStream) {
      try {
        final result = await processAudioConversation(
          audioFilePath: audioPath,
          systemPrompt: systemPrompt,
          conversationHistory: conversationHistory,
          voiceStyle: voiceStyle,
        );

        // 대화 기록 업데이트
        conversationHistory.addAll([
          {'role': 'user', 'content': result['userTranscription']},
          {'role': 'assistant', 'content': result['responseText']},
        ]);

        // 최근 10개 대화만 유지
        if (conversationHistory.length > 20) {
          conversationHistory = conversationHistory.sublist(conversationHistory.length - 20);
        }

        yield result;
      } catch (e) {
        yield {
          'error': true,
          'message': e.toString(),
          'source': 'gpt-4o-audio-preview',
        };
      }
    }
  }

  /// 🎯 감정 인식 음성 대화
  Future<Map<String, dynamic>> processEmotionalAudioConversation({
    required String audioFilePath,
    String voiceStyle = 'shimmer',
  }) async {
    const emotionalSystemPrompt = '''
당신은 전문 심리 상담사입니다. 사용자의 음성에서 감정을 읽고 적절히 반응하세요.

특별 지침:
- 사용자의 음성 톤과 말하는 속도를 고려하여 감정 상태를 파악하세요
- 슬픔, 분노, 기쁨, 불안 등 다양한 감정에 맞는 적절한 톤으로 응답하세요
- 감정적 공감과 전문적 조언을 균형있게 제공하세요
- 응답은 따뜻하고 지지적이어야 합니다

응답 형식:
- 감정 인식: "지금 [감정]을 느끼고 계시는 것 같네요"로 시작
- 공감 표현: 사용자의 감정에 공감하는 표현
- 조언 제공: 도움이 되는 구체적 조언
- 격려: 긍정적 마무리
''';

    return processAudioConversation(
      audioFilePath: audioFilePath,
      systemPrompt: emotionalSystemPrompt,
      voiceStyle: voiceStyle,
    );
  }

  /// 📝 GPT-4o Audio 응답 생성
  Future<String> _generateAudioResponse({
    required String userMessage,
    String? systemPrompt,
    List<Map<String, dynamic>>? conversationHistory,
  }) async {
    final defaultSystemPrompt = '''
당신은 "틔운이"라는 이름의 따뜻하고 공감적인 AI 상담사입니다.
사용자와 자연스러운 음성 대화를 나누며, 감정적 지원을 제공합니다.

음성 대화 특화 지침:
- 자연스럽고 대화체로 응답하세요
- 적절한 억양과 감정이 표현되도록 작성하세요
- 너무 길지 않게, 음성으로 듣기 편한 길이로 응답하세요
- 필요시 잠깐의 침묵(쉼표, 마침표)을 활용하세요
''';

    final systemMessage = systemPrompt ?? defaultSystemPrompt;

    List<Map<String, dynamic>> messages = [
      {'role': 'system', 'content': systemMessage},
    ];

    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      messages.addAll(conversationHistory.take(10));
    }

    messages.add({'role': 'user', 'content': userMessage});

    final requestBody = jsonEncode({
      'model': _audioModel,
      'messages': messages,
      'max_tokens': 800,
      'temperature': 0.8,
      'top_p': 0.9,
      'frequency_penalty': 0.1,
      'presence_penalty': 0.1,
      'modalities': ['text'],
      'audio': {
        'voice': 'nova',
        'format': 'mp3'
      }
    });

    final response = await http.post(
      Uri.parse(_chatCompletionsUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: requestBody,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final responseText = data['choices'][0]['message']['content'] as String;
      AppLogger.info('Gpt4oAudioService: GPT-4o Audio response generated successfully');
      return responseText.trim();
    } else {
      AppLogger.error('Gpt4oAudioService: GPT-4o Audio API error (${response.statusCode}): ${response.body}');
      throw AppError(
        type: AppErrorType.server,
        code: response.statusCode.toString(),
        message: 'GPT-4o Audio API 오류가 발생했습니다.',
        details: response.body,
      );
    }
  }

  /// 🎙️ 음성을 텍스트로 변환 (Whisper)
  Future<String> _transcribeAudio(String audioFilePath) async {
    final file = File(audioFilePath);
    if (!await file.exists()) {
      throw AppError(
        type: AppErrorType.data,
        message: '오디오 파일을 찾을 수 없습니다: $audioFilePath',
      );
    }

    final request = http.MultipartRequest('POST', Uri.parse(_audioTranscriptionsUrl));

    request.headers.addAll({
      'Authorization': 'Bearer $_apiKey',
    });

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      audioFilePath,
      filename: 'audio.m4a',
    ));

    request.fields['model'] = _whisperModel;
    request.fields['language'] = 'ko';
    request.fields['response_format'] = 'json';

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException('Whisper API 요청 시간 초과');
      },
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['text'] as String;
    } else {
      throw AppError(
        type: AppErrorType.server,
        code: response.statusCode.toString(),
        message: 'Whisper API 오류가 발생했습니다.',
        details: response.body,
      );
    }
  }

  /// 🔊 🆕 개선된 고품질 음성 생성 (OpenAI TTS Service 활용)
  Future<String> _generateHighQualityAudioWithService({
    required String text,
    String voice = 'nova',
  }) async {
    try {
      // 🆕 주입받은 TTS 서비스 사용
      AppLogger.info('Gpt4oAudioService: Using OpenAI TTS Service for high-quality audio generation');

      final audioPath = await _ttsService.generateSpeech(
        text: text,
        voice: voice,
        model: 'tts-1-hd',
        responseFormat: 'mp3',
        speed: 1.0,
      );

      AppLogger.info('Gpt4oAudioService: High-quality audio generated via TTS service: $audioPath');
      return audioPath;
    } catch (e) {
      AppLogger.error('Gpt4oAudioService: Failed to generate audio via TTS service: $e');

      // 🔄 폴백: 기존 방식 사용
      AppLogger.warning('Gpt4oAudioService: Falling back to direct TTS API call');
      return await _generateHighQualityAudioDirect(text: text, voice: voice);
    }
  }

  /// 🔊 기존 직접 TTS API 호출 방식 (폴백용)
  Future<String> _generateHighQualityAudioDirect({
    required String text,
    String voice = 'nova',
  }) async {
    final requestBody = jsonEncode({
      'model': 'tts-1-hd',
      'input': text,
      'voice': voice,
      'response_format': 'mp3',
      'speed': 1.0,
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/audio/speech'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: requestBody,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${_uuid.v4()}.mp3';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath;
    } else {
      throw AppError(
        type: AppErrorType.server,
        code: response.statusCode.toString(),
        message: 'TTS-1-HD API 오류가 발생했습니다.',
        details: response.body,
      );
    }
  }

  /// 🎨 음성 스타일 최적화
  String recommendVoiceStyle({
    required String emotionType,
    required String conversationType,
  }) {
    switch (conversationType) {
      case '위로가 필요할 때':
      case '고민거리':
        return emotionType == 'sadness' ? 'shimmer' : 'nova';
      case '자랑거리':
      case '시시콜콜':
        return 'echo';
      case '화가 나요':
        return 'onyx';
      default:
        return 'alloy';
    }
  }

  /// 🧠 음성 기반 감정 분석
  Future<Map<String, dynamic>> analyzeAudioEmotion(String audioFilePath) async {
    try {
      final transcription = await _transcribeAudio(audioFilePath);

      const analysisPrompt = '''
다음 음성 대화 텍스트를 분석하여 사용자의 감정 상태를 파악하세요.
음성으로 전달된 내용이므로 말의 톤, 속도, 감정적 뉘앙스를 고려하여 분석하세요.

JSON 형식으로 응답해주세요:
{
  "emotion": "주요 감정 (joy, sadness, anger, fear, surprise, neutral)",
  "intensity": "감정 강도 (1-10)",
  "confidence": "분석 확신도 (0.0-1.0)",
  "emotional_indicators": ["감정을 나타내는 지표들"],
  "recommended_response_tone": "추천 응답 톤"
}
''';

      final analysisResponse = await _generateAudioResponse(
        userMessage: '$analysisPrompt\n\n분석할 텍스트: $transcription',
        systemPrompt: '당신은 음성 기반 감정 분석 전문가입니다.',
      );

      try {
        return jsonDecode(analysisResponse);
      } catch (e) {
        return {
          'emotion': 'neutral',
          'intensity': 5,
          'confidence': 0.5,
          'emotional_indicators': ['분석 실패'],
          'recommended_response_tone': 'balanced',
          'raw_analysis': analysisResponse,
        };
      }
    } catch (e) {
      AppLogger.error('Gpt4oAudioService: Audio emotion analysis failed: $e');
      return {
        'emotion': 'neutral',
        'intensity': 1,
        'confidence': 0.0,
        'error': e.toString(),
      };
    }
  }

  /// 🔄 리소스 정리
  Future<void> dispose() async {
    AppLogger.info('Gpt4oAudioService: Disposing resources');
    // TTS 서비스는 Provider에서 관리되므로 별도 dispose 불필요
  }
}
