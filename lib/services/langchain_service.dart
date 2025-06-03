// lib/services/langchain_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'dart:convert';
import '../models/conversation_model.dart';
import '../models/message_model.dart'; // MessageModel import
import 'firebase_service.dart'; // FirebaseService로 변경
import 'voice_service.dart';
import 'conversation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:tiiun/services/remote_config_service.dart';

// LangChain 서비스 Provider
final langchainServiceProvider = Provider<LangchainService>((ref) {
  final firebaseService = FirebaseService(); // FirebaseService 직접 생성
  final voiceService = ref.watch(voiceServiceProvider);
  final conversationService = ref.watch(conversationServiceProvider);
  final remoteConfigService = ref.watch(remoteConfigServiceProvider);
  final openAIapiKey = remoteConfigService.getOpenAIApiKey();
  return LangchainService(firebaseService, voiceService, conversationService, openAIapiKey);
});

class LangchainResponse {
  final String text;
  final String? voiceFileUrl;
  final double? voiceDuration;
  final String? voiceId;
  final String? ttsSource;

  LangchainResponse({
    required this.text,
    this.voiceFileUrl,
    this.voiceDuration,
    this.voiceId,
    this.ttsSource,
  });
}

class LangchainService {
  final FirebaseService _firebaseService; // FirebaseService로 변경
  final VoiceService _voiceService;
  final ConversationService _conversationService;
  final String _openAIapiKey; // Store the API key

  ChatOpenAI? _chatModel;

  LangchainService(
      this._firebaseService, // FirebaseService로 변경
      this._voiceService,
      this._conversationService,
      this._openAIapiKey, // Receive API key
      ) {
    _initializeLangChain();
  }

  // LangChain 초기화
  void _initializeLangChain() {
    if (_openAIapiKey.isNotEmpty) {
      _chatModel = ChatOpenAI(
        apiKey: _openAIapiKey,
        model: 'gpt-4.1-2025-04-14',
        temperature: 0.7,
        maxTokens: 1000,
      );
      debugPrint("LangchainService initialized with OpenAI API key.");
    } else {
      debugPrint("LangchainService: OpenAI API key is missing. LLM features will be limited or use dummy responses.");
    }
  }

  // 사용자 메시지에 대한 응답 생성
  Future<LangchainResponse> getResponse({
    required String conversationId,
    required String userMessage,
  }) async {
    try {
      final userId = _firebaseService.currentUserId; // FirebaseService 메서드 사용
      if (userId == null) {
        return _createDefaultResponse('로그인이 필요합니다. 로그인 후 다시 시도해주세요.');
      }

      final messagesHistory = await _getConversationHistory(conversationId);
      final user = await _firebaseService.getUserData(userId); // FirebaseService 메서드 사용

      // 사용자가 선택한 음성 ID
      String? selectedVoiceId = user?.preferredVoice ?? 'default'; // null 체크 추가
      debugPrint('LangchainService: 사용자 선호 음성 ID - $selectedVoiceId');

      // API 키가 설정되지 않았거나 테스트 모드인 경우 (_chatModel 유무로 판단)
      if (_chatModel == null || _openAIapiKey.isEmpty) {
        debugPrint("LangchainService: 채팅 모델 없음 (API 키 없음). 더미 응답 사용.");
        final dummyResponse = _getDummyResponse(userMessage);
        try {
          debugPrint('LangchainService: 더미 응답에 대한 TTS 생성 시도');
          final voiceData = await _voiceService.textToSpeechFile(
              dummyResponse,
              selectedVoiceId
          );

          if (voiceData['url'] == null || (voiceData['url'] as String).isEmpty) {
            debugPrint('LangchainService: TTS URL이 비어있음 - 오류: ${voiceData['error']}');
            return LangchainResponse(
              text: dummyResponse,
              voiceId: selectedVoiceId,
              ttsSource: 'error',
            );
          }

          debugPrint('LangchainService: 더미 응답 TTS 성공 - URL: ${voiceData['url']}, 소스: ${voiceData['source']}');
          return LangchainResponse(
            text: dummyResponse,
            voiceFileUrl: voiceData['url'] as String?,
            voiceDuration: voiceData['duration'] as double?,
            voiceId: selectedVoiceId,
            ttsSource: voiceData['source'] as String?,
          );
        } catch (e) {
          debugPrint('음성 생성 오류 (dummy response): $e');
          return LangchainResponse(
            text: dummyResponse,
            voiceId: selectedVoiceId,
            ttsSource: 'error',
          );
        }
      }

      // LangChain을 사용하여 응답 생성
      String llmResponseText = '';
      try {
        llmResponseText = await _generateResponseWithLangChain(
          messagesHistory,
          userMessage,
          selectedVoiceId,
        );
        debugPrint('LangchainService: LangChain 응답 생성 성공 - 길이: ${llmResponseText.length}');
      } catch (e) {
        debugPrint('LangChain 응답 생성 오류: $e. Falling back to dummy response.');
        llmResponseText = _getDummyResponse(userMessage);
      }

      try {
        // TTS를 사용하여 음성 생성
        debugPrint('LangchainService: 응답 텍스트에 대한 TTS 파일 생성 시도');
        final voiceData = await _voiceService.textToSpeechFile(
            llmResponseText,
            selectedVoiceId
        );

        if (voiceData['url'] == null || (voiceData['url'] as String).isEmpty) {
          debugPrint('LangchainService: TTS URL이 비어있음 - 오류: ${voiceData['error']}');
          return LangchainResponse(
            text: llmResponseText,
            voiceId: selectedVoiceId,
            ttsSource: 'error',
          );
        }

        debugPrint('LangchainService: TTS 파일 생성 성공 - URL: ${voiceData['url']}, 소스: ${voiceData['source']}');
        return LangchainResponse(
          text: llmResponseText,
          voiceFileUrl: voiceData['url'] as String?,
          voiceDuration: voiceData['duration'] as double?,
          voiceId: selectedVoiceId,
          ttsSource: voiceData['source'] as String?,
        );
      } catch (e) {
        debugPrint('LangchainService: 음성 생성 오류 (LLM response): $e');
        return LangchainResponse(
          text: llmResponseText,
          voiceId: selectedVoiceId,
          ttsSource: 'error',
        );
      }
    } catch (e) {
      debugPrint('LangChain getResponse 중 전반적인 오류 발생: $e');
      return _createDefaultResponse('응답을 생성하는 중 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  LangchainResponse _createDefaultResponse(String text) {
    return LangchainResponse(
      text: text,
      voiceId: 'default',
      ttsSource: 'none',
    );
  }

  Future<String> _generateResponseWithLangChain(
      List<MessageModel> messageHistory, // MessageModel로 변경
      String userMessage,
      String? appVoiceIdForPrompt, // App-specific voice ID to tailor system prompt
      ) async {
    if (_chatModel == null) {
      throw Exception("Chat model is not initialized. Cannot generate response.");
    }
    try {
      final systemMessage = SystemChatMessage(
        content: _generateSystemPrompt(appVoiceIdForPrompt ?? 'default'),
      );
      List<ChatMessage> history = messageHistory.map((message) {
        if (message.sender == 'user') { // String 비교로 변경
          return HumanChatMessage(content: message.content);
        } else {
          return AIChatMessage(content: message.content);
        }
      }).toList();
      history.add(HumanChatMessage(content: userMessage));
      final messages = [systemMessage, ...history];
      final result = await _chatModel!.call(messages);
      return result.content;
    } catch (e) {
      debugPrint("Error calling LangChain model: $e");
      throw Exception('LangChain 호출 중 오류 발생: $e');
    }
  }

  Future<List<MessageModel>> _getConversationHistory(String conversationId) async { // MessageModel로 변경
    final messagesStream = _conversationService.getConversationMessages(conversationId);
    final messages = await messagesStream.first;
    return messages.length > 10 ? messages.sublist(messages.length - 10) : messages;
  }

  String _generateSystemPrompt(String voiceId) {
    switch (voiceId) {
      case 'male_1':
        return '''
당신은 정서적 지원과 공감을 제공하는 상담 AI입니다.
차분하고 신중한 남성 상담사의 성격으로 대화합니다.
사용자의 감정에 공감하고, 문제 해결에 도움이 되는 조언을 제공하세요.
간결하고 명확하게 대화하되, 항상 공감적인 태도를 유지하세요.
''';
      case 'child_1':
        return '''
당신은 정서적 지원과 공감을 제공하는 상담 AI입니다.
친근하고 밝은 성격으로 대화합니다.
간단하고 이해하기 쉬운 언어를 사용하며, 친구처럼 대화하세요.
사용자를 격려하고 긍정적인 에너지를 전달하세요.
''';
      case 'calm_1':
        return '''
당신은 정서적 지원과 공감을 제공하는 상담 AI입니다.
차분하고 따뜻한 여성 상담사의 성격으로 대화합니다.
깊은 공감과 이해를 바탕으로 사용자의 감정을 인정하고 수용하세요.
명상과 마음챙김 관점에서 도움이 되는 조언을 제공하세요.
''';
      default: // 'default'
        return '''
당신은 정서적 지원과 공감을 제공하는 상담 AI입니다.
따뜻하고 친절한 여성 상담사의 성격으로 대화합니다.
사용자의 감정에 공감하고, 심리적 안정감을 주는 대화를 하세요.
긍정적이고 지지적인 태도로 사용자가 자신의 감정을 표현하도록 격려하세요.
대화는 간결하게 유지하고, 너무 길지 않게 응답하세요.
''';
    }
  }

  String _getDummyResponse(String userMessage) {
    if (userMessage.contains('안녕') || userMessage.contains('반가워')) {
      return '안녕하세요! 오늘 기분이 어떠신가요? 무슨 일이 있으셨나요?';
    } else if (userMessage.contains('슬퍼') || userMessage.contains('우울해')) {
      return '그런 감정이 드셨군요. 슬픔을 느끼는 것은 자연스러운 일이에요. 어떤 일이 있으셨는지 더 이야기해주실 수 있을까요?';
    } else if (userMessage.contains('화가 나') || userMessage.contains('짜증')) {
      return '화가 나셨군요. 그런 감정이 드는 것은 정상적인 반응이에요. 어떤 상황이 그런 감정을 불러일으켰나요?';
    } else {
      return '말씀해주셔서 감사합니다. 더 자세히 이야기해주실 수 있을까요? 어떤 감정이 느껴지시나요?';
    }
  }

  Future<Map<String, dynamic>> analyzeSentimentWithLangChain(String text) async {
    if (_chatModel == null || _openAIapiKey.isEmpty) {
      debugPrint("LangchainService: No chat model for sentiment analysis. Using test sentiment.");
      final score = _getTestSentimentScore(text);
      final label = score > 0 ? 'positive' : score < 0 ? 'negative' : 'neutral';
      return {
        'score': score,
        'label': label,
        'emotionType': _getTestEmotionType(text),
        'confidence': 0.7,
      };
    }
    try {
      const template = """
다음 텍스트의 감정을 분석하고 JSON 형식으로 결과를 반환하세요:

텍스트: {text}

결과는 다음 형식이어야 합니다:
{{
  "score": [-1.0에서 1.0 사이의 숫자, 1.0에 가까울수록 긍정적],
  "label": ["positive", "neutral", "negative" 중 하나],
  "emotionType": [주요 감정 유형 - "joy", "sadness", "anger", "fear", "surprise", "disgust", "neutral" 중 하나],
  "confidence": [0.0에서 1.0 사이의 신뢰도]
}}
""";
      final promptTemplate = PromptTemplate.fromTemplate(template);
      final prompt = promptTemplate.format({'text': text});
      final chatPrompt = [
        const SystemChatMessage(content: "You are a sentiment analysis expert. Analyze the sentiment in the given text and return the result in the specified JSON format."),
        HumanChatMessage(content: prompt)
      ];
      final result = await _chatModel!.call(chatPrompt);
      return _extractJsonFromString(result.content);
    } catch (e) {
      debugPrint("Error during sentiment analysis with LangChain: $e");
      throw Exception('감정 분석 중 오류 발생: $e');
    }
  }

  Map<String, dynamic> _extractJsonFromString(String text) {
    try {
      final regex = RegExp(r'{[\s\S]*}');
      final match = regex.firstMatch(text);
      if (match != null) {
        final jsonStr = match.group(0);
        if (jsonStr != null) return jsonDecode(jsonStr);
      }
      return {'score': 0.0, 'label': 'neutral', 'emotionType': 'neutral', 'confidence': 0.5, 'error': 'Failed to parse JSON from LLM response'};
    } catch (e) {
      debugPrint("Error extracting JSON from string: $e, String: $text");
      return {'score': 0.0, 'label': 'neutral', 'emotionType': 'neutral', 'confidence': 0.5, 'error': e.toString()};
    }
  }

  double _getTestSentimentScore(String text) {
    final positiveWords = ['행복', '기쁨', '좋아', '감사', '즐거움', '희망'];
    final negativeWords = ['슬픔', '우울', '화남', '불안', '걱정', '두려움', '무서움'];
    double score = 0.0;
    for (final word in positiveWords) if (text.contains(word)) score += 0.1;
    for (final word in negativeWords) if (text.contains(word)) score -= 0.1;
    return score.clamp(-1.0, 1.0);
  }

  String _getTestEmotionType(String text) {
    if (text.contains('행복') || text.contains('기쁨') || text.contains('좋아')) return 'joy';
    if (text.contains('슬픔') || text.contains('우울')) return 'sadness';
    if (text.contains('화남') || text.contains('짜증')) return 'anger';
    if (text.contains('불안') || text.contains('걱정') || text.contains('두려움')) return 'fear';
    if (text.contains('놀라')) return 'surprise';
    if (text.contains('역겨') || text.contains('혐오')) return 'disgust';
    return 'neutral';
  }
}