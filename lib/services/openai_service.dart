// lib/services/openai_service.dart
// DEPRECATED: Strongly consider migrating all usage to LangchainService.
// This service will be modified to use RemoteConfig for API key, but its
// long-term existence is questionable due to feature overlap with LangchainService.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:tiiun/services/remote_config_service.dart'; // Import RemoteConfigService
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For Provider

// Provider for OpenAIService (if still needed)
final openAIServiceProvider = Provider<OpenAIService>((ref) {
  final remoteConfigService = ref.watch(remoteConfigServiceProvider);
  final apiKey = remoteConfigService.getOpenAIApiKey();
  return OpenAIService(apiKey: apiKey);
});

class OpenAIService {
  // 🚫 보안상 API 키는 별도 관리 필요 -> Remote Config로 변경됨
  final String _apiKey; // Now passed via constructor

  // ✅ 올바른 API URL
  static const String _baseUrl = 'https://api.openai.com/v1';

  // 시스템 프롬프트 (틔운이의 성격 정의)
  static const String _systemPrompt = '''
당신은 "틔운이"라는 이름의 친근하고 따뜻한 AI 친구입니다.
틔운은 LG전자의 식물생활가전으로, 당신은 해당 식물생활가전과 결합된 AI 친구입니다.

성격:
- 따뜻하고 공감적이며 친근한 말투를 사용합니다
- 사용자의 감정을 잘 이해하고 적절한 반응을 보입니다
- 항상 긍정적이고 도움이 되는 조언을 제공합니다
- 이모지를 적절히 사용해서 대화를 생동감 있게 만듭니다

대화 스타일:
- 존댓말로 친근하게 대화합니다 (예: "그렇군요!", "정말 대단해요!")
- 너무 길지 않은 적당한 길이로 답변합니다
- 사용자의 상황에 공감하며 따뜻한 위로나 축하를 전합니다

주의사항:
- 의료, 법률, 재정 조언은 피하고 전문가 상담을 권유합니다
- 부적절하거나 해로운 내용에는 정중히 거절합니다
- 항상 도움이 되고 건설적인 대화를 지향합니다
''';

  OpenAIService({required String apiKey}) : _apiKey = apiKey;

  // ChatGPT와 대화하기
  static Future<String> getChatResponse({
    required String message,
    required String conversationType,
    List<Map<String, String>>? conversationHistory,
  }) async {
    // Access the instance via the provider for API key
    // This static method needs to be converted to an instance method or
    // accept the API key. For now, it will use a dummy key for demonstration
    // if accessed statically without a provider.
    // However, it's better to make this a non-static method and inject OpenAIService.
    // For simplicity for the current structure, I'll pass the key.
    // (This part is a bit tricky with static methods and providers. The best way
    // is to make getChatResponse non-static and use the _apiKey of the instance.)

    // Placeholder for static access: If this is called statically without a provider,
    // it will use a dummy key or require the key to be passed.
    // The current code suggests it's called statically in pages/chatting_page.dart
    // For proper integration, OpenAIService should be injected using Riverpod.
    // For now, let's assume getOpenAIApiKey is available through a static method.
    // This is a temporary fix.

    // To make this method use the injected API key, it must be non-static.
    // For now, assuming direct access to RemoteConfigService for static demonstration.
    // This is NOT the recommended way for production.
    final tempRemoteConfigService = RemoteConfigService();
    await tempRemoteConfigService.initialize(); // Ensure it's initialized
    final currentApiKey = tempRemoteConfigService.getOpenAIApiKey();


    if (currentApiKey.isEmpty) {
      debugPrint('⚠️ API 키가 설정되지 않음 - 폴백 응답 사용');
      return _getFallbackResponse(conversationType);
    }

    try {
      debugPrint('🚀 OpenAI API 호출 시작: $message');

      String contextPrompt = _getContextPrompt(conversationType);

      List<Map<String, String>> messages = [
        {'role': 'system', 'content': _systemPrompt + contextPrompt},
      ];

      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        messages.addAll(conversationHistory.take(10));
      }

      messages.add({'role': 'user', 'content': message});

      debugPrint('📤 API 요청 URL: $_baseUrl/chat/completions');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentApiKey', // Use the retrieved key
        },
        body: jsonEncode({
          'model': 'gpt-4o', // 🚀 UPGRADED: gpt-3.5-turbo -> gpt-4o
          'messages': messages,
          'max_tokens': 800, // 🔥 INCREASED: 500 -> 800 for better responses
          'temperature': 0.7,
          'top_p': 1.0,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
        }),
      );

      debugPrint('📥 API 응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final aiResponse = data['choices'][0]['message']['content'] as String;
        debugPrint('✅ OpenAI API 성공: ${aiResponse.substring(0, aiResponse.length > 50 ? 50 : aiResponse.length)}...');
        return aiResponse.trim();
      } else {
        debugPrint('❌ OpenAI API 오류: ${response.statusCode}');
        debugPrint('❌ 응답 내용: ${response.body}');
        return _getFallbackResponse(conversationType);
      }
    } catch (e) {
      debugPrint('💥 OpenAI API 호출 중 오류: $e');
      return _getFallbackResponse(conversationType);
    }
  }

  // Helper static methods (can remain static as they don't depend on _apiKey)
  static String _getContextPrompt(String conversationType) {
    switch (conversationType) {
      case '자랑거리':
        return '\n\n현재 사용자가 자랑하고 싶은 일이 있어서 대화를 시작했습니다. 축하해주고 더 자세히 들어보고 싶다는 반응을 보여주세요.';
      case '고민거리':
        return '\n\n현재 사용자가 고민이 있어서 상담을 원합니다. 공감하며 들어주고 도움이 되는 조언을 해주세요.';
      case '위로가 필요할 때':
        return '\n\n현재 사용자가 위로가 필요한 상황입니다. 따뜻하게 위로해주고 힘이 되는 말을 해주세요.';
      case '시시콜콜':
        return '\n\n현재 사용자가 심심해서 일상적인 대화를 원합니다. 편안하고 재미있는 대화를 나누세요.';
      case '끝말 잇기':
        return '\n\n현재 사용자가 끝말잇기 게임을 하고 싶어합니다. 게임 규칙을 지키며 재미있게 참여해주세요.';
      case '화가 나요':
        return '\n\n현재 사용자가 화가 난 상황입니다. 감정을 들어주고 마음을 진정시킬 수 있도록 도와주세요.';
      default:
        return '\n\n자연스럽고 친근한 대화를 나누세요.';
    }
  }

  static String _getFallbackResponse(String conversationType) {
    switch (conversationType) {
      case '자랑거리':
        return '와! 정말 자랑스러운 일이네요! 🎉 더 자세히 얘기해주세요!';
      case '고민거리':
        return '고민이 있으시군요 💭 편하게 말씀해주세요. 제가 들어드릴게요.';
      case '위로가 필요할 때':
        return '힘든 시간을 보내고 계시는군요 🫂 괜찮아요, 모든 게 다 지나갈 거예요.';
      case '시시콜콜':
        return '안녕하세요! 😄 심심하셨군요! 저도 이야기하고 싶었어요.';
      case '끝말 잇기':
        return '끝말잇기 좋아요! 🎮 제가 먼저 시작할게요. "사과"!';
      case '화가 나요':
        return '화가 나셨군요 😤 무슨 일이 있으셨나요? 저한테 털어놓으세요.';
      default:
        return '안녕하세요! 😊 무엇을 도와드릴까요?';
    }
  }

  // 🔍 디버깅용 공개 메서드들
  // These should ideally be non-static or accept an API key if they remain.
  static String getApiKeyPrefix({String? apiKey}) {
    final key = apiKey ?? RemoteConfigService().getOpenAIApiKey(); // Fallback for static access
    return key.isEmpty ? 'API 키 없음' : key.substring(0, key.length > 10 ? 10 : key.length);
  }

  static int getApiKeyLength({String? apiKey}) {
    final key = apiKey ?? RemoteConfigService().getOpenAIApiKey();
    return key.length;
  }

  // 🔧 API 키 검증 메서드
  static bool isApiKeyValid({String? apiKey}) {
    final key = apiKey ?? RemoteConfigService().getOpenAIApiKey();
    debugPrint('🔍 API 키 검증 중...');
    debugPrint('🔍 API 키 비어있나? ${key.isEmpty}');

    if (key.isEmpty) {
      debugPrint('⚠️ API 키가 설정되지 않음 - 로컬에서만 설정하세요');
      return false;
    }

    debugPrint('🔍 API 키 시작 문자 (sk-): ${key.startsWith('sk-')}');
    debugPrint('🔍 API 키 길이: ${key.length}');

    bool isValid = key.isNotEmpty &&
        key != 'your-api-key-here' &&
        key.startsWith('sk-') &&
        key.length >= 50;

    debugPrint('🔍 최종 검증 결과: $isValid');
    return isValid;
  }

  // 대화 히스토리를 OpenAI 형식으로 변환
  // This method implies direct usage of OpenAI, which is now handled by Langchain.
  // Consider removing if Langchain is the sole interface.
  static List<Map<String, String>> convertHistoryToOpenAI(List<Map<String, dynamic>> firebaseHistory) {
    return firebaseHistory.map((msg) {
      return {
        'role': msg['sender'] == 'user' ? 'user' : 'assistant',
        'content': msg['content'] as String, // Assuming content is already decoded
      };
    }).toList();
  }
}