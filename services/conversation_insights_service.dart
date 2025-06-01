// lib/services/conversation_insights_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'dart:convert';
import '../models/conversation_insight_model.dart'; // ConversationInsight 모델 import 추가
import '../models/conversation_model.dart' as app_models;
import '../models/message_model.dart' as app_message; // Message 모델 import 추가
import 'sentiment_analysis_service.dart';
import 'package:tiiun/services/remote_config_service.dart'; // Import RemoteConfigService

// 대화 인사이트 서비스 Provider
final conversationInsightsServiceProvider = Provider<ConversationInsightsService>((ref) {
  final sentimentService = ref.watch(sentimentAnalysisServiceProvider);
  final remoteConfigService = ref.watch(remoteConfigServiceProvider);
  final apiKey = remoteConfigService.getOpenAIApiKey(); // Get API key from Remote Config
  return ConversationInsightsService(sentimentService, apiKey);
});

class ConversationInsightsService {
  final SentimentAnalysisService _sentimentService;
  final String _apiKey; // Made final as it's passed in constructor
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // FireStore 인스턴스 추가
  late ChatOpenAI _chatModel;

  ConversationInsightsService(this._sentimentService, this._apiKey) { // Constructor takes apiKey
    _initChatModel();
  }

  // API 키 설정 (이제 필요 없지만, 기존 호출을 고려해 남겨둠)
  // void setApiKey(String apiKey) {
  //   _apiKey = apiKey;
  //   _initChatModel();
  // }

  void _initChatModel() {
    if (_apiKey.isNotEmpty) { // Check if API key is not empty
      _chatModel = ChatOpenAI(
        apiKey: _apiKey,
        model: 'gpt-3.5-turbo',
        temperature: 0.3,
        maxTokens: 1000,
      );
    }
  }

  // 대화 인사이트를 FireStore에 저장
  Future<ConversationInsight> saveInsightToFirestore(ConversationInsight insight) async {
    try {
      // 새 ID 생성 (기존 ID가 비어있는 경우)
      final docId = insight.id.isEmpty ? _firestore.collection('conversation_insights').doc().id : insight.id;
      
      final updatedInsight = insight.copyWith(id: docId);
      
      // FireStore에 저장
      await _firestore
          .collection('conversation_insights') // 스키마 컬렉션명
          .doc(docId)
          .set(updatedInsight.toFirestore());
      
      return updatedInsight;
    } catch (e) {
      throw Exception('대화 인사이트를 저장할 수 없습니다: $e');
    }
  }

  // 대화 인사이트 생성 및 저장
  Future<ConversationInsight> generateAndSaveConversationInsight({
    required String conversationId,
    required String userId,
    required List<app_message.Message> messages,
    bool toUserYn = true,
  }) async {
    try {
      // 인사이트 데이터 생성
      final summary = await generateConversationSummary(messages);
      final topics = await extractConversationTopics(messages);
      final analysisResult = await _sentimentService.analyzeConversation(messages);
      
      // ConversationInsight 객체 생성
      final insight = ConversationInsight(
        id: '', // 저장 시 ID 생성
        userId: userId,
        conversationId: conversationId,
        createdAt: DateTime.now(),
        keyTopics: topics.join(', '), // List<String>을 문자열로 변환 (스키마에 맞춰)
        overallMood: analysisResult['dominantEmotion'] ?? 'neutral',
        sentimentSummary: summary,
        toUserYn: toUserYn,
      );
      
      // FireStore에 저장
      return await saveInsightToFirestore(insight);
    } catch (e) {
      throw Exception('대화 인사이트 생성 및 저장 오류: $e');
    }
  }

  // 특정 대화의 인사이트 가져오기
  Future<List<ConversationInsight>> getInsightsByConversation(String conversationId) async {
    try {
      final snapshot = await _firestore
          .collection('conversation_insights')
          .where('conversation_id', isEqualTo: conversationId) // conversation_id
          .orderBy('created_at', descending: true) // created_at
          .get();
      
      return snapshot.docs
          .map((doc) => ConversationInsight.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // 사용자의 모든 인사이트 가져오기
  Future<List<ConversationInsight>> getInsightsByUser(String userId, {int? limit, bool? toUserYn}) async {
    try {
      Query query = _firestore
          .collection('conversation_insights')
          .where('user_id', isEqualTo: userId); // user_id
      
      if (toUserYn != null) {
        query = query.where('to_user_yn', isEqualTo: toUserYn); // to_user_yn
      }
      
      query = query.orderBy('created_at', descending: true); // created_at
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => ConversationInsight.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // 인사이트 삭제
  Future<void> deleteInsight(String insightId) async {
    try {
      await _firestore
          .collection('conversation_insights')
          .doc(insightId)
          .delete();
    } catch (e) {
      throw Exception('인사이트를 삭제할 수 없습니다: $e');
    }
  }

  // 대화 요약 생성
  Future<String> generateConversationSummary(List<app_message.Message> messages) async {
    if (_apiKey.isEmpty || messages.isEmpty) { // Check _apiKey directly
      return '대화 요약을 위한 API 키가 설정되지 않았거나 메시지가 없습니다.';
    }

    try {
      // 대화 내용 형식화
      // messages[i].content는 이미 Message 모델에서 디코딩된 상태
      String conversationText = messages.map((msg) {
        final role = msg.sender == app_message.MessageSender.user ? '사용자' : '상담사';
        return '$role: ${msg.content}';
      }).join('\n\n');

      final prompt = """
다음 상담 대화를 심리적 관점에서 분석하고 요약해주세요:

$conversationText

요약에는 다음을 포함해주세요:
1. 대화의 주요 주제와 사용자의 주요 관심사
2. 사용자의 감정 상태 변화와 주요 우려사항
3. 상담 과정에서 발견된 주요 통찰점
4. 제공된 조언과 사용자의 반응

전체적인 상담 과정의 핵심을 3-5문장으로 요약해주세요.
""";

      final chatMessages = [
        const SystemChatMessage(content: "당신은 심리 상담 대화를 분석하고 요약하는 전문가입니다. 핵심 내용과 감정적 통찰을 간결하게 요약해주세요."),
        HumanChatMessage(content: prompt),
      ];

      final result = await _chatModel.call(chatMessages);
      return result.content;
    } catch (e) {
      return '대화 요약 중 오류가 발생했습니다: $e';
    }
  }

  // 주요 대화 주제 추출
  Future<List<String>> extractConversationTopics(List<app_message.Message> messages) async {
    if (_apiKey.isEmpty || messages.isEmpty) { // Check _apiKey directly
      return ['주제를 추출할 수 없습니다'];
    }

    try {
      // 대화 내용 형식화
      // messages[i].content는 이미 Message 모델에서 디코딩된 상태
      String conversationText = messages.map((msg) {
        final role = msg.sender == app_message.MessageSender.user ? '사용자' : '상담사';
        return '$role: ${msg.content}';
      }).join('\n\n');

      final prompt = """
다음 심리 상담 대화에서 논의된 주요 주제를 5개 이내로 추출해주세요:

$conversationText

응답은 다음 형식의 JSON으로 제공해주세요:
{{
  "topics": ["주제1", "주제2", "주제3"]
}}

각 주제는 간결한 단어나 짧은 구로 표현해주세요 (예: "직장 스트레스", "가족 관계", "불안감").
""";

      final chatMessages = [
        const SystemChatMessage(content: "당신은 심리 상담 대화에서 주요 주제를 추출하는 전문가입니다."),
        HumanChatMessage(content: prompt),
      ];

      final result = await _chatModel.call(chatMessages);

      final jsonStr = result.content;
      final extractedJson = _extractJsonFromString(jsonStr);

      if (extractedJson.containsKey('topics') && extractedJson['topics'] is List) {
        return List<String>.from(extractedJson['topics']);
      }

      return ['주제를 추출할 수 없습니다'];
    } catch (e) {
      return ['주제 추출 중 오류 발생: $e'];
    }
  }

  // 맞춤형 심리적 조언 생성
  Future<Map<String, dynamic>> generatePersonalizedAdvice(
    List<app_message.Message> messages,
    {Map<String, dynamic>? userProfile}
  ) async {
    if (_apiKey.isEmpty || messages.isEmpty) { // Check _apiKey directly
      return {
        'advice': '맞춤형 조언을 생성할 수 없습니다.',
        'exercises': [],
        'resources': [],
      };
    }

    try {
      final analysisResult = await _sentimentService.analyzeConversation(messages);

      final recentMessages = messages.length > 5
          ? messages.sublist(messages.length - 5)
          : messages;

      String conversationText = recentMessages.map((msg) {
        final role = msg.sender == app_message.MessageSender.user ? '사용자' : '상담사';
        return '$role: ${msg.content}';
      }).join('\n\n');

      String userProfileText = '';
      if (userProfile != null) {
        userProfileText = """
사용자 프로필 정보:
- 연령대: ${userProfile['ageGroup'] ?? '알 수 없음'}
- 성별: ${userProfile['gender'] ?? '알 수 없음'}
- 선호하는 활동: ${userProfile['preferredActivities']?.join(', ') ?? '알 수 없음'}
- 이전 상담 경험: ${userProfile['hasPreviousCounseling'] == true ? '있음' : '없음'}
""";
      }

      final prompt = """
사용자의 심리 상담 대화와 감정 분석 결과를 바탕으로 맞춤형 심리적 조언과 연습, 자료를 제공해주세요.

$userProfileText

최근 대화 내용:
$conversationText

감정 분석 결과:
- 평균 감정 점수: ${analysisResult['averageMoodScore']}
- 주요 감정 유형: ${analysisResult['dominantEmotion']}
- 감정 변화 감지: ${analysisResult['moodChangeDetected'] ? '있음' : '없음'}

응답은 다음 형식의 JSON으로 제공해주세요:
{{
  "advice": "사용자에게 맞춤화된 심리적 조언 (3-4문장)",
  "exercises": [
    "도움이 될 수 있는 심리 연습이나 활동 1",
    "도움이 될 수 있는 심리 연습이나 활동 2",
    "도움이 될 수 있는 심리 연습이나 활동 3"
  ],
  "resources": [
    "추천 자료나 읽을거리 1",
    "추천 자료나 읽을거리 2"
  ]
}}

조언은 공감적이고 지지적이며, 현실적으로 적용 가능한 것이어야 합니다.
""";

      final chatMessages = [
        const SystemChatMessage(content: "당신은 심리 상담 전문가로서 공감적이고 맞춤화된 심리적 조언을 제공합니다."),
        HumanChatMessage(content: prompt),
      ];

      final result = await _chatModel.call(chatMessages);

      final jsonStr = result.content;
      final extractedJson = _extractJsonFromString(jsonStr);

      return {
        'advice': extractedJson['advice'] ?? '맞춤형 조언을 생성할 수 없습니다.',
        'exercises': extractedJson['exercises'] ?? [],
        'resources': extractedJson['resources'] ?? [],
      };
    } catch (e) {
      return {
        'advice': '맞춤형 조언 생성 중 오류가 발생했습니다.',
        'exercises': [],
        'resources': [],
        'error': e.toString(),
      };
    }
  }

  // 대화 패턴 및 진행 상황 분석
  Future<Map<String, dynamic>> analyzeConversationProgress(List<app_models.Conversation> conversations) async {
    if (_apiKey.isEmpty || conversations.isEmpty) { // Check _apiKey directly
      return {
        'progressSummary': '대화 진행 상황을 분석할 수 없습니다.',
        'patterns': [],
        'recommendations': [],
      };
    }

    try {
      List<Map<String, dynamic>> conversationData = [];

      for (final conversation in conversations) {
        // conversation.title, conversation.summary 등은 Conversation 모델에서 이미 디코딩된 상태
        conversationData.add({
          'title': conversation.title,
          'createdAt': conversation.createdAt.toString(),
          'messageCount': conversation.messageCount,
          'averageMoodScore': conversation.averageMoodScore ?? 0.0,
          'moodChangeDetected': conversation.moodChangeDetected ?? false,
          'summary': conversation.summary ?? '요약 없음',
          'tags': conversation.tags.join(', '),
        });
      }

      final prompt = """
다음 사용자의 여러 상담 대화 정보를 분석하여 심리적 패턴과 진행 상황을 평가해주세요:

${jsonEncode(conversationData)}

응답은 다음 형식의 JSON으로 제공해주세요:
{{
  "progressSummary": "사용자의 전반적인 심리적 진행 상황에 대한 요약 (3-4문장)",
  "patterns": [
    "발견된 심리적 패턴 1",
    "발견된 심리적 패턴 2",
    "발견된 심리적 패턴 3"
  ],
  "recommendations": [
    "향후 상담 방향에 대한 추천 1",
    "향후 상담 방향에 대한 추천 2"
  ]
}}

패턴 분석에는 특정 주제의 반복, 감정 변화 패턴, 대화 참여도 등이 포함될 수 있습니다.
""";

      final chatMessages = [
        const SystemChatMessage(content: "당신은 심리 상담 패턴을 분석하고 진행 상황을 평가하는 전문가입니다."),
        HumanChatMessage(content: prompt),
      ];

      final result = await _chatModel.call(chatMessages);

      final jsonStr = result.content;
      final extractedJson = _extractJsonFromString(jsonStr);

      return {
        'progressSummary': extractedJson['progressSummary'] ?? '진행 상황을 분석할 수 없습니다.',
        'patterns': extractedJson['patterns'] ?? [],
        'recommendations': extractedJson['recommendations'] ?? [],
      };
    } catch (e) {
      return {
        'progressSummary': '대화 진행 상황 분석 중 오류가 발생했습니다.',
        'patterns': [],
        'resources': [],
        'error': e.toString(),
      };
    }
  }

  // 문자열에서 JSON 추출
  Map<String, dynamic> _extractJsonFromString(String text) {
    try {
      final regex = RegExp(r'{[\s\S]*}');
      final match = regex.firstMatch(text);

      if (match != null) {
        final jsonStr = match.group(0);
        if (jsonStr != null) {
          return jsonDecode(jsonStr);
        }
      }

      return {};
    } catch (e) {
      return {};
    }
  }
}