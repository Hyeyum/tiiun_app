// lib/services/sentiment_analysis_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'dart:convert';
import 'dart:math';
import 'langchain_service.dart';
import '../models/conversation_model.dart' as app_models;
import '../models/message_model.dart' as app_message; // Message 모델 import with prefix
import '../models/sentiment_analysis_result_model.dart'; // SentimentAnalysisResult 모델 추가
import 'package:tiiun/services/remote_config_service.dart';
import 'package:tiiun/utils/error_handler.dart'; // Import ErrorHandler
import 'package:tiiun/utils/logger.dart'; // Import AppLogger

// 감정 분석 서비스 Provider
final sentimentAnalysisServiceProvider = Provider<SentimentAnalysisService>((ref) {
  final langchainService = ref.watch(langchainServiceProvider);
  final remoteConfigService = ref.watch(remoteConfigServiceProvider);
  final apiKey = remoteConfigService.getOpenAIApiKey();
  return SentimentAnalysisService(langchainService, apiKey);
});

class SentimentAnalysisService {
  final LangchainService _langchainService;
  final String? _apiKey; // Made final as it's passed in constructor
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // FireStore 인스턴스 추가
  ChatOpenAI? _chatModel;

  SentimentAnalysisService(this._langchainService, this._apiKey) {
    _initChatModel();
  }

  void _initChatModel() {
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      _chatModel = ChatOpenAI(
        apiKey: _apiKey,
        model: 'gpt-4o', // 🚀 UPGRADED: gpt-3.5-turbo -> gpt-4o
        temperature: 0.3,
        maxTokens: 600, // 🔥 INCREASED: 500 -> 600 for better analysis
      );
      AppLogger.debug('SentimentAnalysisService: ChatOpenAI model initialized.');
    } else {
      AppLogger.warning('SentimentAnalysisService: OpenAI API key is missing. Sentiment analysis will be limited.');
    }
  }

  // 텍스트 감정 분석 -> SentimentAnalysisResult 반환
  Future<SentimentAnalysisResult> analyzeSentiment(String text, String? conversationId, String userId) async {
    return ErrorHandler.safeFuture(() async { // Use safeFuture for consistent error handling
      if (_chatModel == null) {
        AppLogger.warning('SentimentAnalysisService: Cannot analyze sentiment, chat model not initialized.');
        // 스키마에 맞는 기본 SentimentAnalysisResult 반환
        return SentimentAnalysisResult(
          id: '',
          userId: userId,
          conversationId: conversationId,
          analyzedAt: DateTime.now(),
          confidence: '0.0', // 문자열로 수정
          emotionType: 'neutral',
          sentimentalLabel: 'neutral',
        );
      }
      final result = await _langchainService.analyzeSentimentWithLangChain(text);

      // SentimentAnalysisResult 객체 생성 및 반환
      return SentimentAnalysisResult(
        id: '', // ID는 Firestore 저장 시 생성
        userId: userId,
        conversationId: conversationId,
        analyzedAt: DateTime.now(),
        confidence: (result['confidence']?.toDouble() ?? 0.5).toString(), // 문자열로 변환
        emotionType: result['emotionType'] ?? 'neutral',
        sentimentalLabel: result['label'] ?? 'neutral', // label -> sentimental_label
      );
    });
  }

  // 감정 분석 결과를 FireStore에 저장
  Future<SentimentAnalysisResult> saveSentimentToFirestore(SentimentAnalysisResult result) async {
    return ErrorHandler.safeFuture(() async {
      try {
        // 새 ID 생성 (기존 ID가 비어있는 경우)
        final docId = result.id.isEmpty ? _firestore.collection('sentiment_analysis').doc().id : result.id;

        final updatedResult = result.copyWith(id: docId);

        // FireStore에 저장
        await _firestore
            .collection('sentiment_analysis') // 스키마 컬렉션명
            .doc(docId)
            .set(updatedResult.toFirestore());

        AppLogger.debug('SentimentAnalysisService: Saved to Firestore - $docId');
        return updatedResult;
      } catch (e) {
        AppLogger.error('SentimentAnalysisService: Failed to save to Firestore - $e');
        throw Exception('감정 분석 결과를 저장할 수 없습니다: $e');
      }
    });
  }

  // 감정 분석 및 FireStore 저장을 한번에 수행
  Future<SentimentAnalysisResult> analyzeAndSaveSentiment(String text, String? conversationId, String userId) async {
    final result = await analyzeSentiment(text, conversationId, userId);
    return await saveSentimentToFirestore(result);
  }

  // 특정 대화의 감정 분석 결과들 가져오기
  Future<List<SentimentAnalysisResult>> getSentimentsByConversation(String conversationId) async {
    return ErrorHandler.safeFuture(() async {
      try {
        final snapshot = await _firestore
            .collection('sentiment_analysis')
            .where('conversation_id', isEqualTo: conversationId) // conversation_id
            .orderBy('analyzed_at', descending: true) // analyzed_at
            .get();

        return snapshot.docs
            .map((doc) => SentimentAnalysisResult.fromFirestore(doc))
            .toList();
      } catch (e) {
        AppLogger.error('SentimentAnalysisService: Failed to get sentiments by conversation - $e');
        return [];
      }
    });
  }

  // 사용자의 모든 감정 분석 결과 가져오기
  Future<List<SentimentAnalysisResult>> getSentimentsByUser(String userId, {int? limit}) async {
    return ErrorHandler.safeFuture(() async {
      try {
        Query query = _firestore
            .collection('sentiment_analysis')
            .where('user_id', isEqualTo: userId) // user_id
            .orderBy('analyzed_at', descending: true); // analyzed_at

        if (limit != null) {
          query = query.limit(limit);
        }

        final snapshot = await query.get();

        return snapshot.docs
            .map((doc) => SentimentAnalysisResult.fromFirestore(doc))
            .toList();
      } catch (e) {
        AppLogger.error('SentimentAnalysisService: Failed to get sentiments by user - $e');
        return [];
      }
    });
  }

  // 대화 전체 감정 분석 및 요약
  Future<Map<String, dynamic>> analyzeConversation(List<app_message.Message> messages) async {
    return ErrorHandler.safeFuture(() async { // Use safeFuture
      if (messages.isEmpty) {
        return {
          'averageMoodScore': 0.0,
          'dominantEmotion': 'neutral',
          'moodChangeDetected': false,
          'summary': '대화 내용이 없습니다.',
        };
      }

      if (_chatModel == null) {
        AppLogger.warning('SentimentAnalysisService: Cannot analyze conversation, chat model not initialized.');
        return {
          'averageMoodScore': 0.0,
          'dominantEmotion': 'neutral',
          'moodChangeDetected': false,
          'summary': 'API 키가 설정되지 않아 대화 분석을 수행할 수 없습니다.',
          'error': 'API key not set for sentiment analysis.',
        };
      }

      // 사용자 메시지만 필터링
      final userMessages = messages
          .where((msg) => msg.sender == app_message.MessageSender.user)
          .toList();

      if (userMessages.isEmpty) {
        return {
          'averageMoodScore': 0.0,
          'dominantEmotion': 'neutral',
          'moodChangeDetected': false,
          'summary': '사용자 메시지가 없습니다.',
        };
      }

      // 각 메시지의 감정 분석
      List<double> sentimentScores = [];
      List<String> emotionTypes = [];
      String? currentUserId = messages.first.userId; // 메시지에서 userId 가져오기

      for (final message in userMessages) {
        SentimentAnalysisResult sentiment; // MessageSentiment 대신 SentimentAnalysisResult 사용

        if (message.sentiment != null) {
          // Message 내부의 sentiment 필드 (SentimentAnalysisResult 타입)를 그대로 사용
          sentiment = message.sentiment!;
        } else {
          sentiment = await analyzeSentiment(message.content, message.conversationId, currentUserId ?? '');
        }

        sentimentScores.add(double.parse(sentiment.confidence)); // 문자열을 double로 변환
        if (sentiment.emotionType != null) {
          emotionTypes.add(sentiment.emotionType);
        }
      }

      final averageMoodScore = sentimentScores.isNotEmpty
          ? sentimentScores.reduce((a, b) => a + b) / sentimentScores.length
          : 0.0;

      String dominantEmotion = 'neutral';
      if (emotionTypes.isNotEmpty) {
        final emotionCounts = <String, int>{};
        for (final emotion in emotionTypes) {
          emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
        }

        int maxCount = 0;
        for (final entry in emotionCounts.entries) {
          if (entry.value > maxCount) {
            maxCount = entry.value;
            dominantEmotion = entry.key;
          }
        }
      }

      bool moodChangeDetected = false;
      if (sentimentScores.length >= 3) {
        final firstThreeAvg = sentimentScores.sublist(0, min(3, sentimentScores.length))
            .reduce((a, b) => a + b) / min(3, sentimentScores.length);

        final lastThreeAvg = sentimentScores.sublist(max(0, sentimentScores.length - 3))
            .reduce((a, b) => a + b) / min(3, sentimentScores.length);

        moodChangeDetected = (lastThreeAvg - firstThreeAvg).abs() >= 0.3;
      }

      String summary = await _summarizeConversation(messages);

      return {
        'averageMoodScore': averageMoodScore,
        'dominantEmotion': dominantEmotion,
        'moodChangeDetected': moodChangeDetected,
        'summary': summary,
      };
    });
  }

  // 대화 요약
  Future<String> _summarizeConversation(List<app_message.Message> messages) async {
    return ErrorHandler.safeFuture(() async { // Use safeFuture
      if (_chatModel == null || messages.isEmpty) {
        return '대화 요약을 생성할 수 없습니다.';
      }

      final chatMessages = messages.map((msg) {
        final role = msg.sender == app_message.MessageSender.user ? '사용자' : '상담사';
        return '$role: ${msg.content}';
      }).join('\n\n');

      final prompt = """
다음 대화를 간결하게 요약해주세요:

$chatMessages

요약에는 다음을 포함해주세요:
1. 대화의 주요 주제
2. 사용자의 주요 감정 상태나 우려사항
3. 주요 논의 사항이나 발견된 통찰
4. 상담에서 나온 중요한 조언이나 제안

핵심적인 내용을 3-4문장으로 요약해주세요.
""";

      const systemMsg = SystemChatMessage(content: "당신은 심리 상담 대화를 요약하는 전문가입니다. 핵심 내용과 감정적 통찰을 간결하게 요약해주세요.");
      final humanMsg = HumanChatMessage(content: prompt);

      final result = await _chatModel!.call([systemMsg, humanMsg]);
      return result.content;
    });
  }

  // 사용자 감정 추적 및 분석
  Future<List<Map<String, dynamic>>> trackEmotionTrends(
      List<app_message.Message> messages,
      {int windowSize = 3}
      ) async {
    return ErrorHandler.safeFuture(() async { // Use safeFuture
      if (messages.isEmpty) {
        return [];
      }
      if (_chatModel == null) {
        AppLogger.warning("SentimentAnalysisService: _chatModel is null for trackEmotionTrends.");
        return [];
      }

      final userMessages = messages
          .where((msg) => msg.sender == app_message.MessageSender.user)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (userMessages.isEmpty) {
        return [];
      }

      List<Map<String, dynamic>> emotionData = [];
      String? currentUserId = messages.first.userId; // 메시지에서 userId 가져오기

      for (final message in userMessages) {
        SentimentAnalysisResult sentiment; // MessageSentiment 대신 SentimentAnalysisResult 사용

        if (message.sentiment != null) {
          // Message 내부의 sentiment 필드 (SentimentAnalysisResult 타입)를 SentimentAnalysisResult로 변환
          sentiment = SentimentAnalysisResult(
            id: message.sentiment!.id, // id 추가
            userId: currentUserId ?? '',
            conversationId: message.conversationId,
            analyzedAt: message.createdAt,
            confidence: message.sentiment!.confidence, // confidence 사용
            emotionType: message.sentiment!.emotionType,
            sentimentalLabel: message.sentiment!.sentimentalLabel, // sentimentalLabel 사용
          );
        } else {
          sentiment = await analyzeSentiment(message.content, message.conversationId, currentUserId ?? '');
        }

        emotionData.add({
          'timestamp': message.createdAt,
          'score': double.parse(sentiment.confidence), // 문자열을 double로 변환
          'label': sentiment.sentimentalLabel, // sentimentalLabel 사용
          'emotionType': sentiment.emotionType,
          'message': message.content,
        });
      }

      List<Map<String, dynamic>> trends = [];

      for (int i = 0; i < emotionData.length; i++) {
        final start = max(0, i - windowSize + 1);
        final window = emotionData.sublist(start, i + 1);

        final avgScore = window
            .map((e) => e['score'] as double)
            .reduce((a, b) => a + b) / window.length;

        final emotionTypes = window.map((e) => e['emotionType'] as String).toList();
        final emotionCounts = <String, int>{};

        for (final type in emotionTypes) {
          emotionCounts[type] = (emotionCounts[type] ?? 0) + 1;
        }

        String dominantEmotion = 'neutral';
        int maxCount = 0;

        for (final entry in emotionCounts.entries) {
          if (entry.value > maxCount) {
            maxCount = entry.value;
            dominantEmotion = entry.key;
          }
        }

        trends.add({
          'timestamp': emotionData[i]['timestamp'],
          'avgScore': avgScore,
          'dominantEmotion': dominantEmotion,
          'message': emotionData[i]['message'],
        });
      }

      return trends;
    });
  }

  // 사용자 감정 변화 감지 및 개선 제안
  Future<Map<String, dynamic>> generateEmotionalInsights(List<app_message.Message> messages) async {
    return ErrorHandler.safeFuture(() async { // Use safeFuture
      if (_chatModel == null || messages.isEmpty) {
        return {
          'insights': '감정 분석을 위한 API 키가 설정되지 않았거나 메시지가 없습니다.',
          'suggestions': [],
        };
      }

      final trends = await trackEmotionTrends(messages);

      if (trends.isEmpty) {
        return {
          'insights': '감정 분석을 위한 충분한 데이터가 없습니다.',
          'suggestions': [],
        };
      }

      bool hasImprovement = false;
      bool hasDecline = false;
      bool isVolatile = false;
      bool isStable = true;

      if (trends.length > 2) {
        final firstScore = trends.first['avgScore'] as double;
        final lastScore = trends.last['avgScore'] as double;

        hasImprovement = lastScore > firstScore && (lastScore - firstScore) >= 0.2;
        hasDecline = lastScore < firstScore && (firstScore - lastScore) >= 0.2;

        double maxDiff = 0.0;
        for (int i = 1; i < trends.length; i++) {
          final prevScore = trends[i - 1]['avgScore'] as double;
          final currScore = trends[i]['avgScore'] as double;
          final diff = (currScore - prevScore).abs();

          maxDiff = max(maxDiff, diff);
        }

        isVolatile = maxDiff >= 0.3;
        isStable = maxDiff <= 0.1;
      }

      final dominantEmotions = trends.map((e) => e['dominantEmotion'] as String).toList();
      final recentEmotion = dominantEmotions.last;

      final promptTemplate = """
사용자의 감정 추세 정보에 기반하여 심리적 통찰력과 개선 제안을 제공해주세요.

감정 추세 정보:
- 감정 개선 여부: ${hasImprovement ? '있음' : '없음'}
- 감정 악화 여부: ${hasDecline ? '있음' : '없음'}
- 감정 변동성: ${isVolatile ? '높음' : (isStable ? '안정적' : '보통')}
- 최근 주요 감정: $recentEmotion
- 전체 감정 추이: ${dominantEmotions.join(', ')}

다음을 포함한 응답을 JSON 형식으로 제공해주세요:
{
  "insights": "사용자의 감정 상태에 대한 통찰력을 2-3문장으로 설명",
  "suggestions": [
    "감정적 웰빙을 향상시키기 위한 제안 1",
    "감정적 웰빙을 향상시키기 위한 제안 2",
    "감정적 웰빙을 향상시키기 위한 제안 3"
  ]
}
""";

      const systemMsg = SystemChatMessage(content: "당신은 감정 분석과 심리 상담 전문가입니다. 사용자의 감정 패턴을 분석하고 통찰력 있는 조언을 제공해주세요.");
      final humanMsg = HumanChatMessage(content: promptTemplate);

      final result = await _chatModel!.call([systemMsg, humanMsg]);

      final jsonStr = result.content;
      final Map<String, dynamic> insightsData = _extractJsonFromString(jsonStr);

      return {
        'insights': insightsData['insights'] ?? '감정 분석을 처리할 수 없습니다.',
        'suggestions': insightsData['suggestions'] ?? [],
      };
    });
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
      AppLogger.warning('SentimentAnalysisService: Failed to extract JSON from string: $text');
      return {
        'insights': 'JSON 응답을 처리할 수 없습니다.',
        'suggestions': [],
      };
    } catch (e) {
      AppLogger.error('SentimentAnalysisService: Error extracting JSON: $e, text: $text');
      return {
        'insights': 'JSON 응답 처리 중 오류가 발생했습니다.',
        'suggestions': [],
      };
    }
  }
}