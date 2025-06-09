// 수정됨

import 'package:flutter/material.dart';
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiiun/services/conversation_service.dart';
import 'package:tiiun/models/conversation_model.dart';
import 'package:tiiun/services/sentiment_analysis_service.dart';
import 'package:tiiun/services/conversation_insights_service.dart';
import 'package:tiiun/services/mood_service.dart';
import 'package:tiiun/services/auth_service.dart';
import 'package:tiiun/models/mood_record_model.dart';
import 'package:tiiun/models/conversation_insight_model.dart';
import 'package:tiiun/models/sentiment_analysis_result_model.dart';
import 'package:tiiun/models/conversation_analysis_model.dart';
import 'package:tiiun/models/personalized_advice_model.dart';
import 'package:tiiun/models/conversation_summary_model.dart';
import 'package:tiiun/utils/error_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/pages/home_chatting/full_conversation_history_page.dart';
import 'package:tiiun/pages/home_chatting/activity_detail_page.dart';
import 'dart:ui';

class ModalAnalysisScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ModalAnalysisScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ModalAnalysisScreen> createState() => _ModalAnalysisScreenState();
}

class _ModalAnalysisScreenState extends ConsumerState<ModalAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 분석 상태
  bool _isLoadingAnalysis = true;
  bool _isLoadingInsights = true;

  // 감정 분석 데이터
  double _averageSentimentScore = 0.0;
  String _mainSentiment = '분석 중...';
  String _sentimentChange = '분석 중...';
  String _summary = '분석 중...';
  List<Map<String, dynamic>> _emotionTrends = [];

  // 인사이트 데이터
  String _insights = '분석 중...';
  List<String> _insightsTags = [];
  List<String> _suggestions = [];
  String _personalizedAdvice = '분석 중...';
  List<String> _exercises = [];
  List<String> _resources = [];

  // 사용자 데이터
  String _userName = '사용자';
  List<MoodRecord> _recentMoodRecords = [];

  // 실제 FireStore 데이터
  List<ConversationInsight> _conversationInsights = [];
  List<SentimentAnalysisResult> _sentimentResults = [];
  String _actualKeyTopics = '';
  String _actualOverallMood = '';
  String _actualSentimentSummary = '';

  // 새로운 고급 분석 데이터
  ConversationAnalysisModel? _comprehensiveAnalysis;
  PersonalizedAdviceModel? _personalizedAdviceData;
  ConversationSummaryModel? _detailedSummary;
  bool _isLoadingComprehensiveAnalysis = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _loadActualFireStoreData();
    _performComprehensiveAnalysis();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final authService = ref.read(authServiceProvider);
      final moodService = ref.read(moodServiceProvider);

      final userId = authService.getCurrentUserId();
      if (userId != null) {
        final userModel = await authService.getUserModel(userId);
        final moodRecords = await moodService.getMoodRecordsByPeriod(7);

        if (mounted) {
          setState(() {
            _userName = userModel.userName;
            _recentMoodRecords = moodRecords;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('사용자 정보를 불러오는 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 실제 FireStore 데이터 로드
  Future<void> _loadActualFireStoreData() async {
    try {
      final conversationInsightsService = ref.read(conversationInsightsServiceProvider);
      final sentimentAnalysisService = ref.read(sentimentAnalysisServiceProvider);

      // 대화 인사이트 가져오기
      final insights = await conversationInsightsService.getInsightsByConversation(widget.conversationId);

      // 감정 분석 결과 가져오기
      final sentiments = await sentimentAnalysisService.getSentimentsByConversation(widget.conversationId);

      if (mounted) {
        setState(() {
          _conversationInsights = insights;
          _sentimentResults = sentiments;

          if (insights.isNotEmpty) {
            final latestInsight = insights.first;
            _actualKeyTopics = latestInsight.keyTopics;
            _actualOverallMood = latestInsight.overallMood;
            _actualSentimentSummary = latestInsight.sentimentSummary;
          }
        });
      }
    } catch (e) {
      print('FireStore 데이터 로드 오류: $e');
    }
  }

  Future<void> _performComprehensiveAnalysis() async {
    await Future.wait([
      _performSentimentAnalysis(),
      _generateConversationInsights(),
      _performAdvancedAnalysis(), // 새로운 고급 분석 추가
    ]);
  }

  Future<void> _performSentimentAnalysis() async {
    setState(() {
      _isLoadingAnalysis = true;
    });

    try {
      final conversationService = ref.read(conversationServiceProvider);
      final sentimentAnalysisService = ref.read(sentimentAnalysisServiceProvider);

      final messages = await conversationService.getConversationMessages(widget.conversationId).first;

      if (messages.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoadingAnalysis = false;
            _mainSentiment = '대화 내용 없음';
            _sentimentChange = '해당 없음';
            _summary = '대화 내용이 없습니다.';
          });
        }
        return;
      }

      final conversationAnalysisResult = await sentimentAnalysisService.analyzeConversation(messages);
      final emotionTrends = await sentimentAnalysisService.trackEmotionTrends(messages);
      final emotionalInsightsResult = await sentimentAnalysisService.generateEmotionalInsights(messages);

      if (mounted) {
        setState(() {
          _isLoadingAnalysis = false;
          _averageSentimentScore = (conversationAnalysisResult['averageMoodScore'] as double? ?? 0.0) * 100;
          _mainSentiment = _getMoodLabel(conversationAnalysisResult['dominantEmotion'] as String? ?? 'neutral');
          _sentimentChange = (conversationAnalysisResult['moodChangeDetected'] as bool? ?? false)
              ? '감정 변화 감지됨'
              : '안정적';
          _summary = conversationAnalysisResult['summary'] as String? ?? '요약 없음';
          _insights = emotionalInsightsResult['insights'] as String? ?? '통찰 없음';
          _suggestions = List<String>.from(emotionalInsightsResult['suggestions'] ?? []);
          _emotionTrends = emotionTrends;
          _insightsTags = _extractKeywordsFromInsight(_insights);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAnalysis = false;
          _mainSentiment = '오류 발생';
          _sentimentChange = '분석 실패';
          _summary = '분석 중 오류가 발생했습니다: ${e.toString()}';
          _insights = '분석을 완료할 수 없습니다.';
        });
        _showErrorSnackBar('감정 분석 중 오류가 발생했습니다: ${e.toString()}');
      }
    }
  }

  /// 새로운 고급 분석 수행
  Future<void> _performAdvancedAnalysis() async {
    setState(() {
      _isLoadingComprehensiveAnalysis = true;
    });

    try {
      final conversationService = ref.read(conversationServiceProvider);
      final conversationInsightsService = ref.read(conversationInsightsServiceProvider);
      final authService = ref.read(authServiceProvider);

      final messages = await conversationService.getConversationMessages(widget.conversationId).first;
      final userId = authService.getCurrentUserId();

      if (messages.isNotEmpty && userId != null) {
        final userModel = await authService.getUserModel(userId);
        final userProfile = {
          'ageGroup': userModel.ageGroup ?? '알 수 없음',
          'gender': userModel.gender ?? '알 수 없음',
          'preferredActivities': userModel.preferredActivities ?? [],
          'hasPreviousCounseling': false, // 안전한 기본값
        };

        // 병렬로 고급 분석 수행
        final analysisResults = await Future.wait([
          // 1. 종합적 대화 분석
          conversationInsightsService.generateComprehensiveAnalysis(
            conversationId: widget.conversationId,
            userId: userId,
            messages: messages,
            userProfile: userProfile,
          ),
        ]);

        final comprehensiveAnalysis = analysisResults[0] as ConversationAnalysisModel;

        // 2. 근거 기반 맞춤형 조언 생성
        final personalizedAdviceData = await conversationInsightsService.generatePersonalizedAdviceWithEvidence(
          conversationId: widget.conversationId,
          userId: userId,
          messages: messages,
          analysis: comprehensiveAnalysis,
          userProfile: userProfile,
        );

        // 3. 상세한 대화 요약 생성
        final detailedSummary = await conversationInsightsService.generateDetailedSummary(
          conversationId: widget.conversationId,
          userId: userId,
          messages: messages,
          analysis: comprehensiveAnalysis,
        );

        if (mounted) {
          setState(() {
            _isLoadingComprehensiveAnalysis = false;
            _comprehensiveAnalysis = comprehensiveAnalysis;
            _personalizedAdviceData = personalizedAdviceData;
            _detailedSummary = detailedSummary;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingComprehensiveAnalysis = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingComprehensiveAnalysis = false;
        });
        _showErrorSnackBar('고급 분석 중 오류가 발생했습니다: ${e.toString()}');
      }
    }
  }

  Future<void> _generateConversationInsights() async {
    setState(() {
      _isLoadingInsights = true;
    });

    try {
      final conversationService = ref.read(conversationServiceProvider);
      final conversationInsightsService = ref.read(conversationInsightsServiceProvider);
      final sentimentAnalysisService = ref.read(sentimentAnalysisServiceProvider);
      final authService = ref.read(authServiceProvider);

      final messages = await conversationService.getConversationMessages(widget.conversationId).first;
      final userId = authService.getCurrentUserId();

      if (messages.isNotEmpty && userId != null) {
        final userModel = await authService.getUserModel(userId);
        final userProfile = {
          'ageGroup': userModel.ageGroup,
          'gender': userModel.gender,
          'preferredActivities': userModel.preferredActivities,
        };

        // 인사이트가 이미 존재하지 않으면 새로 생성
        if (_conversationInsights.isEmpty) {
          await conversationInsightsService.generateAndSaveConversationInsight(
            conversationId: widget.conversationId,
            userId: userId,
            messages: messages,
          );
          await _loadActualFireStoreData(); // 새로 생성된 데이터 로드
        }

        // 다중 소스에서 조언 생성 - 병렬 처리로 성능 향상
        final adviceGenerationTasks = await Future.wait([
          // 1. 기본 개인화된 조언
          conversationInsightsService.generatePersonalizedAdvice(messages, userProfile: userProfile),
          // 2. 감정 분석 기반 인사이트
          sentimentAnalysisService.generateEmotionalInsights(messages),
          // 3. 강화된 조언 생성
          _generateEnhancedAdvice(messages, userModel),
        ]);

        final personalizedAdviceResult = adviceGenerationTasks[0] as Map<String, dynamic>;
        final emotionalInsights = adviceGenerationTasks[1] as Map<String, dynamic>;
        final enhancedAdvice = adviceGenerationTasks[2] as String;

        // 기본 조언 생성 (대체 수단으로 사용)
        String fallbackAdvice = '';
        if (_personalizedAdviceData?.mainAdvice.coreMessage.isNotEmpty == true) {
          fallbackAdvice = _personalizedAdviceData!.mainAdvice.coreMessage;
        } else {
          fallbackAdvice = _combineAdviceFromSources(
            personalizedAdviceResult['advice'] as String? ?? '',
            emotionalInsights['insights'] as String? ?? '',
            enhancedAdvice,
            userModel,
          );
        }

        if (mounted) {
          setState(() {
            _isLoadingInsights = false;
            // 고급 분석 데이터가 있으면 사용, 없으면 기본 조언 사용
            _personalizedAdvice = _personalizedAdviceData?.mainAdvice.coreMessage.isNotEmpty == true
                ? _getEnhancedAdviceText()
                : fallbackAdvice;
            _exercises = _personalizedAdviceData?.actionableRecommendations
                .map((rec) => rec.title)
                .toList() ?? List<String>.from(personalizedAdviceResult['exercises'] ?? []);
            _resources = _personalizedAdviceData?.recommendedResources
                .map((res) => res.title)
                .toList() ?? List<String>.from(personalizedAdviceResult['resources'] ?? []);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingInsights = false;
            _personalizedAdvice = '대화 내용이 없어 조언을 생성할 수 없습니다.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingInsights = false;
          _personalizedAdvice = '조언 생성 중 오류가 발생했습니다: ${e.toString()}';
        });
        _showErrorSnackBar('인사이트 생성 중 오류가 발생했습니다: ${e.toString()}');
      }
    }
  }

  // 강화된 조언 생성 메서드
  Future<String> _generateEnhancedAdvice(List<dynamic> messages, dynamic userModel) async {
    try {
      // 대화 내용 분석
      final conversationContent = messages.map((msg) => msg.text ?? '').join(' ');
      final sentimentPattern = _analyzeSentimentPattern(conversationContent);
      final keyThemes = _extractKeyThemes(conversationContent);

      // 사용자 프로필 기반 맞춤 조언
      String advice = _generatePersonalizedAdviceByProfile(
          sentimentPattern,
          keyThemes,
          userModel.ageGroup ?? '성인',
          userModel.gender ?? 'unknown',
          _averageSentimentScore
      );

      return advice;
    } catch (e) {
      return '개인화된 조언을 생성하는 중 오류가 발생했습니다.';
    }
  }

  // 여러 소스의 조언을 통합하는 메서드
  String _combineAdviceFromSources(
      String basicAdvice,
      String emotionalInsights,
      String enhancedAdvice,
      dynamic userModel
      ) {
    // 빈 조언들 필터링
    List<String> validAdvices = [basicAdvice, emotionalInsights, enhancedAdvice]
        .where((advice) => advice.isNotEmpty &&
        advice != '조언을 생성할 수 없습니다.' &&
        advice != '통찰 없음' &&
        !advice.contains('오류가 발생했습니다'))
        .toList();

    if (validAdvices.isEmpty) {
      return _generateFallbackAdvice(userModel);
    }

    // 가장 구체적이고 도움이 되는 조언 선택
    String finalAdvice = validAdvices.reduce((current, next) =>
    current.length > next.length ? current : next);

    // 조언이 너무 짧으면 보완
    if (finalAdvice.length < 50) {
      finalAdvice += ' ${_generateAdditionalAdvice(_mainSentiment, userModel.ageGroup ?? '성인')}';
    }

    return finalAdvice;
  }

  // 감정 패턴 분석
  String _analyzeSentimentPattern(String content) {
    final lowerContent = content.toLowerCase();

    if (lowerContent.contains(RegExp(r'스트레스|힘들|어려|피곤|짜증|화나|우울'))) {
      return 'negative_stress';
    } else if (lowerContent.contains(RegExp(r'불안|걱정|두려|무서|긴장'))) {
      return 'anxiety';
    } else if (lowerContent.contains(RegExp(r'외로|혼자|고독|쓸쓸'))) {
      return 'loneliness';
    } else if (lowerContent.contains(RegExp(r'좋|행복|기쁘|즐거|만족|감사'))) {
      return 'positive';
    } else {
      return 'neutral';
    }
  }

  // 주요 테마 추출
  List<String> _extractKeyThemes(String content) {
    List<String> themes = [];
    final lowerContent = content.toLowerCase();

    Map<String, RegExp> themePatterns = {
      '관계': RegExp(r'친구|가족|연인|동료|사람|관계'),
      '일': RegExp(r'직장|회사|업무|일|상사|동료|프로젝트'),
      '건강': RegExp(r'몸|건강|아프|병|운동|식사'),
      '미래': RegExp(r'미래|계획|목표|꿈|진로|취업'),
      '자아': RegExp(r'자신|나|정체성|자존감|자신감'),
    };

    themePatterns.forEach((theme, pattern) {
      if (pattern.hasMatch(lowerContent)) {
        themes.add(theme);
      }
    });

    return themes.isEmpty ? ['일반'] : themes;
  }

  // 프로필 기반 개인화된 조언 생성
  String _generatePersonalizedAdviceByProfile(
      String sentimentPattern,
      List<String> themes,
      String ageGroup,
      String gender,
      double sentimentScore
      ) {
    String advice = '';

    // 연령대별 조언
    if (ageGroup.contains('청소년') || ageGroup.contains('10대')) {
      advice += '청소년기는 많은 변화와 고민이 있는 시기입니다. ';
    } else if (ageGroup.contains('20대')) {
      advice += '20대는 자신을 찾아가는 중요한 시기입니다. ';
    } else if (ageGroup.contains('30대')) {
      advice += '30대는 안정과 성장을 동시에 추구하는 시기입니다. ';
    } else {
      advice += '지금의 경험과 지혜를 바탕으로 ';
    }

    // 감정 패턴별 조언
    switch (sentimentPattern) {
      case 'negative_stress':
        advice += '스트레스를 받고 계시는 것 같습니다. 깊은 숨을 쉬고 잠시 휴식을 취해보세요. 스트레스의 원인을 파악하고 하나씩 해결해 나가는 것이 중요합니다.';
        break;
      case 'anxiety':
        advice += '불안한 마음이 드시는군요. 불안은 자연스러운 감정입니다. 현재에 집중하고, 통제할 수 있는 것에 에너지를 집중해보세요.';
        break;
      case 'loneliness':
        advice += '외로움을 느끼고 계시는군요. 혼자만의 시간도 소중하지만, 가까운 사람들과 소통하거나 새로운 사회적 활동을 시도해보시는 것도 좋겠습니다.';
        break;
      case 'positive':
        advice += '긍정적인 에너지가 느껴집니다! 이런 좋은 기분을 유지하시고, 주변 사람들과도 이 긍정적인 에너지를 나누어보세요.';
        break;
      default:
        advice += '현재 상황을 차분히 되돌아보고, 자신의 감정을 인정하는 것이 첫 번째 단계입니다.';
    }

    // 테마별 추가 조언
    if (themes.contains('관계')) {
      advice += ' 인간관계에서는 솔직하고 진심어린 소통이 가장 중요합니다.';
    }
    if (themes.contains('일')) {
      advice += ' 업무에서는 완벽을 추구하기보다 꾸준함과 성장에 집중해보세요.';
    }
    if (themes.contains('건강')) {
      advice += ' 몸과 마음의 건강은 모든 것의 기초입니다. 규칙적인 생활패턴을 유지해보세요.';
    }

    return advice;
  }

  // 폴백 조언 생성
  String _generateFallbackAdvice(dynamic userModel) {
    final ageGroup = userModel.ageGroup ?? '성인';

    if (_averageSentimentScore >= 70) {
      return '현재 긍정적인 마음가짐을 유지하고 계시는 것 같습니다. 이런 좋은 에너지를 계속 유지하시면서, 주변 사람들과도 긍정적인 영향을 나누어보세요. 감사한 마음을 표현하고, 작은 성취도 인정해주시는 것이 좋겠습니다.';
    } else if (_averageSentimentScore >= 40) {
      return '현재 다양한 감정을 경험하고 계시는군요. 이는 매우 자연스러운 일입니다. 자신의 감정을 인정하고 받아들이는 것부터 시작해보세요. 충분한 휴식과 자신만의 시간을 갖는 것도 중요합니다.';
    } else {
      return '지금은 힘든 시기를 보내고 계시는 것 같습니다. 이런 감정을 느끼는 것은 자연스러운 일이며, 혼자가 아니라는 것을 기억해주세요. 작은 것부터 천천히 시작하고, 필요하다면 주변의 도움을 받는 것도 좋은 방법입니다.';
    }
  }

  // 추가 조언 생성
  String _generateAdditionalAdvice(String sentiment, String ageGroup) {
    switch (sentiment) {
      case '기쁨':
        return '이런 긍정적인 감정을 오래 유지하기 위해 감사 일기를 써보시거나 좋은 순간들을 기록해보세요.';
      case '좋음':
        return '안정적인 마음 상태를 유지하면서 새로운 도전이나 취미 활동을 시작해보시는 것도 좋겠습니다.';
      case '중립':
        return '현재의 평온함 속에서 자신이 정말 원하는 것이 무엇인지 천천히 생각해보는 시간을 가져보세요.';
      case '나쁨':
        return '힘든 시기일수록 기본적인 자기 관리(충분한 수면, 규칙적인 식사, 가벼운 운동)가 중요합니다.';
      default:
        return '하루하루 작은 변화부터 시작해보세요.';
    }
  }

  List<String> _extractKeywordsFromInsight(String insightText) {
    if (insightText.isEmpty || insightText == '통찰 없음' || insightText.contains('분석을 완료할 수 없습니다.')) {
      return [];
    }
    final List<String> words = insightText.split(RegExp(r'[,\.\s]+')).where((s) => s.isNotEmpty).toList();
    final List<String> relevantWords = words.where((word) => word.length > 1).toList();
    return relevantWords.take(5).toList();
  }

  // 실제 키 토픽에서 태그 추출 (명사형 키워드로 변환)
  /// 고급 분석 데이터를 활용한 맞춤형 조언 텍스트 생성
  String _getEnhancedAdviceText() {
    if (_personalizedAdviceData == null) {
      return _personalizedAdvice;
    }

    final advice = _personalizedAdviceData!.mainAdvice;
    String enhancedText = advice.coreMessage;

    // 상세 설명이 있으면 추가
    if (advice.detailedExplanation.isNotEmpty) {
      enhancedText += '\n\n${advice.detailedExplanation}';
    }

    // 근거 정보 추가 (간략하게)
    final rationale = _personalizedAdviceData!.rationale;
    if (rationale.identifiedIssues.isNotEmpty) {
      enhancedText += '\n\n이 조언의 근거: ${rationale.identifiedIssues.take(2).join(', ')}';
    }

    return enhancedText;
  }

  /// 고급 분석 데이터를 활용한 키워드 태그 생성
  List<String> _getEnhancedInsightTags() {
    List<String> keywords = [];

    // 고급 분석 데이터에서 키워드 추출
    if (_comprehensiveAnalysis != null) {
      // 주요 주제들에서 키워드 추출
      keywords.addAll(_comprehensiveAnalysis!.topicAnalysis.mainTopics.take(3));

      // 감정 패턴에서 키워드 추출
      keywords.addAll(_comprehensiveAnalysis!.emotionPattern.dominantEmotions.take(2));

      // 성장 영역에서 키워드 추출
      keywords.addAll(_comprehensiveAnalysis!.growthIndicators.positiveChangeAreas.take(2));
    } else {
      // 기본 키워드 추출 로직 사용
      keywords = _getActualInsightTags();
    }

    // 중복 제거 및 최대 5개 반환
    return keywords.where((k) => k.isNotEmpty).toSet().take(5).toList();
  }

  List<String> _getActualInsightTags() {
    List<String> keywords = [];

    // 감정 상태에 따른 키워드 추가
    keywords.addAll(_getEmotionKeywords(_mainSentiment));

    // 실제 키 토픽에서 키워드 추출
    if (_actualKeyTopics.isNotEmpty) {
      keywords.addAll(_extractNounKeywords(_actualKeyTopics));
    }

    // 인사이트에서 키워드 추출
    if (_insights.isNotEmpty && _insights != '분석 중...' && _insights != '통찰 없음') {
      keywords.addAll(_extractNounKeywords(_insights));
    }

    // 중복 제거 및 최대 5개 반환
    return keywords.toSet().take(5).toList();
  }

  /// 고급 분석 데이터를 활용한 대화 요약 데이터 가져오기
  Map<String, String> _getEnhancedSummaryData() {
    if (_detailedSummary == null) {
      return {
        '주요 주제': _actualKeyTopics.isNotEmpty ? _actualKeyTopics : '대화에서 논의된 주요 주제들',
        '$_userName님의 감정': _actualOverallMood.isNotEmpty ? _getMoodLabel(_actualOverallMood) : _mainSentiment,
        '통찰': _insights,
        '조언': _personalizedAdvice,
      };
    }

    final summary = _detailedSummary!;
    return {
      '주요 주제': summary.keyDiscussions.isNotEmpty
          ? summary.keyDiscussions.map((d) => d.topic).join(', ')
          : _actualKeyTopics.isNotEmpty ? _actualKeyTopics : '일반적 대화',
      '${_userName}님의 감정': '${summary.emotionalJourney.startingState.primaryEmotion} → ${summary.emotionalJourney.endingState.primaryEmotion}',
      '통찰': summary.achievements.isNotEmpty
          ? summary.achievements.first.description
          : '대화를 통한 자기 인식 향상',
      '조언': summary.nextSteps.shortTermGoals.isNotEmpty
          ? summary.nextSteps.shortTermGoals.first
          : '지속적인 자기 관찰',
    };
  }

  // 감정 상태에 따른 관련 키워드 반환
  List<String> _getEmotionKeywords(String emotion) {
    switch (emotion) {
      case '기쁨':
        return ['긍정', '활력', '희망', '성취'];
      case '좋음':
        return ['만족', '안정', '평온', '균형'];
      case '중립':
        return ['일상', '평범', '무난', '보통'];
      case '나쁨':
        return ['스트레스', '피로', '걱정', '불안'];
      default:
        return ['감정', '마음', '상태'];
    }
  }

  // 텍스트에서 명사형 키워드 추출
  List<String> _extractNounKeywords(String text) {
    List<String> keywords = [];

    // 감정 관련 키워드 매핑
    Map<String, List<String>> emotionMapping = {
      '스트레스': ['스트레스', '압박'],
      '불안': ['불안', '걱정'],
      '우울': ['우울', '슬픔'],
      '행복': ['행복', '기쁨'],
      '분노': ['분노', '화'],
      '피로': ['피로', '지침'],
      '외로움': ['외로움', '고독'],
      '사랑': ['사랑', '애정'],
      '희망': ['희망', '기대'],
      '두려움': ['두려움', '공포'],
    };

    // 일반적인 주제 키워드 매핑
    Map<String, List<String>> topicMapping = {
      '일': ['업무', '직장', '일'],
      '관계': ['관계', '인간관계', '소통'],
      '가족': ['가족', '부모', '자녀'],
      '친구': ['친구', '우정'],
      '연애': ['연애', '사랑', '연인'],
      '건강': ['건강', '몸', '운동'],
      '돈': ['돈', '경제', '재정'],
      '미래': ['미래', '계획', '목표'],
      '과거': ['과거', '추억', '경험'],
      '학교': ['학교', '공부', '학습'],
      '취미': ['취미', '여가', '활동'],
      '여행': ['여행', '휴식'],
      '음식': ['음식', '식사'],
      '잠': ['수면', '잠', '휴식'],
    };

    // 텍스트에서 키워드 찾기
    String lowerText = text.toLowerCase();

    emotionMapping.forEach((key, values) {
      if (lowerText.contains(key)) {
        keywords.addAll(values);
      }
    });

    topicMapping.forEach((key, values) {
      if (lowerText.contains(key)) {
        keywords.addAll(values);
      }
    });

    // 기본 키워드가 없으면 텍스트에서 직접 추출
    if (keywords.isEmpty) {
      List<String> words = text.split(RegExp(r'[,\.\s]+')).where((s) => s.length > 1).toList();
      keywords.addAll(words.take(3));
    }

    return keywords;
  }

  String _getMoodLabel(String moodKey) {
    switch (moodKey) {
      case 'bad':
        return '나쁨';
      case 'neutral':
        return '중립';
      case 'good':
        return '좋음';
      case 'joy':
        return '기쁨';
      default:
        return '중립';
    }
  }

  String _getMoodIconPath(String moodLabel) {
    switch (moodLabel) {
      case '나쁨':
        return 'assets/icons/sentiment/negative.svg';
      case '중립':
        return 'assets/icons/sentiment/neutral.svg';
      case '좋음':
        return 'assets/icons/sentiment/positive.svg';
      case '기쁨':
        return 'assets/icons/sentiment/happy.svg';
      default:
        return 'assets/icons/sentiment/neutral.svg';
    }
  }

  Widget _buildTag(String text) {
    return Container(
      // width: 90, // 두 번째 코드와 동일하게 주석 처리
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 두 번째 코드와 동일한 패딩
      decoration: BoxDecoration(
        color: AppColors.grey100, // 두 번째 코드와 동일한 색상
        borderRadius: BorderRadius.circular(32), // 두 번째 코드와 동일한 borderRadius
      ),
      child: Text(
        text,
        style: AppTypography.c1.withColor(AppColors.grey700), // 두 번째 코드와 동일한 색상
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 고급 분석 데이터를 활용한 맞춤형 조언 섹션
  Widget _buildEnhancedAdviceSection() {
    final hasAdvancedData = _personalizedAdviceData != null;
    final advice = hasAdvancedData ? _personalizedAdviceData!.mainAdvice : null;
    final recommendations = hasAdvancedData ? _personalizedAdviceData!.actionableRecommendations : [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.grey50, // 두 번째 코드와 동일한 색상
          borderRadius: BorderRadius.circular(12) // 두 번째 코드와 동일한 borderRadius
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/sentiment/advice.svg', // 두 번째 코드와 동일한 아이콘
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Text(
                  '$_userName님을 위한 조언',
                  style: AppTypography.s2.withColor(AppColors.grey900) // 두 번째 코드와 동일한 스타일
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hasAdvancedData ? _getEnhancedAdviceText() : _personalizedAdvice,
            style: TextStyle( // 두 번째 코드와 동일한 TextStyle
              fontFamily: AppTypography.fontFamily,
              fontSize: 14,
              color: AppColors.grey900,
              fontWeight: FontWeight.w400,
              height: 20/14,
            ),
          ),
        ],
      ),
    );
  }

  /// 고급 분석 데이터를 활용한 요약 아이템들 생성
  List<Widget> _buildEnhancedSummaryItems() {
    final summaryData = _getEnhancedSummaryData();
    final items = <Widget>[];

    int index = 0;
    for (final entry in summaryData.entries) {
      if (index > 0) {
        items.add(Container( // 두 번째 코드와 동일한 구분선 구조
          margin: EdgeInsets.symmetric(vertical: 12),
          color: AppColors.grey200,
          height: 0.5,
        ));
      }

      items.add(_buildSummaryItem(entry.key, entry.value));
      index++;
    }

    return items;
  }

  // 난이도에 따른 색상 반환
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return AppColors.main600;
    }
  }

  // 난이도 레이블
  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return '쉽음';
      case 'medium':
        return '보통';
      case 'hard':
        return '어려움';
      default:
        return '보통';
    }
  }

  // 카테고리에 따른 아이콘
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'mindfulness':
        return Icons.self_improvement;
      case 'exercise':
        return Icons.fitness_center;
      case 'social':
        return Icons.people;
      case 'creative':
        return Icons.palette;
      case 'breathing':
        return Icons.air;
      case 'meditation':
        return Icons.spa;
      default:
        return Icons.lightbulb;
    }
  }

  Widget _buildSummaryItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.s2.withColor(AppColors.grey900),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: AppTypography.b3.withColor(AppColors.grey600).copyWith(height: 1.4),
        ),
      ],
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.point900,
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.grey600,
      ),
    );
  }

  void _showActivityDetailModal({
    required String imagePath,
    required String imageTag,
    required String title,
    required String shortDescription,
    required String longDescription,
    required String buttonText,
    required VoidCallback onStartActivity,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ActivityDetailPage(
          imagePath: imagePath,
          imageTag: imageTag,
          title: title,
          shortDescription: shortDescription,
          longDescription: longDescription,
          buttonText: buttonText,
          onStartActivity: onStartActivity,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 56, // 두 번째 코드와 동일한 높이
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16), // 두 번째 코드와 동일한 radius
          topRight: Radius.circular(16), // 두 번째 코드와 동일한 radius
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24), // 두 번째 코드와 동일한 패딩
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        '대화 기록',
                        style: AppTypography.h5.withColor(AppColors.grey900), // 두 번째 코드와 동일한 스타일
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.grey800, // 두 번째 코드와 동일한 색상
                unselectedLabelColor: AppColors.grey500,
                indicatorColor: Colors.transparent, // 두 번째 코드와 동일하게 투명
                dividerColor: Colors.transparent, // 두 번째 코드와 동일하게 투명
                indicator: const UnderlineTabIndicator( // 두 번째 코드와 동일한 indicator
                  borderSide: BorderSide(width: 3.0, color: AppColors.main700),
                  insets: EdgeInsets.symmetric(horizontal: 88), // indicator 길이 조절
                ),
                labelStyle: AppTypography.s2,
                unselectedLabelStyle: AppTypography.s2,
                tabs: const [
                  Tab(text: '감정 분석'),
                  Tab(text: '대화 인사이트'),
                ],
              )
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSentimentAnalysisTab(),
                _buildInsightsAndRecommendationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentAnalysisTab() {
    if (_isLoadingAnalysis) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.main600),
            ),
            const SizedBox(height: 20),
            Text(
              '대화 내용을 분석 중입니다...',
              style: AppTypography.b2.withColor(AppColors.grey600),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // 두 번째 코드와 동일한 패딩
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 감정 정보 컨테이너
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 16), // 두 번째 코드와 동일한 마진
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12), // 두 번째 코드와 동일한 패딩
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    '평균 감정 점수',
                    '${_averageSentimentScore.toStringAsFixed(1)}', // 두 번째 코드와 동일하게 '%' 제거
                    showProgress: true,
                  ),
                  const SizedBox(height: 12), // 두 번째 코드와 동일한 간격
                  _buildInfoRow(
                    '주요 감정',
                    _mainSentiment,
                    iconPath: _getMoodIconPath(_mainSentiment),
                  ),
                  const SizedBox(height: 12), // 두 번째 코드와 동일한 간격
                  _buildInfoRow(
                    '감정 변화',
                    _sentimentChange,
                  ),
                ],
              ),
            ),

            // 추천 활동 섹션
            Text(
              '$_userName님을 위한 추천 활동',
              style: AppTypography.s1.withColor(AppColors.grey900),
            ),
            const SizedBox(height: 8), // 두 번째 코드와 동일한 간격

            Container(
              width: double.infinity,
              child: Column(
                children: [
                  _buildActivityCard(
                    'assets/images/dialog/meditation.png',
                    '명상을 통한 스트레스 해소',
                    '마음을 집중하고 깊은 호흡을 통해 스트레스를 해소하는 명상을 시도해보세요!',
                    onTap: () {
                      _showActivityDetailModal(
                        imagePath: 'assets/images/dialog/meditation.png',
                        imageTag: '명상',
                        title: '명상을 통한 스트레스 해소',
                        shortDescription: '마음을 집중하고 깊은 호흡을 통해 스트레스를 해소하는 명상을 시도해보세요!',
                        longDescription: '외부 환경에서 오는 스트레스를 해소하는 데 도움이 되고, 마음의 안정과 집중력을 높여 일상에서의 감정 조절 능력을 향상시키는 데 효과적이에요.',
                        buttonText: '활동 시작하기',
                        onStartActivity: () {
                          Navigator.pop(context);
                          _showSnackBar('명상 활동을 시작합니다!');
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8), // 두 번째 코드와 동일한 간격
                  _buildActivityCard(
                    'assets/images/dialog/walking.png',
                    '자연 속 산책', // 두 번째 코드와 동일한 제목
                    '자연 속으로 나가 신선한 공기를 마시며 걷는 것은 마음과 몸에 상쾌한 영향을 주어요.', // 두 번째 코드와 동일한 설명
                    onTap: () {
                      _showActivityDetailModal(
                        imagePath: 'assets/images/dialog/walking.png',
                        imageTag: '산책',
                        title: '자연 속 산책',
                        shortDescription: '자연 속으로 나가 신선한 공기를 마시며 걷는 것은 마음과 몸에 상쾌한 영향을 주어요.',
                        longDescription: '자연 속에서 걷는 것은 기분 전환에 좋고, 신체 활동은 스트레스 호르몬을 줄이는 데 도움이 됩니다. 규칙적인 산책은 전반적인 건강 증진에도 기여합니다.',
                        buttonText: '활동 시작하기',
                        onStartActivity: () {
                          Navigator.pop(context);
                          _showSnackBar('산책 활동을 시작합니다!');
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8), // 두 번째 코드와 동일한 간격
                  _buildActivityCard(
                    'assets/images/dialog/sitting.png',
                    '창 밖의 풍경 감상', // 두 번째 코드와 동일한 제목
                    '창가에 앉아 밖의 풍경을 바라보며 마음을 편하게 해보세요.', // 두 번째 코드와 동일한 설명
                    onTap: () {
                      _showActivityDetailModal(
                        imagePath: 'assets/images/dialog/sitting.png',
                        imageTag: '휴식',
                        title: 'assets/images/dialog/sitting.png', // 두 번째 코드와 동일
                        shortDescription: '창가에 앉아 밖의 풍경을 바라보며 마음을 편하게 해보세요.',
                        longDescription: '아름다운 풍경을 보는 것은 마음을 평온하게 하고 스트레스를 줄이는 데 도움을 줍니다. 잠시 일상에서 벗어나 자연의 아름다움에 집중하며 긍정적인 에너지를 충전해보세요.',
                        buttonText: '활동 시작하기',
                        onStartActivity: () {
                          Navigator.pop(context);
                          _showSnackBar('풍경 감상 활동을 시작합니다!');
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12), // 두 번째 코드와 동일한 간격
                  _buildActivityCard(
                    'assets/images/dialog/music.png',
                    '평화로운 음악 감상', // 두 번째 코드와 동일한 제목
                    '음악을 들으며 마음을 안정시키고 편안한 상태로 이어지는 시간을 즐겨 보아요.', // 두 번째 코드와 동일한 설명
                    onTap: () {
                      _showActivityDetailModal(
                        imagePath: 'assets/images/dialog/music.png',
                        imageTag: '풍경 감상', // 두 번째 코드와 동일
                        title: '아름다운 풍경 감상', // 두 번째 코드와 동일
                        shortDescription: '음악을 들으며 마음을 안정시키고 편안한 상태로 이어지는 시간을 즐겨 보아요.',
                        longDescription: '음악은 정서적 안정과 스트레스 감소에 효과적인 도구입니다. 차분한 음악은 긴장을 완화하고, 활기찬 음악은 기분을 북돋아 줄 수 있습니다. 나만의 플레이리스트를 만들어보세요.',
                        buttonText: '활동 시작하기',
                        onStartActivity: () {
                          Navigator.pop(context);
                          _showSnackBar('음악 감상 활동을 시작합니다!');
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 42), // 두 번째 코드와 동일한 간격
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsAndRecommendationsTab() {
    if (_isLoadingInsights) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.main600),
            ),
            const SizedBox(height: 20),
            Text(
              '인사이트를 생성 중입니다...',
              style: AppTypography.b2.withColor(AppColors.grey600),
            ),
            if (_isLoadingComprehensiveAnalysis) ...
            [
              const SizedBox(height: 10),
              Text(
                '고급 분석 수행 중...',
                style: AppTypography.c1.withColor(AppColors.grey500),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 실제 데이터에서 가져온 태그들 또는 기본 태그들
                Center(
                  child: Wrap(
                    spacing: 10, // 두 번째 코드와 동일한 spacing
                    runSpacing: 10, // 두 번째 코드와 동일한 runSpacing
                    alignment: WrapAlignment.center,
                    children: _getActualInsightTags().map((tag) => _buildTag(tag)).toList(),
                  ),
                ),
                const SizedBox(height: 16), // 두 번째 코드와 동일한 간격

                // 맞춤형 조언 섹션 - 고급 분석 데이터 활용
                _buildEnhancedAdviceSection(),
                const SizedBox(height: 16), // 두 번째 코드와 동일한 간격

                // 대화 요약 - 고급 분석 데이터 사용
                Text(
                  '대화 요약',
                  style: AppTypography.s2.withColor(AppColors.grey900), // 두 번째 코드와 동일한 스타일
                ),
                const SizedBox(height: 12), // 두 번째 코드와 동일한 간격

                ..._buildEnhancedSummaryItems(),
                const SizedBox(height: 90), // 두 번째 코드와 동일한 간격
              ],
            ),
          ),
        ),

        // 하단 고정 버튼
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20), // 두 번째 코드와 동일한 마진
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FullConversationHistoryPage(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.main700, // 두 번째 코드와 동일한 색상
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '전체 대화 리포트 보러가기', // 두 번째 코드와 동일한 텍스트
                  style: AppTypography.s2.withColor(Colors.white), // 두 번째 코드와 동일한 스타일
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {String? iconPath, bool showProgress = false}) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.b1.withColor(AppColors.grey900), // 두 번째 코드와 동일한 스타일
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showProgress) ...[
                Text(
                  value,
                  style: AppTypography.c2.withColor(AppColors.main700), // 두 번째 코드와 동일한 색상
                ),
                const SizedBox(width: 8), // 두 번째 코드와 동일한 간격
                SizedBox(
                  width: 134, // 두 번째 코드와 동일한 width
                  child: LinearProgressIndicator(
                    value: _averageSentimentScore / 100,
                    backgroundColor: AppColors.grey200,
                    color: AppColors.main700, // 두 번째 코드와 동일한 색상
                    minHeight: 12, // 두 번째 코드와 동일한 높이
                    borderRadius: BorderRadius.circular(16), // 두 번째 코드와 동일한 radius
                  ),
                ),
              ] else ...[
                if (iconPath != null) ...[
                  SvgPicture.asset(
                    iconPath,
                    width: 24, // 두 번째 코드와 동일한 크기
                    height: 24, // 두 번째 코드와 동일한 크기
                  ),
                  const SizedBox(width: 10), // 두 번째 코드와 동일한 간격
                ],
                Text(
                  value,
                  style: AppTypography.b2.withColor(AppColors.grey400), // 두 번째 코드와 동일한 색상
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(String imagePath, String title, String shortDescription, {String? description, VoidCallback? onTap}) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16), // 두 번째 코드와 동일한 패딩
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center, // 두 번째 코드와 동일한 정렬
              children: [
                Container(
                  width: 60, // 두 번째 코드와 동일한 크기
                  height: 60, // 두 번째 코드와 동일한 크기
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.grey50,
                      width: 1,
                    ),
                    boxShadow: [ // 두 번째 코드와 동일한 boxShadow
                      BoxShadow(
                        color: Color(0xFF131927).withOpacity(0.08),
                        blurRadius: 8,
                        spreadRadius: -4,
                        offset: Offset(2, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8), // 패딩을 줄여서 이미지를 더 크게
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(width: 16), // 두 번째 코드와 동일한 간격
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.b4.withColor(AppColors.grey900), // 두 번째 코드와 동일한 스타일
                      ),
                      const SizedBox(height: 2), // 두 번째 코드와 동일한 간격
                      Text(
                        shortDescription,
                        style: AppTypography.c1.withColor(AppColors.grey700), // 두 번째 코드와 동일한 스타일
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16), // 두 번째 코드와 동일한 간격
                SvgPicture.asset( // 두 번째 코드와 동일한 아이콘 추가
                  'assets/icons/functions/more.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                      AppColors.grey700,
                      BlendMode.srcIn
                  ),
                )
              ],
            ),
            if (description != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                child: Text(
                  description,
                  style: AppTypography.c1.withColor(AppColors.grey700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}