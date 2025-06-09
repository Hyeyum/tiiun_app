# 🚀 GPT-4o & Audio 모델 사용 가이드

## 📋 목차
1. [기본 사용법](#기본-사용법)
2. [GPT-4o-audio-preview 활용](#gpt-4o-audio-preview-활용)
3. [성능 최적화 팁](#성능-최적화-팁)
4. [문제 해결](#문제-해결)
5. [모범 사례](#모범-사례)

## 🎯 기본 사용법

### 1. 기존 코드 변경 없이 자동 업그레이드

기존의 모든 AI 서비스들이 자동으로 GPT-4o를 사용합니다:

```dart
// 변경 없음 - 자동으로 GPT-4o 사용
final langchainService = ref.watch(langchainServiceProvider);
final response = await langchainService.getResponse(
  conversationId: conversationId,
  userMessage: userMessage,
);
```

### 2. 고품질 TTS 사용

TTS 서비스도 자동으로 TTS-1-HD를 사용합니다:

```dart
// 변경 없음 - 자동으로 TTS-1-HD 사용
final voiceService = ref.watch(voiceServiceProvider);
final result = await voiceService.textToSpeechFile(text, voiceId);
```

## 🎙️ GPT-4o-audio-preview 활용

### 1. 기본 설정

새로운 GPT-4o Audio 서비스를 사용하려면:

```dart
import 'package:tiiun/services/gpt4o_audio_service.dart';

class AudioChatPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gpt4oAudio = ref.watch(gpt4oAudioServiceProvider);
    
    return Scaffold(
      // UI 구성
    );
  }
}
```

### 2. 실시간 음성 대화

```dart
Future<void> handleVoiceConversation(String audioFilePath) async {
  try {
    final result = await gpt4oAudio.processAudioConversation(
      audioFilePath: audioFilePath,
      systemPrompt: '''
      당신은 친근한 AI 상담사입니다.
      사용자의 감정에 공감하며 도움이 되는 조언을 제공하세요.
      ''',
      voiceStyle: 'nova', // 친근한 여성 목소리
    );
    
    // 결과 활용
    final userSaid = result['userTranscription'];
    final aiResponse = result['responseText'];
    final audioPath = result['responseAudioPath'];
    
    // UI 업데이트
    setState(() {
      messages.add(Message(sender: 'user', content: userSaid));
      messages.add(Message(sender: 'ai', content: aiResponse));
    });
    
    // 음성 재생
    await audioPlayer.setFilePath(audioPath);
    await audioPlayer.play();
    
  } catch (e) {
    print('음성 대화 오류: $e');
  }
}
```

### 3. 스트림 기반 실시간 대화

```dart
Stream<String> audioPathStream = ...; // 음성 파일 스트림

await for (final result in gpt4oAudio.streamAudioConversation(
  audioPathStream: audioPathStream,
  voiceStyle: 'shimmer', // 차분한 목소리
)) {
  if (result['error'] == true) {
    print('오류: ${result['message']}');
    continue;
  }
  
  // 실시간 대화 처리
  final transcription = result['userTranscription'];
  final response = result['responseText'];
  final audioPath = result['responseAudioPath'];
  
  // UI 실시간 업데이트
  updateChatUI(transcription, response);
  playAudio(audioPath);
}
```

### 4. 감정 기반 상담

```dart
Future<void> emotionalCounseling(String audioPath) async {
  // 감정 분석
  final emotionData = await gpt4oAudio.analyzeAudioEmotion(audioPath);
  
  final emotion = emotionData['emotion']; // 'sadness', 'joy', etc.
  final intensity = emotionData['intensity']; // 1-10
  
  // 감정에 맞는 응답
  final result = await gpt4oAudio.processEmotionalAudioConversation(
    audioFilePath: audioPath,
    voiceStyle: gpt4oAudio.recommendVoiceStyle(
      emotionType: emotion,
      conversationType: '위로가 필요할 때',
    ),
  );
  
  // 감정 기반 UI 업데이트
  updateEmotionalIndicator(emotion, intensity);
  playResponseAudio(result['responseAudioPath']);
}
```

## ⚡ 성능 최적화 팁

### 1. 토큰 사용 최적화

```dart
// 🚫 비효율적 - 너무 긴 프롬프트
final response = await langchainService.getResponse(
  userMessage: '''
  매우 긴 사용자 메시지...
  불필요한 세부사항들...
  반복적인 내용들...
  ''',
);

// ✅ 효율적 - 핵심만 전달
final response = await langchainService.getResponse(
  userMessage: '오늘 기분이 좋지 않아요. 위로해주세요.',
);
```

### 2. 캐싱 활용

```dart
class ChatService {
  final Map<String, String> _responseCache = {};
  
  Future<String> getCachedResponse(String input) async {
    // 캐시 확인
    if (_responseCache.containsKey(input)) {
      return _responseCache[input]!;
    }
    
    // GPT-4o 호출
    final response = await langchainService.getResponse(
      userMessage: input,
    );
    
    // 캐시 저장
    _responseCache[input] = response;
    return response;
  }
}
```

### 3. 병렬 처리

```dart
Future<Map<String, dynamic>> processAudioInParallel(String audioPath) async {
  // 동시에 처리
  final futures = await Future.wait([
    gpt4oAudio.analyzeAudioEmotion(audioPath), // 감정 분석
    whisperService.transcribeAudio(audioPath), // 음성 인식
  ]);
  
  final emotionData = futures[0] as Map<String, dynamic>;
  final transcription = futures[1] as String;
  
  return {
    'emotion': emotionData,
    'transcription': transcription,
  };
}
```

### 4. 음성 품질별 모델 선택

```dart
class AdaptiveTtsService {
  Future<String> generateSpeech(String text, {bool highQuality = true}) async {
    if (highQuality && text.length > 100) {
      // 긴 텍스트 + 고품질 = TTS-1-HD
      return openAiTtsService.generateSpeech(
        text: text,
        model: 'tts-1-hd',
      );
    } else {
      // 짧은 텍스트 = 일반 TTS (비용 절약)
      return openAiTtsService.generateSpeech(
        text: text,
        model: 'tts-1',
      );
    }
  }
}
```

## 🔧 문제 해결

### 1. API 응답 속도 저하

```dart
// 문제: 응답이 너무 느림
// 해결책: 타임아웃과 재시도 구현

Future<String> robustApiCall(String message) async {
  int retryCount = 0;
  const maxRetries = 3;
  
  while (retryCount < maxRetries) {
    try {
      final response = await langchainService.getResponse(
        userMessage: message,
      ).timeout(
        Duration(seconds: 30), // 30초 타임아웃
      );
      
      return response;
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries) rethrow;
      
      // 재시도 전 대기
      await Future.delayed(Duration(seconds: 2));
    }
  }
  
  throw Exception('최대 재시도 횟수 초과');
}
```

### 2. 메모리 사용량 관리

```dart
class ConversationManager {
  List<Message> _messages = [];
  static const int maxMessages = 20; // 최대 메시지 수
  
  void addMessage(Message message) {
    _messages.add(message);
    
    // 메모리 관리: 오래된 메시지 제거
    if (_messages.length > maxMessages) {
      _messages.removeRange(0, _messages.length - maxMessages);
    }
  }
  
  // 주기적 정리
  void cleanup() {
    // 오래된 오디오 파일 정리
    cleanupOldAudioFiles();
    
    // 캐시 정리
    clearResponseCache();
  }
}
```

### 3. 오프라인 지원

```dart
class HybridAiService {
  Future<String> getResponse(String message) async {
    try {
      // 온라인: GPT-4o 사용
      if (await hasInternetConnection()) {
        return await langchainService.getResponse(userMessage: message);
      }
    } catch (e) {
      print('온라인 AI 실패: $e');
    }
    
    // 오프라인: 로컬 응답
    return generateOfflineResponse(message);
  }
  
  String generateOfflineResponse(String message) {
    // 규칙 기반 응답 또는 캐시된 응답
    if (message.contains('안녕')) {
      return '안녕하세요! 현재 오프라인 모드입니다.';
    }
    return '죄송합니다. 인터넷 연결을 확인해주세요.';
  }
}
```

## 🏆 모범 사례

### 1. 사용자 경험 우선

```dart
class ChatViewModel extends ChangeNotifier {
  bool _isTyping = false;
  bool get isTyping => _isTyping;
  
  Future<void> sendMessage(String message) async {
    // 즉시 UI 반영
    addUserMessage(message);
    
    // 타이핑 표시
    _isTyping = true;
    notifyListeners();
    
    try {
      final response = await langchainService.getResponse(
        userMessage: message,
      );
      
      addAiMessage(response);
    } catch (e) {
      addErrorMessage('응답을 가져올 수 없습니다.');
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }
}
```

### 2. 점진적 기능 제공

```dart
class FeatureFlags {
  static const bool useGpt4oAudio = true;
  static const bool useHighQualityTts = true;
  
  static bool shouldUseAdvancedFeatures(User user) {
    return user.isPremium || user.isBetaTester;
  }
}

class AdaptiveAiService {
  Future<String> getResponse(String message, User user) async {
    if (FeatureFlags.shouldUseAdvancedFeatures(user)) {
      // 프리미엄: GPT-4o 전체 기능
      return await langchainService.getResponse(userMessage: message);
    } else {
      // 일반: 기본 기능
      return await openAIService.getChatResponse(
        message: message,
        conversationType: '일반',
      );
    }
  }
}
```

### 3. 에러 처리 및 로깅

```dart
class AiServiceWrapper {
  Future<String> safeGetResponse(String message) async {
    try {
      AppLogger.info('AI 요청 시작: $message');
      
      final response = await langchainService.getResponse(
        userMessage: message,
      );
      
      AppLogger.info('AI 응답 성공: ${response.length} 문자');
      return response;
      
    } on AppError catch (e) {
      AppLogger.error('AI 서비스 오류: ${e.message}');
      return '죄송합니다. 잠시 후 다시 시도해주세요.';
      
    } catch (e) {
      AppLogger.error('예상치 못한 오류: $e');
      return '서비스에 문제가 발생했습니다.';
    }
  }
}
```

### 4. 성능 모니터링

```dart
class PerformanceMonitor {
  static void trackApiCall(String service, int responseTime, bool success) {
    final metrics = {
      'service': service,
      'response_time_ms': responseTime,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // Analytics 전송 (Firebase Analytics, 등)
    FirebaseAnalytics.instance.logEvent(
      name: 'ai_api_call',
      parameters: metrics,
    );
  }
}

// 사용 예시
final stopwatch = Stopwatch()..start();
try {
  final response = await langchainService.getResponse(userMessage: message);
  PerformanceMonitor.trackApiCall('gpt4o', stopwatch.elapsedMilliseconds, true);
} catch (e) {
  PerformanceMonitor.trackApiCall('gpt4o', stopwatch.elapsedMilliseconds, false);
}
```

## 🎯 다음 단계

### 1. 실험적 기능
- **멀티모달 입력**: 이미지 + 텍스트 + 음성
- **실시간 스트리밍**: 응답을 실시간으로 스트리밍
- **개인화**: 사용자별 맞춤 AI 성격

### 2. 고급 활용
- **RAG (Retrieval-Augmented Generation)**: 외부 지식 베이스 연동
- **Fine-tuning**: 틔운이 전용 모델 학습
- **에이전트**: 복합 작업 수행 AI

### 3. 모니터링 강화
- **A/B 테스트**: 모델별 성능 비교
- **사용자 피드백**: 응답 품질 개선
- **비용 최적화**: 효율적인 모델 사용

---

🚀 **이제 GPT-4o와 GPT-4o-audio-preview의 강력한 기능을 활용하여 더욱 자연스럽고 도움이 되는 AI 상담 서비스를 제공할 수 있습니다!**

문의사항이나 추가 도움이 필요하시면 언제든 연락 주세요. 🤖✨
