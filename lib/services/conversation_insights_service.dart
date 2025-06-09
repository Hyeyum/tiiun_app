// lib/services/conversation_insights_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'dart:convert';
import '../models/conversation_insight_model.dart'; // ConversationInsight 모델 import 추가
import '../models/conversation_analysis_model.dart'; // 새로운 분석 모델
import '../models/personalized_advice_model.dart'; // 새로운 조언 모델
import '../models/conversation_summary_model.dart'; // 새로운 요약 모델
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
        model: 'gpt-4o', // 🚀 UPGRADED: gpt-3.5-turbo -> gpt-4o
        temperature: 0.3,
        maxTokens: 1200, // 🔥 INCREASED: 1000 -> 1200 for better insights
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

  // ================================
  // 새로운 고급 분석 메서드들
  // ================================

  /// 종합적 대화 분석 수행
  Future<ConversationAnalysisModel> generateComprehensiveAnalysis({
    required String conversationId,
    required String userId,
    required List<app_message.Message> messages,
    Map<String, dynamic>? userProfile,
  }) async {
    if (_apiKey.isEmpty || messages.isEmpty) {
      return _createEmptyAnalysis(conversationId, userId);
    }

    try {
      // 병렬로 여러 분석 수행
      final analysisResults = await Future.wait([
        _analyzeEmotionPattern(messages),
        _analyzeTopics(messages),
        _analyzeUserGrowth(messages, userProfile),
        _analyzeConversationQuality(messages),
        _analyzePersonalizationFactors(messages, userProfile),
      ]);

      return ConversationAnalysisModel(
        id: '',
        conversationId: conversationId,
        userId: userId,
        createdAt: DateTime.now(),
        emotionPattern: analysisResults[0] as EmotionPatternAnalysis,
        topicAnalysis: analysisResults[1] as TopicAnalysis,
        growthIndicators: analysisResults[2] as UserGrowthIndicators,
        qualityMetrics: analysisResults[3] as ConversationQualityMetrics,
        personalizationFactors: analysisResults[4] as PersonalizationFactors,
      );
    } catch (e) {
      print('종합 분석 오류: $e');
      return _createEmptyAnalysis(conversationId, userId);
    }
  }

  /// 근거 기반 맞춤형 조언 생성
  Future<PersonalizedAdviceModel> generatePersonalizedAdviceWithEvidence({
    required String conversationId,
    required String userId,
    required List<app_message.Message> messages,
    required ConversationAnalysisModel analysis,
    Map<String, dynamic>? userProfile,
  }) async {
    if (_apiKey.isEmpty || messages.isEmpty) {
      return _createEmptyAdvice(conversationId, userId);
    }

    try {
      // 조언 생성을 위한 컨텍스트 준비
      final context = _prepareAdviceContext(messages, analysis, userProfile);

      final prompt = """
다음 정보를 바탕으로 구체적이고 근거 있는 맞춤형 조언을 생성해주세요:

대화 분석 결과:
- 감정 패턴: ${analysis.emotionPattern.overallTrend}
- 주요 주제들: ${analysis.topicAnalysis.mainTopics.join(', ')}
- 성장 지표: 자기인식 ${analysis.growthIndicators.selfAwarenessLevel}/10
- 대화 품질: ${analysis.qualityMetrics.engagementScore}/10

사용자 특성:
- 연령대: ${analysis.personalizationFactors.ageGroup}
- 의사소통 스타일: ${analysis.personalizationFactors.communicationStyle}

최근 대화 내용:
$context

다음 JSON 형식으로 응답해주세요:
{
  "coreMessage": "핵심 조언 (2-3문장)",
  "detailedExplanation": "상세 설명 (왜 이런 조언을 하는지)",
  "expectedOutcome": "예상되는 효과",
  "timeframe": "적용 시기 (immediate/short_term/long_term)",
  "difficulty": "난이도 (easy/medium/hard)",
  "actionableRecommendations": [
    {
      "title": "추천사항 제목",
      "description": "설명",
      "steps": ["단계1", "단계2", "단계3"],
      "category": "카테고리",
      "estimatedDurationMinutes": 15,
      "priority": 5,
      "effectivenessScore": 8
    }
  ],
  "recommendedResources": [
    {
      "title": "리소스 제목",
      "description": "설명",
      "type": "book/article/video/app",
      "relatedTopics": ["주제1", "주제2"],
      "recommendationReason": "추천 이유"
    }
  ],
  "rationale": {
    "identifiedIssues": ["발견된 이슈들"],
    "emotionPatternEvidence": "감정 패턴 근거",
    "conversationEvidence": ["대화 내용 근거들"],
    "profileConsiderations": ["프로필 고려사항들"],
    "theoreticalBasis": "이론적 근거",
    "successProbability": 8
  }
}
""";

      final chatMessages = [
        const SystemChatMessage(content: "당신은 심리학 박사이자 상담 전문가입니다. 근거 기반의 맞춤형 조언을 제공해주세요."),
        HumanChatMessage(content: prompt),
      ];

      final result = await _chatModel.call(chatMessages);
      final jsonData = _extractJsonFromString(result.content);

      return _parseAdviceFromJson(jsonData, conversationId, userId);
    } catch (e) {
      print('맞춤형 조언 생성 오류: $e');
      return _createEmptyAdvice(conversationId, userId);
    }
  }

  /// 상세한 대화 요약 생성
  Future<ConversationSummaryModel> generateDetailedSummary({
    required String conversationId,
    required String userId,
    required List<app_message.Message> messages,
    required ConversationAnalysisModel analysis,
  }) async {
    if (_apiKey.isEmpty || messages.isEmpty) {
      return _createEmptySummary(conversationId, userId);
    }

    try {
      final conversationText = messages.map((msg) {
        final role = msg.sender == app_message.MessageSender.user ? '사용자' : '상담사';
        return '$role: ${msg.content}';
      }).join('\n\n');

      final prompt = """
다음 대화를 분석하여 구조화된 요약을 생성해주세요:

$conversationText

분석 정보:
- 감정 변화: ${analysis.emotionPattern.overallTrend}
- 주요 주제: ${analysis.topicAnalysis.mainTopics.join(', ')}
- 대화 품질: ${analysis.qualityMetrics.engagementScore}/10

다음 JSON 형식으로 응답해주세요:
{
  "overview": {
    "title": "대화 제목",
    "oneLinerSummary": "한 줄 요약",
    "durationMinutes": 30,
    "messageCount": ${messages.length},
    "conversationType": "initial/follow_up/crisis/celebration",
    "overallTone": "supportive/exploratory/challenging"
  },
  "keyDiscussions": [
    {
      "topic": "논의 주제",
      "summary": "내용 요약",
      "importance": 8,
      "resolutionStatus": "resolved/partially_resolved/unresolved",
      "relatedEmotions": ["감정들"],
      "discussionOrder": 1
    }
  ],
  "emotionalJourney": {
    "startingState": {
      "primaryEmotion": "초기 감정",
      "intensity": 6,
      "description": "상태 설명",
      "score": 0.6
    },
    "endingState": {
      "primaryEmotion": "최종 감정",
      "intensity": 7,
      "description": "상태 설명",
      "score": 0.7
    },
    "journeySummary": "감정 변화 요약",
    "biggestEmotionalShift": "가장 큰 변화"
  },
  "keyInsights": [
    {
      "content": "인사이트 내용",
      "category": "self_awareness/emotional_regulation/relationships",
      "importance": 9,
      "supportingEvidence": ["근거들"],
      "applicability": "immediate/short_term/long_term"
    }
  ],
  "achievements": [
    {
      "description": "달성한 것",
      "type": "insight/breakthrough/skill_development",
      "completionLevel": 8,
      "significance": "의미"
    }
  ],
  "nextSteps": {
    "shortTermGoals": ["단기 목표들"],
    "longTermGoals": ["장기 목표들"],
    "recommendedActivities": ["추천 활동들"],
    "monitoringPoints": ["관찰 사항들"],
    "suggestedTopicsForNextSession": ["다음 세션 주제들"]
  },
  "overallAssessment": {
    "effectivenessScore": 8,
    "engagementScore": 9,
    "progressScore": 7,
    "assessmentSummary": "전체 평가 요약",
    "strengths": ["강점들"],
    "areasForImprovement": ["개선 영역들"]
  }
}
""";

      final chatMessages = [
        const SystemChatMessage(content: "당신은 심리 상담 요약 전문가입니다. 구조화되고 통찰력 있는 요약을 제공해주세요."),
        HumanChatMessage(content: prompt),
      ];

      final result = await _chatModel.call(chatMessages);
      final jsonData = _extractJsonFromString(result.content);

      return _parseSummaryFromJson(jsonData, conversationId, userId);
    } catch (e) {
      print('상세 요약 생성 오류: $e');
      return _createEmptySummary(conversationId, userId);
    }
  }

  // ================================
  // 헬퍼 메서드들
  // ================================

  Future<EmotionPatternAnalysis> _analyzeEmotionPattern(List<app_message.Message> messages) async {
    try {
      final emotionTrends = await _sentimentService.trackEmotionTrends(messages);

      if (emotionTrends.isEmpty) {
        return _createEmptyEmotionPattern();
      }

      final startingScore = emotionTrends.first['avgScore'] as double;
      final endingScore = emotionTrends.last['avgScore'] as double;
      final averageScore = emotionTrends
          .map((e) => e['avgScore'] as double)
          .reduce((a, b) => a + b) / emotionTrends.length;

      String overallTrend = 'stable';
      if (endingScore > startingScore + 0.2) {
        overallTrend = 'improving';
      } else if (endingScore < startingScore - 0.2) {
        overallTrend = 'declining';
      }

      // 변동성 계산
      double volatility = 0.0;
      for (int i = 1; i < emotionTrends.length; i++) {
        final prev = emotionTrends[i - 1]['avgScore'] as double;
        final curr = emotionTrends[i]['avgScore'] as double;
        volatility += (curr - prev).abs();
      }
      volatility = volatility / (emotionTrends.length - 1);

      String volatilityLevel = 'low';
      if (volatility > 0.3) {
        volatilityLevel = 'high';
      } else if (volatility > 0.15) {
        volatilityLevel = 'medium';
      }

      final dominantEmotions = emotionTrends
          .map((e) => e['dominantEmotion'] as String)
          .toSet()
          .toList();

      return EmotionPatternAnalysis(
        overallTrend: overallTrend,
        volatility: volatilityLevel,
        dominantEmotions: dominantEmotions,
        turningPoints: [],
        startingScore: startingScore,
        endingScore: endingScore,
        averageScore: averageScore,
      );
    } catch (e) {
      return _createEmptyEmotionPattern();
    }
  }

  Future<TopicAnalysis> _analyzeTopics(List<app_message.Message> messages) async {
    try {
      final topics = await extractConversationTopics(messages);

      return TopicAnalysis(
        mainTopics: topics,
        topicEmotionMapping: {},
        topicProgression: topics,
        resolvedTopics: [],
        ongoingConcerns: topics,
      );
    } catch (e) {
      return TopicAnalysis(
        mainTopics: ['일반'],
        topicEmotionMapping: {},
        topicProgression: [],
        resolvedTopics: [],
        ongoingConcerns: [],
      );
    }
  }

  Future<UserGrowthIndicators> _analyzeUserGrowth(List<app_message.Message> messages, Map<String, dynamic>? userProfile) async {
    // 사용자 메시지 내용 분석을 통한 성장 지표 추정
    final userMessages = messages
        .where((msg) => msg.sender == app_message.MessageSender.user)
        .map((msg) => msg.content.toLowerCase())
        .join(' ');

    int selfAwarenessLevel = 5;
    int emotionalRegulationLevel = 5;
    int problemSolvingImprovement = 5;
    int communicationSkillDevelopment = 5;

    // 키워드 기반 분석
    if (userMessages.contains(RegExp(r'느끼|생각|깨달|알겠|이해'))) {
      selfAwarenessLevel = 7;
    }
    if (userMessages.contains(RegExp(r'조절|관리|차분|안정|진정'))) {
      emotionalRegulationLevel = 7;
    }
    if (userMessages.contains(RegExp(r'해결|방법|계획|시도|노력'))) {
      problemSolvingImprovement = 7;
    }
    if (userMessages.contains(RegExp(r'표현|말하|소통|대화|전달'))) {
      communicationSkillDevelopment = 7;
    }

    return UserGrowthIndicators(
      selfAwarenessLevel: selfAwarenessLevel,
      emotionalRegulationLevel: emotionalRegulationLevel,
      problemSolvingImprovement: problemSolvingImprovement,
      communicationSkillDevelopment: communicationSkillDevelopment,
      positiveChangeAreas: ['자기 인식', '감정 표현'],
      improvementNeededAreas: ['스트레스 관리', '목표 설정'],
    );
  }

  Future<ConversationQualityMetrics> _analyzeConversationQuality(List<app_message.Message> messages) async {
    final userMessages = messages.where((msg) => msg.sender == app_message.MessageSender.user).toList();

    // 참여도: 사용자 메시지 길이와 개수로 계산
    final avgMessageLength = userMessages.isEmpty ? 0 :
    userMessages.map((msg) => msg.content.length).reduce((a, b) => a + b) / userMessages.length;
    final engagementScore = (avgMessageLength / 50).clamp(1, 10).round();

    // 개방성: 감정 표현 키워드로 계산
    final emotionKeywords = ['느끼', '생각', '마음', '감정', '기분', '슬프', '기쁘', '화나', '불안'];
    final emotionMentions = userMessages
        .map((msg) => emotionKeywords.where((kw) => msg.content.contains(kw)).length)
        .reduce((a, b) => a + b);
    final opennessScore = (emotionMentions / userMessages.length * 10).clamp(1, 10).round();

    return ConversationQualityMetrics(
      engagementScore: engagementScore,
      opennessScore: opennessScore,
      depthScore: 6,
      consistencyScore: 7,
      flowQuality: 7,
    );
  }

  Future<PersonalizationFactors> _analyzePersonalizationFactors(List<app_message.Message> messages, Map<String, dynamic>? userProfile) async {
    return PersonalizationFactors(
      ageGroup: userProfile?['ageGroup'] ?? 'unknown',
      gender: userProfile?['gender'] ?? 'unknown',
      preferredActivities: List<String>.from(userProfile?['preferredActivities'] ?? []),
      mainInterests: [],
      communicationStyle: 'balanced',
      stressCopingStyle: 'adaptive',
    );
  }

  String _prepareAdviceContext(List<app_message.Message> messages, ConversationAnalysisModel analysis, Map<String, dynamic>? userProfile) {
    final recentMessages = messages.length > 3
        ? messages.sublist(messages.length - 3)
        : messages;

    return recentMessages.map((msg) {
      final role = msg.sender == app_message.MessageSender.user ? '사용자' : '상담사';
      return '$role: ${msg.content}';
    }).join('\n\n');
  }

  // 빈 객체 생성 메서드들
  ConversationAnalysisModel _createEmptyAnalysis(String conversationId, String userId) {
    return ConversationAnalysisModel(
      id: '',
      conversationId: conversationId,
      userId: userId,
      createdAt: DateTime.now(),
      emotionPattern: _createEmptyEmotionPattern(),
      topicAnalysis: TopicAnalysis(
        mainTopics: ['일반'],
        topicEmotionMapping: {},
        topicProgression: [],
        resolvedTopics: [],
        ongoingConcerns: [],
      ),
      growthIndicators: UserGrowthIndicators(
        selfAwarenessLevel: 5,
        emotionalRegulationLevel: 5,
        problemSolvingImprovement: 5,
        communicationSkillDevelopment: 5,
        positiveChangeAreas: [],
        improvementNeededAreas: [],
      ),
      qualityMetrics: ConversationQualityMetrics(
        engagementScore: 5,
        opennessScore: 5,
        depthScore: 5,
        consistencyScore: 5,
        flowQuality: 5,
      ),
      personalizationFactors: PersonalizationFactors(
        ageGroup: 'unknown',
        gender: 'unknown',
        preferredActivities: [],
        mainInterests: [],
        communicationStyle: 'balanced',
        stressCopingStyle: 'adaptive',
      ),
    );
  }

  EmotionPatternAnalysis _createEmptyEmotionPattern() {
    return EmotionPatternAnalysis(
      overallTrend: 'stable',
      volatility: 'medium',
      dominantEmotions: ['neutral'],
      turningPoints: [],
      startingScore: 0.5,
      endingScore: 0.5,
      averageScore: 0.5,
    );
  }

  PersonalizedAdviceModel _createEmptyAdvice(String conversationId, String userId) {
    return PersonalizedAdviceModel(
      id: '',
      conversationId: conversationId,
      userId: userId,
      createdAt: DateTime.now(),
      mainAdvice: AdviceContent(
        coreMessage: '현재 조언을 생성할 수 없습니다.',
        detailedExplanation: '',
        expectedOutcome: '',
        timeframe: 'immediate',
        difficulty: 'medium',
      ),
      actionableRecommendations: [],
      recommendedResources: [],
      rationale: AdviceRationale(
        identifiedIssues: [],
        emotionPatternEvidence: '',
        conversationEvidence: [],
        profileConsiderations: [],
        theoreticalBasis: '',
        successProbability: 5,
      ),
      personalization: AdvicePersonalization(
        personalizationAreas: [],
        userCharacteristics: {},
        preferenceConsiderations: [],
        historicalResponsePattern: 'unknown',
        culturalConsiderations: [],
      ),
      priorityScore: 5,
    );
  }

  ConversationSummaryModel _createEmptySummary(String conversationId, String userId) {
    return ConversationSummaryModel(
      id: '',
      conversationId: conversationId,
      userId: userId,
      createdAt: DateTime.now(),
      overview: ConversationOverview(
        title: '대화 요약',
        oneLinerSummary: '요약을 생성할 수 없습니다.',
        durationMinutes: 0,
        messageCount: 0,
        conversationType: 'general',
        overallTone: 'neutral',
      ),
      keyDiscussions: [],
      emotionalJourney: EmotionalJourney(
        startingState: EmotionalState(
          primaryEmotion: 'neutral',
          intensity: 5,
          description: '',
          score: 0.5,
        ),
        endingState: EmotionalState(
          primaryEmotion: 'neutral',
          intensity: 5,
          description: '',
          score: 0.5,
        ),
        milestones: [],
        journeySummary: '',
        biggestEmotionalShift: '',
      ),
      keyInsights: [],
      achievements: [],
      nextSteps: NextSteps(
        shortTermGoals: [],
        longTermGoals: [],
        recommendedActivities: [],
        monitoringPoints: [],
        suggestedTopicsForNextSession: [],
      ),
      overallAssessment: OverallAssessment(
        effectivenessScore: 5,
        engagementScore: 5,
        progressScore: 5,
        assessmentSummary: '',
        strengths: [],
        areasForImprovement: [],
      ),
    );
  }

  PersonalizedAdviceModel _parseAdviceFromJson(Map<String, dynamic> jsonData, String conversationId, String userId) {
    try {
      return PersonalizedAdviceModel(
        id: '',
        conversationId: conversationId,
        userId: userId,
        createdAt: DateTime.now(),
        mainAdvice: AdviceContent(
          coreMessage: jsonData['coreMessage'] ?? '조언을 생성할 수 없습니다.',
          detailedExplanation: jsonData['detailedExplanation'] ?? '',
          expectedOutcome: jsonData['expectedOutcome'] ?? '',
          timeframe: jsonData['timeframe'] ?? 'immediate',
          difficulty: jsonData['difficulty'] ?? 'medium',
        ),
        actionableRecommendations: (jsonData['actionableRecommendations'] as List<dynamic>?)
            ?.map((ar) => ActionableRecommendation.fromMap(ar))
            .toList() ?? [],
        recommendedResources: (jsonData['recommendedResources'] as List<dynamic>?)
            ?.map((rr) => RecommendedResource.fromMap(rr))
            .toList() ?? [],
        rationale: AdviceRationale.fromMap(jsonData['rationale'] ?? {}),
        personalization: AdvicePersonalization(
          personalizationAreas: [],
          userCharacteristics: {},
          preferenceConsiderations: [],
          historicalResponsePattern: 'unknown',
          culturalConsiderations: [],
        ),
        priorityScore: 7,
      );
    } catch (e) {
      return _createEmptyAdvice(conversationId, userId);
    }
  }

  ConversationSummaryModel _parseSummaryFromJson(Map<String, dynamic> jsonData, String conversationId, String userId) {
    try {
      return ConversationSummaryModel.fromMap({
        'id': '',
        'conversation_id': conversationId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
        ...jsonData,
      });
    } catch (e) {
      return _createEmptySummary(conversationId, userId);
    }
  }
}